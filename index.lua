local white = Color.new(255,255,255)
local yellow = Color.new(255,205,66)
local red = Color.new(255,0,0)
local green = Color.new(55,255,0)
local hourlyUrl = "http://astronautlevel2.github.io/Luma3DS/latest.zip"
local stableUrl = "http://astronautlevel2.github.io/Luma3DS/release.zip"
local hourlyDevUrl = "http://astronautlevel2.github.io/Luma3DSDev/latest.zip"
local stableDevUrl = "http://astronautlevel2.github.io/Luma3DSDev/release.zip"
local payload_path = "/arm9loaderhax.bin"
local zip_path = "/Luma3DS.zip"
local backup_path = payload_path..".bak"
local remoteVer = "http://astronautlevel2.github.io/Luma3DS/lastVer"
local remoteCommit = "http://astronautlevel2.github.io/Luma3DS/lastCommit"
local remoteDevCommit = "http://astronautlevel2.github.io/Luma3DSDev/lastCommit"
local latestCIA = "http://www.ataber.pw/u"
local latestHBX = "http://gs2012.xyz/3ds/starupdater/index.lua" -- I'll be hosting it for now, I suppose.
local curPos = 20
local isMenuhax = false
local isDev = false
local menuhaxmode, devmode = 1,2
local localVer = ""
local remoteVerNum = ""

local pad = Controls.read()
local oldpad = pad

--CIA/3DSX
local iscia = 1
local isofficial = 0

if isofficial == 0 then
	latestCIA = "http://gs2012.xyz/3ds/starupdater/latest.zep"
end

--Version Info
local sver = "1.4.0"
local lver = "???" --This is fetched from the server
local verserver = "http://gs2012.xyz/3ds/starupdater/version"
if Network.isWifiEnabled() then
	lver = Network.requestString(verserver)
end
function readConfig(fileName)
    if (isMenuhax) then
        payload_path = "/Luma3DS.dat"
        backup_path = payload_path..".bak"
        return
    end
    if (System.doesFileExist(fileName)) then
        local file = io.open(fileName, FREAD)
        payload_path = io.read(file, 0, io.size(file))
        payload_path = string.gsub(payload_path, "\n", "")
        payload_path = string.gsub(payload_path, "\r", "")
        backup_path = payload_path..".bak"
    elseif (not System.doesFileExist(fileName) and not isMenuhax) then
		if System.doesFileExist("/arm9loaderhax_si.bin") and (not System.doesFileExist("/arm9loaderhax.bin")) then
			payload_path = "/arm9loaderhax_si.bin"
		else
			payload_path = "/arm9loaderhax.bin"
		end
        backup_path = payload_path..".bak"
        return
    end
end

function restoreBackup()
    Screen.refresh()
    Screen.clear(TOP_SCREEN)
    Screen.waitVblankStart()
    Screen.flip()
    if System.doesFileExist(backup_path) then
        Screen.debugPrint(5,5, "Deleting new payload...", yellow, TOP_SCREEN)
        System.deleteFile(payload_path)
        Screen.debugPrint(5,20, "Renaming backup to "..payload_path.."...", yellow, TOP_SCREEN)
        System.renameFile(backup_path, payload_path)
        Screen.debugPrint(5,35, "Press START to go back to HBL/Home menu", green, TOP_SCREEN)
        while true do
            pad = Controls.read()
                if Controls.check(pad,KEY_START) then
                    Screen.waitVblankStart()
                    Screen.flip()
                    System.exit()
            end
        end
    else
        Screen.debugPrint(5,5, "Backup path: "..backup_path, yellow, TOP_SCREEN)
        Screen.debugPrint(5,20, "Press START to go back to HBL/Home menu", green, TOP_SCREEN)
        while true do
            pad = Controls.read()
            if Controls.check(pad,KEY_START) then
                Screen.waitVblankStart()
                Screen.flip()
                System.exit()
            end
        end
    end
end

function sleep(n)
  local timer = Timer.new()
  local t0 = Timer.getTime(timer)
  while Timer.getTime(timer) - t0 <= n do end
end

