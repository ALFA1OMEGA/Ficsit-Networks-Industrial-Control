----------------------var------------------------------------------
Server = "A95659614E3764D6CA3A53948E6E9FFE"
Name = "Terminal_1"
data_typ = {}
data_name = {}
data_amount = {}
screen_id = "6E5FB6124199ADC8A83B54A17359CA2E"
line_per_page = 28
---------------------get-hardware----------------------------------
local page = 1
local max_page = 1
local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
local panel = component.proxy(component.findComponent("Panel"))

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
button_1 = panel[1]:getModule(0,0)
gpu:bindScreen(screen)
gpu:setSize(120,34)
w,h = gpu:getSize()
gpu:setSize(w,h)
gpu:setText(0,0,"Start Terminal......")
gpu:flush()
event.pull(10)
gpu:fill(0,0,w,h," ")
gpu:flush()
----------------------function-------------------------------------
function network_send(receiver, port_s, data)
 netcard = component.proxy(NetworkCard.id)
 netcard:open(port_s)
 netcard:open(8081)
 netcard:send(receiver, port_s, data) 
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function in_table(table, element)
 for _, value in pairs(table) do
  if value == element then
   return true
  end
 end
 return false
end

function table_pos(table,stri)
 local index={}
 for k,v in pairs(table) do
   index[v]=k
 end
 return index[stri]
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

function screen_draw()
 gpu:fill(0,0,w,h," ")
 gpu:flush()
 gpu:setText(40,0,Name.." Items: "..#data_name)
 line = 1
 screen_left = {}
 screen_right ={}
 screen_left_a = {}
 screen_right_a ={}
 line_a = 0
 for i=1,#data_typ do
  if string.find(data_typ[i],"Fluid") then
   table.insert(screen_left,data_typ[i].." "..data_name[i])
   table.insert(screen_left_a,data_amount[i])
  end
  if string.find(data_typ[i],"Container") then
   table.insert(screen_right,data_typ[i].." "..data_name[i])
   table.insert(screen_right_a,data_amount[i])
  end
 end
 for i=1,#screen_left do
  gpu:setText(1,line+i,screen_left[i])
  gpu:setText(35,line+i,screen_left_a[i])
 end
 line_start = 1
 line_end = line_per_page
 max_page = math.floor(#screen_right / line_per_page)
 if max_page < (#screen_right / line_per_page) then
  max_page = max_page + 1
 end
 if page > 1 then
  line_start = line_per_page * (page-1)
  line_end = line_per_page * page
 end
 if line_end > #screen_right then
  line_end = #screen_right
 end
 for i=line_start, line_end do
  text_line = i+line
  if page > 1 then
   text_line = (i-line_per_page)+line
  end
  gpu:setText(60,text_line,screen_right[i])
  gpu:setText(107,text_line,screen_right_a[i])
  line_a = i
 end
 draw_frame(0,1,line_a,"down")
 draw_frame(119,1,line_a,"down")
 draw_frame(58,1,line_a,"down")
 draw_frame(0,1,120,"right")
 draw_frame(0,line_a+2,120,"right")
 gpu:setText(80,0, "Page: "..page)
 gpu:flush()
end
---------------------register----------------------------------------
network_send(Server, 5256, Name)
---------------------send_data---------------------------------------
while true do
 event.listen(netcard,button_1)
 typ, to, ip, port, data = event.pull(10)
 if to == button_1 then
  page = page + 1
  if page > max_page then
   page = 1
  end
 end
 network_send(Server, 5256, Name)
 if(port == 8081) then
  cach = split(data,"|")
  if in_table(data_name,cach[2]) == false then
   table.insert(data_typ,cach[1])
   table.insert(data_name,cach[2])
   table.insert(data_amount,cach[3])
  else
   t_pos = table_pos(data_name,cach[2])
   if(data_amount[t_pos] ~= cach[3]) then 
    --update amount for a item
    data_amount[t_pos]=cach[3]
   end
  end
 end
 screen_draw()
end