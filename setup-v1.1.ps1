
$root = Join-Path (Get-Location) "MaquiBotV1"

function Log($m){ Write-Host "[INSTALLER] $m" }

Log "===================================="
Log " MAQUIBOT V1 INSTALLER"
Log "===================================="

# ================= CLEAN =================
if(Test-Path $root){
    Remove-Item $root -Recurse -Force
}

# ================= STRUCTURE =================
New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path "$root\web" | Out-Null

# ================= PACKAGE =================
@'
{
  "name": "maquibotv1",
  "version": "1.0.0",
  "main": "bot.js",
  "dependencies": {
    "mineflayer": "^4.20.0",
    "mineflayer-pathfinder": "^2.4.5",
    "express": "^4.19.2",
    "socket.io": "^4.7.5"
  }
}
'@ | Out-File "$root\package.json" -Encoding utf8

# ================= CONFIG =================
@'
{
  "host": "localhost",
  "port": 25565,
  "auth": "offline",
  "webPort": 3000,
  "username": "MaquiBotV1"
}
'@ | Out-File "$root\config.json" -Encoding utf8

# ================= BOT =================
@'
process.title = "MaquiBotV1"

const mineflayer = require("mineflayer")
const express = require("express")
const http = require("http")
const { Server } = require("socket.io")

const { pathfinder, Movements, goals } = require("mineflayer-pathfinder")
const { GoalBlock, GoalFollow } = goals

const config = require("./config.json")

const app = express()
const server = http.createServer(app)
const io = new Server(server)

app.use(express.static(__dirname + "/web"))
server.listen(config.webPort)

let bot
let queue = []
let working = false
let move

function log(type,msg){
    console.log(`[${type}] ${msg}`)
    io.emit("log",{type,msg})
}

// ================= TASK SYSTEM =================
function processQueue(){

if(!bot || !bot.entity) return
if(working) return
if(queue.length === 0) return

const task = queue.shift()
working = true

try{

if(task.type === "follow"){
    const player = bot.players[task.target]?.entity
    if(player){
        bot.pathfinder.setGoal(new GoalFollow(player, 2), true)
        log("system","Following " + task.target)
    }
}

if(task.type === "mine"){
    const b = bot.findBlock({ matching: () => true, maxDistance: 5 })
    if(b){
        bot.dig(b)
        log("system","Mining block")
    }
}

if(task.type === "goto"){
    const [x,y,z] = task.target.split(" ").map(Number)

    if(x && y && z){
        bot.pathfinder.setGoal(new GoalBlock(x,y,z))
        log("system",`Going to ${x} ${y} ${z}`)
    }
}

if(task.type === "combat"){
    const e = Object.values(bot.entities).find(e=>e.type==="mob")
    if(e){
        bot.attack(e)
        log("system","Attacking mob")
    }
}

}catch(e){
log("error",e.message)
}

setTimeout(()=> working=false,1200)
}

// ================= BOT =================
function createBot(){

log("system","Starting bot...")

bot = mineflayer.createBot(config)

bot.loadPlugin(pathfinder)

bot.once("spawn",()=>{
    move = new Movements(bot)
    bot.pathfinder.setMovements(move)

    log("system","Bot online ✔")
})

bot.on("chat",(u,m)=>{
    log("chat",`${u}: ${m}`)
})

bot.on("error",(e)=>{
    log("error",e.message)
})

bot.on("end",()=>{
    log("system","Reconnecting...")
    setTimeout(createBot,5000)
})

}

// ================= FIX 1: SOCKET QUEUE =================
io.on("connection",(socket)=>{
    socket.on("task",(data)=>{
        queue.push(data)
    })
})

createBot()

setInterval(()=>{

processQueue()

if(!bot || !bot.entity) return

io.emit("state",{
hp:bot.health,
x:bot.entity.position.x,
y:bot.entity.position.y,
z:bot.entity.position.z,
queue:queue.length
})

},500)
'@ | Out-File "$root\bot.js" -Encoding utf8


# ================= WEB =================
@'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MaquiBot V1</title>

<style>
body{
margin:0;
font-family:system-ui;
background:#0a0a0a;
color:white;
overflow:auto;
}

body::before{
content:"";
position:fixed;
inset:0;
background:
linear-gradient(rgba(255,255,255,.06) 1px,transparent 1px),
linear-gradient(90deg,rgba(255,255,255,.06) 1px,transparent 1px);
background-size:40px 40px;
opacity:.5;
animation:grid 18s linear infinite;
}

