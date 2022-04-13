----------------------var------------------------------------------
emergency_power_limit = 4500
power_text_length = 43
cont_text_length = 55
Server = "513DA8754E9C4B5255BE6CB5262F2077"
Name = "Main_PC"
screen_id = "E2751B9A40B9F1E8D769C79400FD5CD8"
----------------------get-hardware---------------------------------
local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
 
local InternetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]

local gpu = computer.getPCIDevices(findClass("GPUT1"))[1]
if not gpu then
 error("No GPU T1 found!")
end

local screen = computer.getPCIDevices(findClass("FINComputerScreen"))[1]
if not screen then
 local comp_b=""
 local comp = component.findComponent(findClass("Screen"))
 for i=1, #comp do
  if comp[i] == screen_id then
   comp_b = comp[i]
  end
 end
 screen = component.proxy(comp_b)
end
gpu:bindScreen(screen)
gpu:setSize(120,34)
w,h = gpu:getSize()
gpu:setSize(w,h)
gpu:setText(0,0,"Start Terminal......")
gpu:flush()
event.pull(10)
gpu:fill(0,0,w,h," ")
gpu:flush()

local switch = component.proxy(component.findComponent("Switch"))
local gen = component.proxy(component.findComponent("Generator"))
local akw = component.proxy(component.findComponent("AKW")) 
local storage = component.proxy(component.findComponent("Storage"))
local constructor = component.proxy(component.findComponent("Constructor"))
local fabricator = component.proxy(component.findComponent("Fabricator"))
local powerpole = component.proxy(component.findComponent("PowerPole"))
local panel = component.proxy(component.findComponent("Panel"))
local machine = component.proxy(component.findComponent("Machine"))
local fluid = component.proxy(component.findComponent("F_Storage"))
local bat = component.proxy(component.findComponent("Battery"))
local pole = component.proxy(component.findComponent("Pole"))
local maschine_stat = "Offline"
---------------------functions------------------------------------------
function bios()
 --print("Screen-ID: "..screen.id)
 for i=1, #switch do
  print("Switch_"..i.."-ID: "..switch[i].id)
  switch[i].isSwitchOn = false
 end
 for i=1, #gen do
  print("Bio_Generator_"..i.."-ID: "..gen[i].id)
 end
 for i=1, #storage do
  print("Storage_"..i.."-ID: "..storage[i].id)
 end
 for i=1, #constructor do
  print("Constructor_"..i.."-ID: "..constructor[i].id)
 end
 for i=1, #fabricator do
  print("Fabricator_"..i.."-ID: "..fabricator[i].id)
 end
 for i=1, #fabricator do
  print("Power_Powle_"..i.."-ID: "..powerpole[i].id)
 end
 for i=1, #akw do
  print("AKW_"..i.."-ID: "..akw[i].id)
 end
 for i=1, #panel do
  print("Panel_"..i.."-ID: "..panel[i].id)
 end
 for i=1, #machine do
  print("Machine_"..i.."-ID: "..machine[i].id)
 end 
 for i=1, #fluid do
  print("Fluid_Storage_"..i.."-ID: "..fluid[i].id)
 end
 for i=1, #bat do
  print("Battery_"..i.."-ID: "..bat[i].id)
 end
 for i=1, #pole do
  print("Pole_"..i.."-ID: "..pole[i].id)
  pole[i]:setcolor(1,0,0,5)
 end 
 -- clean screen
 gpu:setBackground(0,0,0,0)
 gpu:setForeground(1,1,1,1)
 gpu:fill(0,0,w,h," ")
 --
 gpu:setSize(w/2,h/2)
 gpu:setForeground(1,1,0,1)
 gpu:setText(0,0, "caworks Modular Bios V.10")
 gpu:setForeground(1,1,1,1)
 gpu:setText(0,1, "2011 - 2013 caworks Software Inc")
 gpu:setText(0,2, "Processor caCore 2,4 GHZ x4")
 gpu:setText(0,3, "Memory Testing: ok  2096084K")
 gpu:setText(0,4, "----------------------------------------")
 gpu:setText(0,5, "IDE Channel 0: Master  CW34342525 500GB")
 gpu:setText(0,6, "IDE Channel 1: NONE")
 gpu:setText(0,14, "Press F12 for Bios Setup")
 gpu:flush()
 event.pull(5)
 gpu:fill(0,0,w,h," ")
 gpu:flush()
 test_network()
end

