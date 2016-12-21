--[[ 
Jeder Client der in einem Channel ist, dessen Channelnamen etwas von der Blacklist beinhaltet, wird nicht angestupst / gemoved.
z.B. blacklistchannel = {"Aufnahme"}
Alle Clients die in den Aufnahme Channeln sind werden nicht angestupst / gemoved.
z.B. blacklistchannel = {"Aufnahme","Watching"}
Alle Clients die in den Aufnahme Channeln oder Community Watching / Member Watching sind werden nicht angestupst / gemoved.
Weitere Namen müssen wie folgt hinzu gefügt werden. z.B. (Bespr.)
1. Man setzt es in Anführungszeichen: "(Bespr.)"
2. Man setzt ein Koma davor: ,"(Bespr.)"
3. Man fügt es der Blacklist hinzu: 
blacklistchannel = {"Aufnahme","(Bespr.)"}

Das wiederholt man falls man andere Channel hinzufügen will:
blacklistchannel = {"Aufnahme","(Bespr.)","Watching"}

Jeder Client dessen Name etwas von der Blacklist beinhaltet, wird nicht angestupst / gemoved.
z.B. blacklistClientNames = {"bot"}
Alle Clients die bot im Namen haben werden nicht angestupst / gemoved.
z.B. blacklistClientNames = {"bot","Alfred"}
Alle Clients die bot oder Alfred im Namen haben werden nicht angestupst / gemoved.
Weitere Namen müssen wie folgt hinzu gefügt werden. z.B. Musik
1. Man setzt es in Anführungszeichen: "Musik"
2. Man setzt ein Koma davor: ,"Musik"
3. Man fügt es der Blacklist hinzu: 
blacklistClientNames = {"bot","Musik"}

Das wiederholt man falls man andere Namen hinzufügen will:
blacklistClientNames = {"Musik", "Music", "bot", "Alfred", "Houseband"}
]]


--Default:
--local blacklistchannel = {"Aufnahme", "Record"}
--local blacklistChannelMaMoCh = {}
--local blacklistClientNames = {"Musik", "Music", "bot"}
local blacklistchannel = {"Aufnahme", "Record"}
local blacklistChannelMaMoCh = {}
local blacklistClientNames = {"Musik", "Music", "bot"}

require("ts3defs")
require("ts3errors")

local serverConnectionHandlerID = ts3.getCurrentServerConnectionHandlerID()

local function xprint(msg)
	local error = ts3.printMessageToCurrentTab(msg)
	if error ~= ts3errors.ERROR_ok then
		print("Error printing message: " .. msg)
		return
	end
end

xprint("xLife MassPoke / MassMove wird geladen.")

local function formatString(inputstring, digits, character)
	return string.rep(character, digits - string.len(tostring(inputstring))) .. inputstring
end

function mapohelp()
	local helpTable = {"Konfiguration ist am Anfang der Datei: " .. ts3.getPluginPath() .. "lua_plugin/xlife_mp/main.lua",
	"Befehle:",
	"Hilfe: '/lua run mapohelp'",
	"Massenanstupsen: '/lua run mapo <Nachricht>'",
	"z.B. /lua run mapo Event startet in 30 min!",
	"Massenmoven: '/lua run mamo <Channel Passwort>'",
	"z.B. /lua run mamo SuperSecretPass",
	"z.B. /lua run mamo",
	"Massenmoven der Clients im eigenen Channel: '/lua run mamoch <ChannelID> <Channel Passwort>",
	"z.B. /lua run mamoch 1 SuperSecretPass",
	"z.B. /lua run mamoch 20",
	"Auflisten der ChannelIDs: '/lua run getchids'",
	"z.B. /lua run getchids",
	"© xLifeHD@gmail.com"}
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	for i, txt in ipairs(helpTable) do
		xprint("│ " .. txt)
		if (i % 5) == 0 and #helpTable ~= i then
			xprint("├───────────────────────────────────────────────────────────────────────────────────────────────")
		end
	end
	xprint("└───────────────────────────────────────────────────────────────────────────────────────────────")
end

mapohelp()

