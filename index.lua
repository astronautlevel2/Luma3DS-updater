-- StarUpdater

-- Colours
local colors =
{
	white = Color.new(255,255,255),
	yellow = Color.new(255,205,66),
	red = Color.new(255,0,0),
	green = Color.new(55,255,0)
}

-- Luma3DS URLs

local url =
{
	hourly = "http://astronautlevel2.github.io/Luma3DS/latest.zip",
	stable = "http://astronautlevel2.github.io/Luma3DS/release.zip",
	remver = "http://astronautlevel2.github.io/Luma3DS/lastVer",
	remcommit = "http://astronautlevel2.github.io/Luma3DS/lastCommit",
}

-- Additional Paths
local payload_path = "/arm9loaderhax.bin"
local zip_path = "/Luma3DS.zip"
local backup_path = payload_path..".bak"

-- StarUpdater URLs
local latestCIA = "http://gs2012.xyz/3ds/starupdater/StarUpdater.cia" -- Unofficial URL is: http://gs2012.xyz/3ds/starupdater/latest.zep
local latestHB = "http://gs2012.xyz/3ds/starupdater/lateststarupdater.3dsx" -- Astronaut must replace this with their own URL, as done for other URLs.
local verserver = "http://gs2012.xyz/3ds/starupdater/version" -- Unofficial URL http://gs2012.xyz/3ds/starupdater/version
local svrelverserver = "http://gs2012.xyz/3ds/starupdater/relver" -- Astronaut must replace this with their own URL, as done above

-- Version Info
local sver = "1.5.1-UN"
local lver = "???" --This is fetched from the server
local relver = 1 -- This is a number that is checked against the server version for mandatory updates. if svrelver > relver, StarUpdater will auto-update.
local svrelver = 0 -- Fetched from server


local curPos = 20
local isMenuhax = false
local localVer = ""
local remoteVerNum = ""

local pad = Controls.read()
local oldpad = pad

--CIA/3DSX
local iscia = 0
if System.checkBuild() == 2 then
	iscia = 0
else
	iscia = 1
end


if Network.isWifiEnabled() then
	lver = Network.requestString(verserver)
	svrelver = tonumber(Network.requestString(svrelverserver))
end

--Auto-update check
if svrelver > relver then
	autoupdate = 1
else
	autoupdate = 0
end
--End of Auto-Update check

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
        Screen.debugPrint(5,5, "Deleting new payload...", colors.yellow, TOP_SCREEN)
        System.deleteFile(payload_path)
        Screen.debugPrint(5,20, "Renaming backup to "..payload_path.."...", colors.yellow, TOP_SCREEN)
        System.renameFile(backup_path, payload_path)
        Screen.debugPrint(5,35, "Press START to go back to HBL/Home menu", colors.green, TOP_SCREEN)
        while true do
            pad = Controls.read()
                if Controls.check(pad,KEY_START) then
                    Screen.waitVblankStart()
                    Screen.flip()
                    System.exit()
            end
        end
    else
        Screen.debugPrint(5,5, "Backup path: "..backup_path, colors.yellow, TOP_SCREEN)
        Screen.debugPrint(5,20, "Press START to go back to HBL/Home menu", colors.green, TOP_SCREEN)
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

