--[[
    register.lua - Register ChironFeatures specialization

    This file is loaded via <extraSourceFiles> in modDesc.xml.
    It registers the ChironFeatures specialization so it's available
    for the bugattiChiron vehicle type defined in modDesc.xml.

    Note: Unlike the ExampleScript mod which injects into ALL drivable
    vehicles, this registration is handled by the <vehicleTypes> section
    in modDesc.xml, which explicitly adds chironFeatures only to the
    bugattiChiron type. This file just ensures the class is loaded.
]]

local modDirectory = g_currentModDirectory or ""
local modName = g_currentModName or ""

-- Source the specialization file to make the class available
source(modDirectory .. "scripts/ChironFeatures.lua")
