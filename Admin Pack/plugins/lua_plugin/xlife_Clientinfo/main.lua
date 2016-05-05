require("ts3defs")
require("ts3errors")

local function xprint(msg)
	ts3.printMessageToCurrentTab(msg)
end
xprint("xLife ClientInfo wird geladen.")

function clinfohelp()
	xprint("Befehle:")
	xprint("Hilfe: '/lua run clinfohelp'")
	xprint("Infos ueber alle Clients: '/lua run clinfo'")
	xprint("Erweiterte Infos ueber alle Clients: '/lua run clinfo true'")
	xprint("© xLife | Felix")
end

clinfohelp()

local function formatString(inputstring, digits, character)
	return string.rep(character, digits - string.len(tostring(inputstring))) .. tostring(inputstring)
end

function clinfo(serverConnectionHandlerID, ...)
	local arg = { ... }
	local adv = ""
	if type(arg[1]) ~= "nil" and string.lower(tostring(arg[1])) == "true" then
		adv = true
	else 
		adv = false
	end
	local Clients, error = ts3.getClientList(serverConnectionHandlerID)
	if error ~= ts3errors.ERROR_ok then xprint("Error getting list of clients: " .. error .. " | SID: " .. serverConnectionHandlerID) end
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	for i, clientID in ipairs(Clients) do
		if (i % 3) == 0 and #Clients ~= i then
			xprint("├───────────────────────────────────────────────────────────────────────────────────────────────")
		end
		if (i % 9) == 0 and #Clients ~= i or i == 1 then
			if adv == true then
				xprint("│ CliID |#DBID#|########UniqueID########| Type | Nickname | Description | Servergroups")
			else
				xprint("│ ClID | DBID | UniqueID | Nickname")
			end
		end
		
		local ClientDBID, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 32)
		if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientDBID: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
		
		local ClientUID, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 0)
		if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientUID: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
		
		local ClientNickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 1)
		if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientNickname: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
		
		if adv == true then
			local ClientType, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 40)
			if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientType: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
			
			local ClientSrvGrps, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 34)
			if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientSrvGrps: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
			
			local ClientDscrp, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 45)
			if error ~= ts3errors.ERROR_ok then xprint("Error getting Client Description: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
			
			xprint("│ " .. formatString(clientID, 4, "0") .. " | " .. formatString(ClientDBID, 5, "0") .. " | " .. formatString(ClientUID, 28, " ") .. " | " .. ClientType .. " | \"" .. ClientNickname .. "\" | \"" .. ClientDscrp .. "\" | " .. ClientSrvGrps)
		else
			xprint("│ " .. formatString(clientID, 4, "0") .. " | " .. formatString(ClientDBID, 5, "0") .. " | " .. formatString(ClientUID, 28, " ") .. " | " .. ClientNickname)
		end
	end
	xprint("└───────────────────────────────────────────────────────────────────────────────────────────────")
end

xprint("ClientInfo initialisiert!")