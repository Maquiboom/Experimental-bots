$project = Join-Path `
    (Get-Location).Path `
    "RedNeuronal-FNAF1"
$root = Get-Location

$project = Join-Path $root "RedNeuronal-FNAF1"

Write-Host ""

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host " RedNeuronal FNAF 1 Installer " -ForegroundColor Cyan
Write-Host " RedNeuronal FNAF 1 " -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

Write-Host ""



if(Test-Path $project){


    Write-Host "Proyecto existente encontrado." -ForegroundColor Yellow


    $oldModel = Join-Path `
        $project `
        "models\checkpoint.pt"
    $backup = Join-Path $root "FNAF_Backup"


    New-Item -ItemType Directory -Path $backup -Force | Out-Null

    if(Test-Path $oldModel){


        $backup = Join-Path `
            (Get-Location).Path `
            "FNAF_checkpoint_backup.pt"
    $filesToBackup = @(

        "models\model.pt",

        "models\checkpoint.pt",

        Copy-Item `
            $oldModel `
            $backup `
            -Force
        "config\calibration.json"

    )


        Write-Host "Checkpoint guardado:" -ForegroundColor Green

        Write-Host $backup
    foreach($file in $filesToBackup){

    }

        $source = Join-Path $project $file


    Remove-Item `
        $project `
        -Recurse `
        -Force

        if(Test-Path $source){


    Write-Host "Proyecto anterior eliminado." -ForegroundColor Green
            Copy-Item $source $backup -Force

}

            Write-Host "Backup:" $file -ForegroundColor Green

        }

    }


New-Item `
    -ItemType Directory `
    -Path $project `
    -Force | Out-Null

    Remove-Item $project -Recurse -Force


    Write-Host "Proyecto anterior eliminado." -ForegroundColor Green

}

$folders=@(

    "ai",

    "environment",

    "ui",

    "config",
New-Item -ItemType Directory -Path $project -Force | Out-Null

    "models",

    "logs",

    "data",

    "data\vision_memory"
$folders = @(

)
"ai",

"environment",

"dashboard",

"ui",

"config",

foreach($folder in $folders){
"models",

"logs",

    New-Item `
"data",

        -ItemType Directory `
"data\screenshots",

        -Path (Join-Path $project $folder) `
"data\templates",

        -Force | Out-Null
"data\templates\animatronics",

"data\templates\states"

)

}


foreach($folder in $folders){


    $path = Join-Path $project $folder

Write-Host ""

Write-Host "Estructura creada." -ForegroundColor Green
    New-Item -ItemType Directory -Path $path -Force | Out-Null

}





$requirements=@'
$requirements = @'
torch
torchvision
opencv-python
@@ -131,49 +127,45 @@ pillow
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





$initFiles=@(

    "ai\__init__.py",
$initFiles = @(

    "environment\__init__.py",
"ai\__init__.py",

    "ui\__init__.py",
"environment\__init__.py",

    "config\__init__.py"
"dashboard\__init__.py",

)
"ui\__init__.py",

"config\__init__.py"

)