function mamo(serverConnectionHandlerID, ...)
	local arg = { ... }
	local password = ""
	if type(arg[1]) ~= "nil" then
		password = arg[1]
	end
	local myClientID = ts3.getClientID(serverConnectionHandlerID)
	local Clients, error = ts3.getClientList(serverConnectionHandlerID)
	if error == ts3errors.ERROR_not_connected then
		xprint("Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		xprint("Error getting client list: " .. error)
		return
	end
	local ChannelIDs, error = ts3.getChannelList(serverConnectionHandlerID)
	if error ~= ts3errors.ERROR_ok then
		xprint("Error getting ChannelIDs: " .. error)
		return
	end
	local ChannelNames = {}
	local blacklistmp = {}
	for i, ChannelID in ipairs(ChannelIDs) do
		local ChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, ChannelID, ts3defs.ChannelProperties.CHANNEL_NAME)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error getting channel name: " .. error)
			return
		end
		table.insert(ChannelNames, {ChannelID, ChannelName})
	end
	for i, ChannelName in ipairs(ChannelNames) do
		for i2, blacklistName in ipairs(blacklistchannel) do
			if tostring(string.find(string.lower(ChannelName[2]), string.lower(blacklistName))) ~= "nil" then
				table.insert(blacklistmp, ChannelName[1])
			end
		end
	end
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	for i, ClientID in ipairs(Clients) do
		if ClientID ~= myClientID then
			local ChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, ClientID)
			if error ~= ts3errors.ERROR_ok then
				xprint("Error getting own channel: " .. error)
				return
			end
			local poke = true
			for i,v in ipairs(blacklistmp) do
				if v == ChannelID then
					poke = false
				end
			end
			local Nickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, ClientID, ts3defs.ClientProperties.CLIENT_NICKNAME)
			if error ~= ts3errors.ERROR_ok then
				xprint("Error getting client nickname: " .. error .. " | ID: " .. ClientID)
				return
			end
			for i, blockedName in ipairs(blacklistClientNames) do
				if tostring(string.find(string.lower(Nickname), string.lower(blockedName))) ~= "nil" then
					poke = false
				end
			end
			local pokestring
			if poke == true then pokestring = "Y" else pokestring = "N" end
			xprint("│ ID: " .. formatString(tostring(ClientID), 4, "0") .. " | Moved: " .. pokestring .. " | Nickname: \"" .. Nickname .. "\"") 
			if poke == true then	
				local myChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, myClientID)
				if password ~= nil then
					local error = ts3.requestClientMove(serverConnectionHandlerID, ClientID, myChannelID, password)
				else
					local error = ts3.requestClientMove(serverConnectionHandlerID, ClientID, myChannelID, "")
				end
				if error ~= ts3errors.ERROR_ok then
					xprint("Error moving: " .. error)
					return
				end
			end
		end
		if (i % 5) == 0 and #Clients ~= i then
			xprint("├───────────────────────────────────────────────────────────────────────────────────────────────")
		end
	end
	xprint("└───────────────────────────────────────────────────────────────────────────────────────────────")
end

function mapo(serverConnectionHandlerID, ...)
	local arg = { ... }
	local myClientID = ts3.getClientID(serverConnectionHandlerID)
	local Clients, error = ts3.getClientList(serverConnectionHandlerID)
	if error == ts3errors.ERROR_not_connected then
		xprint("Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		xprint("Error getting client list: " .. error)
		return
	end
	local argMsg = ""
	for i,v in ipairs(arg) do
		argMsg = argMsg .. tostring(v) .. " "
	end
	if string.len(argMsg) > 0 and string.len(argMsg) <= 100 then
		local ChannelIDs, error = ts3.getChannelList(serverConnectionHandlerID)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error getting ChannelIDs: " .. error)
			return
		end
		local ChannelNames = {}
		local blacklistmp = {}
		for i, v in pairs(ChannelIDs) do
			local ChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, v, ts3defs.ChannelProperties.CHANNEL_NAME)
			if error ~= ts3errors.ERROR_ok then
				xprint("Error getting channel name: " .. error)
				return
			end
			ChannelNames[#ChannelNames+1] = {v, ChannelName}
		end
		for i,v in ipairs(ChannelNames) do
			for i2,v2 in ipairs(blacklistchannel) do
				if tostring(string.find(string.lower(v[2]), string.lower(v2))) ~= "nil" then
					blacklistmp[#blacklistmp+1] = v[1]
				end
			end
		end
		xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
		for i, ClientID in ipairs(Clients) do
			if ClientID ~= myClientID then
				local ChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, ClientID)
				if error ~= ts3errors.ERROR_ok then
					xprint("Error getting own channel: " .. error)
					return
				end
				local poke = true
				for j, v in ipairs(blacklistmp) do
					if v == ChannelID then
						poke = false
					end
				end
				local Nickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, ClientID, ts3defs.ClientProperties.CLIENT_NICKNAME)
				if error ~= ts3errors.ERROR_ok then
					xprint("Error getting client nickname: " .. error .. " | ID: " .. ClientID)
					return
				end
				for j, blockedName in ipairs(blacklistClientNames) do
					if tostring(string.find(string.lower(Nickname), string.lower(blockedName))) ~= "nil" then
						poke = false
					end
				end
				if poke == true then pokestring = "Y" else pokestring = "N" end
				xprint("│ ID: " .. formatString(tostring(ClientID), 4, "0") .. " | Poked: " .. pokestring .. " | Nickname: \"" .. Nickname .. "\"") 
				if poke == true then
					local error = ts3.requestClientPoke(serverConnectionHandlerID, ClientID, argMsg)
					if error ~= ts3errors.ERROR_ok then
						xprint("Error poking: " .. error)
						return
					end
				end
			end
			if (i % 5) == 0 and #Clients ~= i then
				xprint("├───────────────────────────────────────────────────────────────────────────────────────────────")
			end
		end
		xprint("└───────────────────────────────────────────────────────────────────────────────────────────────")
	elseif string.len(argMsg) <= 0 then
		xprint("Error message too short")
	elseif string.len(argMsg) > 100 then
		xprint("Error message too long")
	end
