--[[ 
Jeder Client der in einem Channel ist, dessen Channelnamen etwas von der Blacklist beinhaltet, wird nicht angestupst.
z.B. blacklistchannel = {"Aufnahme"}
Alle Clients die in den Aufnahme Channeln sind werden nicht angestupst.
z.B. blacklistchannel = {"Aufnahme","Watching"}
Alle Clients die in den Aufnahme Channeln oder Community Watching / Member Watching sind werden nicht angestupst.
Weitere Namen müssen wie folgt hinzu gefügt werden. z.B. (Bespr.)
1. Man setzt es in Anführungszeichen: "(Bespr.)"
2. Man setzt ein Koma davor: ,"(Bespr.)"
3. Man fügt es der Blacklist hinzu: 
blacklistchannel = {"Aufnahme","(Bespr.)"}

Das wiederholt man falls man andere Channel hinzufügen will:
blacklistchannel = {"Aufnahme","(Bespr.)","Watching"}
]]--


--Standard:
--blacklistchannel = {"Aufnahme"}
local blacklistchannel = {"Aufnahme", "Bespr"}

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
	xprint("Konfiguration ist am Anfang der Datei: <TeamSpeak3>\\plugins\\lua_plugin\\xlife_mp\\main.lua")
	xprint("Befehle:")
	xprint("Hilfe: '/lua run mapohelp'")
	xprint("Massenanstupsen: '/lua run mapo <Nachricht>'")
	xprint("z.B. /lua run mapo Event startet in 30 min!")
	xprint("Massenmoven: '/lua run mamo <Channel Passwort>'")
	xprint("z.B. /lua run mamo SuperSecretPass")
	xprint("z.B. /lua run mamo")
	xprint("© xLifeHD@gmail.com")
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
			poke = true
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
		for i = 1, #ChannelIDs do
			local ChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, ChannelIDs[i], ts3defs.ChannelProperties.CHANNEL_NAME)
			if error ~= ts3errors.ERROR_ok then
				xprint("Error getting channel name: " .. error)
				return
			end
			ChannelNames[#ChannelNames+1] = {ChannelIDs[i], ChannelName}
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
				poke = true
				for i, v in ipairs(blacklistmp) do
					if v == ChannelID then
						poke = false
					end
				end
				local Nickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, ClientID, ts3defs.ClientProperties.CLIENT_NICKNAME)
				if error ~= ts3errors.ERROR_ok then
					xprint("Error getting client nickname: " .. error .. " | ID: " .. ClientID)
					return
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

xprint("MassPoke / MassMove initialised!")