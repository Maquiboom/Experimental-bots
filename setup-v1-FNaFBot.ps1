# ============================================================
# RedNeuronal FNAF 1
# Bloque 1/5
# Instalador base + entorno virtual
# ============================================================


$project = "RedNeuronal FNAF1"


$scriptFolder = Split-Path `
    -Parent `
    $MyInvocation.MyCommand.Path



Write-Host ""

Write-Host "======================================" `
-ForegroundColor Cyan

Write-Host " RedNeuronal FNAF 1 "

Write-Host " Instalacion base "

Write-Host "======================================" `
-ForegroundColor Cyan



Write-Host ""



# ============================================================
# Backup del modelo anterior
# ============================================================


$oldModel = Join-Path `
    $project `
    "models\model.pt"


$backup = Join-Path `
    $scriptFolder `
    "model_backup.pt"



if(Test-Path $oldModel){


    Write-Host "Guardando modelo anterior..." `
    -ForegroundColor Yellow



    if(Test-Path $backup){


        Remove-Item `
        $backup `
        -Force

    }



    Copy-Item `
    $oldModel `
    $backup `
    -Force



    Write-Host "Modelo guardado." `
    -ForegroundColor Green

}







# ============================================================
# Crear estructura
# ============================================================



$folders=@(


"$project",

"$project\ai",

"$project\environment",

"$project\ui",

"$project\config",

"$project\models",

"$project\logs",

"$project\data",

"$project\data\screenshots",

"$project\venv"


)



foreach($folder in $folders){


    New-Item `
    -ItemType Directory `
    -Path $folder `
    -Force | Out-Null


}






Write-Host ""

Write-Host "Carpetas creadas." `
-ForegroundColor Green







# ============================================================
# Crear entorno virtual
# ============================================================


Set-Location `
$project



if(!(Test-Path "venv\Scripts\python.exe")){


    Write-Host ""

    Write-Host "Creando entorno virtual..." `
    -ForegroundColor Cyan



    python -m venv venv


}
else{


    Write-Host "Entorno virtual encontrado." `
    -ForegroundColor Green

}







# ============================================================
# requirements.txt
# ============================================================


@'
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

tqdm
'@ | Set-Content `
"requirements.txt" `
-Encoding UTF8







# ============================================================
# Activar entorno
# ============================================================


Write-Host ""

Write-Host "Activando entorno virtual..." `
-ForegroundColor Cyan



.\venv\Scripts\activate






# ============================================================
# Actualizar pip
# ============================================================


python -m pip install --upgrade pip







# ============================================================
# Instalar dependencias
# ============================================================


Write-Host ""

Write-Host "Instalando dependencias..." `
-ForegroundColor Cyan



pip install -r requirements.txt






# ============================================================
# Crear archivos init
# ============================================================


$initFiles=@(

"ai\__init__.py",

"environment\__init__.py",

"ui\__init__.py",

"config\__init__.py"

)



foreach($file in $initFiles){


    New-Item `
    -ItemType File `
    -Path $file `
    -Force | Out-Null


}







# ============================================================
# Configuracion inicial
# ============================================================


@'
{
    "capture": {
        "x":0,
        "y":0,
        "width":1280,
        "height":720
    }
}
'@ | Set-Content `
"config\settings.json" `
-Encoding UTF8







# ============================================================
# Calibration vacio
# ============================================================


@'
{}
'@ | Set-Content `
"config\calibration.json" `
-Encoding UTF8







# ============================================================
# Crear carpetas de datos
# ============================================================


New-Item `
-ItemType Directory `
-Path "data\vision_memory" `
-Force | Out-Null



New-Item `
-ItemType Directory `
-Path "logs" `
-Force | Out-Null







Write-Host ""

Write-Host "======================================" `
-ForegroundColor Green

Write-Host " Base creada correctamente "

Write-Host ""

Write-Host "Entorno virtual listo."

Write-Host ""

Write-Host "Siguiente bloque: IA CNN + DQN"

