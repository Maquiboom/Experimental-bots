$project = Join-Path `
    (Get-Location).Path `
    "RedNeuronal-FNAF1"


Write-Host ""

Write-Host "====================================" -ForegroundColor Cyan
Write-Host " RedNeuronal FNAF 1 Installer " -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

Write-Host ""



if(Test-Path $project){

    Write-Host "Proyecto existente encontrado." -ForegroundColor Yellow


    $oldModel = Join-Path `
        $project `
        "models\checkpoint.pt"



    if(Test-Path $oldModel){


        $backup = Join-Path `
            (Get-Location).Path `
            "FNAF_checkpoint_backup.pt"



        Copy-Item `
            $oldModel `
            $backup `
            -Force



        Write-Host "Checkpoint guardado:" -ForegroundColor Green

        Write-Host $backup

    }



    Remove-Item `
        $project `
        -Recurse `
        -Force



    Write-Host "Proyecto anterior eliminado." -ForegroundColor Green

}





New-Item `
    -ItemType Directory `
    -Path $project `
    -Force | Out-Null





$folders=@(

    "ai",

    "environment",

    "ui",

    "config",

    "models",

    "logs",

    "data",

    "data\vision_memory"

)





foreach($folder in $folders){


    New-Item `

        -ItemType Directory `

        -Path (Join-Path $project $folder) `

        -Force | Out-Null

}





Write-Host ""

Write-Host "Estructura creada." -ForegroundColor Green





$requirements=@'
torch
torchvision
opencv-python
numpy
pyautogui
pillow
pyqt6
pyqtgraph
matplotlib
'@





Set-Content `

    -Path (Join-Path $project "requirements.txt") `

    -Value $requirements `

    -Encoding UTF8





$initFiles=@(

    "ai\__init__.py",

    "environment\__init__.py",

    "ui\__init__.py",

    "config\__init__.py"

)





foreach($file in $initFiles){


    New-Item `

        -ItemType File `

        -Path (Join-Path $project $file) `

        -Force | Out-Null

}





$config=@'
import os



BASE_DIR=os.path.dirname(

    os.path.dirname(

        os.path.abspath(__file__)

    )

)



MODEL_PATH=os.path.join(

    BASE_DIR,

    "models",

    "checkpoint.pt"

)



SCREENSHOT_PATH=os.path.join(

    BASE_DIR,

    "data",

    "vision_memory"

)



STATE_SIZE=56


ACTION_SIZE=14



LEARNING_RATE=0.0005


GAMMA=0.95



MEMORY_SIZE=50000


BATCH_SIZE=64



EPSILON_START=1.0


EPSILON_END=0.05


EPSILON_DECAY=0.995



TARGET_UPDATE=500



IMAGE_SIZE=224

'@





Set-Content `

    -Path (Join-Path $project "config\config.py") `

    -Value $config `

    -Encoding UTF8





Write-Host ""

Write-Host "Creando entorno virtual..." -ForegroundColor Cyan





$venv = Join-Path `
    $project `
    "venv"





python -m venv $venv





$python = Join-Path `
    $venv `
    "Scripts\python.exe"





if(!(Test-Path $python)){


    Write-Host "No se pudo crear Python virtual." -ForegroundColor Red

    exit

}





Write-Host ""

Write-Host "Instalando dependencias..." -ForegroundColor Cyan





& $python -m pip install --upgrade pip





& $python -m pip install `

    -r (Join-Path $project "requirements.txt")





Write-Host ""

Write-Host "Base del proyecto creada." -ForegroundColor Green

$model=@'
import torch

import torch.nn as nn


from config.config import STATE_SIZE,ACTION_SIZE





class FNAFNetwork(nn.Module):


    def __init__(self):

        super().__init__()


        self.layers=nn.Sequential(

            nn.Linear(

                STATE_SIZE,

                256

            ),

            nn.ReLU(),



            nn.Linear(

                256,

                256

            ),

            nn.ReLU(),



            nn.Linear(

                256,

                128

            ),

            nn.ReLU(),



            nn.Linear(

                128,

                ACTION_SIZE

            )

        )





    def forward(self,x):

        return self.layers(x)

'@