function getMode(mode)
    if mode == menuhaxmode then
        if (isMenuhax) then
            return "MenuHax"
        else
            return "Arm9LoaderHax"
        end
    else
        if (isDev) then
            return "Dev"
        else
            return "Regular"
        end
    end
end

function unicodify(str)
    local new_str = ""
    for i = 1, #str,1 do
        new_str = new_str..string.sub(str,i,i)..string.char(00)
    end
    return new_str
end

function getVer(path)
    if (path ~= "remote") then
      	local searchString = "Luma3DS "
      	local verString = ""
      	local isDone = false
        if (System.doesFileExist(path) == true) then
            local file = io.open(path, FREAD)
            local fileData = io.read(file, 0, io.size(file))
            io.close(file)
            local offset = string.find(fileData, searchString)
            if (offset ~= nil) then
                offset = offset + string.len(searchString)
                while(isDone == false)
                do
                    bitRead = fileData:sub(offset,offset)
                    if bitRead == " " then
                        isDone = true
                    else
                        verString = verString..bitRead
                    end
                    offset = offset + 1
                end
                return verString
            else
                return "Config error!"
            end
        else
            return "Config error!"
        end
    else
        if Network.isWifiEnabled() then
        	if (not isDev) then
            	return Network.requestString(remoteVer).."-"..Network.requestString(remoteCommit)
            else
            	return Network.requestString(remoteVer).."-"..Network.requestString(remoteDevCommit)
            end
        else
            return "No connection!"
        end
    end
end

function path_changer()
    local file = io.open(payload_path, FREAD)
    local a9lh_data = io.read(file, 0, io.size(file))
    io.close(file)
    local offset = string.find(a9lh_data, "%"..unicodify("arm9loaderhax.bin"))
    local new_path = unicodify(string.sub(payload_path,2,-1))
    if #new_path < 74 then
        for i = 1,74-#new_path,1 do
            new_path = new_path..string.char(00)
        end
        local file = io.open(payload_path, FWRITE)
        io.write(file, offset-1, new_path, 74)
        io.close(file)
    end
end

function update(site)
    Screen.refresh()
    Screen.clear(TOP_SCREEN)
    Screen.waitVblankStart()
    Screen.flip()
    if Network.isWifiEnabled() then
    	Screen.debugPrint(5,5, "Downloading file...", yellow, TOP_SCREEN)
        Network.downloadFile(site, zip_path)
        Screen.debugPrint(5,15, "File downloaded!", green, TOP_SCREEN)
        Screen.debugPrint(5,35, "Backing up payload", yellow, TOP_SCREEN)
        if (System.doesFileExist(backup_path)) then
            System.deleteFile(backup_path)
        end
        if (System.doesFileExist(payload_path)) then
            System.renameFile(payload_path, backup_path)
        end
        if (isMenuhax == false) then
            System.extractFromZIP(zip_path, "out/arm9loaderhax.bin", payload_path)
            Screen.debugPrint(5,50, "Moving to payload location...", yellow, TOP_SCREEN)
            System.deleteFile(zip_path)
            Screen.debugPrint(5,65, "Changing path for reboot patch", yellow, TOP_SCREEN)
            path_changer()
        elseif (isMenuhax == true) then
            Screen.debugPrint(5,50, "Moving to payload location...", yellow, TOP_SCREEN)
            System.extractFromZIP(zip_path, "out/Luma3DS.dat", "/Luma3DS.dat")
            System.deleteFile(zip_path)
        end
        Screen.debugPrint(5,80, "Done!", green, TOP_SCREEN)
        Screen.debugPrint(5,95, "Press START to go back to HBL/Home menu", green, TOP_SCREEN)
        Screen.debugPrint(5,110, "Press SELECT to reboot", green, TOP_SCREEN)
        while true do
            pad = Controls.read()
            if Controls.check(pad,KEY_START) then
                Screen.waitVblankStart()
                Screen.flip()
                System.exit()
            elseif Controls.check(pad,KEY_SELECT) then
                System.reboot()
            end
        end

    else
        Screen.debugPrint(5,5, "WiFi is off! Please turn it on and retry!", red, TOP_SCREEN)
        Screen.debugPrint(5,20, "Press START to go back to HBL/Home menu", red, TOP_SCREEN)
        while true do
            pad = Controls.read()
            if Controls.check(pad,KEY_START) then
                Screen.waitVblankStart()
                Screen.flip()
                System.exit()
            end
        end
    end
