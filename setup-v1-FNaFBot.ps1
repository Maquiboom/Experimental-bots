$root = Get-Location

$project = Join-Path $root "RedNeuronal-FNAF1"


Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host " RedNeuronal FNAF 1 " -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""



if(Test-Path $project){


    Write-Host "Proyecto existente encontrado." -ForegroundColor Yellow


    $backup = Join-Path $root "FNAF_Backup"


    New-Item -ItemType Directory -Path $backup -Force | Out-Null



    $filesToBackup = @(

        "models\model.pt",

        "models\checkpoint.pt",

        "config\calibration.json"

    )



    foreach($file in $filesToBackup){


        $source = Join-Path $project $file



        if(Test-Path $source){


            Copy-Item $source $backup -Force


            Write-Host "Backup:" $file -ForegroundColor Green

        }

    }



    Remove-Item $project -Recurse -Force


    Write-Host "Proyecto anterior eliminado." -ForegroundColor Green

}





New-Item -ItemType Directory -Path $project -Force | Out-Null




$folders = @(

"ai",

"environment",

"dashboard",

"ui",

"config",

"models",

"logs",

"data",

"data\screenshots",

"data\templates",

"data\templates\animatronics",

"data\templates\states"

)



foreach($folder in $folders){


    $path = Join-Path $project $folder


    New-Item -ItemType Directory -Path $path -Force | Out-Null

}





$requirements = @'
torch
torchvision
opencv-python
numpy
pyautogui
pillow
pyqt6
pyqtgraph
matplotlib
keyboard
mouse
psutil
'@



Set-Content `
    -Path (Join-Path $project "requirements.txt") `
    -Value $requirements `
    -Encoding UTF8






$initFiles = @(

"ai\__init__.py",

"environment\__init__.py",

"dashboard\__init__.py",

"ui\__init__.py",

"config\__init__.py"

)



foreach($file in $initFiles){


    New-Item `
        -ItemType File `
        -Path (Join-Path $project $file) `
        -Force | Out-Null

}






$config = @'
import os
import json


BASE_DIR = os.path.dirname(
    os.path.dirname(
        os.path.abspath(__file__)
    )
)



MODEL_PATH = os.path.join(

    BASE_DIR,

    "models",

    "checkpoint.pt"

)



LOG_PATH = os.path.join(

    BASE_DIR,

    "logs"

)



SCREENSHOT_PATH = os.path.join(

    BASE_DIR,

    "data",

    "screenshots"

)



TEMPLATE_PATH = os.path.join(

    BASE_DIR,

    "data",

    "templates"

)



CALIBRATION_PATH = os.path.join(

    BASE_DIR,

    "config",

    "calibration.json"

)



STATE_SIZE = 64


ACTION_SIZE = 12



LEARNING_RATE = 0.0005


GAMMA = 0.95



MEMORY_SIZE = 100000


BATCH_SIZE = 64



EPSILON_START = 1.0


EPSILON_END = 0.05


EPSILON_DECAY = 0.995



TARGET_UPDATE = 500



IMAGE_SIZE = 224
'@



Set-Content `
    -Path (Join-Path $project "config\config.py") `
    -Value $config `
    -Encoding UTF8






$settings = @'
{
    "project": "RedNeuronal-FNAF1",
    "version": "2.0",
    "dashboard": true,
    "vision": true,
    "training": true
}
'@



Set-Content `
    -Path (Join-Path $project "config\settings.json") `
    -Value $settings `
    -Encoding UTF8






$calibration = @'
{

}
'@



Set-Content `
    -Path (Join-Path $project "config\calibration.json") `
    -Value $calibration `
    -Encoding UTF8






Write-Host ""
Write-Host "Creando entorno virtual..." -ForegroundColor Cyan



$venv = Join-Path $project "venv"



python -m venv $venv




$python = Join-Path $venv "Scripts\python.exe"



if(!(Test-Path $python)){


    Write-Host "Error creando entorno Python." -ForegroundColor Red

    exit

}






Write-Host "Instalando dependencias..." -ForegroundColor Cyan



& $python -m pip install --upgrade pip



& $python -m pip install -r (Join-Path $project "requirements.txt")






Write-Host ""
Write-Host "Base preparada correctamente." -ForegroundColor Green
Write-Host ""

Write-Host "Proyecto creado en:" -ForegroundColor Cyan

Write-Host $project

$model = @'
import torch
import torch.nn as nn


from config.config import STATE_SIZE,ACTION_SIZE





class FNAFNetwork(nn.Module):


    def __init__(self):

        super().__init__()



        self.network = nn.Sequential(


            nn.Linear(

                STATE_SIZE,

                512

            ),


            nn.ReLU(),



            nn.Linear(

                512,

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

        return self.network(x)

'@



Set-Content `
    -Path (Join-Path $project "ai\model.py") `
    -Value $model `
    -Encoding UTF8