Set-Content `
    -Path (Join-Path $project "ai\model.py") `
    -Value $model `
    -Encoding UTF8







$visionNet=@'
import torch

import torch.nn as nn


from config.config import IMAGE_SIZE





class VisionNetwork(nn.Module):


    def __init__(self):

        super().__init__()



        self.features=nn.Sequential(

            nn.Conv2d(

                3,

                16,

                5,

                stride=2

            ),

            nn.ReLU(),



            nn.Conv2d(

                16,

                32,

                5,

                stride=2

            ),

            nn.ReLU(),



            nn.Conv2d(

                32,

                64,

                5,

                stride=2

            ),

            nn.ReLU()

        )




        self.pool=nn.AdaptiveAvgPool2d(

            (4,4)

        )




        self.output=nn.Sequential(

            nn.Flatten(),



            nn.Linear(

                64*4*4,

                128

            ),



            nn.ReLU(),



            nn.Linear(

                128,

                32

            )

        )





    def forward(self,x):


        x=self.features(x)


        x=self.pool(x)


        return self.output(x)

'@



Set-Content `
    -Path (Join-Path $project "ai\vision_net.py") `
    -Value $visionNet `
    -Encoding UTF8







$memory=@'
import random

from collections import deque





class ReplayMemory:



    def __init__(self,size):


        self.memory=deque(

            maxlen=size

        )





    def add(self,item):


        self.memory.append(

            item

        )





    def sample(self,size):


        return random.sample(

            self.memory,

            size

        )





    def __len__(self):


        return len(

            self.memory

        )

'@



Set-Content `
    -Path (Join-Path $project "ai\replay.py") `
    -Value $memory `
    -Encoding UTF8







$agent=@'
import os

import random


import torch

import torch.nn as nn

import torch.optim as optim



from ai.model import FNAFNetwork

from ai.replay import ReplayMemory



from config.config import *





class Agent:



    def __init__(self):


        self.device=torch.device(

            "cuda"

            if torch.cuda.is_available()

            else

            "cpu"

        )



        self.model=FNAFNetwork().to(

            self.device

        )



        self.target=FNAFNetwork().to(

            self.device

        )



        self.optimizer=optim.Adam(

            self.model.parameters(),

            lr=LEARNING_RATE

        )



        self.loss_function=nn.MSELoss()



        self.memory=ReplayMemory(

            MEMORY_SIZE

        )



        self.epsilon=EPSILON_START


        self.steps=0



        self.load()






    def act(self,state,explore=True):


        if explore and random.random()<self.epsilon:


            return random.randrange(

                ACTION_SIZE

            )



        state=torch.tensor(

            state,

            dtype=torch.float32,

            device=self.device

        )



        with torch.no_grad():


            output=self.model(

                state

            )



        return torch.argmax(

            output

        ).item()






    def remember(

        self,

        state,

        action,

        reward,

        next_state,

        done

    ):


        self.memory.add(

            (

                state,

                action,

                reward,

                next_state,

                done

            )

        )








    def learn(self):


        if len(self.memory)<BATCH_SIZE:

            return



        batch=self.memory.sample(

            BATCH_SIZE

        )



        states=[]

        actions=[]

        rewards=[]

        next_states=[]

        dones=[]




        for item in batch:


            s,a,r,n,d=item


            states.append(s)

            actions.append(a)

            rewards.append(r)

            next_states.append(n)

            dones.append(d)





        states=torch.tensor(

            states,

            dtype=torch.float32,

            device=self.device

        )



        next_states=torch.tensor(

            next_states,

            dtype=torch.float32,

            device=self.device

        )



        actions=torch.tensor(

            actions,

            dtype=torch.long,

            device=self.device

        )



        rewards=torch.tensor(

            rewards,

            dtype=torch.float32,

            device=self.device

        )



        dones=torch.tensor(

            dones,

            dtype=torch.float32,

            device=self.device

        )






        current=self.model(

            states

        ).gather(

            1,

            actions.unsqueeze(1)

        ).squeeze()





        with torch.no_grad():


            future=self.target(

                next_states

            ).max(

                1

            )[0]



            expected=rewards+(

                GAMMA*

                future*

                (1-dones)

            )





        loss=self.loss_function(

            current,

            expected

        )





        self.optimizer.zero_grad()


        loss.backward()


        self.optimizer.step()



        self.steps+=1



        self.epsilon=max(

            EPSILON_END,

            self.epsilon*EPSILON_DECAY

        )



        if self.steps % TARGET_UPDATE==0:


            self.target.load_state_dict(

                self.model.state_dict()

            )








    def save(self):


        torch.save(

            {

            "model":self.model.state_dict(),

            "target":self.target.state_dict(),

            "optimizer":self.optimizer.state_dict(),

            "epsilon":self.epsilon,

            "steps":self.steps

            },

            MODEL_PATH

        )






    def load(self):


        if not os.path.exists(

            MODEL_PATH

        ):

            self.target.load_state_dict(

                self.model.state_dict()

            )

            return





        checkpoint=torch.load(

            MODEL_PATH,

            map_location=self.device

        )



        self.model.load_state_dict(

            checkpoint["model"]

        )



        self.target.load_state_dict(

            checkpoint["target"]

        )



        self.optimizer.load_state_dict(

            checkpoint["optimizer"]

        )



        self.epsilon=checkpoint.get(

            "epsilon",

            EPSILON_START

        )



        self.steps=checkpoint.get(

            "steps",

            0

        )


'@



Set-Content `
    -Path (Join-Path $project "ai\agent.py") `
    -Value $agent `
    -Encoding UTF8





