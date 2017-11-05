--[[
Accesses a github repository and download the files into your computer.

From: http://www.computercraft.info/forums2/index.php?/topic/16360-downloading-files-off-github-and-how-to-use-a-repo/

Courtesy of "mrdawgza"

You need the HTTP API enabled for this to work!

To enable the HTTP API you need to head to the ComputerCraft Config in your 
Minecraft or modpack (computercraft.cfg). If you cannot find this, make sure 
you are in the right directory, and if still not; search for computercraft.cfg.
 Now when you try and open that file, Windows will ask what do you want to do, 
 click Search for Program to run with, and choose Notepad.
Once in; look for 

B:enableAPI_http=false 

and change the false to true.

get("startup","startup") --remember the quotation marks! (" ")
]]
local function get(repoFile,saveTo)
local download = http.get("https://raw.github.com/myName/repo/repoFile") --This will make 'download' hold the contents of the file.
if download then --checks if download returned true or false
   local handle = download.readAll() --Reads everything in download
   download.close() --remember to close the download!
   local file = fs.open(saveTo,"w") --opens the file defined in 'saveTo' with the permissions to write.
   file.write(handle) --writes all the stuff in handle to the file defined in 'saveTo'
   file.close() --remember to close the file!
  else --if returned false
   print("Unable to download the file "..repoFile)
   print("Make sure you have the HTTP API enabled or")
   print("an internet connection!")
  end --end the if
end --close the function