Write-Host "======================================" `
-ForegroundColor Green

# ============================================================
# RedNeuronal FNAF 1
# Bloque 2/5
# CNN Vision + DQN + Replay Memory
# ============================================================



# ============================================================
# ai/vision_net.py
# ============================================================


@'
import torch

import torch.nn as nn





class VisionNetwork(nn.Module):


    def __init__(self):

        super().__init__()



        self.features = nn.Sequential(


            nn.Conv2d(
                3,
                16,
                kernel_size=5,
                stride=2
            ),

            nn.ReLU(),


            nn.Conv2d(
                16,
                32,
                kernel_size=5,
                stride=2
            ),

            nn.ReLU(),


            nn.Conv2d(
                32,
                64,
                kernel_size=3,
                stride=2
            ),

            nn.ReLU()

        )



        self.classifier = nn.Sequential(


            nn.Flatten(),


            nn.Linear(
                64*7*7,
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


        return self.classifier(x)



'@ | Set-Content `
"$project\ai\vision_net.py" `
-Encoding UTF8






# ============================================================
# ai/model.py
# ============================================================


@'
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



'@ | Set-Content `
"$project\ai\model.py" `
-Encoding UTF8







# ============================================================
# ai/replay.py
# ============================================================


@'
from collections import deque

import random





class ReplayMemory:



    def __init__(self,size):


        self.memory=deque(

            maxlen=size

        )





    def add(self,item):


        self.memory.append(

            item

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



'@ | Set-Content `
"$project\ai\replay.py" `
-Encoding UTF8







# ============================================================
# ai/agent.py
# ============================================================


@'
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



        self.target.load_state_dict(

            self.model.state_dict()

        )



        self.memory=ReplayMemory(

            MEMORY_SIZE

        )



        self.optimizer=optim.Adam(

            self.model.parameters(),

            lr=LEARNING_RATE

        )



        self.loss_function=nn.MSELoss()



        self.epsilon=EPSILON_START



        self.loss_value=0






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


            q=self.model(

                state

            )



        return torch.argmax(

            q

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




        for s,a,r,n,d in batch:


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



        self.loss_value=loss.item()



        self.epsilon=max(

            EPSILON_END,

            self.epsilon*EPSILON_DECAY

        )








    def update_target(self):


        self.target.load_state_dict(

            self.model.state_dict()

        )







    def save(self):


        os.makedirs(

            "models",

            exist_ok=True

        )



        torch.save(

            self.model.state_dict(),

            "models/model.pt"

        )







    def load(self):


        if os.path.exists(

            "models/model.pt"

        ):


            self.model.load_state_dict(

                torch.load(

                    "models/model.pt",

                    map_location=self.device

                )

            )


            self.target.load_state_dict(

                self.model.state_dict()

            )



'@ | Set-Content `
"$project\ai\agent.py" `
-Encoding UTF8







# ============================================================
# Actualizar configuracion
# ============================================================


@'
BASE_DIR="."



MODEL_PATH="models/model.pt"



VISION_MODEL_PATH="models/vision.pt"



STATE_SIZE=56



ACTION_SIZE=14



LEARNING_RATE=0.0005



GAMMA=0.95



MEMORY_SIZE=100000



BATCH_SIZE=64



EPSILON_START=1.0



EPSILON_END=0.05



EPSILON_DECAY=0.995



TARGET_UPDATE=500

'@ | Set-Content `
"$project\config\config.py" `
-Encoding UTF8






Write-Host ""

Write-Host "IA CNN + DQN creada correctamente." `
-ForegroundColor Green


Write-Host ""

