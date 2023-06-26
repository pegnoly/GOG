if not (GetEnemyHeroName() == Malgumol) then return end

print('Malgumol fight started')

AddCombatFunction(CombatFunctions.START,
function()
  for i, creature in GetDefenderCreatures() do
    pcall(UnitCastGlobalSpell, creature, 249)
  end
end)

--malg_fight =
--{
--  runic_echo_counter = 10,
--  runic_echo_period  = 75 - diff * 5
--}
--
--function EpicRunicEchoCounterThread()
--  while 1 do
--    sleep(malg_fight.runic_echo_period)
--    malg_fight.runic_echo_counter = malg_fight.runic_echo_counter - 1
--    startThread(CombatFlyingSign, rtext(malg_fight.runic_echo_counter), GetHero(enemy_side), 3.0)
--    if malg_fight.runic_echo_counter == 0 then
--      startThread(EpicRunicEchoPerform)
--      while malg_fight.runic_echo_counter ~= 10 do
--        sleep()
--      end
--    end
--  end
--end
--
--function EpicRunicEchoPerform()
--  DisableCombat()
--  for i, unit in GetCreatures(player_side) do
--    if pcall(UnitCastAimedSpell, GetHero(enemy_side), SPELL_VEIL_TECH_RUNIC_ECHO, unit) then
--      sleep(120)
--    end
--  end
--  EnableCombat()
--  malg_fight.runic_echo_counter = 10
--end
--
--AddCombatFunction(CombatFunctions.START,
--function()
--  SetUnitManaPoints(GetHero(enemy_side), 500)
--  startThread(EpicRunicEchoCounterThread)
--end)