function getMode()
	if (isMenuhax) then
		return "MenuHax"
	else
		return "Arm9LoaderHax"
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
      	local searchString = "Luma3DS v"
      	local verString = "v"
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
		return Network.requestString(url.remver).."-"..Network.requestString(url.remcommit)	
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
    	Screen.debugPrint(5,5, "Downloading file...", colors.yellow, TOP_SCREEN)
        Network.downloadFile(site, zip_path)
        Screen.debugPrint(5,15, "File downloaded!", colors.green, TOP_SCREEN)
        Screen.debugPrint(5,35, "Backing up payload", colors.yellow, TOP_SCREEN)
        if (System.doesFileExist(backup_path)) then
            System.deleteFile(backup_path)
        end
        if (System.doesFileExist(payload_path)) then
            System.renameFile(payload_path, backup_path)
        end
        if (isMenuhax == false) then
            System.extractFromZIP(zip_path, "out/arm9loaderhax.bin", payload_path)
            Screen.debugPrint(5,50, "Moving to payload location...", colors.yellow, TOP_SCREEN)
            System.deleteFile(zip_path)
            Screen.debugPrint(5,65, "Changing path for reboot patch", colors.yellow, TOP_SCREEN)
            path_changer()
        elseif (isMenuhax == true) then
            System.createDirectory("/3ds")
			System.createDirectory("/3ds/Luma3DS")
			Screen.debugPrint(5,50, "Extracting 3DSX/SMDH...", colors.yellow, TOP_SCREEN)
			if System.doesFileExist("/3ds/Luma3DS/luma-up.3dsx") then
				System.deleteFile("/3ds/Luma3DS/luma-up.3dsx")
			end
			if System.doesFileExist("/3ds/Luma3DS/luma-up.smdh") then
				System.deleteFile("/3ds/Luma3DS/luma-up.smdh")
			end
            System.extractFromZIP(zip_path, "out/hax/3ds/Luma3DS/Luma3DS.3dsx", "/3ds/Luma3DS/luma-up.3dsx")
			if System.doesFileExist("/3ds/Luma3DS/Luma3DS.3dsx") then
				System.deleteFile("/3ds/Luma3DS/Luma3DS.3dsx")
			end
			System.renameFile("/3ds/Luma3DS/luma-up.3dsx", "/3ds/Luma3DS/Luma3DS.3dsx")
            System.extractFromZIP(zip_path, "out/hax/3ds/Luma3DS/Luma3DS.smdh", "/3ds/Luma3DS/luma-up.smdh")			
			if System.doesFileExist("/3ds/Luma3DS/Luma3DS.smdh") then
				System.deleteFile("/3ds/Luma3DS/Luma3DS.smdh")
			end
			System.renameFile("/3ds/Luma3DS/luma-up.smdh", "/3ds/Luma3DS/Luma3DS.smdh")
			Screen.debugPrint(5, 65, "Extracting payload...", colors.yellow, TOP_SCREEN)
            if System.doesFileExist("/arm9loaderhax.bin") then
				System.deleteFile("/arm9loaderhax.bin")	
            end
            System.extractFromZIP(zip_path, "out/arm9loaderhax.bin", "/arm9loaderhax.bin")			
            System.deleteFile(zip_path)
        end
        Screen.debugPrint(5,80, "Done!", colors.green, TOP_SCREEN)
        Screen.debugPrint(5,95, "Press START to go back to HBL/Home menu", colors.green, TOP_SCREEN)
        Screen.debugPrint(5,110, "Press SELECT to reboot", colors.green, TOP_SCREEN)
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
        Screen.debugPrint(5,5, "WiFi is off! Please turn it on and retry!", colors.red, TOP_SCREEN)
        Screen.debugPrint(5,20, "Press START to go back to HBL/Home menu", colors.red, TOP_SCREEN)
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
    Screen.debugPrint(5,5, "Welcome to the StarUpdater!", colors.yellow, TOP_SCREEN)
    Screen.debugPrint(0, curPos, "->", colors.white, TOP_SCREEN)
    Screen.debugPrint(30,20, "Update to latest Luma3DS", colors.white, TOP_SCREEN)
    Screen.debugPrint(30,35, "Update to Luma3DS hourly", colors.white, TOP_SCREEN)
    Screen.debugPrint(30,50, "Restore a Luma3DS backup", colors.white, TOP_SCREEN)
    Screen.debugPrint(30,65, "Install mode: "..getMode(), colors.white, TOP_SCREEN)
    Screen.debugPrint(30,80, "Go back to HBL/Home Menu", colors.white, TOP_SCREEN)
    Screen.debugPrint(30,95, "Update the updater", colors.white, TOP_SCREEN)
    Screen.debugPrint(5,130, "Your Luma3DS version  : "..localVer, colors.white, TOP_SCREEN)
    Screen.debugPrint(5,145, "Latest Luma3DS version: "..remoteVerNum, colors.white, TOP_SCREEN)
    if (not isMenuhax) then
        Screen.debugPrint(5, 160, "Install path: "..payload_path, colors.white, TOP_SCREEN)
    end
    Screen.debugPrint(5, 195, "Installed Updater: v."..sver, colors.white, TOP_SCREEN)
    Screen.debugPrint(5, 210, "Latest Updater   : v."..lver, colors.white, TOP_SCREEN)
    Screen.flip()
