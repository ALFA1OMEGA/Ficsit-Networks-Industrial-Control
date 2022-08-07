---------------------var---------------------------------------------
port_register = 5256
port_data = 8080
port_req = 8081
screen_id = "BE69C4D44606577BC3D57292903CFE77"
disk = "840440164E4A30C928FA46BE79FD3B86"
file = "backup.db"
local server_name = {}
local server_ip = {}
local server_ping = {}
local ping_c = 0
local server_data_ip = {}
local server_data_typ = {}
local server_data_item = {}
local server_data_amount = {}
---------------------get-hardware----------------------------------------
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
 end screen = component.proxy(comp_b)
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
---------------------set_network----------------------------------------
local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
netcard = component.proxy(NetworkCard.id)
netcard:open(port_register)
netcard:open(port_data)
---------------------function--------------------------------------------
function network_send(receiver, port_s, data)
 netcard = component.proxy(NetworkCard.id)
 netcard:open(port_s)
 netcard:send(receiver, port_s, data)
end

function search_drives()
 fs = filesystem
 fs.initFileSystem("/dev")
 drive_list = {}
 for _, drive in pairs(fs.childs("/dev")) do
  if drive ~= "serial" then
   table.insert(drive_list,drive)
  end
 end
 return drive_list
end

function write_file(disk_uuid, FileName, Contents)
 fs = filesystem
 fs.initFileSystem("/dev")
 fs.mount("/dev/"..disk_uuid, "/")
 local file = fs.open("/"..FileName.."", "a")
 file:write(Contents,"#")
 file:close()
end

function clear_file(disk_uuid, FileName)
 fs = filesystem
 fs.initFileSystem("/dev")
 fs.mount("/dev/"..disk_uuid, "/")
 local file = fs.open("/"..FileName.."", "w")
 file:write("")--,"\n")
 file:close()
end

function read_file(disk_uuid, FileName)
 fs = filesystem
 data = {}
 fs.initFileSystem("/dev")
 fs.mount("/dev/"..disk_uuid, "/")
 local file = fs.open("/"..FileName.."", "r")
 cach = ""
 cach = file:read(2048)
 if cach ~= nil then
  data = split(cach, "#")
 end
 file:close()
 return data
end

function update_file(disk_uuid,FileName, Contens, Seperator)
 data_update = {}
 data_r = read_file(disk, file)
 for i=1, #data_r do
  if data_r[i] ~= "" then
   cach_1 = split(data_r[i], Seperator)[2]
   cach_2 = split(Contens, Seperator)[2]
   if(cach_1 == cach_2) then
    table.insert(data_update, Contens);
   else
    table.insert(data_update, data_r[i]);
   end
  end
 end
 clear_file(disk,file)
 for i=1, #data_update do
  write_file(disk,file, data_update[i])
 end
end

function load_backup()
 print("Load data Please wait ...")
 lo_data = read_file(disk, file)
 for i=1, #lo_data do
  cach = split(lo_data[i],"|")
  ip = "00000000"
  typ = cach[1]
  item = cach[2]
  amount = cach[3]
  if item ~= nil then
  table.insert(server_data_ip,ip)
  table.insert(server_data_typ,typ)
  table.insert(server_data_item,item)
  table.insert(server_data_amount,amount) 
  end
 end
 print("Ready")
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

function screen_draw()
 gpu:fill(0,0,w,h," ")
 gpu:flush()
 gpu:setText(0,0,"Registed Server: "..#server_ip)
 gpu:setText(30,0,"Saved Data Lines: "..#server_data_ip)
 gpu:setText(0,1,"Name")
 gpu:setText(20,1,"|IP")
 gpu:setText(0,2,"--------------------")
 gpu:setText(20,2,"|----------------------------------")
 line = 2
 for i=1, #server_ip do
  gpu:setText(0,line+i,server_name[i])
  gpu:setText(20,line+i,"|"..server_ip[i])
 end
 line = 1
 gpu:setText(55,0,"Data:")
 for i=1, #server_data_ip do
  gpu:setText(55,line+i,server_data_ip[i].."|"..server_data_typ[i].."|"..server_data_item[i].."|"..server_data_amount[i])
 end
 gpu:flush()
end

function send_data()
 for i=1, #server_ip do
  if(server_name[i] ~= "Main_PC") then
   print("Send data to "..server_ip[i])
   for j=1, #server_data_typ do
    network_send(server_ip[i], port_req, server_data_typ[j].."|"..server_data_item[j].."|"..server_data_amount[j])
   end
  end
 end
end

function ping()
 server_name = {}
 server_ip = {}
 print("Ping")
end
---------------------main_prog---------------------------------------------
s_drives = search_drives()
for i=1, #s_drives do
 print("Drives: "..s_drives[i])
end
disk = s_drives[1]
print(disk)
--load_backup()
computer.beep(5)
clear_file(disk,file)
while true do
 event.listen(netcard)
 typ, to, ip, port, data = event.pull()
 if typ == "NetworkMessage" then
  if port == port_register then
   if in_table(server_ip,ip) == false then
    table.insert(server_name,data)
    table.insert(server_ip,ip)
    print("Registed Server: "..#server_ip)
    send_data()
   end
  end
  
  if port == port_data then
   cach = split(data,"|")
   t_pos = 0
   if in_table(server_data_item,cach[2]) == false then
    table.insert(server_data_ip,ip)
    table.insert(server_data_typ,cach[1])
    table.insert(server_data_item,cach[2])
    table.insert(server_data_amount,cach[3])
    write_file(disk,file, data)
   else
    t_pos = table_pos(server_data_item,cach[2])
    if(server_data_amount[t_pos] ~= cach[3]) then 
     --update amount for a item
     server_data_amount[t_pos]=cach[3]
     update_file(disk,file, data, "|")
    end
   end
  end
  if ping_c == 150 then
   ping()
   ping_c = 0
  end
  ping_c = ping_c + 1
 end
 screen_draw()
end  