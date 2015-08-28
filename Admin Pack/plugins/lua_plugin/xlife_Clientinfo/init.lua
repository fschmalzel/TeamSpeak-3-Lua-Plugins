require("ts3init")            -- Required for ts3RegisterModule
require("xlife_Clientinfo/main")    -- Some demo functions callable from TS3 client chat input

local MODULE_NAME = "xlife_Clientinfo"

local registeredEvents = {}

ts3RegisterModule(MODULE_NAME, registeredEvents)
