if GetGameVar('dung_fight') == 'none' then return end

function SetTraps()
  DisableCombat()
  SetUnitManaPoints(GetDefenderCreatures()[0], 10000)
  while GetUnitManaPoints(GetDefenderCreatures()[0]) ~= 10000 do sleep() end
  for x = 2, 14 do
    for y = 2, 14 do
      pcall(UnitCastAreaSpell, GetDefenderCreatures()[0], SPELL_LAND_MINE, x, y)
    end
  end
  EnableCombat()
end

if GetGameVar('dung_fight') == 'dragon_trap' then
  AddCombatFunction(CombatFunctions.START, SetTraps)
  AddCombatFunction(CombatFunctions.UNIT_MOVE,
  function(unit)
    if ((unit == GetAttackerHero()) or (unit == GetDefenderCreatures()[0])) then
      commandDefend(unit)
      return not nil
    end
  end)
end


last_fury = ''
rage_info = {}

if GetGameVar('dung_fight') == 'fury' then
  AddCombatFunction(CombatFunctions.START,
  function()
    EnableCinematicCamera(nil)
    for i, creature in GetCreatures(DEFENDER) do
      rage_info[creature] = 0
      SetUnitManaPoints(creature, 20)
    end
  end)
  AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE,
  function(creature)
    if rage_info[creature] == 2 then
      pcall(commandDoSpecial, creature, SPELL_ABILITY_BERSERKER_RAGE)
    elseif rage_info[creature] == 1 then
      --DisableCombat()
      combatSetPause(1)
      sleep()
      rage_info[last_fury] = 2
      local name = GetCreatureName(GetCreatureType(last_fury))
      --startThread(playAnimation, last_fury, 'happy', ONESHOT)
      startThread(CombatFlyingSign, rtext('<color=red>'..name..' впадают в кровавую ярость!'), last_fury, 30.0)
      UnitCastAimedSpell(last_fury, SPELL_BLOODLUST, last_fury)
      sleep(300)
      combatSetPause(nil)
      return
      --EnableCombat()
    else
      last_fury = creature
    end
  end)
  AddCombatFunction(CombatFunctions.ATTACKER_CREATURE_DEATH,
  function(creature)
    if rage_info[last_fury] == 0 then
      rage_info[last_fury] = 1
      setATB(last_fury, 1)
    end
  end)
end

-- бой с проклятой рохой
if GetGameVar('dung_fight') == 'cursed_rock' then
  AddCombatFunction(CombatFunctions.PREPARE,
  function()
    --SetControlMode(ATTACKER, MODE_AUTO)
  end)
  AddCombatFunction(CombatFunctions.START,
  function()
    EnableAutoFinish(nil)
    --
    startThread(
    function()
      local check = 1
      while 1 do
        if not next(GetAttackerCreatures()) then
          Finish(DEFENDER)
        end
        if not next(GetDefenderCreatures()) then
          if check then
            AddCreature(ATTACKER, CREATURE_GREMLIN, 1)
            check = nil
          end
          Finish(ATTACKER)
        end
        sleep()
      end
    end)
    --
    DisableCombat()
    local replace_tbl, n = {}, 0
    for i, creature in GetAttackerCreatures() do
      local cx, cy = pos(creature)
      n = n + 1
      -- сохранить инфу о базовых отрядах
      replace_tbl[n] = {type = GetCreatureType(creature),  count = GetCreatureNumber(creature), x = cx, y = cy}
      SetUnitManaPoints(creature, 500)
    end
    sleep(100)
    -- вызвать фантомы
    for i, creature in GetAttackerCreatures() do
      pcall(UnitCastAimedSpell, creature, SPELL_PHANTOM, creature)
    end
    sleep(300)
    -- убрать базовые отряды
    for creature, count in player_real_army do
      removeUnit(creature)
    end
    sleep(300)
    -- переместить фантомы в положения базовых отрядов
    for i, creature in GetAttackerCreatures() do
      if exist(creature) then
        local type, count = GetCreatureType(creature), GetCreatureNumber(creature)
        for i, rep_info in replace_tbl do
          if rep_info.type == type and rep_info.count == count then
            displace(creature, rep_info.x, rep_info.y)
            startThread(playAnimation, creature, 'idle00', ONESHOT)
            replace_tbl = table.remove(replace_tbl, i)
            break
          end
        end
      end
    end
    EnableCombat()
  end)
end