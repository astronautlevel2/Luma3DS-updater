--StarUpdater Bootstrapper (Based on Corbenik CFW Updater: RE's CORE script)
--You can find the original bootstrapper here: http://github.com/gnmmarechal/corbenik-updater-re/blob/master/index.lua
--Runs on Lua Player Plus 3DS

-- This script fetches the latest updater script and runs it. If the server-side script has a higher rel number, the CIA will also be updated.
clientrel = 1
bootstrapver = "1.0.2"

if not Network.isWifiEnabled() then --Checks for Wi-Fi
	error("Failed to connect to the network.")
end

-- Set server script URLs (These have to be changed by astronautlevel for an official release
stableserverscripturl = "http://gs2012.xyz/3ds/StarUpdater/index-server.lua"
nightlyserverscripturl = "http://gs2012.xyz/3ds/StarUpdater/index-nightly.lua"

-- Set script path
scriptpath = "/StarUpdater/index-server.lua"

-- Create directories
System.createDirectory("/StarUpdater")


-- Check if user is in devmode or no (to either use index-server.lua or cure-nightly.lua)
if System.doesFileExist("/StarUpdater/devmode") then
	serverscripturl = nightlyserverscripturl
	devmode = 1
else
	serverscripturl = stableserverscripturl
	devmode = 0
end
-- Download server script
if System.doesFileExist(scriptpath) then
	System.deleteFile(scriptpath)
end
Network.downloadFile(serverscripturl, scriptpath)

-- Run server script
dofile(scriptpath)
System.exit()
