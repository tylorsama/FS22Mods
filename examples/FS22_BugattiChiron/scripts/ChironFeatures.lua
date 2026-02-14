--[[
    ChironFeatures - Bugatti Chiron specialization for FS22

    Adds two drive modes (Road / Top Speed) and a HUD overlay showing
    current mode, speed in km/h, and engine RPM. Based on the real
    Chiron's two-key speed limiter system.

    Road mode:  380 km/h electronic limit (default)
    Top Speed:  420 km/h (requires pressing the mode key, like the
                real Chiron's "Top Speed Key" on the center console)
]]

ChironFeatures = {}

ChironFeatures.MODE_ROAD = 1
ChironFeatures.MODE_TOPSPEED = 2

ChironFeatures.MODE_NAMES = {
    [1] = "chiron_mode_road",
    [2] = "chiron_mode_topspeed",
}

ChironFeatures.SPEED_LIMITS = {
    [1] = 380,   -- Road mode: 380 km/h
    [2] = 420,   -- Top Speed mode: 420 km/h (factory max)
}

function ChironFeatures.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Motorized, specializations)
       and SpecializationUtil.hasSpecialization(Drivable, specializations)
end

function ChironFeatures.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", ChironFeatures)
    SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", ChironFeatures)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", ChironFeatures)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", ChironFeatures)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", ChironFeatures)
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", ChironFeatures)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", ChironFeatures)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", ChironFeatures)
end

function ChironFeatures:onLoad(savegame)
    local spec = self.spec_ChironFeatures
    spec.driveMode = ChironFeatures.MODE_ROAD
    spec.hudVisible = true
    spec.actionEvents = {}
    spec.modeChangeTimer = 0
    spec.modeChangeDisplayTime = 3000 -- show mode change notification for 3s
end

function ChironFeatures:onPostLoad(savegame)
    local spec = self.spec_ChironFeatures
    if savegame ~= nil and not savegame.resetVehicles then
        local key = savegame.key .. ".chironFeatures"
        spec.driveMode = Utils.getNoNil(
            getXMLInt(savegame.xmlFile, key .. "#driveMode"),
            ChironFeatures.MODE_ROAD
        )
    end
    ChironFeatures.applySpeedLimit(self)
end

function ChironFeatures:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local spec = self.spec_ChironFeatures

    -- Tick down mode-change notification timer
    if spec.modeChangeTimer > 0 then
        spec.modeChangeTimer = spec.modeChangeTimer - dt
    end

    -- Enforce speed limit for current mode
    if self.lastSpeed ~= nil then
        local speedKmh = math.abs(self.lastSpeed * 3600)
        local limit = ChironFeatures.SPEED_LIMITS[spec.driveMode]
        if speedKmh > limit then
            local motor = self.spec_motorized.motor
            if motor ~= nil and motor.setSpeedLimit ~= nil then
                motor:setSpeedLimit(limit)
            end
        end
    end
end

