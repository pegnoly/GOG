if GetGameVar('test') == 'none' then return end

if GetGameVar('test') == 'spec_test' then
  AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE,
  function(unit)
    commandDefend(unit)
    return 1
  end)
end