--[[
    register.lua - Inject a specialization into existing vehicle types

    This script hooks into TypeManager.finalizeTypes to register a custom
    specialization and add it to all vehicles that have the Drivable spec.
    Include this file in modDesc.xml via <extraSourceFiles>.
]]

local modDirectory = g_currentModDirectory or ""
local modName = g_currentModName or ""

local function addSpecializations()
    if g_specializationManager == nil then
        return
    end

    g_specializationManager:addSpecialization(
        "{{SPEC_NAME}}",
        "{{SPEC_CLASS}}",
        modDirectory .. "scripts/{{SPEC_CLASS}}.lua",
        nil
    )

    for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
        if SpecializationUtil.hasSpecialization(Drivable, typeEntry.specializations) then
            g_vehicleTypeManager:addSpecialization(typeName, modName .. ".{{SPEC_NAME}}")
        end
    end
end

TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, addSpecializations)
