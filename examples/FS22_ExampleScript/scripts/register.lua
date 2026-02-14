--[[
    register.lua - Inject SpeedDisplay into all drivable vehicles

    This runs at mod load time and adds the SpeedDisplay specialization
    to every vehicle type that has the Drivable specialization.
]]

local modDirectory = g_currentModDirectory or ""
local modName = g_currentModName or ""

local function addSpeedDisplaySpec()
    if g_specializationManager == nil then
        return
    end

    g_specializationManager:addSpecialization(
        "speedDisplay",
        "SpeedDisplay",
        modDirectory .. "scripts/SpeedDisplay.lua",
        nil
    )

    for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
        if SpecializationUtil.hasSpecialization(Drivable, typeEntry.specializations) then
            g_vehicleTypeManager:addSpecialization(typeName, modName .. ".speedDisplay")
        end
    end
end

TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, addSpeedDisplaySpec)