@keyframes grid{
0%{transform:translate(0,0)}
100%{transform:translate(40px,40px)}
}

.container{
position:relative;
z-index:2;
height:100vh;
display:grid;
grid-template-rows:90px 1fr 200px;
padding:15px;
gap:10px;
}

.stats{
display:flex;
justify-content:space-around;
background:rgba(255,255,255,.05);
padding:12px;
border-radius:14px;
font-weight:bold;
}

.main{
display:grid;
grid-template-columns:1fr 1fr;
gap:10px;
}

.card{
background:rgba(255,255,255,.05);
border-radius:14px;
padding:12px;
border:1px solid rgba(255,255,255,.1);
display:flex;
flex-direction:column;
gap:8px;
}

input{
padding:12px;
border-radius:12px;
border:1px solid rgba(255,255,255,.1);
background:rgba(0,0,0,.4);
color:white;
}

button{
padding:10px;
border:none;
border-radius:10px;
background:#1e1e1e;
color:white;
cursor:pointer;
}

button:hover{background:#333}

.guide{
background:rgba(255,255,255,.04);
border-radius:14px;
padding:12px;
font-size:13px;
line-height:1.4;
overflow:auto;
}
</style>
</head>

<body>

<div class="container">

<div class="stats">
<div>HP: <span id="hp">-</span></div>
<div>XYZ: <span id="xyz">-</span></div>
<div>QUEUE: <span id="q">0</span></div>
</div>

<div class="main">

<div class="card">
<input id="player" placeholder="player / coords">

<button onclick="send('follow')">Follow</button>
<button onclick="send('mine')">Mine</button>
<button onclick="send('goto')">Goto</button>
<button onclick="send('combat')">Combat</button>
</div>

<div class="card">
Sistema activo ✔
</div>

</div>

<div class="guide">

<h3>📘 MaquiBot V1 Guide</h3>

Follow → jugador<br>
Mine → bloque cercano<br>
Goto → x y z<br>
Combat → mobs<br>

</div>

</div>

<script src="/socket.io/socket.io.js"></script>
<script>
const s=io()

s.on("state",d=>{
hp.innerText=d.hp
xyz.innerText=`${d.x},${d.y},${d.z}`
q.innerText=d.queue
})

function send(t){
s.emit("task",{type:t,target:player.value})
}
</script>

</body>
</html>
'@ | Out-File "$root\web\index.html" -Encoding utf8

# ================= START.PS1 (FIXED) =================
@'
$root = $PSScriptRoot

function Menu($i){

Clear-Host
Write-Host "===== MAQUIBOT V1 MENU ====="

$items=@("Start Bot","Open Panel","Exit")

for($x=0;$x -lt $items.Count;$x++){
if($x -eq $i){Write-Host "> $($items[$x])" -ForegroundColor Cyan}
else{Write-Host "  $($items[$x])"}
}

$key=[Console]::ReadKey($true)

if($key.Key -eq "UpArrow"){ if($i -gt 0){$i--} }
if($key.Key -eq "DownArrow"){ if($i -lt 2){$i++} }

if($key.Key -eq "Enter"){
switch($i){
0 {
    Start-Process `
        "$root\nodejs\node.exe" `
        -WorkingDirectory $root `
        -ArgumentList "bot.js"
}
1 {Start-Process "http://localhost:3000"}
2 {exit}
}
Start-Sleep 1
}

Menu $i
}

Menu 0
'@ | Out-File "$root\start.ps1" -Encoding utf8

# ================= NODE PORTABLE =================
Log "Descargando Node.js Portable v22 x64..."

$nodeVersion = "v22.18.0"
$nodeZip = "$env:TEMP\node22.zip"
$nodeUrl = "https://nodejs.org/dist/$nodeVersion/node-$nodeVersion-win-x64.zip"

Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeZip

Expand-Archive -Path $nodeZip -DestinationPath $root -Force

Rename-Item `
    "$root\node-$nodeVersion-win-x64" `
    "$root\nodejs"

Remove-Item $nodeZip -Force

# ================= INSTALL =================
Log "Instalando dependencias..."
Push-Location $root
& "$root\nodejs\npm.cmd" install
Pop-Location

Log "===================================="
Log " INSTALL COMPLETE V1 FIXED"
Log " RUN cd ./MaquiBotV1 && ./start.ps1"
Log "===================================="
