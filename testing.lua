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

--[[
save()					Creating User in table 100% Benachrichtigungen fehlen
show()					Displaying Information 100% Benachrichtigungen fehlen
updateNick()			Changing Nickname 100% Benachrichtigungen fehlen
deleteLine()			Deleting one Line 100% Benachrichtigungen fehlen
onTextMessageEvent() Chatcommands 100% Benachrichtigungen fehlen
updateFile()			Updating the File 0%
loadFile()				Loading the File 50%
deleteClient()			Deleting an Client out of the table 100% Benachrichtigungen fehlen
]]

function xprint(msg)
	ts3.printMessageToCurrentTab(msg)
end

function onTextMessageEvent(serverConnectionHandlerID, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored)
	print("Lua: onTextMessageEvent: " .. serverConnectionHandlerID .. " " .. targetMode .. " " .. toID .. " " .. fromID .. " " .. fromName .. " " .. fromUniqueIdentifier .. " " .. message .. " " .. ffIgnored)
	if string.lower(string.sub(message, 1, 4)) == "info" then --     info add
		xprint("info")
		if string.lower(string.sub(message, 6, 8)) == "add" then --   1234567890
			xprint("add"..string.sub(message, 10, string.len(message)))
			save(fromName, fromUniqueIdentifier, string.sub(message, 10, string.len(message)))
		elseif string.lower(string.sub(message, 6, 9)) == "show" then
			xprint("show")
			show(fromID, string.sub(message, 11, string.len(message)))
		elseif string.lower(string.sub(message, 6, 11)) == "update" then
			xprint("update")
			updateNick(fromID, fromName, fromUniqueIdentifier)
		elseif string.lower(string.sub(message, 6, 12)) == "delline" then
			xprint("delline")
			deleteLine(fromID, fromUniqueIdentifier, string.sub(message, 14, string.len(message)))
		elseif string.lower(string.sub(message, 6, 10)) == "delme" then
			xprint("delme")
			deleteClient(fromID, fromUniqueIdentifier, string.sub(message, 12, string.len(message)))
		end
	end	
end

function save(Nickname, UniqueID, Line)
	xprint("HEY")
	local X = 0
	local exists = false
	for index, value in ipairs(data) do
		xprint(index.." | "..tostring(value))
		if value[2] == UniqueID then
			exists = true
			X = index
		end
	end
	if exists == true then
		data[X][3][#data[X][3]+1] = Line -- Adding one line
		data[X][1] = Nickname -- Changing the Nickname
		xprint(data[X][1]..data[X][2]..data[X][3][1])--Debug
		updateFile()
	else
		data[#data+1]={Nickname, UniqueID, {Line}} -- Creating a new User
		X = #data --Debug
		xprint(data[X][1]..data[X][2]..data[X][3][1])--Debug
	end
end

function show(ClientID, Nickname)
	local X = 0
	local exists = false
	for index, value in ipairs(data) do
		if string.find(value[1], Nickname) ~= nil then
			exists = true
			X = index
		end
	end
	if exists == true then
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Information about \""..data[X][1].."\":", ClientID)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error sending message: " .. error)
		end
		for index, value in ipairs(data[X][3]) do
			local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, value, ClientID)
			if error ~= ts3errors.ERROR_ok then
				xprint("Error sending message: " .. error)
			end
		end
	else
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Error: Client does not exist! To create an client simply run \"info add <Line>\"", ClientID)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error sending message: " .. error)
		end
	end
end

function updateFile()
	
end
--table structure: data{{Nickname, UniqueID, {Line1, Line2, Line3, ...}},{Nickname, UniqueID, {Line1, Line2, Line3, ...}}
--data.dat
--L1:N:"Nickname",U:"UniqueID",L:{1:"Line1",2:"Line2",3:"Line3"}
--L9:
function loadFile()
--[[	for --datei laden lines
		data[i]={"Nickname", "UniqueID", {"Line"}}
		Pos1, x = string.find(Line, 'N:"')
		x, Pos2 = string.find(Line, '",')
		if Pos1 ~= nil and Pos2 ~= nil then
			local Nickname = string.sub(Line, tonumber(Pos1+3), tonumber(Pos2-2))
			data[i][1] = Nickname
		end
		Pos1, x = string.find(Line, 'U:"')
		x, Pos2 = string.find(Line, '",', Pos2)
		if Pos1 ~= nil and Pos2 ~= nil then
			local UniqueID = string.sub(Line, tonumber(Pos1+3), tonumber(Pos2-2))
			data[i][2] = UniqueID
		end
		--Linien mussen noch geldaden werden
	end]]
end

function updateNick(ClientID, Nickname, UniqueID)
	local X = 0
	local exists = false
	for index, value in pairs(data) do
		if value[2] == UniqueID then
			exists = true
			X = index
		end
	end
	if exists == true then
		data[X][1] = Nickname -- Changing the Nickname
		updateFile()
	else
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Error: Client does not exist! To create an client simply run \"info add <Line>\"", ClientID)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error sending message: " .. error)
		end
	end
end

function deleteLine(ClientID, UniqueID, numberLine)
	local X = 0
	local exists = false
	for index, value in pairs(data) do
		if value[2] == UniqueID then
			exists = true
			X = index
		end
	end
	if exists == true and tonumber(numberLine) >= 1 and tonumber(numberLine) <= #data[X][3] then
		table.remove(data[X][3], tonumber(numberLine))
		updateFile()
	elseif exists == false then
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Error: Client does not exist! To create an client simply run \"info add <Line>\"", ClientID)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error sending message: " .. error)
		end
	elseif tonumber(numberLine) < 1 or tonumber(numberLine) > #data[X][3]then
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Error: Line does not exist!", ClientID)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error sending message: " .. error)
		end
	end
end

function deleteClient(ClientID, UniqueID, Msg)
	if string.lower(Msg) == "yes" then
		local X = 0
		local exists = false
		for index, value in pairs(data) do
			if value[2] == UniqueID then
				exists = true
				X = index
			end
		end
		if exists == true then
			table.remove(data[X])
		end
	else
		local error = ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Are you sure, that you want to erase yourself in the DB? If you are run \"info delme yes\"", ClientID)
		if error ~= ts3errors.ERROR_ok then
			xprint("Error sending message: " .. error)
		end
	end
end
--table structure: data{{Nickname, UniqueID, {Line1, Line2, Line3, ...}},{Nickname, UniqueID, {Line1, Line2, Line3, ...}}
local data={}
local serverConnectionHandlerID = ts3.getCurrentServerConnectionHandlerID()
local myClientID = ts3.getClientID(serverConnectionHandlerID)
loadFile()

