$visionModel = @'
import torch
import torch.nn as nn





class VisionEncoder(nn.Module):



    def __init__(self):


        super().__init__()



        self.features=nn.Sequential(


            nn.Conv2d(

                3,

                32,

                3,

                stride=2

            ),


            nn.ReLU(),



            nn.Conv2d(

                32,

                64,

                3,

                stride=2

            ),


            nn.ReLU(),



            nn.Conv2d(

                64,

                128,

                3,

                stride=2

            ),


            nn.ReLU()

        )






    def forward(self,x):


        x=self.features(x)



        return torch.flatten(

            x,

            1

        )
'@



Set-Content `
    -Path (Join-Path $project "ai\vision_model.py") `
    -Value $visionModel `
    -Encoding UTF8







$replay = @'
import random

from collections import deque





class ReplayMemory:



    def __init__(self,size):


        self.memory=deque(

            maxlen=size

        )







    def add(self,experience):


        self.memory.append(

            experience

        )







    def sample(self,batch):


        return random.sample(

            self.memory,

            batch

        )






    def __len__(self):


        return len(

            self.memory

        )
'@



Set-Content `
    -Path (Join-Path $project "ai\replay.py") `
    -Value $replay `
    -Encoding UTF8







$checkpoint = @'
import os

import torch





def save_checkpoint(

    path,

    agent

):



    os.makedirs(

        os.path.dirname(path),

        exist_ok=True

    )



    torch.save(

        {

        "model":agent.model.state_dict(),

        "target":agent.target.state_dict(),

        "optimizer":agent.optimizer.state_dict(),

        "epsilon":agent.epsilon,

        "steps":agent.steps,

        "episodes":agent.episodes,

        "reward_history":agent.reward_history

        },

        path

    )








def load_checkpoint(

    path,

    agent

):



    if not os.path.exists(path):


        return False






    data=torch.load(

        path,

        map_location=agent.device

    )



    agent.model.load_state_dict(

        data["model"]

    )



    agent.target.load_state_dict(

        data["target"]

    )



    agent.optimizer.load_state_dict(

        data["optimizer"]

    )



    agent.epsilon=data.get(

        "epsilon",

        1.0

    )



    agent.steps=data.get(

        "steps",

        0

    )



    agent.episodes=data.get(

        "episodes",

        0

    )



    agent.reward_history=data.get(

        "reward_history",

        []

    )



    return True
'@



Set-Content `
    -Path (Join-Path $project "ai\checkpoint.py") `
    -Value $checkpoint `
    -Encoding UTF8







$agent = @'
import random


import torch

import torch.nn as nn

import torch.optim as optim



from ai.model import FNAFNetwork

from ai.replay import ReplayMemory

from ai.checkpoint import save_checkpoint,load_checkpoint



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



        self.target.load_state_dict(

            self.model.state_dict()

        )



        self.optimizer=optim.Adam(

            self.model.parameters(),

            lr=LEARNING_RATE

        )



        self.loss_fn=nn.MSELoss()



        self.memory=ReplayMemory(

            MEMORY_SIZE

        )



        self.epsilon=EPSILON_START



        self.steps=0


        self.episodes=0


        self.reward_history=[]


        self.loss_value=0



        load_checkpoint(

            MODEL_PATH,

            self

        )







    def act(

        self,

        state,

        explore=True

    ):



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


            values=self.model(

                state

            )



        return torch.argmax(

            values

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



        states,actions,rewards,next_states,dones=zip(

            *batch

        )




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

            ).max(1)[0]



            expected=rewards+(

                GAMMA*

                future*

                (1-dones)

            )







        loss=self.loss_fn(

            current,

            expected

        )



        self.optimizer.zero_grad()



        loss.backward()



        self.optimizer.step()



        self.loss_value=loss.item()



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


        save_checkpoint(

            MODEL_PATH,

            self

        )

'@



Set-Content `
    -Path (Join-Path $project "ai\agent.py") `
    -Value $agent `
    -Encoding UTF8