Write-Host ""

Write-Host "IA creada correctamente." -ForegroundColor Green

$actions=@'
ACTIONS=[

    "open_monitor",

    "close_monitor",

    "camera_left",

    "camera_right",

    "camera_cycle",

    "left_light",

    "left_door",

    "right_light",

    "right_door",

    "wait",

    "action_10",

    "action_11",

    "action_12",

    "action_13"

]





def get_action(index):


    if index < 0:

        return None


    if index >= len(ACTIONS):

        return None


    return ACTIONS[index]

'@



Set-Content `
    -Path (Join-Path $project "environment\actions.py") `
    -Value $actions `
    -Encoding UTF8







$vision=@'
import cv2

import numpy as np

import pyautogui

import os

import time



from config.config import IMAGE_SIZE,SCREENSHOT_PATH





class Vision:



    def __init__(self):


        self.size=(

            IMAGE_SIZE,

            IMAGE_SIZE

        )







    def capture(self):


        screenshot=pyautogui.screenshot()



        frame=np.array(

            screenshot

        )



        frame=cv2.cvtColor(

            frame,

            cv2.COLOR_RGB2BGR

        )



        return frame






    def process(self,frame):


        frame=cv2.resize(

            frame,

            self.size

        )



        frame=cv2.cvtColor(

            frame,

            cv2.COLOR_BGR2RGB

        )



        frame=frame.astype(

            np.float32

        )/255.0



        frame=np.transpose(

            frame,

            (

                2,

                0,

                1

            )

        )



        return frame






    def save(self,frame):


        os.makedirs(

            SCREENSHOT_PATH,

            exist_ok=True

        )



        filename=os.path.join(

            SCREENSHOT_PATH,

            str(

                int(time.time()*1000)

            )+".png"

        )



        cv2.imwrite(

            filename,

            frame

        )

'@



Set-Content `
    -Path (Join-Path $project "environment\vision.py") `
    -Value $vision `
    -Encoding UTF8







$controller=@'
import json

import os

import time

import pyautogui





class Controller:



    def __init__(self):


        self.path="config/calibration.json"


        self.points={}


        self.load()






    def load(self):


        if os.path.exists(

            self.path

        ):


            with open(

                self.path,

                "r"

            ) as file:


                self.points=json.load(

                    file

                )







    def click(self,name):


        if name not in self.points:


            print(

                "Sin calibrar:",

                name

            )


            return





        position=self.points[name]



        pyautogui.click(

            position["x"],

            position["y"]

        )



        time.sleep(

            0.15

        )








    def execute(self,action):


        if action:


            self.click(

                action

            )

'@



Set-Content `
    -Path (Join-Path $project "environment\controller.py") `
    -Value $controller `
    -Encoding UTF8







$calibration=@'
import tkinter as tk

import json

import os





BUTTONS=[

"open_monitor",

"close_monitor",

"camera_left",

"camera_right",

"camera_cycle",

"left_light",

"left_door",

"right_light",

"right_door"

]







class Calibration:



    def __init__(self):


        self.data={}







    def select(self,name):


        print(

            "Pulsa sobre:",

            name

        )



        root=tk.Tk()


        root.attributes(

            "-fullscreen",

            True

        )



        result=[]





        def click(event):


            result.append(

                {

                "x":event.x,

                "y":event.y

                }

            )


            root.destroy()





        root.bind(

            "<Button-1>",

            click

        )


        root.mainloop()



        if result:


            self.data[name]=result[0]








    def run(self):


        for button in BUTTONS:


            self.select(

                button

            )



        os.makedirs(

            "config",

            exist_ok=True

        )



        with open(

            "config/calibration.json",

            "w"

        ) as file:


            json.dump(

                self.data,

                file,

                indent=4

            )

'@



Set-Content `
    -Path (Join-Path $project "environment\calibration.py") `
    -Value $calibration `
    -Encoding UTF8







