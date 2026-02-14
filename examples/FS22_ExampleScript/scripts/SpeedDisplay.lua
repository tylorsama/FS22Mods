--[[
    SpeedDisplay - Example FS22 Specialization

    Shows current vehicle speed as large text on the HUD.
    Demonstrates: event listeners, onDraw HUD rendering, input actions,
    multiplayer sync, and savegame persistence.
]]

SpeedDisplay = {}

function SpeedDisplay.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Drivable, specializations)
end

function SpeedDisplay.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", SpeedDisplay)
    SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", SpeedDisplay)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", SpeedDisplay)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", SpeedDisplay)
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", SpeedDisplay)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", SpeedDisplay)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", SpeedDisplay)
end

function SpeedDisplay:onLoad(savegame)
    local spec = self.spec_SpeedDisplay
    spec.isVisible = true
    spec.actionEvents = {}
end

function SpeedDisplay:onPostLoad(savegame)
    local spec = self.spec_SpeedDisplay
    if savegame ~= nil and not savegame.resetVehicles then
        local key = savegame.key .. ".speedDisplay"
        spec.isVisible = Utils.getNoNil(getXMLBool(savegame.xmlFile, key .. "#isVisible"), true)
    end
end

function SpeedDisplay:onDraw(isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if not isActiveForInput then
        return
    end

    local spec = self.spec_SpeedDisplay
    if not spec.isVisible then
        return
    end

    -- Get speed in km/h (self.lastSpeed is in m/ms, multiply by 3600 for km/h)
    local speedKmh = math.abs(self.lastSpeed * 3600)

    -- Format the display string
    local speedText = string.format("%d km/h", speedKmh)

    -- Render at the top-center of the screen
    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextBold(true)
    setTextColor(1, 1, 1, 0.9)

    -- Drop shadow
    local x, y = 0.5, 0.92
    local textSize = 0.04
    setTextColor(0, 0, 0, 0.6)
    renderText(x + 0.001, y - 0.001, textSize, speedText)

    -- Main text
    setTextColor(1, 1, 1, 0.9)
    renderText(x, y, textSize, speedText)

    -- Reset render state
    setTextAlignment(RenderText.ALIGN_LEFT)
    setTextBold(false)
    setTextColor(1, 1, 1, 1)
end

function SpeedDisplay:onDelete()
    -- Nothing to clean up for this simple mod
end

function SpeedDisplay:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_SpeedDisplay
    setXMLBool(xmlFile, key .. "#isVisible", spec.isVisible)
end

function SpeedDisplay:onReadStream(streamId, connection)
    local spec = self.spec_SpeedDisplay
    spec.isVisible = streamReadBool(streamId)
end

function SpeedDisplay:onWriteStream(streamId, connection)
    local spec = self.spec_SpeedDisplay
    streamWriteBool(streamId, spec.isVisible)
end

function SpeedDisplay:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self.spec_SpeedDisplay
        self:clearActionEventsTable(spec.actionEvents)

        if isActiveForInput then
            local _, actionEventId = self:addActionEvent(
                spec.actionEvents,
                "TOGGLE_SPEED_DISPLAY",
                self,
                SpeedDisplay.onToggleDisplay,
                false, true, false, true
            )
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
            g_inputBinding:setActionEventText(actionEventId, g_i18n:getText("speedDisplay_toggle"))
        end
    end
end

function SpeedDisplay:onToggleDisplay(actionName, inputValue, callbackState, isAnalog)
    local spec = self.spec_SpeedDisplay
    spec.isVisible = not spec.isVisible
end