$trainer = @'
import time





class Trainer:



    def __init__(self,agent,env):


        self.agent=agent

        self.env=env






    def run(self):


        while True:



            state=self.env.reset()



            done=False


            reward_total=0





            while not done:



                action=self.agent.act(

                    state

                )



                next_state,reward,done=self.env.step(

                    action

                )



                self.agent.remember(

                    state,

                    action,

                    reward,

                    next_state,

                    done

                )



                self.agent.learn()



                state=next_state



                reward_total+=reward





            self.agent.episodes+=1



            self.agent.reward_history.append(

                reward_total

            )



            self.agent.save()



            print(

                "Episode:",

                self.agent.episodes,

                "Reward:",

                reward_total,

                "Loss:",

                self.agent.loss_value

            )



            time.sleep(

                0.2

            )
'@



Set-Content `
    -Path (Join-Path $project "ai\trainer.py") `
    -Value $trainer `
    -Encoding UTF8







Write-Host ""

Write-Host "Sistema IA creado correctamente." -ForegroundColor Green


$vision = @'
import os

import time


import cv2

import numpy as np

import pyautogui



from config.config import SCREENSHOT_PATH






class Vision:



    def __init__(self):


        self.last_frame=None


        self.frame_count=0






    def capture(self):


        screenshot=pyautogui.screenshot()



        frame=np.array(

            screenshot

        )



        frame=cv2.cvtColor(

            frame,

            cv2.COLOR_RGB2BGR

        )



        self.last_frame=frame


        self.frame_count+=1



        return frame






    def resize(self,frame,size=224):


        return cv2.resize(

            frame,

            (

            size,

            size

            )

        )







    def normalize(self,frame):


        image=frame.astype(

            np.float32

        )



        image/=255.0



        return image






    def prepare_tensor(self,frame):


        image=self.resize(

            frame

        )



        image=self.normalize(

            image

        )



        image=np.transpose(

            image,

            (

            2,

            0,

            1

            )

        )



        return image






    def save(self,frame):


        os.makedirs(

            SCREENSHOT_PATH,

            exist_ok=True

        )



        filename=os.path.join(

            SCREENSHOT_PATH,

            str(

                int(time.time())

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







$templateManager = @'
import os

import cv2






class TemplateManager:



    def __init__(self,path):


        self.path=path


        self.templates={}



        self.load()






    def load(self):


        if not os.path.exists(

            self.path

        ):


            return






        for root,dirs,files in os.walk(

            self.path

        ):



            for file in files:



                if file.lower().endswith(

                    ".png"

                ):



                    full=os.path.join(

                        root,

                        file

                    )



                    image=cv2.imread(

                        full,

                        0

                    )



                    if image is not None:


                        self.templates[file]=image







    def add(self,name,image):


        self.templates[name]=image







    def get_all(self):


        return self.templates
'@



Set-Content `
-Path (Join-Path $project "environment\template_manager.py") `
-Value $templateManager `
-Encoding UTF8







$detector = @'
import cv2

import numpy as np





class Detector:



    def __init__(self,manager):


        self.manager=manager






    def detect(self,frame):


        results={}



        gray=cv2.cvtColor(

            frame,

            cv2.COLOR_BGR2GRAY

        )





        for name,template in self.manager.get_all().items():



            try:



                match=cv2.matchTemplate(

                    gray,

                    template,

                    cv2.TM_CCOEFF_NORMED

                )



                value=float(

                    np.max(match)

                )



                location=np.unravel_index(

                    np.argmax(match),

                    match.shape

                )



                if value>=0.70:


                    results[name]={


                    "confidence":value,


                    "position":location


                    }



            except Exception:



                pass





        return results
'@