$state=@'
import numpy as np





class GameState:



    def build(self,features):


        state=np.zeros(

            56,

            dtype=np.float32

        )


        size=min(

            len(features),

            56

        )


        state[:size]=features[:size]


        return state

'@



Set-Content `
    -Path (Join-Path $project "environment\state.py") `
    -Value $state `
    -Encoding UTF8







$environment=@'
import time

import torch



from environment.vision import Vision

from environment.controller import Controller

from environment.actions import get_action

from environment.state import GameState



from ai.vision_net import VisionNetwork





class FNAFEnvironment:



    def __init__(self):


        self.vision=Vision()


        self.controller=Controller()


        self.state=GameState()



        self.network=VisionNetwork()


        self.network.eval()







    def reset(self):


        frame=self.vision.capture()



        return self.make_state(

            frame

        )








    def make_state(self,frame):


        image=self.vision.process(

            frame

        )



        tensor=torch.tensor(

            image

        ).unsqueeze(0)





        with torch.no_grad():


            output=self.network(

                tensor

            )



        return self.state.build(

            output.numpy()[0]

        )








    def step(self,action):


        command=get_action(

            action

        )


        self.controller.execute(

            command

        )



        time.sleep(

            0.15

        )



        frame=self.vision.capture()



        next_state=self.make_state(

            frame

        )



        reward=0.1


        done=False



        return (

            next_state,

            reward,

            done

        )

'@



Set-Content `
    -Path (Join-Path $project "environment\env.py") `
    -Value $environment `
    -Encoding UTF8





Write-Host ""

Write-Host "Entorno FNAF creado correctamente." -ForegroundColor Green

$graphs=@'
from PyQt6.QtWidgets import QWidget,QVBoxLayout

import pyqtgraph as pg





class Graphs(QWidget):


    def __init__(self):

        super().__init__()


        layout=QVBoxLayout()


        self.graph=pg.PlotWidget()


        self.graph.setTitle(

            "Training Reward"

        )


        layout.addWidget(

            self.graph

        )


        self.values=[]


        self.setLayout(

            layout

        )





    def update_value(self,value):


        self.values.append(

            value

        )


        self.graph.clear()


        self.graph.plot(

            self.values,

            pen=pg.mkPen(

                "green",

                width=3

            )

        )

'@



Set-Content `
    -Path (Join-Path $project "ui\graphs.py") `
    -Value $graphs `
    -Encoding UTF8







$network=@'
import math

from PyQt6.QtWidgets import QWidget

from PyQt6.QtGui import QPainter,QColor,QPen

from PyQt6.QtCore import QTimer





class NetworkView(QWidget):


    def __init__(self):

        super().__init__()


        self.layers=[56,256,256,128,14]


        self.time=0



        self.resize(

            900,

            450

        )



        self.timer=QTimer()


        self.timer.timeout.connect(

            self.animate

        )


        self.timer.start(

            40

        )






    def animate(self):


        self.time+=0.15


        self.update()






    def paintEvent(self,event):


        painter=QPainter(

            self

        )


        painter.setRenderHint(

            QPainter.RenderHint.Antialiasing

        )



        spacing=self.width()/(len(self.layers)+1)



        nodes=[]



        for layer,size in enumerate(self.layers):


            layer_nodes=[]


            amount=min(

                size,

                18

            )


            for index in range(amount):


                x=(layer+1)*spacing


                y=40+(index*20)



                layer_nodes.append(

                    (

                    x,

                    y

                    )

                )



            nodes.append(

                layer_nodes

            )





        painter.setPen(

            QPen(

                QColor(

                    90,

                    90,

                    90

                ),

                1

            )

        )



        for current,next_layer in zip(

            nodes[:-1],

            nodes[1:]

        ):


            for x1,y1 in current:


                for x2,y2 in next_layer:


                    painter.drawLine(

                        int(x1),

                        int(y1),

                        int(x2),

                        int(y2)

                    )






        for layer in nodes:


            for x,y in layer:


                pulse=(

                    math.sin(

                        self.time+x

                    )

                    +

                    1

                )*80




                painter.setBrush(

                    QColor(

                        40,

                        120+int(pulse),

                        255

                    )

                )



                painter.drawEllipse(

                    int(x-6),

                    int(y-6),

                    12,

                    12

                )

'@



Set-Content `
    -Path (Join-Path $project "ui\network_view.py") `
    -Value $network `
    -Encoding UTF8