function bar(r, g, b, x, y, w, h, fill)
  fillLine = round((fill * h) / 100)
  for i=1, h do
   gpu:setText(x-1,y, "|")
   gpu:setText(x+w,y, "|")
   y = y - 1
  end
  y = y + h
  gpu:setForeground(r,g,b,1)
  for i=1, fillLine do
   for i=1, w do
    gpu:setText(x,y, "■")
    x = x + 1
   end
   x = x - w
   y = y - 1
  end
  gpu:setForeground(1,1,1,1)
end

function test_network()
 local req = InternetCard:request("https://httpbin.org/anything", "POST", "Network is ok.", "Content-Type", "text")
 local text_in = req:await()
 gpu:setForeground(1,1,0,1)
 gpu:setSize(w,h)
 gpu:setText(w/3,0, "Network test")
 gpu:setForeground(1,1,1,1)
 gpu:setText(w/3,1, text_in)
 gpu:flush()
 event.pull(3)
 gpu:fill(0,0,w,h," ")
 gpu:flush()
 main_prog()
end

function network_send(receiver, port, data)
 netcard = component.proxy(NetworkCard.id)
 netcard:open(port)
 netcard:send(receiver, port, data) print("Data Sent to: "..receiver..", on Port: "..port)
end

function get_max_power(n)
 connector = powerpole[n]:getPowerConnectors()[1]
 circuit = connector:getCircuit() 
 return circuit.capacity
end

function draw_frame(x,y,le,dire)
 for i=0, le do
  if dire == "right" then
   gpu:setText(x+i,y, "-")
  end
  if dire == "down" then
   gpu:setText(x,y+i, "|")
  end
 end
end

function round(x)
  return math.floor(x + 0.5)
end

