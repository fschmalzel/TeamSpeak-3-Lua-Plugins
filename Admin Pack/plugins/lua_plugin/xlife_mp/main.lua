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

local function formatString(inputstring, digits, character)
	return string.rep(character, digits - string.len(tostring(inputstring))) .. inputstring
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

local function replaceL(str)
	local null
	str, null = string.gsub(string.gsub(string.gsub(str, "|", "i"), "l", "i"), "_", " ")
	return str
end

local function checkOccurence(big, small)
	if tostring(string.find(string.lower(replaceL(big)), string.lower(replaceL(small)))) ~= "nil" then
		return true
	end
	return false
end

function mamo(serverConnectionHandlerID, ...)
	local arg = { ... }
	local password = ""
	if type(arg[1]) ~= "nil" then
		password = arg[1]
	end
	local myClientID = ts3.getClientID(serverConnectionHandlerID)
	local Clients, error = ts3.getClientList(serverConnectionHandlerID)
	errorCheck(error, "getting client list")
	local ChannelIDs, error = ts3.getChannelList(serverConnectionHandlerID)
	errorCheck(error, "getting channel IDs")
	local ChannelNames = {}
	local blacklistmp = {}
	for i, ChannelID in ipairs(ChannelIDs) do
		local ChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, ChannelID, ts3defs.ChannelProperties.CHANNEL_NAME)
		errorCheck(error, "getting channel name")
		table.insert(ChannelNames, {ChannelID, ChannelName})
	end
	for i, ChannelName in ipairs(ChannelNames) do
		for i2, blacklistName in ipairs(blacklistchannel) do
			if checkOccurence(ChannelName[2], blacklistName) then
				table.insert(blacklistmp, ChannelName[1])
			end
		end
	end
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	for i, ClientID in ipairs(Clients) do
		if ClientID ~= myClientID then
			local ChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, ClientID)
			errorCheck(error, "getting own channel")
			local poke = true
			for i,v in ipairs(blacklistmp) do
				if v == ChannelID then
					poke = false
				end
			end
			local Nickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, ClientID, ts3defs.ClientProperties.CLIENT_NICKNAME)
			errorCheck(error, "getting client nickname (ID: " .. ClientID .. ")")
			for i, blockedName in ipairs(blacklistClientNames) do
				if checkOccurence(Nickname, blockedName) then
					poke = false
				end
			end
			local pokestring
			if poke == true then pokestring = "Y" else pokestring = "N" end
			xprint("│ ID: " .. formatString(tostring(ClientID), 4, "0") .. " | Moved: " .. pokestring .. " | Nickname: \"" .. Nickname .. "\"") 
			if poke == true then	
				local myChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, myClientID)
				errorCheck(error, "getting own channel ID")
				if password ~= nil then
					local error = ts3.requestClientMove(serverConnectionHandlerID, ClientID, myChannelID, password)
				else
					local error = ts3.requestClientMove(serverConnectionHandlerID, ClientID, myChannelID, "")
				end
				errorCheck(error, "moving")
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
	errorCheck(error, "getting client list")
	local argMsg = ""
	for i,v in ipairs(arg) do
		argMsg = argMsg .. tostring(v) .. " "
	end
	if string.len(argMsg) > 0 and string.len(argMsg) <= 100 then
		local ChannelIDs, error = ts3.getChannelList(serverConnectionHandlerID)
		errorCheck(error, "getting channel IDs")
		local ChannelNames = {}
		local blacklistmp = {}
		for i, v in pairs(ChannelIDs) do
			local ChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, v, ts3defs.ChannelProperties.CHANNEL_NAME)
			errorCheck(error, "getting channel name")
			ChannelNames[#ChannelNames+1] = {v, ChannelName}
		end
		for i,v in ipairs(ChannelNames) do
			for j, w in ipairs(blacklistchannel) do
				if checkOccurence(v[2], w) then
					blacklistmp[#blacklistmp+1] = v[1]
				end
			end
		end
		xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
		for i, ClientID in ipairs(Clients) do
			if ClientID ~= myClientID then
				local ChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, ClientID)
				errorCheck(error, "getting own channel")
				local poke = true
				for j, v in ipairs(blacklistmp) do
					if v == ChannelID then
						poke = false
					end
				end
				local Nickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, ClientID, ts3defs.ClientProperties.CLIENT_NICKNAME)
				errorCheck(error, "getting client nickname (ID: " .. ClientID .. ")")
				for j, blockedName in ipairs(blacklistClientNames) do
					if checkOccurence(Nickname, blockedName) then
						poke = false
					end
				end
				if poke == true then pokestring = "Y" else pokestring = "N" end
				xprint("│ ID: " .. formatString(tostring(ClientID), 4, "0") .. " | Poked: " .. pokestring .. " | Nickname: \"" .. Nickname .. "\"") 
				if poke == true then
					local error = ts3.requestClientPoke(serverConnectionHandlerID, ClientID, argMsg)
					errorCheck(error, "poking")
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
	errorCheck(error, "getting own client ID")
	
	local myChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, myClientID)
	errorCheck(error, "getting channel of client")
	
	local myChannelClients, error = ts3.getChannelClientList(serverConnectionHandlerID, myChannelID)
	errorCheck(error, "getting client list")
	
	local blacklistedChannel = false
	
	if myChannelID == toChannelID then
		blacklistedChannel = true
	else
		local toChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, toChannelID, ts3defs.ChannelProperties.CHANNEL_NAME)
		errorCheck(error, "getting channel name")
		for i, blacklistName in ipairs(blacklistChannelMaMoCh) do
			if checkOccurence(toChannelName, blacklistName) then
				blacklistedChannel = true
			end
		end
	end
	
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	if blacklistedChannel == false then
		for i, clientID in ipairs(myChannelClients) do
			local clientNickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_NICKNAME)
			errorCheck(error, "getting client nickname (ID: " .. clientID .. ")")
			local poke = true
			for i, blockedName in ipairs(blacklistClientNames) do
				if checkOccurence(clientNickname, blockedName) then
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
				errorCheck(error, "moving")
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

function getchids(serverConnectionHandlerID)
	local ChannelIDs, error = ts3.getChannelList(serverConnectionHandlerID)
	errorCheck(error, "getting channel IDs")
	local ChannelNames = {}
	local blacklistmp = {}
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	for i, ChannelID in ipairs(ChannelIDs) do
		local ChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, ChannelID, ts3defs.ChannelProperties.CHANNEL_NAME)
		errorCheck(error, "getting channel name")
		xprint("│ CHID: " .. formatString(tostring(ChannelID), 4, "0") .. " | Channelname: \"" .. ChannelName .. "\"")
		if (i % 5) == 0 and #ChannelIDs ~= i then
			xprint("├───────────────────────────────────────────────────────────────────────────────────────────────")
		end
	end
	xprint("└───────────────────────────────────────────────────────────────────────────────────────────────")
end

xprint("MassPoke / MassMove initialised!")