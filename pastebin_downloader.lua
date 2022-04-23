disk_uuid = "DC93234B436C8F1B60B66BA15AEE8880"
fileName = '/startup.lua'
url_1 = "https://pastebin.com/raw/emWZhPay" --Server
url_2 = "https://pastebin.com/raw/9qwbe7rC" --Main_pc
url_3 = "https://pastebin.com/raw/QZgWRrSV" --Terminal
 
--------------------------------------no_changes-------------------------------------
local InternetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
local req = InternetCard:request(url_1, "GET", "")
local _, libdata = req:await()
fs = filesystem
if fs.initFileSystem("/dev") == false then
 computer.panic("Cannot initialize /dev")
end
drives = fs.childs("/dev")
for idx, drive in pairs(drives) do
 if drive == "serial" then 
  table.remove(drives, idx) 
 end
end
for i = 1, #drives do
 print(drives[i])
end
fs = filesystem
fs.initFileSystem("/dev")
fs.mount("/dev/"..disk_uuid, "/")
local file = fs.open("/"..fileName.."", "w")
file:write(libdata)
file:close()
fs.mount("/dev/"..disk_uuid, "/")
fs.doFile(fileName)