foreach($file in $initFiles){


    New-Item `

        -ItemType File `

        -Path (Join-Path $project $file) `

        -Force | Out-Null

}
@@ -182,24 +174,21 @@ foreach($file in $initFiles){



$config=@'
import os

$config = @'
import os
import json
BASE_DIR=os.path.dirname(
BASE_DIR = os.path.dirname(
    os.path.dirname(
        os.path.abspath(__file__)
    )
)
MODEL_PATH=os.path.join(
MODEL_PATH = os.path.join(
    BASE_DIR,
@@ -211,107 +200,164 @@ MODEL_PATH=os.path.join(
SCREENSHOT_PATH=os.path.join(
LOG_PATH = os.path.join(
    BASE_DIR,
    "logs"
)
SCREENSHOT_PATH = os.path.join(
    BASE_DIR,
    "data",
    "vision_memory"
    "screenshots"
)
STATE_SIZE=56
TEMPLATE_PATH = os.path.join(
    BASE_DIR,
    "data",
    "templates"
)
ACTION_SIZE=14
CALIBRATION_PATH = os.path.join(
    BASE_DIR,
LEARNING_RATE=0.0005
    "config",
    "calibration.json"
GAMMA=0.95
)
MEMORY_SIZE=50000
STATE_SIZE = 64
BATCH_SIZE=64
ACTION_SIZE = 12
EPSILON_START=1.0
LEARNING_RATE = 0.0005
EPSILON_END=0.05
GAMMA = 0.95
EPSILON_DECAY=0.995
MEMORY_SIZE = 100000
TARGET_UPDATE=500
BATCH_SIZE = 64
IMAGE_SIZE=224
EPSILON_START = 1.0
'@
EPSILON_END = 0.05
EPSILON_DECAY = 0.995
Set-Content `
    -Path (Join-Path $project "config\config.py") `
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





Write-Host ""

Write-Host "Creando entorno virtual..." -ForegroundColor Cyan
$calibration = @'
{
}
'@



Set-Content `
    -Path (Join-Path $project "config\calibration.json") `
    -Value $calibration `
    -Encoding UTF8



$venv = Join-Path `
    $project `
    "venv"



Write-Host ""
Write-Host "Creando entorno virtual..." -ForegroundColor Cyan


python -m venv $venv

$venv = Join-Path $project "venv"



python -m venv $venv


$python = Join-Path `
    $venv `
    "Scripts\python.exe"


$python = Join-Path $venv "Scripts\python.exe"



if(!(Test-Path $python)){


    Write-Host "No se pudo crear Python virtual." -ForegroundColor Red
    Write-Host "Error creando entorno Python." -ForegroundColor Red

    exit

@@ -321,35 +367,32 @@ if(!(Test-Path $python)){



Write-Host ""

Write-Host "Instalando dependencias..." -ForegroundColor Cyan





& $python -m pip install --upgrade pip



& $python -m pip install -r (Join-Path $project "requirements.txt")


& $python -m pip install `

    -r (Join-Path $project "requirements.txt")





Write-Host ""
Write-Host "Base preparada correctamente." -ForegroundColor Green
Write-Host ""

Write-Host "Base del proyecto creada." -ForegroundColor Green
Write-Host "Proyecto creado en:" -ForegroundColor Cyan

$model=@'
import torch
Write-Host $project

$model = @'
import torch
import torch.nn as nn
@@ -367,28 +410,32 @@ class FNAFNetwork(nn.Module):
        super().__init__()
        self.layers=nn.Sequential(
        self.network = nn.Sequential(
            nn.Linear(
                STATE_SIZE,
                256
                512
            ),
            nn.ReLU(),
            nn.Linear(
                256,
                512,
                256
            ),
            nn.ReLU(),
@@ -401,6 +448,7 @@ class FNAFNetwork(nn.Module):
            ),
            nn.ReLU(),
@@ -413,6 +461,7 @@ class FNAFNetwork(nn.Module):
            )
        )
@@ -421,7 +470,7 @@ class FNAFNetwork(nn.Module):
    def forward(self,x):
        return self.layers(x)
        return self.network(x)
'@

@@ -438,57 +487,41 @@ Set-Content `



$visionNet=@'
$visionModel = @'
import torch
import torch.nn as nn
from config.config import IMAGE_SIZE
class VisionEncoder(nn.Module):
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
                3,
                32,
                5,
                3,
                stride=2
            ),
            nn.ReLU(),
@@ -499,80 +532,60 @@ class VisionNetwork(nn.Module):
                64,
                5,
                3,
                stride=2
            ),
            nn.ReLU()
        )
        self.pool=nn.AdaptiveAvgPool2d(
            (4,4)
        )
            nn.ReLU(),
        self.output=nn.Sequential(
            nn.Flatten(),
            nn.Conv2d(
                64,
            nn.Linear(
                128,
                64*4*4,
                3,
                128
                stride=2
            ),
            nn.ReLU(),
            nn.Linear(
                128,
                32
            )
            nn.ReLU()
        )
    def forward(self,x):
        x=self.features(x)
        x=self.pool(x)
        return torch.flatten(
            x,
        return self.output(x)
            1
        )
'@



Set-Content `
    -Path (Join-Path $project "ai\vision_net.py") `
    -Value $visionNet `
    -Path (Join-Path $project "ai\vision_model.py") `
    -Value $visionModel `
    -Encoding UTF8


@@ -581,7 +594,7 @@ Set-Content `



$memory=@'
$replay = @'
import random
from collections import deque
@@ -607,34 +620,39 @@ class ReplayMemory:
    def add(self,item):
    def add(self,experience):
        self.memory.append(
            item
            experience
        )
    def sample(self,size):
    def sample(self,batch):
        return random.sample(
            self.memory,
            size
            batch
        )
    def __len__(self):
@@ -643,14 +661,13 @@ class ReplayMemory:
            self.memory
        )
'@



Set-Content `
    -Path (Join-Path $project "ai\replay.py") `
    -Value $memory `
    -Value $replay `
    -Encoding UTF8