Write-Host "Siguiente bloque: Entorno FNAF + captura pantalla + controles." `
-ForegroundColor Cyan

# ============================================================
# RedNeuronal FNAF 1
# Bloque 3/5
# Entorno + Vision + Control
# ============================================================



# ============================================================
# environment/actions.py
# ============================================================


@'
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

    "extra_1",

    "extra_2",

    "extra_3",

    "extra_4"

]





def get_action(index):


    if index < 0:

        return None



    if index >= len(ACTIONS):

        return None



    return ACTIONS[index]

'@ | Set-Content `
"$project\environment\actions.py" `
-Encoding UTF8






# ============================================================
# environment/vision.py
# ============================================================


@'
import cv2

import numpy as np

import pyautogui

import torch





class Vision:



    def __init__(self):


        self.size=(224,224)







    def capture(self):


        image=pyautogui.screenshot()



        frame=np.array(

            image

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



        tensor=torch.tensor(

            frame

        ).unsqueeze(0)



        return tensor







    def save(self,frame,path):


        cv2.imwrite(

            path,

            frame

        )

'@ | Set-Content `
"$project\environment\vision.py" `
-Encoding UTF8







# ============================================================
# environment/controller.py
# ============================================================


@'
import json

import os

import pyautogui

import time



from config.config import *





class Controller:



    def __init__(self):


        self.points={}


        self.load()





    def load(self):


        if os.path.exists(

            "config/calibration.json"

        ):


            with open(

                "config/calibration.json",

                "r"

            ) as f:


                self.points=json.load(f)








    def click(self,name):


        if name not in self.points:


            print(

                "Falta calibrar:",

                name

            )


            return





        pos=self.points[name]



        pyautogui.click(

            pos["x"],

            pos["y"]

        )



        time.sleep(

            0.1

        )







    def execute(self,action):


        self.click(

            action

        )

'@ | Set-Content `
"$project\environment\controller.py" `
-Encoding UTF8







# ============================================================
# environment/calibration.py
# ============================================================


@'
import tkinter as tk

import json





BUTTONS=[


"open_monitor",

"close_monitor",

"camera_left",

"camera_right",

"camera_cycle",

"left_light",

"left_door",

"right_light",

"right_door",

"wait"

]





class Calibration:



    def __init__(self):


        self.data={}







    def select(self,name):


        print(

            "Selecciona",

            name

        )


        root=tk.Tk()


        root.attributes(

            "-fullscreen",

            True

        )


        position=[]





        def click(event):


            position.append(

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





        if position:


            self.data[name]=position[0]








    def run(self):


        for button in BUTTONS:


            self.select(

                button

            )




        with open(

            "config/calibration.json",

            "w"

        ) as f:


            json.dump(

                self.data,

                f,

                indent=4

            )

'@ | Set-Content `
"$project\environment\calibration.py" `
-Encoding UTF8







# ============================================================
# environment/state.py
# ============================================================


@'
import numpy as np





class GameState:



    def build(self,vision_vector):


        state=np.zeros(

            56,

            dtype=np.float32

        )



        length=min(

            len(vision_vector),

            32

        )



        state[:length]=vision_vector[:length]



        return state

'@ | Set-Content `
"$project\environment\state.py" `
-Encoding UTF8







# ============================================================
# environment/env.py
# ============================================================


@'
import torch

import time



from environment.vision import Vision

from environment.controller import Controller

from environment.state import GameState

from environment.actions import get_action

from ai.vision_net import VisionNetwork





class FNAFEnvironment:



    def __init__(self):


        self.vision=Vision()


        self.controller=Controller()


        self.state=GameState()



        self.visual_net=VisionNetwork()



        self.visual_net.eval()







    def reset(self):


        frame=self.vision.capture()



        return self.get_state(

            frame

        )







    def get_state(self,frame):


        image=self.vision.process(

            frame

        )



        with torch.no_grad():


            vector=self.visual_net(

                image

            ).numpy()[0]



        return self.state.build(

            vector

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



        next_state=self.get_state(

            frame

        )



        reward=0.1


        done=False



        return (

            next_state,

            reward,

            done

        )

'@ | Set-Content `
"$project\environment\env.py" `
-Encoding UTF8







Write-Host ""

Write-Host "Entorno FNAF creado." `
-ForegroundColor Green


Write-Host ""