Set-Content `
-Path (Join-Path $project "environment\detector.py") `
-Value $detector `
-Encoding UTF8







$state = @'
import numpy as np





class GameState:



    def __init__(self):


        self.last={}






    def build(self,detections):


        state=np.zeros(

            64,

            dtype=np.float32

        )



        index=0





        for name,data in detections.items():



            confidence=data["confidence"]



            name=name.lower()





            if "bonnie" in name:


                state[0]=confidence




            elif "chica" in name:


                state[1]=confidence




            elif "foxy" in name:


                state[2]=confidence




            elif "freddy" in name:


                state[3]=confidence







            if index+10 < len(state):


                state[index+10]=confidence



            index+=1





        self.last=state



        return state







    def summary(self):


        active=[]



        for i,value in enumerate(self.last):


            if value>0:


                active.append(

                    (

                    i,

                    float(value)

                    )

                )



        return active
'@



Set-Content `
-Path (Join-Path $project "environment\state.py") `
-Value $state `
-Encoding UTF8







$visionMonitor = @'
class VisionMonitor:



    def __init__(self):


        self.objects={}


        self.frame=None





    def update(self,frame,objects):


        self.frame=frame


        self.objects=objects






    def get_objects(self):


        return self.objects
'@



Set-Content `
-Path (Join-Path $project "environment\vision_monitor.py") `
-Value $visionMonitor `
-Encoding UTF8







Write-Host ""

Write-Host "Sistema de vision creado correctamente." -ForegroundColor Green


$actions = @'
ACTIONS=[

    "open_monitor",

    "camera_1a",

    "camera_1b",

    "camera_2a",

    "camera_2b",

    "camera_3",

    "camera_4a",

    "camera_4b",

    "left_light",

    "left_door",

    "right_light",

    "right_door"

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







$controller = @'
import json

import os

import time


import pyautogui



from config.config import CALIBRATION_PATH






class Controller:



    def __init__(self):


        self.points={}


        self.load()







    def load(self):


        if os.path.exists(

            CALIBRATION_PATH

        ):



            with open(

                CALIBRATION_PATH,

                "r"

            ) as file:


                self.points=json.load(file)







    def click(self,name):


        if name not in self.points:


            print(

                "Accion sin calibrar:",

                name

            )


            return False





        position=self.points[name]



        pyautogui.click(

            position["x"],

            position["y"]

        )



        time.sleep(

            0.15

        )



        return True






    def execute(self,action):


        return self.click(

            action

        )
'@



Set-Content `
-Path (Join-Path $project "environment\controller.py") `
-Value $controller `
-Encoding UTF8







$calibration = @'
import tkinter as tk

import json

import os



from config.config import CALIBRATION_PATH