@@ -659,871 +676,2061 @@ Set-Content `



$agent=@'
$checkpoint = @'
import os
import random
import torch
import torch
import torch.nn as nn
import torch.optim as optim
def save_checkpoint(
    path,
from ai.model import FNAFNetwork
    agent
from ai.replay import ReplayMemory
):
from config.config import *
    os.makedirs(
        os.path.dirname(path),
        exist_ok=True
    )
class Agent:
    torch.save(
        {
    def __init__(self):
        "model":agent.model.state_dict(),
        "target":agent.target.state_dict(),
        self.device=torch.device(
        "optimizer":agent.optimizer.state_dict(),
            "cuda"
        "epsilon":agent.epsilon,
            if torch.cuda.is_available()
        "steps":agent.steps,
            else
        "episodes":agent.episodes,
            "cpu"
        "reward_history":agent.reward_history
        )
        },
        path
    )
        self.model=FNAFNetwork().to(
            self.device
        )
        self.target=FNAFNetwork().to(
            self.device
        )
def load_checkpoint(
    path,
    agent
        self.optimizer=optim.Adam(
):
            self.model.parameters(),
            lr=LEARNING_RATE
        )
    if not os.path.exists(path):
        return False
        self.loss_function=nn.MSELoss()
        self.memory=ReplayMemory(
            MEMORY_SIZE
        )
    data=torch.load(
        path,
        map_location=agent.device
        self.epsilon=EPSILON_START
    )
        self.steps=0
    agent.model.load_state_dict(
        data["model"]
        self.load()
    )
    agent.target.load_state_dict(
        data["target"]
    )
    def act(self,state,explore=True):
        if explore and random.random()<self.epsilon:
    agent.optimizer.load_state_dict(
        data["optimizer"]
            return random.randrange(
    )
                ACTION_SIZE
            )
    agent.epsilon=data.get(
        "epsilon",
        state=torch.tensor(
        1.0
            state,
    )
            dtype=torch.float32,
            device=self.device
        )
    agent.steps=data.get(
        "steps",
        0
        with torch.no_grad():
    )
            output=self.model(
                state
    agent.episodes=data.get(
            )
        "episodes",
        0
    )
        return torch.argmax(
            output
        ).item()
    agent.reward_history=data.get(
        "reward_history",
        []
    )
    def remember(
    return True
'@

        self,

        state,

        action,
Set-Content `
    -Path (Join-Path $project "ai\checkpoint.py") `
    -Value $checkpoint `
    -Encoding UTF8

        reward,

        next_state,

        done

    ):


        self.memory.add(

            (
$agent = @'
import random
                state,
                action,
import torch
                reward,
import torch.nn as nn
                next_state,
import torch.optim as optim
                done
            )
        )
from ai.model import FNAFNetwork
from ai.replay import ReplayMemory
from ai.checkpoint import save_checkpoint,load_checkpoint
from config.config import *
    def learn(self):
        if len(self.memory)<BATCH_SIZE:
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
        states=[]
        actions=[]
        rewards=[]
        next_states=[]
        dones=[]
    def get_objects(self):
        return self.objects
'@


        for item in batch:

Set-Content `
-Path (Join-Path $project "environment\vision_monitor.py") `
-Value $visionMonitor `
-Encoding UTF8

            s,a,r,n,d=item


            states.append(s)

            actions.append(a)

            rewards.append(r)

            next_states.append(n)

            dones.append(d)
Write-Host ""

Write-Host "Sistema de vision creado correctamente." -ForegroundColor Green


$actions = @'
ACTIONS=[
    "open_monitor",
        states=torch.tensor(
    "camera_1a",
            states,
    "camera_1b",
            dtype=torch.float32,
    "camera_2a",
            device=self.device
    "camera_2b",
        )
    "camera_3",
    "camera_4a",
    "camera_4b",
        next_states=torch.tensor(
    "left_light",
            next_states,
    "left_door",
            dtype=torch.float32,
    "right_light",
            device=self.device
    "right_door"
        )
]
        actions=torch.tensor(
            actions,
def get_action(index):
            dtype=torch.long,
            device=self.device
    if index < 0:
        )
        return None
        rewards=torch.tensor(
    if index >= len(ACTIONS):
            rewards,
        return None
            dtype=torch.float32,
            device=self.device
        )
    return ACTIONS[index]
'@



        dones=torch.tensor(
Set-Content `
-Path (Join-Path $project "environment\actions.py") `
-Value $actions `
-Encoding UTF8

            dones,

            dtype=torch.float32,

            device=self.device

        )



$controller = @'
import json
import os
import time
        current=self.model(
            states
import pyautogui
        ).gather(
            1,
            actions.unsqueeze(1)
from config.config import CALIBRATION_PATH
        ).squeeze()
        with torch.no_grad():
