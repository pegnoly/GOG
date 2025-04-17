--- Enables/disables default logic of combat finish detection(default logic = no non-summoned units on battlefield). 
--- 
--- If it is disabled only functions like Finish or Break can finish the battle.
---@param is_enabled nil | number nil = disable default logic, 1|not nil = enable
function EnableAutoFinish(is_enabled)
end

--- Enables/disables camera close-ups in fight
---@param is_enabled nil | number nil = disable camera, 1|not nil = enable
function EnableCinematicCamera(is_enabled)
end

--- Enables/disables dynamic battle mode
---@param is_enabled nil | number nil = disable dynamic battle, 1|not nil = enable
function EnableDynamicBattleMode(is_enabled)
end

--- Returns is the unit currently exists on the battlefield.
---@param unit string Unit script name
---@return nil|number exists unit exist or not. Nil = not exists, 1|not nil = exists
function exist(unit)
    return nil
end