end

function mamoch(serverConnectionHandlerID, toChannelID, ...)

	local arg = { ... }
	local password = ""
	toChannelID = tonumber(toChannelID)
	
	if type(arg[1]) ~= "nil" then
		password = arg[1]
	end
	
	local myClientID, error = ts3.getClientID(serverConnectionHandlerID)
	
	if error == ts3errors.ERROR_not_connected then
		xprint("Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		xprint("Error getting own client ID: " .. error)
		return
	end
	
	local myChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, myClientID)
	
	if error == ts3errors.ERROR_not_connected then
		xprint("Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		xprint("Error getting channel of client: " .. error)
		return
	end
	
	local myChannelClients, error = ts3.getChannelClientList(serverConnectionHandlerID, myChannelID)
	
	if error == ts3errors.ERROR_not_connected then
		xprint("Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		xprint("Error getting client list: " .. error)
		return
	end
	
	local blacklistedChannel = false
	
	if myChannelID == toChannelID then
		blacklistedChannel = true
	else
		local toChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, toChannelID, ts3defs.ChannelProperties.CHANNEL_NAME)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error getting toChannelName: " .. error)
			return
		end
		for i, blacklistName in ipairs(blacklistChannelMaMoCh) do
			if tostring (string.find(string.lower(toChannelName), string.lower(blacklistName))) ~= "nil" then
				blacklistedChannel = true
			end
		end
	end
	
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	if blacklistedChannel == false then
		for i, clientID in ipairs(myChannelClients) do
			local clientNickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_NICKNAME)
			if error ~= ts3errors.ERROR_ok then
				xprint("Error getting client nickname: " .. error .. " | ID: " .. clientID)
				return
			end
			local poke = true
			for i, blockedName in ipairs(blacklistClientNames) do
				if tostring(string.find(string.lower(clientNickname), string.lower(blockedName))) ~= "nil" then
					poke = false
				end
			end
			local pokestring
			if poke == true then pokestring = "Y" else pokestring = "N" end
			xprint("│ ID: " .. formatString(tostring(clientID), 4, "0") .. " | Moved: " .. pokestring .. " | Nickname: \"" .. clientNickname .. "\"") 
			if poke == true then
				if password ~= nil then
					local error = ts3.requestClientMove(serverConnectionHandlerID, clientID, toChannelID, password)
				else
					local error = ts3.requestClientMove(serverConnectionHandlerID, clientID, toChannelID, "")
				end
				if error ~= ts3errors.ERROR_ok then
					xprint("Error moving: " .. error)
					return
				end
			end
			if (i % 5) == 0 and #myChannelClients ~= i then
				xprint("├───────────────────────────────────────────────────────────────────────────────────────────────")
			end
		end
	else
		xprint("│ The desired channel is blacklisted or the channel you are in.")
	end
	xprint("└───────────────────────────────────────────────────────────────────────────────────────────────")
	
end

local function errorCheck(error, msg)
	if error == ts3errors.ERROR_not_connected then
		xprint("Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		xprint("Error " .. msg .. ": " .. error)
		return
	end
end

function mmcn(serverConnectionHandlerID, toChannelName, ...)
	local arg = { ... }
	local password = ""
	if type(arg[1]) ~= "nil" then
		password = arg[1]
	end
	local channelList, error = ts3.getChannelList(serverConnectionHandlerID)
	errorCheck(error, "getting Channellist")
	local toChannelID = -1
	for i, channelID in pairs(channelList) do
		local channelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, channelID, ts3defs.ChannelProperties.CHANNEL_NAME)
		errorCheck(error, "getting ChannelName")
		if checkOccurence(channelName, toChannelName) then
			toChannelID = channelID
		end
	end
	if toChannelID ~= -1 then
		mamoch(serverConnectionHandlerID, toChannelID, password)
	end
end

local function checkOccurence(big, small)
	if tostring(string.find(string.lower(big), string.lower(small))) ~= "nil" then
		return true
	end
	return false
end

function getchids(serverConnectionHandlerID)
	local ChannelIDs, error = ts3.getChannelList(serverConnectionHandlerID)
	if error == ts3errors.ERROR_not_connected then
		xprint("Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		xprint("Error getting ChannelIDs: " .. error)
		return
	end
	local ChannelNames = {}
	local blacklistmp = {}
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	for i, ChannelID in ipairs(ChannelIDs) do
		local ChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, ChannelID, ts3defs.ChannelProperties.CHANNEL_NAME)
		xprint("│ CHID: " .. formatString(tostring(ChannelID), 4, "0") .. " | Channelname: \"" .. ChannelName .. "\"")
		if (i % 5) == 0 and #ChannelIDs ~= i then
			xprint("├───────────────────────────────────────────────────────────────────────────────────────────────")
		end
	end
	xprint("└───────────────────────────────────────────────────────────────────────────────────────────────")
end

xprint("MassPoke / MassMove initialised!")