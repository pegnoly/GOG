if (GetGameVar('mk_q1_rune') + 0) == 0 then return end

dr_rune = round(GetGameVar('mk_q1_rune') + 0)
print('rune if: ', dr_rune)

AddCombatFunction(CombatFunctions.START,
function()
  --
  startThread(
  function()
    while 1 do
      if refresh_creature ~= '' then
        pcall(UnitCastAimedSpell, GetDefenderHero(), 259, refresh_creature)
        refresh_creature = ''
      end
      sleep()
    end
  end)
  --
  SetUnitManaPoints(GetDefenderHero(), 10000)
  --
  while not combatStarted() do
    sleep()
  end
  --
  DisableCombat()
  for i, creature in GetDefenderCreatures() do
    for i = 1, 7 do
      pcall(UnitCastAimedSpell, GetDefenderHero(), SPELL_WARCRY_CALL_OF_BLOOD, creature)
      print(GetRageLevel(creature))
    end
  end
  EnableCombat()
  --
  while not combatReadyPerson() do
    sleep()
  end
  --
end)

AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE,
function(creature)
  if pcall(UnitCastGlobalSpell,creature, dr_rune) then
    refresh_creature = creature
  end
end)