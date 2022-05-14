----------------------var------------------------------------------
Name = "Storage_PC"
screen_id = "641B9F994DBF6D0CD7C95FA072E50089"
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
gpu:setSize(120,40)
w,h = gpu:getSize()
gpu:setSize(w,h)
gpu:fill(0,0,w,h," ")
gpu:flush()
gpu:setText(0,0,"Start Terminal......")
gpu:setText(0,1,"Please wait......")
gpu:flush()
event.pull(10)
gpu:fill(0,0,w,h," ")
gpu:flush()


local storage = component.proxy(component.findComponent("Storage"))
local fluid = component.proxy(component.findComponent("F_Storage"))

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
 while true do
  lines = 0
  linesB = 0
  gpu:fill(0,0,w,h," ")
  gpu:flush()
  gpu:setForeground(1,1,1,1)
  gpu:setSize(w,h)
  gpu:setText(w/3,0, "Storage Monitor V1.0")
  for i=1, #storage do
   lines = i
   inv = storage[i]:getInventories()[1]
   inv:sort()
   amount = inv.itemCount
   itemName = "Empty"
   max = 0
   if amount > 1 then
    max = inv:getStack(0).count * inv.size
    itemName = inv:getStack(0).item.type.name
   end
   gpu:setText(2,i+1, "Container_"..i)
   gpu:setText(16,i+1, itemName)
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
   gpu:setText(47,i+1, amount.."/"..max)
   gpu:setForeground(1,1,1,1)   
  end
  for i=1, #fluid do
   linesB = i
   itemName = "Empty"
   isF = fluid[i].fluidContent
   maxF = fluid[i].maxFluidContent
   if isF > 1 then
    itemName = fluid[i]:getFluidType().name
   end
   gpu:setText(70,i+1, "Fluid_"..i)
   gpu:setText(79,i+1, itemName)
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
    gpu:setForeground(0,1,0,1)
   end
   gpu:setText(103,i+1, round(isF).."/"..round(maxF))
   gpu:setForeground(1,1,1,1)
  end
  draw_frame(0,1,119,"right")
  draw_frame(0,2,lines-1,"down")
  draw_frame(119,2,lines-1,"down")
  draw_frame(65,2,lines-1,"down")
  draw_frame(66,linesB+2,52,"right")
  draw_frame(0,lines+2,119,"right")
  gpu:flush()
  event.pull(10)
 end
end
main_prog()