class Controller:
            future=self.target(
                next_states
    def __init__(self):
            ).max(
                1
        self.points={}
            )[0]
        self.load()
            expected=rewards+(
                GAMMA*
                future*
                (1-dones)
            )
    def load(self):
        if os.path.exists(
            CALIBRATION_PATH
        loss=self.loss_function(
        ):
            current,
            expected
        )
            with open(
                CALIBRATION_PATH,
                "r"
            ) as file:
        self.optimizer.zero_grad()
                self.points=json.load(file)
        loss.backward()
        self.optimizer.step()
        self.steps+=1
    def click(self,name):
        if name not in self.points:
        self.epsilon=max(
            EPSILON_END,
            print(
            self.epsilon*EPSILON_DECAY
                "Accion sin calibrar:",
        )
                name
            )
        if self.steps % TARGET_UPDATE==0:
            return False
            self.target.load_state_dict(
                self.model.state_dict()
            )
        position=self.points[name]
        pyautogui.click(
            position["x"],
            position["y"]
        )
        time.sleep(
            0.15
        )
    def save(self):
        torch.save(
        return True
            {
            "model":self.model.state_dict(),
            "target":self.target.state_dict(),
            "optimizer":self.optimizer.state_dict(),
            "epsilon":self.epsilon,
            "steps":self.steps
    def execute(self,action):
            },
        return self.click(
            MODEL_PATH
            action
        )
'@



Set-Content `
-Path (Join-Path $project "environment\controller.py") `
-Value $controller `
-Encoding UTF8



    def load(self):


        if not os.path.exists(

            MODEL_PATH

        ):
$calibration = @'
import tkinter as tk
            self.target.load_state_dict(
import json
                self.model.state_dict()
import os
            )
            return
from config.config import CALIBRATION_PATH
        checkpoint=torch.load(
            MODEL_PATH,
            map_location=self.device
ACTIONS=[
        )
"open_monitor",
"camera_1a",
        self.model.load_state_dict(
"camera_1b",
            checkpoint["model"]
"camera_2a",
        )
"camera_2b",
"camera_3",
"camera_4a",
        self.target.load_state_dict(
"camera_4b",
            checkpoint["target"]
"left_light",
        )
"left_door",
"right_light",
"right_door"
        self.optimizer.load_state_dict(
]
            checkpoint["optimizer"]
        )
        self.epsilon=checkpoint.get(
            "epsilon",
            EPSILON_START
class Calibration:
        )
    def __init__(self):
        self.steps=checkpoint.get(
            "steps",
        self.data={}
            0
        )
'@
    def select(self,name):
Set-Content `
    -Path (Join-Path $project "ai\agent.py") `
    -Value $agent `
    -Encoding UTF8
        print(
            "Selecciona:",
            name
        )
Write-Host ""
Write-Host "IA creada correctamente." -ForegroundColor Green
$actions=@'
ACTIONS=[
        root=tk.Tk()
    "open_monitor",
    "close_monitor",
    "camera_left",
        root.attributes(
    "camera_right",
            "-fullscreen",
    "camera_cycle",
            True
    "left_light",
        )
    "left_door",
    "right_light",
    "right_door",
        result=[]
    "wait",
    "action_10",
    "action_11",
    "action_12",
    "action_13"
        def click(event):
]
            result.append(
                {
                "x":event.x,
                "y":event.y
def get_action(index):
                }
            )
    if index < 0:
        return None
            root.destroy()
    if index >= len(ACTIONS):
        return None
    return ACTIONS[index]
        root.bind(
'@
            "<Button-1>",
            click
        )
Set-Content `
    -Path (Join-Path $project "environment\actions.py") `
    -Value $actions `
    -Encoding UTF8
        root.mainloop()
        if result:
$vision=@'
import cv2
            self.data[name]=result[0]
import numpy as np
import pyautogui
import os
import time
from config.config import IMAGE_SIZE,SCREENSHOT_PATH
    def run(self):
        for action in ACTIONS:
            self.select(action)
class Vision:
    def __init__(self):
        os.makedirs(
            os.path.dirname(
        self.size=(
                CALIBRATION_PATH
            IMAGE_SIZE,
            ),
            IMAGE_SIZE
            exist_ok=True
        )
        with open(
            CALIBRATION_PATH,
    def capture(self):
            "w"
        ) as file:
        screenshot=pyautogui.screenshot()
            json.dump(
                self.data,
        frame=np.array(
                file,
            screenshot
                indent=4
            )
        print(
            "Calibracion guardada"
        )
'@



        frame=cv2.cvtColor(
Set-Content `
-Path (Join-Path $project "environment\calibration.py") `
-Value $calibration `
-Encoding UTF8

            frame,

            cv2.COLOR_RGB2BGR

        )



        return frame

$reward = @'
class RewardSystem:
    def __init__(self):
    def process(self,frame):
        self.previous={}
        frame=cv2.resize(
            frame,
            self.size
        )
    def calculate(self,state):
        frame=cv2.cvtColor(
        reward=0
            frame,
            cv2.COLOR_BGR2RGB
        )
        frame=frame.astype(
        if state[0]>0:
            np.float32
        )/255.0
            reward+=0.05
        frame=np.transpose(
            frame,
            (
                2,
        if state[1]>0:
                0,
                1
            reward+=0.05
            )
        )
        return frame
        if state[2]>0:
            reward+=0.15
    def save(self,frame):
        os.makedirs(
            SCREENSHOT_PATH,
        if state[3]>0:
            exist_ok=True
        )
            reward+=0.05
        filename=os.path.join(
            SCREENSHOT_PATH,
            str(
                int(time.time()*1000)
        if state[12]>0:
            )+".png"
        )
            reward-=100
        cv2.imwrite(
            filename,
            frame
        )
        if state[13]>0:
'@
            reward+=200
