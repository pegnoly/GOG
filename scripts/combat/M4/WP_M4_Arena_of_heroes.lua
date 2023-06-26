if GetGameVar('arena_of_heroes_combat') == 'none' then return end

current_up = GetGameVar('ah_curr_up') + 0

AddCombatFunction(CombatFunctions.START,
function()
  EnableAutoFinish(nil)
  EnableDynamicBattleMode(1)
  startThread(
  function()
    while next(GetAttackerCreatures()) and next(GetDefenderCreatures()) do
      sleep()
    end
    repeat
      sleep()
    until combatReadyPerson()
    DisableCombat()
    if not next(GetAttackerCreatures()) then
      SetGameVar('arena_of_heroes_combat', 'lost')
      combatPlayEmotion(DEFENDER, 1)
    else
      SetGameVar('arena_of_heroes_combat', 'win')
      combatPlayEmotion(ATTACKER, 1)
    end
    sleep(200)
    Break()
  end)
end)