end

function init()
	readConfig("/luma/update.cfg")
	localVer = getVer(payload_path)
	remoteVerNum = getVer("remote")
end

function main()
    Screen.refresh()
    Screen.clear(TOP_SCREEN)
    Screen.debugPrint(5,5, "Welcome to the StarUpdater!", yellow, TOP_SCREEN)
    Screen.debugPrint(0, curPos, "->", white, TOP_SCREEN)
    Screen.debugPrint(30,20, "Update stable Luma3DS", white, TOP_SCREEN)
    Screen.debugPrint(30,35, "Update unstable Luma3DS", white, TOP_SCREEN)
    Screen.debugPrint(30,50, "Restore a Luma3DS backup", white, TOP_SCREEN)
    Screen.debugPrint(30,65, "Developer mode: "..getMode(devmode), white, TOP_SCREEN)
    Screen.debugPrint(30,80, "Install mode: "..getMode(menuhaxmode), white, TOP_SCREEN)
    Screen.debugPrint(30,95, "Go back to HBL/Home menu", white, TOP_SCREEN)
    Screen.debugPrint(30,110, "Update the updater", white, TOP_SCREEN)
    Screen.debugPrint(5,145, "Your Luma3DS version  : "..localVer, white, TOP_SCREEN)
    Screen.debugPrint(5,160, "Latest Luma3DS version: "..remoteVerNum, white, TOP_SCREEN)
    if (not isMenuhax) then
        Screen.debugPrint(5, 175, "Install directory: "..payload_path, white, TOP_SCREEN)
    end
    Screen.debugPrint(5, 195, "Installed Updater: v."..sver, white, TOP_SCREEN)
    Screen.debugPrint(5, 210, "Latest Updater   : v."..lver, white, TOP_SCREEN)
    Screen.flip()
end

init()
main()
while true do
        pad = Controls.read()
        
        if Controls.check(pad,KEY_START) and not Controls.check(oldpad,KEY_START) then
        	System.exit()
        end	
            
        if Controls.check(pad,KEY_DDOWN) and not Controls.check(oldpad,KEY_DDOWN) then
            if (curPos < 110) then
                curPos = curPos + 15
                main()
            end
        elseif Controls.check(pad,KEY_DUP) and not Controls.check(oldpad,KEY_DUP) then
            if (curPos > 20) then
                curPos = curPos - 15
                main()
            end
        elseif Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
            if (curPos == 20) then
                if (not isDev) then
                    update(stableUrl)
                else
                    update(stableDevUrl)
                end
            elseif (curPos == 35) then
                if (not isDev) then
                    update(hourlyUrl)
                else
                    update(hourlyDevUrl)
                end
            elseif (curPos == 50) then
                restoreBackup()
            elseif (curPos == 65) then
                isDev = not isDev
                main()
            elseif (curPos == 80) then
                isMenuhax = not isMenuhax
                init()
                main()
            elseif (curPos == 95) then
                System.exit()
            elseif (curPos == 110) then
            	if iscia == 1 then
                	Screen.clear(TOP_SCREEN)
        		Screen.debugPrint(5, 5, "Downloading new CIA...", yellow, TOP_SCREEN)
       			Network.downloadFile(latestCIA, "/Updater.CIA")
                	sleep(2000)
                	Screen.debugPrint(5, 20, "Installing CIA...", yellow, TOP_SCREEN)
                	System.installCIA("/Updater.CIA", SDMC)
                	System.deleteFile("/Updater.CIA")
                	System.exit()
                else
                	Screen.clear(TOP_SCREEN)
                	Screen.debugPrint(5, 5, "Downloading new script...", yellow, TOP_SCREEN)
					System.deleteFile("/3ds/StarUpdater/index.lua")
                	Network.downloadFile(latestHBX, "/3ds/StarUpdater/index.lua")
                	System.exit()
            	end	

            end
        end
        oldpad = pad
    end