$dashboard=@'
import sys


from PyQt6.QtWidgets import QApplication,QWidget,QVBoxLayout,QLabel



from ui.network_view import NetworkView

from ui.graphs import Graphs





class Dashboard(QWidget):


    def __init__(self):

        super().__init__()



        self.setWindowTitle(

            "RedNeuronal FNAF 1"

        )


        self.resize(

            1100,

            750

        )



        layout=QVBoxLayout()



        self.status=QLabel(

            "Neural Network Online"

        )



        self.network=NetworkView()



        self.graph=Graphs()



        layout.addWidget(

            self.status

        )


        layout.addWidget(

            self.network

        )


        layout.addWidget(

            self.graph

        )



        self.setLayout(

            layout

        )






    def run(self):


        app=QApplication(

            sys.argv

        )


        self.show()


        sys.exit(

            app.exec()

        )

'@



Set-Content `
    -Path (Join-Path $project "ui\dashboard.py") `
    -Value $dashboard `
    -Encoding UTF8







$main=@'
import argparse

import time



from ai.agent import Agent

from environment.env import FNAFEnvironment

from environment.calibration import Calibration

from ui.dashboard import Dashboard





def calibrate():

    Calibration().run()





def dashboard():

    Dashboard().run()





def collect():


    env=FNAFEnvironment()


    while True:


        frame=env.vision.capture()


        env.vision.save(

            frame

        )


        time.sleep(

            0.5

        )







def train():


    env=FNAFEnvironment()


    agent=Agent()



    episode=0



    while True:


        episode+=1


        state=env.reset()


        done=False


        reward_total=0





        while not done:


            action=agent.act(

                state

            )



            next_state,reward,done=env.step(

                action

            )



            agent.remember(

                state,

                action,

                reward,

                next_state,

                done

            )



            agent.learn()



            state=next_state


            reward_total+=reward




        agent.save()



        print(

            "Episode:",

            episode,

            "Reward:",

            reward_total

        )







def play():


    env=FNAFEnvironment()


    agent=Agent()



    while True:


        state=env.reset()


        done=False



        while not done:


            action=agent.act(

                state,

                False

            )


            state,_,done=env.step(

                action

            )






parser=argparse.ArgumentParser()


parser.add_argument(

    "--mode"

)


args=parser.parse_args()



if args.mode=="dashboard":

    dashboard()


elif args.mode=="calibrate":

    calibrate()


elif args.mode=="collect":

    collect()


elif args.mode=="train":

    train()


elif args.mode=="play":

    play()

'@



Set-Content `
    -Path (Join-Path $project "main.py") `
    -Value $main `
    -Encoding UTF8







$start=@'
param(

[string]$mode="dashboard"

)



$python="venv\Scripts\python.exe"



& $python main.py --mode $mode
'@



Set-Content `
    -Path (Join-Path $project "start.ps1") `
    -Value $start `
    -Encoding UTF8







$launcher=@'
Write-Host ""

Write-Host "================================"

Write-Host " RedNeuronal FNAF 1 "

Write-Host "================================"

Write-Host ""

Write-Host "1 - Dashboard"

Write-Host "2 - Calibrar"

Write-Host "3 - Capturar datos"

Write-Host "4 - Entrenar IA"

Write-Host "5 - Jugar"

Write-Host ""



$option=Read-Host "Selecciona"



switch($option){


1 {.\start.ps1 dashboard}

2 {.\start.ps1 calibrate}

3 {.\start.ps1 collect}

4 {.\start.ps1 train}

5 {.\start.ps1 play}

}
'@



Set-Content `
    -Path (Join-Path $project "launcher.ps1") `
    -Value $launcher `
    -Encoding UTF8







Write-Host ""

Write-Host "====================================" -ForegroundColor Green

Write-Host " RedNeuronal FNAF 1 instalado "

Write-Host "====================================" -ForegroundColor Green

Write-Host ""

Write-Host "Ejecuta:" -ForegroundColor Cyan

Write-Host "cd $project"

Write-Host ".\launcher.ps1"