Write-Host "Siguiente bloque: Dashboard neuronal avanzado + visualizacion CNN." `
-ForegroundColor Cyan

# ============================================================
# RedNeuronal FNAF 1
# Bloque 4/5
# Dashboard neuronal avanzado
# ============================================================



# ============================================================
# ui/vision_view.py
# ============================================================


@'
import cv2

from PyQt6.QtWidgets import QWidget

from PyQt6.QtGui import (
    QPainter,
    QImage,
    QPixmap
)

from PyQt6.QtCore import QTimer



class VisionView(QWidget):


    def __init__(self):

        super().__init__()


        self.frame=None


        self.resize(
            400,
            250
        )


        self.timer=QTimer(self)


        self.timer.timeout.connect(
            self.update
        )


        self.timer.start(
            100
        )





    def set_frame(self,frame):


        self.frame=frame






    def paintEvent(self,event):


        painter=QPainter(
            self
        )


        if self.frame is None:


            return



        rgb=cv2.cvtColor(

            self.frame,

            cv2.COLOR_BGR2RGB

        )



        h,w,c=rgb.shape



        image=QImage(

            rgb.data,

            w,

            h,

            w*c,

            QImage.Format.Format_RGB888

        )



        painter.drawPixmap(

            0,

            0,

            QPixmap.fromImage(

                image

            ).scaled(

                self.width(),

                self.height()

            )

        )

'@ | Set-Content `
"$project\ui\vision_view.py" `
-Encoding UTF8






# ============================================================
# ui/network_view.py
# ============================================================


@'
import math

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


        self.resize(
            800,
            450
        )


        self.phase=0



        self.layers=[

            32,

            256,

            256,

            128,

            14

        ]



        self.timer=QTimer(self)


        self.timer.timeout.connect(

            self.animate

        )


        self.timer.start(

            50

        )





    def animate(self):


        self.phase+=0.15


        self.update()






    def paintEvent(self,event):


        painter=QPainter(

            self

        )


        painter.setRenderHint(

            QPainter.RenderHint.Antialiasing

        )



        positions=[]


        step=self.width()/(len(self.layers)+1)





        for layer,size in enumerate(self.layers):


            nodes=[]


            amount=min(

                size,

                20

            )


            for n in range(amount):


                x=(layer+1)*step


                y=(self.height()/2)+(

                    n-(amount/2)

                )*20



                nodes.append(

                    (

                    x,

                    y

                    )

                )


            positions.append(

                nodes

            )





        # conexiones


        painter.setPen(

            QPen(

                QColor(

                    90,

                    90,

                    90,

                    100

                )

            )

        )



        for a,b in zip(

            positions[:-1],

            positions[1:]

        ):


            for x1,y1 in a:


                for x2,y2 in b:


                    painter.drawLine(

                        int(x1),

                        int(y1),

                        int(x2),

                        int(y2)

                    )





        # neuronas


        for layer,nodes in enumerate(

            positions

        ):


            for index,(x,y) in enumerate(nodes):


                pulse=(

                    math.sin(

                        self.phase+index

                    )

                    +1

                )/2



                color=QColor(

                    int(

                        100+

                        pulse*155

                    ),

                    80,

                    255

                )



                painter.setBrush(

                    color

                )



                painter.drawEllipse(

                    int(x-7),

                    int(y-7),

                    14,

                    14

                )

'@ | Set-Content `
"$project\ui\network_view.py" `
-Encoding UTF8







# ============================================================
# ui/graphs.py
# ============================================================


@'
from PyQt6.QtWidgets import QWidget,QVBoxLayout

import pyqtgraph as pg





class Graphs(QWidget):


    def __init__(self):


        super().__init__()



        layout=QVBoxLayout()



        self.graph=pg.PlotWidget()



        self.graph.setTitle(

            "Aprendizaje"

        )


        layout.addWidget(

            self.graph

        )



        self.values=[]



        self.setLayout(

            layout

        )






    def add_value(self,value):


        self.values.append(

            value

        )


        self.graph.clear()



        self.graph.plot(

            self.values,

            pen="green"

        )

'@ | Set-Content `
"$project\ui\graphs.py" `
-Encoding UTF8







# ============================================================
# ui/dashboard.py
# ============================================================


@'
import sys

from PyQt6.QtWidgets import (

    QApplication,

    QWidget,

    QVBoxLayout,

    QLabel,

    QHBoxLayout

)


from PyQt6.QtCore import QTimer



from ui.network_view import NetworkView

from ui.vision_view import VisionView

from ui.graphs import Graphs





class Dashboard(QWidget):


    def __init__(self):


        super().__init__()



        self.setWindowTitle(

            "RedNeuronal FNAF 1 - Cerebro"

        )


        self.resize(

            1200,

            900

        )





        layout=QVBoxLayout()



        self.info=QLabel(

            "IA esperando..."

        )



        top=QHBoxLayout()



        self.vision=VisionView()


        self.network=NetworkView()



        top.addWidget(

            self.vision

        )


        top.addWidget(

            self.network

        )




        self.graph=Graphs()



        layout.addWidget(

            self.info

        )


        layout.addLayout(

            top

        )


        layout.addWidget(

            self.graph

        )



        self.setLayout(

            layout

        )



        self.timer=QTimer(self)


        self.timer.timeout.connect(

            self.refresh

        )


        self.timer.start(

            200

        )





    def refresh(self):


        self.info.setText(

            "Vision CNN  |  DQN activa  |  aprendiendo..."

        )







    def run(self):


        app=QApplication(

            sys.argv

        )


        self.show()


        sys.exit(

            app.exec()

        )

'@ | Set-Content `
"$project\ui\dashboard.py" `
-Encoding UTF8







Write-Host ""

Write-Host "Dashboard neuronal creado correctamente." `
-ForegroundColor Green