ACTIONS=[


"open_monitor",

"camera_1a",

"camera_1b",

"camera_2a",

"camera_2b",

"camera_3",

"camera_4a",

"camera_4b",

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

            "Selecciona:",

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


        for action in ACTIONS:


            self.select(action)





        os.makedirs(

            os.path.dirname(

                CALIBRATION_PATH

            ),

            exist_ok=True

        )





        with open(

            CALIBRATION_PATH,

            "w"

        ) as file:


            json.dump(

                self.data,

                file,

                indent=4

            )



        print(

            "Calibracion guardada"

        )
'@



Set-Content `
-Path (Join-Path $project "environment\calibration.py") `
-Value $calibration `
-Encoding UTF8







$reward = @'
class RewardSystem:



    def __init__(self):


        self.previous={}






    def calculate(self,state):


        reward=0






        if state[0]>0:


            reward+=0.05






        if state[1]>0:


            reward+=0.05






        if state[2]>0:


            reward+=0.15






        if state[3]>0:


            reward+=0.05






        if state[12]>0:


            reward-=100






        if state[13]>0:


            reward+=200






        return reward
'@



Set-Content `
-Path (Join-Path $project "environment\rewards.py") `
-Value $reward `
-Encoding UTF8







$env = @'
import time



from environment.vision import Vision

from environment.template_manager import TemplateManager

from environment.detector import Detector

from environment.state import GameState

from environment.controller import Controller

from environment.actions import get_action

from environment.rewards import RewardSystem



from config.config import TEMPLATE_PATH






class FNAFEnvironment:



    def __init__(self):


        self.vision=Vision()



        self.templates=TemplateManager(

            TEMPLATE_PATH

        )



        self.detector=Detector(

            self.templates

        )



        self.state_builder=GameState()



        self.controller=Controller()



        self.reward=RewardSystem()







    def reset(self):


        frame=self.vision.capture()



        detections=self.detector.detect(

            frame

        )



        return self.state_builder.build(

            detections

        )








    def step(self,action_id):


        action=get_action(

            action_id

        )



        self.controller.execute(

            action

        )



        time.sleep(

            0.15

        )



        frame=self.vision.capture()



        detections=self.detector.detect(

            frame

        )



        next_state=self.state_builder.build(

            detections

        )



        reward=self.reward.calculate(

            next_state

        )



        done=False





        if next_state[12]>0:


            done=True





        if next_state[13]>0:


            done=True






        return (

            next_state,

            reward,

            done

        )
'@



Set-Content `
-Path (Join-Path $project "environment\env.py") `
-Value $env `
-Encoding UTF8







Write-Host ""

Write-Host "Entorno FNAF creado correctamente." -ForegroundColor Green


$networkView = @'
import math

import random


from PyQt6.QtWidgets import QWidget

from PyQt6.QtGui import (

    QPainter,

    QColor,

    QPen

)

from PyQt6.QtCore import QTimer





class NetworkView(QWidget):


    def __init__(self):

        super().__init__()



        self.layers=[

            64,

            512,

            256,

            128,

            12

        ]



        self.activations=[]


        self.phase=0



        self.resize(

            1000,

            500

        )



        self.timer=QTimer()



        self.timer.timeout.connect(

            self.update_animation

        )



        self.timer.start(

            40

        )







    def set_values(self,values):


        self.activations=values


        self.update()







    def update_animation(self):


        self.phase+=0.05


        self.update()







    def paintEvent(self,event):


        painter=QPainter(

            self

        )



        painter.setRenderHint(

            QPainter.RenderHint.Antialiasing

        )





        positions=[]



        spacing=self.width()/(len(self.layers)+1)





        for index,size in enumerate(self.layers):


            nodes=[]



            visible=min(

                size,

                20

            )



            for n in range(visible):


                x=(index+1)*spacing


                y=40+(n*22)



                nodes.append(

                    (

                    x,

                    y

                    )

                )



            positions.append(nodes)






        painter.setPen(

            QPen(

                QColor(

                    80,

                    80,

                    80

                ),

                1

            )

        )






        for current,next_layer in zip(

            positions[:-1],

            positions[1:]

        ):


            for x1,y1 in current:


                for x2,y2 in next_layer:


                    intensity=int(

                        (

                        math.sin(

                            self.phase+x1

                        )

                        +1

                        )

                        *

                        70

                    )



                    painter.setPen(

                        QColor(

                            40,

                            40+intensity,

                            120+intensity

                        )

                    )



                    painter.drawLine(

                        int(x1),

                        int(y1),

                        int(x2),

                        int(y2)

                    )







        for layer in positions:


            for x,y in layer:


                value=random.random()



                color=int(

                    80+

                    value*

                    170

                )



                painter.setBrush(

                    QColor(

                        color,

                        120,

                        255

                    )

                )



                painter.drawEllipse(

                    int(x-7),

                    int(y-7),

                    14,

                    14

                )
'@



Set-Content `
-Path (Join-Path $project "dashboard\network_view.py") `
-Value $networkView `
-Encoding UTF8







$graphs = @'
from PyQt6.QtWidgets import QWidget,QVBoxLayout

import pyqtgraph as pg






class RewardGraph(QWidget):



    def __init__(self):


        super().__init__()



        layout=QVBoxLayout()



        self.plot=pg.PlotWidget()



        self.plot.setTitle(

            "Reward"

        )



        layout.addWidget(

            self.plot

        )



        self.values=[]



        self.setLayout(

            layout

        )







    def add_reward(self,value):


        self.values.append(

            value

        )



        self.plot.clear()



        self.plot.plot(

            self.values,

            pen="cyan"

        )
'@



Set-Content `
-Path (Join-Path $project "dashboard\graphs.py") `
-Value $graphs `
-Encoding UTF8







$monitor = @'
from PyQt6.QtCore import QObject,pyqtSignal





class TrainingMonitor(QObject):


    reward_changed=pyqtSignal(float)


    status_changed=pyqtSignal(str)



    def update_reward(self,value):


        self.reward_changed.emit(

            value

        )




    def update_status(self,text):


        self.status_changed.emit(

            text

        )
'@



Set-Content `
-Path (Join-Path $project "dashboard\monitor.py") `
-Value $monitor `
-Encoding UTF8







$dashboard = @'
import sys



from PyQt6.QtWidgets import (

    QApplication,

    QWidget,

    QVBoxLayout,

    QLabel

)



from dashboard.network_view import NetworkView

from dashboard.graphs import RewardGraph






class Dashboard(QWidget):



    def __init__(self):


        super().__init__()



        self.setWindowTitle(

            "RedNeuronal FNAF 1 - Brain"

        )



        self.resize(

            1200,

            900

        )





        layout=QVBoxLayout()



        self.status=QLabel(

            "Esperando IA..."

        )



        self.network=NetworkView()



        self.graph=RewardGraph()



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







    def set_status(self,text):


        self.status.setText(

            text

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
-Path (Join-Path $project "dashboard\dashboard.py") `
-Value $dashboard `
-Encoding UTF8







Write-Host ""

Write-Host "Dashboard neuronal creado correctamente." -ForegroundColor Green


$main = @'
import argparse

import threading

import time



from ai.agent import Agent

from ai.trainer import Trainer


from environment.env import FNAFEnvironment


from environment.calibration import Calibration


from dashboard.dashboard import Dashboard





def train():


    print(

        "Iniciando entrenamiento..."

    )



    env=FNAFEnvironment()



    agent=Agent()



    trainer=Trainer(

        agent,

        env

    )



    trainer.run()







def play():


    print(

        "Modo jugador IA"

    )



    env=FNAFEnvironment()



    agent=Agent()



    state=env.reset()






    while True:


        action=agent.act(

            state,

            False

        )



        state,reward,done=env.step(

            action

        )



        if done:


            print(

                "Partida terminada"

            )


            time.sleep(2)



            state=env.reset()







def calibrate():


    Calibration().run()







def dashboard():


    Dashboard().run()







def train_with_dashboard():


    env=FNAFEnvironment()



    agent=Agent()



    trainer=Trainer(

        agent,

        env

    )



    thread=threading.Thread(

        target=trainer.run

    )



    thread.daemon=True



    thread.start()



    Dashboard().run()







def main():



    parser=argparse.ArgumentParser()



    parser.add_argument(

        "--mode",

        required=True

    )



    args=parser.parse_args()





    if args.mode=="train":


        train()





    elif args.mode=="train_dashboard":


        train_with_dashboard()





    elif args.mode=="play":


        play()





    elif args.mode=="calibrate":


        calibrate()





    elif args.mode=="dashboard":


        dashboard()





if __name__=="__main__":


    main()
'@



Set-Content `
-Path (Join-Path $project "main.py") `
-Value $main `
-Encoding UTF8







$launcher = @'
$python="venv\Scripts\python.exe"



Write-Host ""

Write-Host "=============================="

Write-Host " RedNeuronal FNAF 1 "

Write-Host "=============================="

Write-Host ""



Write-Host "1 - Dashboard"

Write-Host "2 - Calibrar"

Write-Host "3 - Entrenar"

Write-Host "4 - Entrenar + Dashboard"

Write-Host "5 - Jugar"

Write-Host ""



$option=Read-Host "Selecciona"





switch($option){



1 {


& $python main.py --mode dashboard


}



2 {


& $python main.py --mode calibrate


}



3 {


& $python main.py --mode train


}



4 {


& $python main.py --mode train_dashboard


}



5 {


& $python main.py --mode play


}



}
'@



Set-Content `
-Path (Join-Path $project "launcher.ps1") `
-Value $launcher `
-Encoding UTF8







$start = @'
Write-Host ""

Write-Host "RedNeuronal FNAF 1"

Write-Host ""



powershell -ExecutionPolicy Bypass -File launcher.ps1
'@



Set-Content `
-Path (Join-Path $project "start.ps1") `
-Value $start `
-Encoding UTF8







$gitignore = @'
venv/

__pycache__/

*.pyc

logs/

data/screenshots/

'@



Set-Content `
-Path (Join-Path $project ".gitignore") `
-Value $gitignore `
-Encoding UTF8







Write-Host ""

Write-Host "====================================" -ForegroundColor Green

Write-Host " RedNeuronal FNAF 1 FINALIZADA "

Write-Host "====================================" -ForegroundColor Green

Write-Host ""

Write-Host "Ruta del proyecto:"

Write-Host $project

Write-Host ""

Write-Host "Ejecuta launcher.ps1 para comenzar."