function main_prog()
 event.pull(3)
 for i=1, #akw do
  akw[i].standby = false
 end
 for i=1, #gen do
  gen[i].standby = true
 end
 button = panel[1]:getModule(5,5)
 display = panel[1]:getModule(5,9)
 display.text = "Running..."
 display.size = 50
 for i=1, #machine do
  machine[i].standby = false
  maschine_stat = "Online"
 end
 for i=1, #switch do
  switch[i].isSwitchOn = false
 end
 for i=1, #pole do
  pole[i]:setcolor(0,1,0,5)
 end 
 while true do
  network_send(Server, 5256, Name)
  gpu:fill(0,0,w,h," ")
  gpu:flush()
  gpu:setForeground(1,1,1,1)
  gpu:setSize(w,h)
  gpu:setText(w/3,0, "caworks Control V1.0")
  power = 0
  if #powerpole > 0 then
   power = get_max_power(1)
  end
  if(power < emergency_power_limit) then
   gpu:setForeground(1,0,0,1)
   for i=1, #gen do
    gen[i].standby = false
   end 
   for i=1, #machine do
    machine[i].standby = true
    maschine_stat = "Offline"
   end
   for i=1, #switch do
    switch[i].isSwitchOn = false
   end 
  end
  if(power > emergency_power_limit) then
   gpu:setForeground(1,1,1,1)
   for i=1, #gen do
    gen[i].standby = true
   end
   for i=1, #switch do
    switch[i].isSwitchOn = true
   end
   for i=1, #machine do
    machine[i].standby = false
    maschine_stat = "Online"
   end  
  end
  gpu:setText(1,2, "Current Max Power. "..power.." MWh")
  gpu:setForeground(1,1,1,1)
  for i=1, #akw do
   cach = akw[i].standby
   out = "Offline"
   gpu:setForeground(1,0,0,1)
   if cach == false then
    out = "Online"
    gpu:setForeground(0,1,0,1)
   end
   gpu:setText(10,i+3, out)
   gpu:setForeground(1,1,1,1)
   gpu:setText(1,i+3, "AKW "..i.." is ")
  end
  lines = 0
  for i=1, #gen do
   cach = gen[i].standby
   out = "Offline"
   gpu:setForeground(1,0,0,1)
   if cach == false then
    out = "Online"
    gpu:setForeground(0,1,0,1)
   end
   gpu:setText((w/6)+16,i+3, out)
   gpu:setForeground(1,1,1,1)
   gpu:setText(w/6,i+3, "Generator "..i.." is ")
   lines = i
  end
  draw_frame(0,1,power_text_length,"right")
  draw_frame(0,2,lines+1,"down")
  draw_frame(power_text_length,2,lines+1,"down")
  draw_frame(0,lines+4,power_text_length,"right")
  linesB = 0
  for i=1, #storage do
   inv = storage[i]:getInventories()[1]
   inv:sort()
   amount = inv.itemCount
   itemName = "Empty"
   max = 0
   if amount > 1 then
      max = inv:getStack(0).count * inv.size
      itemName = inv:getStack(0).item.type.name
   end
   gpu:setText(power_text_length+1,i+1, "Container_"..i)
   gpu:setText(power_text_length+14,i+1, itemName)
   if (max/2) > amount then
    gpu:setForeground(1,0,0,1)
   end
   if (max/2) < amount then
    gpu:setForeground(1,1,0,1)
   end
   if amount == max then
    gpu:setForeground(0,1,0,1)
   end
   if amount == 0 then
    gpu:setForeground(1,0,0,1)
   end
   gpu:setText(power_text_length+45,i+1, amount.."/"..max)
   gpu:setForeground(1,1,1,1)
   linesB = i
   network_send(Server, 8080, "Container_"..i.."|"..itemName.."|"..amount.."/"..max)
  end
  draw_frame(power_text_length+1,1,cont_text_length,"right")
  draw_frame(power_text_length,2,linesB-1,"down")
  draw_frame(power_text_length+cont_text_length+1,2,linesB-1,"down")
  draw_frame(power_text_length,linesB+2,cont_text_length+1,"right")
  num_machine = #machine
  gpu:setText(1,lines+5, "Machine found: "..num_machine)
  gpu:setText(1,lines+6, "Machine are ")
  if maschine_stat == "Offline" then
   gpu:setForeground(1,0,0,1)
  end
  if maschine_stat == "Online" then
   gpu:setForeground(0,1,0,1)
  end
  gpu:setText(13,lines+6, maschine_stat)
  gpu:setForeground(1,1,1,1)
  draw_frame(0,lines+4,2,"down")
  draw_frame(power_text_length,lines+4,2,"down")
  draw_frame(0,lines+7,power_text_length,"right")
  linesC = 0
  for i=1, #fluid do
   itemName = "Empty"
   isF = fluid[i].fluidContent
   maxF = fluid[i].maxFluidContent
   itemName = fluid[i]:getFluidType().name
   gpu:setText(1,lines+7+i, "Fluid_"..i)
   gpu:setText(9,lines+7+i, itemName)
   if (maxF/2) > isF then
    gpu:setForeground(1,0,0,1)
   end
   if (maxF/2) < isF then
    gpu:setForeground(1,1,0,1)
   end
   if isF == maxF then
    gpu:setForeground(0,1,0,1)
   end
   if isF == 0 then
    gpu:setForeground(1,0,0,1)
   end
   if isF > maxF then
    gpu:setForeground(1,1,1,1)
   end
   gpu:setText(33,lines+7+i, round(isF).."/"..round(maxF))
   gpu:setForeground(1,1,1,1)
   network_send(Server, 8080, "Fluid_"..i.."|"..itemName.."|"..round(isF).."/"..round(maxF))
   if itemName == "Schwefelsäure" and isF >= maxF then
    print("flush")
    fluid[i]:flush()
   end
   if itemName == "Aluoxid-Lösung" and isF >= maxF then
    print("flush")
    fluid[i]:flush()
   end   linesC = i
  end
  draw_frame(0,lines+8+linesC,power_text_length,"right")
  draw_frame(0,lines+7,linesC,"down")
  draw_frame(power_text_length,lines+7,linesC,"down")
  if #bat > 0 then
  maxCap = 0
  maxStored = 0
  for i=1, #bat do
   store = bat[i].powerStore
   cap = bat[i].powerCapacity
   storeMW = (store * cap) / 100
   maxCap = maxCap + cap
   maxStored = maxStored + storeMW
  end
  maxPre = (maxStored * 100) / maxCap
  bar(0, 1, 0, 115, 33, 4, 32, maxPre)
  gpu:setText(115, 0, round(maxPre).."%")
  gpu:setText(115, 1, round(maxCap).."MW")
  end
  gpu:flush()
  event.listen(button)
  e, s = event.pull(30)
  if s == button then
   display.text = "STOP!!!"
   for i=1, #machine do
    machine[i].standby = true
    maschine_stat = "Offline"
   end
   for i=1, #switch do
    switch[i].isSwitchOn = false
   end
   for i=1, #pole do
    pole[i]:setcolor(1,0,0,5)
   end   
   gpu:fill(0,0,w,h," ")
   gpu:flush()
   break
  end
 end
end
----------------------main-programm--------------------------------
bios()