Write-Host ""

Write-Host "Siguiente bloque: Main final + modos train/play/collect." `
-ForegroundColor Cyan

# ============================================================
# RedNeuronal FNAF 1
# Bloque 5/5
# Main + Start final
# ============================================================



# ============================================================
# main.py
# ============================================================


@'
import argparse

import time

import os

import torch



from ai.agent import Agent

from environment.env import FNAFEnvironment

from environment.calibration import Calibration

from environment.vision import Vision



from ui.dashboard import Dashboard





def collect():

    print()

    print("=== RECOLECTANDO EXPERIENCIA ===")



    env=FNAFEnvironment()

    vision=Vision()



    counter=0



    os.makedirs(

        "data/vision_memory",

        exist_ok=True

    )



    while True:


        frame=vision.capture()



        path=(

            "data/vision_memory/"

            +

            str(counter)

            +

            ".png"

        )



        vision.save(

            frame,

            path

        )



        counter+=1



        print(

            "Captura:",

            counter

        )



        time.sleep(

            0.2

        )







def train():


    print()

    print("=== ENTRENAMIENTO ===")



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

            "Episodio",

            episode,

            "Reward",

            reward_total

        )









def play():


    print()

    print("=== MODO JUEGO ===")



    env=FNAFEnvironment()



    agent=Agent()


    agent.load()



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


            state=env.reset()







def calibrate():


    Calibration().run()







def dashboard():


    Dashboard().run()







def main():


    parser=argparse.ArgumentParser()



    parser.add_argument(

        "--mode",

        required=True

    )



    args=parser.parse_args()



    modes={


        "collect":collect,


        "train":train,


        "play":play,


        "dashboard":dashboard,


        "calibrate":calibrate


    }





    if args.mode in modes:


        modes[args.mode]()



    else:


        print(

            "Modo incorrecto"

        )







if __name__=="__main__":


    main()

'@ | Set-Content `
"$project\main.py" `
-Encoding UTF8







# ============================================================
# start.ps1
# ============================================================


@'
param(

[string]$mode="dashboard"

)



Write-Host ""

Write-Host "===================================" -ForegroundColor Cyan

Write-Host " RedNeuronal FNAF 1 "

Write-Host " Modo:" $mode

Write-Host "===================================" -ForegroundColor Cyan



if(!(Test-Path "venv\Scripts\python.exe")){


    Write-Host ""

    Write-Host "No existe entorno virtual." -ForegroundColor Red

    Write-Host "Ejecuta primero el instalador."

    exit

}





.\venv\Scripts\activate



python main.py --mode $mode

'@ | Set-Content `
"$project\start.ps1" `
-Encoding UTF8







# ============================================================
# Crear acceso rapido launcher.ps1
# ============================================================


@'
Write-Host ""

Write-Host "RedNeuronal FNAF 1"

Write-Host ""

Write-Host "1 - Dashboard"

Write-Host "2 - Calibrar"

Write-Host "3 - Recolectar"

Write-Host "4 - Entrenar"

Write-Host "5 - Jugar"

Write-Host ""



$option=Read-Host "Seleccion"



switch($option){


1 {.\start.ps1 dashboard}

2 {.\start.ps1 calibrate}

3 {.\start.ps1 collect}

4 {.\start.ps1 train}

5 {.\start.ps1 play}


}

'@ | Set-Content `
"$project\launcher.ps1" `
-Encoding UTF8






Write-Host ""

Write-Host "======================================" `
-ForegroundColor Green


Write-Host " Proyecto completo creado "

Write-Host ""

Write-Host "Ejecuta:"

Write-Host ""

Write-Host ".\launcher.ps1"

Write-Host ""

Write-Host "para iniciar la IA."

Write-Host "======================================" `
-ForegroundColor Green