function ChironFeatures:onDraw(isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if not isActiveForInput then
        return
    end

    local spec = self.spec_ChironFeatures
    if not spec.hudVisible then
        return
    end

    local speedKmh = 0
    if self.lastSpeed ~= nil then
        speedKmh = math.abs(self.lastSpeed * 3600)
    end

    local rpm = 0
    if self.spec_motorized ~= nil and self.spec_motorized.motor ~= nil then
        rpm = self.spec_motorized.motor.lastMotorRpm or 0
    end

    local modeName = g_i18n:getText(ChironFeatures.MODE_NAMES[spec.driveMode])
    local limit = ChironFeatures.SPEED_LIMITS[spec.driveMode]

    -- === HUD Layout ===
    -- Bottom-right panel, above the vehicle info
    local baseX = 0.83
    local baseY = 0.30
    local lineHeight = 0.025
    local textSize = 0.018
    local headerSize = 0.015

    -- Background overlay
    local bgW = 0.16
    local bgH = 0.11
    setOverlayColor(GuiElement.OVERLAY_STATE_DEFAULT, 0, 0, 0, 0.5)

    -- Mode header
    setTextAlignment(RenderText.ALIGN_LEFT)
    setTextBold(true)
    setTextColor(0.8, 0.6, 0.1, 1) -- Bugatti gold
    renderText(baseX, baseY + 3 * lineHeight, headerSize, "BUGATTI CHIRON")

    -- Mode
    local modeColor = spec.driveMode == ChironFeatures.MODE_TOPSPEED
        and {1.0, 0.3, 0.2, 1.0}   -- red for top speed
        or  {0.2, 0.8, 0.4, 1.0}   -- green for road
    setTextColor(unpack(modeColor))
    setTextBold(false)
    renderText(baseX, baseY + 2 * lineHeight, textSize,
        string.format("%s [%d km/h]", modeName, limit))

    -- Speed
    setTextColor(1, 1, 1, 0.95)
    setTextBold(true)
    renderText(baseX, baseY + 1 * lineHeight, textSize + 0.004,
        string.format("%d km/h", speedKmh))

    -- RPM bar
    setTextBold(false)
    setTextColor(0.7, 0.7, 0.7, 0.8)
    local rpmPct = math.min(rpm / 6700, 1.0)
    local rpmBarWidth = 0.12
    renderText(baseX, baseY, headerSize,
        string.format("%d RPM", rpm))

    -- RPM bar background
    local barY = baseY - 0.008
    local barH = 0.005
    setTextColor(0.2, 0.2, 0.2, 0.6)
    renderText(baseX, barY, barH, string.rep("|", 30))

    -- RPM bar fill (color shifts from green to yellow to red)
    local r = math.min(rpmPct * 2, 1.0)
    local g = math.min(2 - rpmPct * 2, 1.0)
    setTextColor(r, g, 0.0, 0.9)
    local fillChars = math.floor(rpmPct * 30)
    if fillChars > 0 then
        renderText(baseX, barY, barH, string.rep("|", fillChars))
    end

    -- Mode change notification (fades out)
    if spec.modeChangeTimer > 0 then
        local alpha = math.min(spec.modeChangeTimer / 1000, 1.0)
        setTextAlignment(RenderText.ALIGN_CENTER)
        setTextBold(true)

        -- Shadow
        setTextColor(0, 0, 0, alpha * 0.7)
        renderText(0.501, 0.599, 0.035, modeName)

        -- Main text
        setTextColor(unpack(modeColor))
        setTextColor(modeColor[1], modeColor[2], modeColor[3], alpha)
        renderText(0.5, 0.6, 0.035, modeName)
    end

    -- Reset render state
    setTextAlignment(RenderText.ALIGN_LEFT)
    setTextBold(false)
    setTextColor(1, 1, 1, 1)
end

function ChironFeatures:onDelete()
    -- Nothing to clean up
end

function ChironFeatures:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_ChironFeatures
    setXMLInt(xmlFile, key .. "#driveMode", spec.driveMode)
end

function ChironFeatures:onReadStream(streamId, connection)
    local spec = self.spec_ChironFeatures
    spec.driveMode = streamReadInt8(streamId)
    ChironFeatures.applySpeedLimit(self)
end

function ChironFeatures:onWriteStream(streamId, connection)
    local spec = self.spec_ChironFeatures
    streamWriteInt8(streamId, spec.driveMode)
end

function ChironFeatures:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self.spec_ChironFeatures
        self:clearActionEventsTable(spec.actionEvents)

        if isActiveForInput then
            local _, actionEventId = self:addActionEvent(
                spec.actionEvents,
                "CHIRON_TOGGLE_MODE",
                self,
                ChironFeatures.onToggleMode,
                false, true, false, true
            )
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
            g_inputBinding:setActionEventText(actionEventId, g_i18n:getText("chiron_action_toggleMode"))
        end
    end
end

--- Toggle between Road and Top Speed modes.
function ChironFeatures:onToggleMode(actionName, inputValue, callbackState, isAnalog)
    local spec = self.spec_ChironFeatures

    if spec.driveMode == ChironFeatures.MODE_ROAD then
        spec.driveMode = ChironFeatures.MODE_TOPSPEED
    else
        spec.driveMode = ChironFeatures.MODE_ROAD
    end

    spec.modeChangeTimer = spec.modeChangeDisplayTime
    ChironFeatures.applySpeedLimit(self)
end

--- Apply the speed limit for the current drive mode.
function ChironFeatures.applySpeedLimit(vehicle)
    local spec = vehicle.spec_ChironFeatures
    if spec == nil then
        return
    end

    local limit = ChironFeatures.SPEED_LIMITS[spec.driveMode]
    if vehicle.spec_motorized ~= nil and vehicle.spec_motorized.motor ~= nil then
        local motor = vehicle.spec_motorized.motor
        if motor.setSpeedLimit ~= nil then
            motor:setSpeedLimit(limit)
        end
    end
end
