--[[
    main.lua - Script-only mod template

    For mods that modify gameplay without adding vehicles or placeables.
    Hooks into game lifecycle events directly.
]]

{{MOD_CLASS}} = {}

{{MOD_CLASS}}.modDirectory = g_currentModDirectory or ""
{{MOD_CLASS}}.modName = g_currentModName or ""

--- Called when the mission (game session) has finished loading.
function {{MOD_CLASS}}:onMissionLoaded(mission)
    {{MOD_CLASS}}.mission = mission
    print(string.format("[%s] Mod loaded successfully.", {{MOD_CLASS}}.modName))
end

--- Called on each game update tick.
function {{MOD_CLASS}}:onUpdate(dt)
    -- Per-frame update logic here
end

--- Called when the savegame is saved.
function {{MOD_CLASS}}:onSave(xmlFile, key)
    -- Save mod state here
end

--- Called when the mission is about to be deleted.
function {{MOD_CLASS}}:onMissionDelete()
    {{MOD_CLASS}}.mission = nil
end

-- Hook into game lifecycle
Mission00.loadMission00Finished = Utils.appendedFunction(
    Mission00.loadMission00Finished,
    function(mission, node)
        {{MOD_CLASS}}:onMissionLoaded(mission)
    end
)

BaseMission.delete = Utils.prependedFunction(
    BaseMission.delete,
    function(mission)
        {{MOD_CLASS}}:onMissionDelete()
    end
)
