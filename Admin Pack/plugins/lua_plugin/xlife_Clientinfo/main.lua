require("ts3defs")
require("ts3errors")

function xprint(msg)
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

function clinfo(serverConnectionHandlerID, adv)
	Clients, error = ts3.getClientList(serverConnectionHandlerID)
	if error ~= ts3errors.ERROR_ok then xprint("Error getting list of clients: " .. error .. " | SID: " .. serverConnectionHandlerID) end
	xprint("┌───────────────────────────────────────────────────────────────────────────────────────────────")
	if adv == "true" then
		xprint("│ ClID | DBID | UniqueID | Type | Nickname | Description | Servergroups")
	else
		xprint("│ ClID | DBID | UniqueID | Nickname")
	end
	for i, clientID in ipairs(Clients) do
		local ClientID = (string.rep("0", 4 - string.len(clientID)) .. clientID)
		local ClientDBID, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 32)
		if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientDBID: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
		if string.len(ClientDBID) < 4 then
			ClientDBID = (string.rep("0", 4 - string.len(ClientDBID)) .. ClientDBID)
		end
		local ClientUID, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 0)
		if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientUID: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
		local ClientNickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 1)
		if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientNickname: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
		if adv == "true" then
			ClientType, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 40)
			if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientType: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
			local ClientSrvGrps, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 34)
			if error ~= ts3errors.ERROR_ok then xprint("Error getting ClientSrvGrps: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
			local ClientDscrp, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 45)
			if error ~= ts3errors.ERROR_ok then xprint("Error getting Client Description: " .. error .. " | SID: " .. serverConnectionHandlerID .. " | ClientID: " .. clientID) end
			xprint("│ " .. ClientID .. " | " .. ClientDBID .. " | " .. ClientUID .. " | " .. ClientType .. " | " .. ClientNickname .. " | " .. ClientDscrp .. " | " .. ClientSrvGrps)
		else
			xprint("│ " .. ClientID .. " | " .. ClientDBID .. " | " .. ClientUID .. " | " .. ClientNickname)
		end
		if (math.floor(i / 3)) == (i / 3) and #Clients ~= i then
			xprint("├───────────────────────────────────────────────────────────────────────────────────────────────")
		end
		if (math.floor(i / 9)) == (i / 9) and #Clients ~= i then
			if adv == "true" then
				xprint("│ ClID | DBID | UniqueID | Type | Nickname | Description | Servergroups")
			else
				xprint("│ ClID | DBID | UniqueID | Nickname")
			end
		end
	end
	xprint("└───────────────────────────────────────────────────────────────────────────────────────────────")
end

xprint("ClientInfo initialisiert!")