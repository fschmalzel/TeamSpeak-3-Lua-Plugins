require("ts3init")            -- Required for ts3RegisterModule
require("xlife_mp/main")    -- Some demo functions callable from TS3 client chat input

local MODULE_NAME = "xlife_mp"

local registeredEvents = {}

ts3RegisterModule(MODULE_NAME, registeredEvents)
