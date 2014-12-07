require("ts3init")            -- Required for ts3RegisterModule
require("xlife/events")  -- Forwarded TeamSpeak 3 callbacks
require("xlife/main")    -- Some demo functions callable from TS3 client chat input

local MODULE_NAME = "xlife"

local registeredEvents = {
	onTextMessageEvent = xlife_events.onTextMessageEvent,
	onPluginCommandEvent = xlife_events.onPluginCommandEvent
}

ts3RegisterModule(MODULE_NAME, registeredEvents)
