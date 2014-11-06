--[[
ts3.getChannelOfClient(serverConnectionHandlerID, clientID) > channelID, error
ts3.getCurrentServerConnectionHandlerID()
ts3.printMessageToCurrentTab(message)
ts3.requestClientPoke(serverConnectionHandlerID, clientID, message) > error
ts3.getClientList(serverConnectionHandlerID) > clientsList, error

local myChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, myChannelID, ts3defs.ChannelProperties.CHANNEL_NAME)
if error ~= ts3errors.ERROR_ok then
	print("Error getting channel name: " .. error)
	return
end]]--

require("ts3defs")
require("ts3errors")
require("ts3init")
require("ts3autoload")
require("ts3events")

--data{{Nickname, UniqueID, {Line1, Line2, Line3, ...}},{Nickname, UniqueID, {Line1, Line2, Line3, ...}}
data={}
serverConnectionHandlerID = ts3.getCurrentServerConnectionHandlerID()
myClientID = ts3.getClientID(serverConnectionHandlerID)

function xprint(msg)
	ts3.printMessageToCurrentTab(msg)
end

function getIDs()
	Clients = ts3.getClientList(serverConnectionHandlerID)
	for i = 1, #Clients do
		local Nickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, Clients[i], ts3defs.ClientProperties.CLIENT_NICKNAME)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error getting client nickname: " .. error .. " | ID: " .. Clients[i])
			return
		end
		xprint("ID: " .. Clients[i] .. " | Nickname: " .. Nickname)
	end
end

function onTextMessageEvent(serverConnectionHandlerID, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored)
	print("Lua: onTextMessageEvent: " .. serverConnectionHandlerID .. " " .. targetMode .. " " .. toID .. " " .. fromID .. " " .. fromName .. " " .. fromUniqueIdentifier .. " " .. message .. " " .. ffIgnored)
	if string.lower(string.sub(message, 1, 4) == "info" then -- info add
		if string.lower(string.sub(message, 6, 8) == "add" then --   1234567890
			save(fromName, UniqueID, string.sub(message, 10, string.len(message))
		elseif string.lower(string.sub(message, 6, 9) == "show" then
			show(fromID, string.sub(message, 11, string.len(message))
		end
	end	
end

function save(Nickname, UniqueID, Line)
	for i, v in 
end

function show(ClientID, Name)
	
end