end

init()
main()
while true do
	if autoupdate == 0 then
			pad = Controls.read()
			
			if Controls.check(pad,KEY_START) and not Controls.check(oldpad,KEY_START) then
				System.exit()
			end	
				
			if Controls.check(pad,KEY_DDOWN) and not Controls.check(oldpad,KEY_DDOWN) then
				if (curPos < 95) then
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
					update(url.stable)
				elseif (curPos == 35) then
					update(url.hourly)
				elseif (curPos == 50) then
					restoreBackup()
				elseif (curPos == 65) then
					isMenuhax = not isMenuhax
					init()
					main()
				elseif (curPos == 80) then
					System.exit()
				elseif (curPos == 95) then
					if iscia == 1 then
						Screen.clear(TOP_SCREEN)
					Screen.debugPrint(5, 5, "Downloading new CIA...", colors.yellow, TOP_SCREEN)
					Network.downloadFile(latestCIA, "/Updater.CIA")
						sleep(2000)
						Screen.debugPrint(5, 20, "Installing CIA...", colors.yellow, TOP_SCREEN)
						System.installCIA("/Updater.CIA", SDMC)
						System.deleteFile("/Updater.CIA")
						System.exit()
					else
						Screen.clear(TOP_SCREEN)
						Screen.debugPrint(5, 5, "Downloading new 3DSX...", colors.yellow, TOP_SCREEN)
						if System.doesFileExist("/3ds/StarUpdater/StarUpdater-up.3dsx") then
							System.deleteFile("/3ds/StarUpdater/StarUpdater-up.3dsx")
						end
						Network.downloadFile(latestHB, "/3ds/StarUpdater/StarUpdater-up.3dsx")
						if System.doesFileExist("/3ds/StarUpdater/StarUpdater-up.3dsx") then
							System.deleteFile("/3ds/StarUpdater/StarUpdater.3dsx")
							System.renameFile("/3ds/StarUpdater/StarUpdater-up.3dsx", "/3ds/StarUpdater/StarUpdater-up.3dsx")
						end
						System.exit()
					end	
	
				end
			end
			oldpad = pad
	else
		if iscia == 1 then
			Screen.clear(TOP_SCREEN)
			Screen.debugPrint(5, 5, "StarUpdater Self Auto-Updater", colors.yellow, TOP_SCREEN)
			Screen.debugPrint(5, 20, "Downloading update...", colors.yellow, TOP_SCREEN)
			Network.downloadFile(latestCIA, "/Updater.CIA")
			sleep(2000)
			Screen.debugPrint(5, 35, "Installing update...", colors.yellow, TOP_SCREEN)
			Screen.installCIA("/Updater.CIA", SDMC)
			System.deleteFile("/Updater.CIA")
			System.exit()
		else
			Screen.clear(TOP_SCREEN)
			Screen.debugPrint(5, 5, "StarUpdater Self Auto-Updater", colors.yellow, TOP_SCREEN)
			Screen.debugPrint(5, 20, "Downloading update...", colors.yellow, TOP_SCREEN)
			if System.doesFileExist("/3ds/StarUpdater/StarUpdater-up.3dsx") then
				System.deleteFile("/3ds/StarUpdater/StarUpdater-up.3dsx")
			end
			Network.downloadFile(latestHB, "/3ds/StarUpdater/StarUpdater-up.3dsx")
			if System.doesFileExist("/3ds/StarUpdater/StarUpdater-up.3dsx") then
				System.deleteFile("/3ds/StarUpdater/StarUpdater.3dsx")
				System.renameFile("/3ds/StarUpdater/StarUpdater-up.3dsx", "/3ds/StarUpdater/StarUpdater-up.3dsx")
			end
			System.exit()
		end	

	end
end