Set-Content `
    -Path (Join-Path $project "environment\vision.py") `
    -Value $vision `
    -Encoding UTF8
        return reward
'@



$controller=@'
import json
Set-Content `
-Path (Join-Path $project "environment\rewards.py") `
-Value $reward `
-Encoding UTF8

import os

import time

import pyautogui




$env = @'
import time
class Controller:
from environment.vision import Vision
    def __init__(self):
from environment.template_manager import TemplateManager
from environment.detector import Detector
        self.path="config/calibration.json"
from environment.state import GameState
from environment.controller import Controller
        self.points={}
from environment.actions import get_action
from environment.rewards import RewardSystem
        self.load()
from config.config import TEMPLATE_PATH
    def load(self):
        if os.path.exists(
class FNAFEnvironment:
            self.path
        ):
    def __init__(self):
            with open(
                self.path,
        self.vision=Vision()
                "r"
            ) as file:
        self.templates=TemplateManager(
                self.points=json.load(
            TEMPLATE_PATH
                    file
        )
                )
        self.detector=Detector(
            self.templates
        )
    def click(self,name):
        self.state_builder=GameState()
        if name not in self.points:
        self.controller=Controller()
            print(
                "Sin calibrar:",
                name
        self.reward=RewardSystem()
            )
            return
    def reset(self):
        position=self.points[name]
        frame=self.vision.capture()
        pyautogui.click(
            position["x"],
        detections=self.detector.detect(
            position["y"]
            frame
        )
        time.sleep(
        return self.state_builder.build(
            0.15
            detections
        )
@@ -1534,465 +2741,473 @@ class Controller:
    def execute(self,action):
    def step(self,action_id):
        if action:
        action=get_action(
            action_id
            self.click(
        )
                action
            )
'@
        self.controller.execute(
            action
        )
Set-Content `
    -Path (Join-Path $project "environment\controller.py") `
    -Value $controller `
    -Encoding UTF8
        time.sleep(
            0.15
        )
$calibration=@'
import tkinter as tk
        frame=self.vision.capture()
import json
import os
        detections=self.detector.detect(
            frame
        )
BUTTONS=[
"open_monitor",
        next_state=self.state_builder.build(
"close_monitor",
            detections
"camera_left",
        )
"camera_right",
"camera_cycle",
"left_light",
        reward=self.reward.calculate(
"left_door",
            next_state
"right_light",
        )
"right_door"
]
        done=False
        if next_state[12]>0:
class Calibration:
            done=True
    def __init__(self):
        self.data={}
        if next_state[13]>0:
            done=True
    def select(self,name):
        print(
        return (
            next_state,
            "Pulsa sobre:",
            reward,
            name
            done
        )
'@



        root=tk.Tk()
Set-Content `
-Path (Join-Path $project "environment\env.py") `
-Value $env `
-Encoding UTF8


        root.attributes(

            "-fullscreen",

            True

        )


Write-Host ""

        result=[]
Write-Host "Entorno FNAF creado correctamente." -ForegroundColor Green


$networkView = @'
import math
import random
        def click(event):
from PyQt6.QtWidgets import QWidget
from PyQt6.QtGui import (
            result.append(
    QPainter,
                {
    QColor,
                "x":event.x,
    QPen
                "y":event.y
)
                }
from PyQt6.QtCore import QTimer
            )
            root.destroy()
class NetworkView(QWidget):
    def __init__(self):
        root.bind(
        super().__init__()
            "<Button-1>",
            click
        )
        self.layers=[
            64,
        root.mainloop()
            512,
            256,
            128,
        if result:
            12
        ]
            self.data[name]=result[0]
        self.activations=[]
        self.phase=0
        self.resize(
    def run(self):
            1000,
            500
        for button in BUTTONS:
        )
            self.select(
                button
        self.timer=QTimer()
            )
        self.timer.timeout.connect(
        os.makedirs(
            self.update_animation
            "config",
        )
            exist_ok=True
        )
        self.timer.start(
            40
        with open(
        )
            "config/calibration.json",
            "w"
        ) as file:
            json.dump(
                self.data,
                file,
    def set_values(self,values):
                indent=4
            )
        self.activations=values
'@
        self.update()
Set-Content `
    -Path (Join-Path $project "environment\calibration.py") `
    -Value $calibration `
    -Encoding UTF8
    def update_animation(self):
$state=@'
import numpy as np
        self.phase+=0.05
        self.update()
class GameState:
    def build(self,features):
    def paintEvent(self,event):
        state=np.zeros(
            56,
        painter=QPainter(
            dtype=np.float32
            self
        )
        size=min(
            len(features),
        painter.setRenderHint(
            56
            QPainter.RenderHint.Antialiasing
        )
        state[:size]=features[:size]
        return state
'@
        positions=[]
Set-Content `
    -Path (Join-Path $project "environment\state.py") `
    -Value $state `
    -Encoding UTF8
        spacing=self.width()/(len(self.layers)+1)
        for index,size in enumerate(self.layers):
$environment=@'
import time
import torch
            nodes=[]
from environment.vision import Vision
            visible=min(
from environment.controller import Controller
                size,
from environment.actions import get_action
                20
from environment.state import GameState
            )
from ai.vision_net import VisionNetwork
            for n in range(visible):
                x=(index+1)*spacing
                y=40+(n*22)
class FNAFEnvironment:
                nodes.append(
    def __init__(self):
                    (
                    x,
        self.vision=Vision()
                    y
                    )
        self.controller=Controller()
                )
        self.state=GameState()
            positions.append(nodes)
        self.network=VisionNetwork()
        self.network.eval()
        painter.setPen(
            QPen(
                QColor(
                    80,
                    80,
    def reset(self):
                    80
                ),
        frame=self.vision.capture()
                1
            )
        )
        return self.make_state(
            frame
        )
        for current,next_layer in zip(
            positions[:-1],
            positions[1:]
        ):
    def make_state(self,frame):
            for x1,y1 in current:
        image=self.vision.process(
                for x2,y2 in next_layer:
            frame
        )
                    intensity=int(
                        (
                        math.sin(
        tensor=torch.tensor(
                            self.phase+x1
            image
                        )
        ).unsqueeze(0)
                        +1
                        )
                        *
                        70
                    )
        with torch.no_grad():
            output=self.network(
                    painter.setPen(
                tensor
                        QColor(
            )
                            40,
                            40+intensity,
                            120+intensity
        return self.state.build(
                        )
            output.numpy()[0]
                    )
        )
                    painter.drawLine(
                        int(x1),
                        int(y1),
                        int(x2),
                        int(y2)
                    )
    def step(self,action):
        command=get_action(
            action
        )
        self.controller.execute(
        for layer in positions:
            command
        )
            for x,y in layer:
                value=random.random()
        time.sleep(
            0.15
        )
                color=int(
                    80+
                    value*
        frame=self.vision.capture()
                    170
                )
        next_state=self.make_state(
            frame
                painter.setBrush(
        )
                    QColor(
                        color,
                        120,
        reward=0.1
                        255
                    )
        done=False
                )
        return (
                painter.drawEllipse(
            next_state,
                    int(x-7),
            reward,
                    int(y-7),
            done
                    14,
        )
                    14
                )
'@



Set-Content `
    -Path (Join-Path $project "environment\env.py") `
    -Value $environment `
    -Encoding UTF8
-Path (Join-Path $project "dashboard\network_view.py") `
-Value $networkView `
-Encoding UTF8





Write-Host ""

Write-Host "Entorno FNAF creado correctamente." -ForegroundColor Green

$graphs=@'
$graphs = @'
from PyQt6.QtWidgets import QWidget,QVBoxLayout
import pyqtgraph as pg
@@ -2001,828 +3216,756 @@ import pyqtgraph as pg
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
class RewardGraph(QWidget):
        )
        self.values=[]
    def __init__(self):
        self.setLayout(
        super().__init__()
            layout
        )
        layout=QVBoxLayout()
        self.plot=pg.PlotWidget()
    def update_value(self,value):
        self.values.append(
        self.plot.setTitle(
            value
            "Reward"
        )
        self.graph.clear()
        layout.addWidget(
        self.graph.plot(
            self.plot
            self.values,
        )
            pen=pg.mkPen(
                "green",
                width=3
        self.values=[]
            )
        )
'@
        self.setLayout(
            layout
        )
Set-Content `
    -Path (Join-Path $project "ui\graphs.py") `
    -Value $graphs `
    -Encoding UTF8
    def add_reward(self,value):
$network=@'
import math
from PyQt6.QtWidgets import QWidget
        self.values.append(
from PyQt6.QtGui import QPainter,QColor,QPen
            value
from PyQt6.QtCore import QTimer
        )
        self.plot.clear()
class NetworkView(QWidget):
        self.plot.plot(
    def __init__(self):
            self.values,
        super().__init__()
            pen="cyan"
        )
'@

        self.layers=[56,256,256,128,14]


        self.time=0
Set-Content `
-Path (Join-Path $project "dashboard\graphs.py") `
-Value $graphs `
-Encoding UTF8



        self.resize(

            900,

            450

        )

$monitor = @'
from PyQt6.QtCore import QObject,pyqtSignal
        self.timer=QTimer()
        self.timer.timeout.connect(
            self.animate
class TrainingMonitor(QObject):
        )
    reward_changed=pyqtSignal(float)
        self.timer.start(
            40
    status_changed=pyqtSignal(str)
        )
    def update_reward(self,value):
        self.reward_changed.emit(
            value
    def animate(self):
        )
        self.time+=0.15
        self.update()
    def update_status(self,text):
        self.status_changed.emit(
            text
        )
'@


    def paintEvent(self,event):

Set-Content `
-Path (Join-Path $project "dashboard\monitor.py") `
-Value $monitor `
-Encoding UTF8

        painter=QPainter(

            self

        )


        painter.setRenderHint(

            QPainter.RenderHint.Antialiasing

        )
$dashboard = @'
import sys
        spacing=self.width()/(len(self.layers)+1)
from PyQt6.QtWidgets import (
    QApplication,
    QWidget,
        nodes=[]
    QVBoxLayout,
    QLabel
)
        for layer,size in enumerate(self.layers):
            layer_nodes=[]
from dashboard.network_view import NetworkView
from dashboard.graphs import RewardGraph
            amount=min(
                size,
                18
            )
            for index in range(amount):
class Dashboard(QWidget):
                x=(layer+1)*spacing
    def __init__(self):
                y=40+(index*20)
        super().__init__()
                layer_nodes.append(
                    (
        self.setWindowTitle(
                    x,
            "RedNeuronal FNAF 1 - Brain"
                    y
        )
                    )
                )
        self.resize(
            1200,
            nodes.append(
            900
                layer_nodes
        )
            )
        layout=QVBoxLayout()
        painter.setPen(
            QPen(
                QColor(
        self.status=QLabel(
                    90,
            "Esperando IA..."
                    90,
        )
                    90
                ),
                1
        self.network=NetworkView()
            )
        )
        self.graph=RewardGraph()
        for current,next_layer in zip(
            nodes[:-1],
        layout.addWidget(
            nodes[1:]
            self.status
        ):
        )
            for x1,y1 in current:
        layout.addWidget(
                for x2,y2 in next_layer:
            self.network
        )
                    painter.drawLine(
                        int(x1),
                        int(y1),
        layout.addWidget(
                        int(x2),
            self.graph
                        int(y2)
        )
                    )
        self.setLayout(
            layout
        )
        for layer in nodes:
            for x,y in layer:
                pulse=(
                    math.sin(
    def set_status(self,text):
                        self.time+x
                    )
        self.status.setText(
                    +
            text
                    1
        )
                )*80
                painter.setBrush(
                    QColor(
                        40,
                        120+int(pulse),
    def run(self):
                        255
                    )
        app=QApplication(
                )
            sys.argv
        )
                painter.drawEllipse(
                    int(x-6),
        self.show()
                    int(y-6),
                    12,
                    12
        sys.exit(
                )
            app.exec()
        )
'@



Set-Content `
    -Path (Join-Path $project "ui\network_view.py") `
    -Value $network `
    -Encoding UTF8


-Path (Join-Path $project "dashboard\dashboard.py") `
-Value $dashboard `
-Encoding UTF8





$dashboard=@'
import sys


from PyQt6.QtWidgets import QApplication,QWidget,QVBoxLayout,QLabel
Write-Host ""

Write-Host "Dashboard neuronal creado correctamente." -ForegroundColor Green


from ui.network_view import NetworkView
$main = @'
import argparse
from ui.graphs import Graphs
import threading
import time
from ai.agent import Agent
class Dashboard(QWidget):
from ai.trainer import Trainer
    def __init__(self):
from environment.env import FNAFEnvironment
        super().__init__()
from environment.calibration import Calibration
        self.setWindowTitle(
from dashboard.dashboard import Dashboard
            "RedNeuronal FNAF 1"
        )
        self.resize(
            1100,
def train():
            750
        )
    print(
        "Iniciando entrenamiento..."
    )
        layout=QVBoxLayout()
    env=FNAFEnvironment()
        self.status=QLabel(
            "Neural Network Online"
        )
    agent=Agent()
        self.network=NetworkView()
    trainer=Trainer(
        agent,
        env
        self.graph=Graphs()
    )
        layout.addWidget(
    trainer.run()
            self.status
        )
        layout.addWidget(
            self.network
        )
def play():
        layout.addWidget(
            self.graph
    print(
        )
        "Modo jugador IA"
    )
        self.setLayout(
            layout
    env=FNAFEnvironment()
        )
    agent=Agent()
    state=env.reset()
    def run(self):
        app=QApplication(
            sys.argv
        )
    while True:
        self.show()
        action=agent.act(
        sys.exit(
            state,
            app.exec()
            False
        )
'@
        state,reward,done=env.step(
Set-Content `
    -Path (Join-Path $project "ui\dashboard.py") `
    -Value $dashboard `
    -Encoding UTF8
            action
        )
        if done:
            print(
$main=@'
import argparse
                "Partida terminada"
import time
            )
            time.sleep(2)
from ai.agent import Agent
from environment.env import FNAFEnvironment
from environment.calibration import Calibration
            state=env.reset()
from ui.dashboard import Dashboard
def calibrate():
    Calibration().run()
def dashboard():
    Dashboard().run()
def collect():
    env=FNAFEnvironment()
def train_with_dashboard():
    while True:
    env=FNAFEnvironment()
        frame=env.vision.capture()
    agent=Agent()
        env.vision.save(
            frame
        )
    trainer=Trainer(
        agent,
        time.sleep(
        env
            0.5
    )
        )
    thread=threading.Thread(
        target=trainer.run
    )
def train():
    thread.daemon=True
    env=FNAFEnvironment()
    thread.start()
    agent=Agent()
    Dashboard().run()
    episode=0
    while True:
        episode+=1
def main():
        state=env.reset()
        done=False
    parser=argparse.ArgumentParser()
        reward_total=0
    parser.add_argument(
        "--mode",
        required=True
    )
        while not done:
            action=agent.act(
    args=parser.parse_args()
                state
            )
            next_state,reward,done=env.step(
    if args.mode=="train":
                action
            )
        train()
            agent.remember(
                state,
                action,
    elif args.mode=="train_dashboard":
                reward,
                next_state,
        train_with_dashboard()
                done
            )
            agent.learn()
    elif args.mode=="play":
        play()
            state=next_state
            reward_total+=reward
    elif args.mode=="calibrate":
        agent.save()
        calibrate()
        print(
            "Episode:",
            episode,
    elif args.mode=="dashboard":
            "Reward:",
            reward_total
        dashboard()
        )
if __name__=="__main__":
    main()
'@

def play():


    env=FNAFEnvironment()
Set-Content `
-Path (Join-Path $project "main.py") `
-Value $main `
-Encoding UTF8


    agent=Agent()



    while True:


        state=env.reset()
$launcher = @'
$python="venv\Scripts\python.exe"
        done=False
Write-Host ""
Write-Host "=============================="
        while not done:
Write-Host " RedNeuronal FNAF 1 "
Write-Host "=============================="
            action=agent.act(
Write-Host ""
                state,
                False
            )
Write-Host "1 - Dashboard"
Write-Host "2 - Calibrar"
            state,_,done=env.step(
Write-Host "3 - Entrenar"
                action
Write-Host "4 - Entrenar + Dashboard"
            )
Write-Host "5 - Jugar"
Write-Host ""
$option=Read-Host "Selecciona"
parser=argparse.ArgumentParser()
parser.add_argument(
    "--mode"
switch($option){
)
args=parser.parse_args()
1 {
& $python main.py --mode dashboard
if args.mode=="dashboard":
    dashboard()
}
elif args.mode=="calibrate":
    calibrate()
2 {
elif args.mode=="collect":
& $python main.py --mode calibrate
    collect()
}
elif args.mode=="train":
    train()
3 {
elif args.mode=="play":
    play()
& $python main.py --mode train
'@
}
Set-Content `
    -Path (Join-Path $project "main.py") `
    -Value $main `
    -Encoding UTF8
4 {
& $python main.py --mode train_dashboard
}
$start=@'
param(
[string]$mode="dashboard"
5 {
)
& $python main.py --mode play
$python="venv\Scripts\python.exe"
}
& $python main.py --mode $mode
}
'@



