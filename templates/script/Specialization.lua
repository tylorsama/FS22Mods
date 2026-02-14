--[[
    {{SPEC_CLASS}} - FS22 Vehicle Specialization Template

    A specialization adds custom behavior to vehicles. Register event listeners
    for the lifecycle hooks you need, and access per-vehicle data via
    self.spec_{{SPEC_CLASS}}.

    Required functions: prerequisitesPresent, registerEventListeners
]]

{{SPEC_CLASS}} = {}

--- Check that required base specializations are present on the vehicle type.
-- Return true if all prerequisites are met.
function {{SPEC_CLASS}}.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Drivable, specializations)
end

--- Register which lifecycle events this specialization listens to.
function {{SPEC_CLASS}}.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", {{SPEC_CLASS}})
    SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", {{SPEC_CLASS}})
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", {{SPEC_CLASS}})
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", {{SPEC_CLASS}})
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", {{SPEC_CLASS}})
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", {{SPEC_CLASS}})
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", {{SPEC_CLASS}})
end

--- Called when the vehicle is loaded into the world.
function {{SPEC_CLASS}}:onLoad(savegame)
    local spec = self.spec_{{SPEC_CLASS}}
    spec.isActive = false
end

--- Called after all specializations have finished onLoad.
function {{SPEC_CLASS}}:onPostLoad(savegame)
    local spec = self.spec_{{SPEC_CLASS}}
    if savegame ~= nil and not savegame.resetVehicles then
        local key = savegame.key .. ".{{SPEC_KEY}}"
        spec.isActive = Utils.getNoNil(getXMLBool(savegame.xmlFile, key .. "#isActive"), false)
    end
end

--- Called every frame. dt is delta time in milliseconds.
function {{SPEC_CLASS}}:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local spec = self.spec_{{SPEC_CLASS}}
    if not spec.isActive then
        return
    end

    -- Update logic here
end

--- Called when the vehicle is removed from the world.
function {{SPEC_CLASS}}:onDelete()
    -- Cleanup resources here
end

--- Save specialization state to the savegame XML.
function {{SPEC_CLASS}}:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_{{SPEC_CLASS}}
    setXMLBool(xmlFile, key .. "#isActive", spec.isActive)
end

--- Multiplayer: read initial state when a client joins.
function {{SPEC_CLASS}}:onReadStream(streamId, connection)
    local spec = self.spec_{{SPEC_CLASS}}
    spec.isActive = streamReadBool(streamId)
end

--- Multiplayer: write initial state when a client joins.
function {{SPEC_CLASS}}:onWriteStream(streamId, connection)
    local spec = self.spec_{{SPEC_CLASS}}
    streamWriteBool(streamId, spec.isActive)
end

--- Register input action events when the player enters the vehicle.
function {{SPEC_CLASS}}:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self.spec_{{SPEC_CLASS}}
        self:clearActionEventsTable(spec.actionEvents)

        if isActiveForInput then
            local _, actionEventId = self:addActionEvent(
                spec.actionEvents,
                "{{ACTION_NAME}}",
                self,
                {{SPEC_CLASS}}.onActionToggle,
                false, true, false, true
            )
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
            g_inputBinding:setActionEventText(actionEventId, g_i18n:getText("{{L10N_TOGGLE_KEY}}"))
        end
    end
end

--- Handle the toggle action input.
function {{SPEC_CLASS}}:onActionToggle(actionName, inputValue, callbackState, isAnalog)
    local spec = self.spec_{{SPEC_CLASS}}
    spec.isActive = not spec.isActive
end
