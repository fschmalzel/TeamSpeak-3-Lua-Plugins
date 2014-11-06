--[[
ts3.getChannelOfClient(serverConnectionHandlerID, clientID) > channelID, error
ts3.getCurrentServerConnectionHandlerID()
ts3.printMessageToCurrentTab(message)
ts3.requestClientPoke(serverConnectionHandlerID, clientID, message) > error
ts3.getClientList(serverConnectionHandlerID) > clientsList, error
ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, message, targetClientID) > error
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
local data={}
loadFile()
local serverConnectionHandlerID = ts3.getCurrentServerConnectionHandlerID()
local myClientID = ts3.getClientID(serverConnectionHandlerID)

local function xprint(msg)
	ts3.printMessageToCurrentTab(msg)
end

function getIDs()
	local Clients = ts3.getClientList(serverConnectionHandlerID)
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
	if string.lower(string.sub(message, 1, 4) == "info" then --     info add
		if string.lower(string.sub(message, 6, 8) == "add" then --   1234567890
			save(fromName, fromUniqueIdentifier, string.sub(message, 10, string.len(message))
		elseif string.lower(string.sub(message, 6, 9) == "show" then
			show(fromID, string.sub(message, 11, string.len(message))
		elseif string.lower(string.sub(message, 6, 11) == "update" then
			updateInfo(fromID, fromName, fromUniqueIdentifier)
		elseif string.lower(string.sub(message, 6, 12) == "delline" then
			deleteLine(fromID, fromUniqueIdentifier, string.sub(message, 14, string.len(message)))
		end
	end	
end

local function save(Nickname, UniqueID, Line)
	local value = 0
	local exists = false
	for index, value in pairs(data) do
		if value[2] == UniqueID then
			exists = true
			value = index
		end
	end
	if exists == true then
		data[index][3][#data[index][3]+1] = Line -- Adding one line
		data[index][1] = Nickname -- Changing the Nickname
		updateFile()
	else
		data[#data+1]={Nickname, UniqueID, {Line}}
	end
end

local function show(ClientID, Nickname)
	
end

local function updateFile()
	
end

local function loadFile()

end

local function updateInfo(ClientID, Nickname, UniqueID)
	local value = 0
	local exists = false
	for index, value in pairs(data) do
		if value[2] == UniqueID then
			exists = true
			value = index
		end
	end
	if exists == true then
		data[index][1] = Nickname -- Changing the Nickname
		updateFile()
	else
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Error: Client does not exist! To create an client simply run \"info add <Line>\"", ClientID)
		if error ~= ts3errors.ERROR_ok then
			print("Error sending message: " .. error)
		end
	end
end

local function deleteLine(ClientID, UniqueID, numberLine)
	if tonumber(numberLine) >= 1 
	local value = 0
	local exists = false
	for index, value in pairs(data) do
		if value[2] == UniqueID then
			exists = true
			value = index
		end
	end
	if exists == true and tonumber(numberLine) >= 1 and tonumber(numberLine) <= #data[index][3] then
		table.remove(data[index][3], tonumber(numberLine))
		updateFile()
	elseif exists == false then
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Error: Client does not exist! To create an client simply run \"info add <Line>\"", ClientID)
		if error ~= ts3errors.ERROR_ok then
			print("Error sending message: " .. error)
		end
	elseif tonumber(numberLine) < 1 or tonumber(numberLine) > #data[index][3]then
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Error: Line does not exist!", ClientID)
		if error ~= ts3errors.ERROR_ok then
			print("Error sending message: " .. error)
		end
	end
end