Set-Content `
    -Path (Join-Path $project "start.ps1") `
    -Value $start `
    -Encoding UTF8
-Path (Join-Path $project "launcher.ps1") `
-Value $launcher `
-Encoding UTF8







$launcher=@'
$start = @'
Write-Host ""
Write-Host "================================"
Write-Host " RedNeuronal FNAF 1 "
Write-Host "================================"
Write-Host "RedNeuronal FNAF 1"
Write-Host ""
Write-Host "1 - Dashboard"
Write-Host "2 - Calibrar"
Write-Host "3 - Capturar datos"
Write-Host "4 - Entrenar IA"
powershell -ExecutionPolicy Bypass -File launcher.ps1
'@

Write-Host "5 - Jugar"

Write-Host ""

Set-Content `
-Path (Join-Path $project "start.ps1") `
-Value $start `
-Encoding UTF8


$option=Read-Host "Selecciona"



switch($option){


1 {.\start.ps1 dashboard}
$gitignore = @'
venv/
2 {.\start.ps1 calibrate}
__pycache__/
3 {.\start.ps1 collect}
*.pyc
4 {.\start.ps1 train}
logs/
5 {.\start.ps1 play}
data/screenshots/
}
'@



Set-Content `
    -Path (Join-Path $project "launcher.ps1") `
    -Value $launcher `
    -Encoding UTF8
-Path (Join-Path $project ".gitignore") `
-Value $gitignore `
-Encoding UTF8



@@ -2834,14 +3977,16 @@ Write-Host ""

Write-Host "====================================" -ForegroundColor Green

Write-Host " RedNeuronal FNAF 1 instalado "
Write-Host " RedNeuronal FNAF 1 FINALIZADA "

Write-Host "====================================" -ForegroundColor Green

Write-Host ""

Write-Host "Ejecuta:" -ForegroundColor Cyan
Write-Host "Ruta del proyecto:"

Write-Host "cd $project"
Write-Host $project

Write-Host ""

Write-Host ".\launcher.ps1"
Write-Host "Ejecuta launcher.ps1 para comenzar."
Footer
© 2026 GitHub, Inc.
Footer navigation

    Terms
    Privacy
    Security
    Status
    Community
    Docs
    Contact

 
