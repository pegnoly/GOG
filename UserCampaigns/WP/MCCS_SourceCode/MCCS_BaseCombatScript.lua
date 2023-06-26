--------------------------------------------------------------------------------
-- базовый скрипт. ќпредел€ет услови€ бо€ и назначает боевые функции согласно им.
-- —истема организации скрипта, а так же √ѕ—„ и некоторые другие функции позаимствованы
-- из карты Ёхо ѕустоты от RedHeavenHero, за что ему огромна€ благодарность
--consoleCmd('game_writelog 1')
-- номер бо€(дл€ дебага) 0.4.0
--do
--  local fight_number = -1
--  if GetGameVar("MCCS_FightNumber") == '' then
--    fight_number = 1
--    SetGameVar("MCCS_FightNumber", 1)
--  else
--    fight_number = ceil(GetGameVar("MCCS_FightNumber") + 0) + 1
--    SetGameVar("MCCS_FightNumber", fight_number)
--  end
--  local attacker = GetHeroName(GetAttackerHero())
--  local defender = GetDefenderHero() and GetHeroName(GetDefenderHero()) or "neutrals"
--  print("##Combat mode started##")
--  print("Fight є", fight_number, ' started between ', attacker, ' and ', defender)
--end

doFile('/scripts/lib/combat_init.lua')
doFile('/scripts/lib/mccs_default_settings.lua')
while not (hero_info and InitGlobalTables) do
  sleep()
end
InitGlobalTables()

ATB_FILTER = 64679235
GetCreatureAtb = function(unit) return GetCreatureCount(unit, ATB_FILTER)
end

--
--------------------------------------------------------------------------------
-- определение режима игры(один компьютер или сеть)

if GetGameVar('MCCS_IsHotseat') == 'true' then
  print('<color=yellow>Game mode: <color=green>single or hotseat')
  local curr_owner = GetGameVar(GetHeroName(GetAttackerHero())..'_owner')
  if GetGameVar('combat_active_thread') ~= curr_owner then
    SetGameVar('combat_active_thread', curr_owner)
  end
  print('curr script owner changed to ', curr_owner)
  consoleCmd("@SetGameVar('"..curr_owner.."_combat_mode', 'real')")
  if GetDefenderHero() then
    local def_owner = GetGameVar(GetHeroName(GetDefenderHero())..'_owner')
    consoleCmd("@SetGameVar('"..def_owner.."_combat_mode', 'real')")
  end
-- LAN
else
   print('<color=yellow>Game mode: <color=green>LAN')
   if GetGameVar(GetHeroName(GetAttackerHero())..'_owner') == '1' and
    GetGameVar('combat_active_thread') == '' then
    SetGameVar('combat_active_thread', '1')
    --consoleCmd("@SetGameVar('combat_active_thread', '1')")
    print('<color=yellow>LAN: <color=green>player 1 calibrated')
  end
  --
  if GetGameVar(GetHeroName(GetAttackerHero())..'_owner') == '2' and
    GetGameVar('combat_active_thread') == '' then
    SetGameVar('combat_active_thread', '2')
    --consoleCmd("@SetGameVar('combat_active_thread', '2')")
    print('<color=yellow>LAN: <color=green>player 2 calibrated')
  end
  --
  if GetGameVar(GetHeroName(GetAttackerHero())..'_owner') == '3' and
    GetGameVar('combat_active_thread') == '' then
    SetGameVar('combat_active_thread', '3')
    --consoleCmd("@SetGameVar('combat_active_thread', '3')")
    print('<color=yellow>LAN: <color=green>player 3 calibrated')
  end
  --
  if GetGameVar(GetHeroName(GetAttackerHero())..'_owner') == '4' and
    GetGameVar('combat_active_thread') == '' then
    SetGameVar('combat_active_thread', '4')
    --consoleCmd("@SetGameVar('combat_active_thread', '4')")
    print('<color=yellow>LAN: <color=green>player 4 calibrated')
  end
  --
  if GetGameVar(GetHeroName(GetAttackerHero())..'_owner') == '5' and
    GetGameVar('combat_active_thread') == '' then
    SetGameVar('combat_active_thread', '5')
    --consoleCmd("@SetGameVar('combat_active_thread', '5')")
    print('<color=yellow>LAN: <color=green>player 5 calibrated')
  end
  --
  if GetGameVar(GetHeroName(GetAttackerHero())..'_owner') == '6' and
    GetGameVar('combat_active_thread') == '' then
    SetGameVar('combat_active_thread', '6')
    --consoleCmd("@SetGameVar('combat_active_thread', '6')")
    print('<color=yellow>LAN: <color=green>player 6 calibrated')
  end
  --
  if GetGameVar(GetHeroName(GetAttackerHero())..'_owner') == '7' and
    GetGameVar('combat_active_thread') == '' then
    SetGameVar('combat_active_thread', '7')
    --consoleCmd("@SetGameVar('combat_active_thread', '7')")
    print('<color=yellow>LAN: <color=green>player 7 calibrated')
  end
  --
  if GetGameVar(GetHeroName(GetAttackerHero())..'_owner') == '8' and
    GetGameVar('combat_active_thread') == '' then
    SetGameVar('combat_active_thread', '8')
    --consoleCmd("@SetGameVar('combat_active_thread', '8')")
    print('<color=yellow>LAN: <color=green>player 8 calibrated')
  end
end

--
--------------------------------------------------------------------------------
-- таблицы армий

attacker_army = {} -- базова€ нападающего(поддерживает добавление призванных)
attacker_real_army = {} -- реальна€ нападающего(учитываютс€ только стартовые юниты)
attacker_army_copies = {} -- таблица копий армии нападающего(нужно, если манипул€ции изменени€ затрагивают базовую таблицу, а инфа из нее нужна где-то еще)
                        -- если така€ необходимость возникла, просто создаем копии армии и измен€ем их
defender_army = {} -- аналогичные дл€ стороны защиты
defender_real_army = {}
defender_army_copies = {}

--reserved_turn = 0 -- флаг, что нужно скипнуть ход(в случае, когда вражеский юнит что-то кастует,
                  -- а затем должен сделать что-то еще по скрипту, UNIT_MOVE запускаетс€ оп€ть и это может привести к проблемем)
                  
                  
-- ивенты
combat_event_add_creature = {}
combat_event_turn_end = {}

function AddCombatEvent(event_table, desc, func)
  event_table[desc] = func
end
--
--------------------------------------------------------------------------------

print((GetGameVar('active_scripts')))
paths = parse(GetGameVar('active_scripts'))()

-- получает функции дл€ управлени€ боем согласно его услови€м
function GetCombatFunctions()
  local thread = GetGameVar('combat_active_thread')
  consoleCmd("@SetGameVar('"..thread.."_combat_mode', 'real')")
  print ('<color=yellow>Combat thread: <color=green>active thread is: ', thread)
  if thread ~= GetGameVar(GetHeroName(GetAttackerHero())..'_owner') then
    print('<color=yellow>Combat thread: <color=green>another script thread is active so skip this')
    return
  end
  print("<color=yellow>Combat thread: <color=green>combat thread is same with attacker's owner, so this thread will be executed")
  --
  AddCombatFunction(CombatFunctions.START,
  function()
    InitRandom()
    while not random do
      sleep()
    end
   	for i, unit in GetCreatures(ATTACKER) do
      attacker_army[unit] = GetCreatureNumber(unit)
    end
    table.copy(attacker_army, attacker_real_army)
    for i, unit in GetCreatures(DEFENDER) do
      defender_army[unit] = GetCreatureNumber(unit)
    end
    table.copy(defender_army, defender_real_army)
    startThread(NewCreaturesAddToTablesThread)
    --
    for side = ATTACKER, DEFENDER do
      for i, creature in GetCreatures(side) do
        local abils_info = GetCreatureActiveAbilsInfo(creature)
        --print('abils_info: ', abils_info)
        if abils_info == HAS_BY_DEFAULT and GetUnitMaxManaPoints(creature) == 0 then
          SetUnitManaPoints(creature, 1)
        end
      end
    end
    --
    for i, creature in GetAttackerCreatures() do
      print(creature, " has position ", GetCreatureNumber(creature, 64679235))
    end
    --
  end)
  --
  if paths then
    for i, path in paths.to_cmb do
      doFile(path)
    end
  end
  --
end

-- добавл€ет функцию в таблицу, соответсвующую базовой функции
function AddCombatFunction(event_table, func)
	local l = length(event_table)
	event_table[l + 1] = func
end

-- последовательно вызывает функции из таблицы
function CallCombatFunctions(event_table, param, temp)
	local x
	for i = 1, length(event_table) do
    x = event_table[i](param) or temp
	end
	return x
end

-- таблицы дл€ базовых функций
CombatFunctions =
{
  PREPARE = {},

	START = {},

	UNIT_MOVE = {},

	ATTACKER_UNIT_MOVE = {},
	ATTACKER_HERO_MOVE = {},
	ATTACKER_CREATURE_MOVE = {},
	ATTACKER_WARMACHINE_MOVE = {},
	ATTACKER_BUILDING_MOVE = {},

  DEFENDER_UNIT_MOVE = {},
	DEFENDER_HERO_MOVE = {},
	DEFENDER_CREATURE_MOVE = {},
	DEFENDER_WARMACHINE_MOVE = {},
	DEFENDER_BUILDING_MOVE = {},

	UNIT_DEATH = {},

  ATTACKER_UNIT_DEATH = {},
	ATTACKER_CREATURE_DEATH = {},
	ATTACKER_WARMACHINE_DEATH = {},
	ATTACKER_BUILDING_DEATH = {},

	DEFENDER_UNIT_DEATH = {},
	DEFENDER_CREATURE_DEATH = {},
	DEFENDER_WARMACHINE_DEATH = {},
	DEFENDER_BUILDING_DEATH = {},
}

-- базовые функции
function Prepare()
	CallCombatFunctions(CombatFunctions.PREPARE)
end

function Start()
	startThread(CallCombatFunctions, CombatFunctions.START)
end

function UnitMove(unit)
  local res = CallCombatFunctions(CombatFunctions.UNIT_MOVE, unit)
  if IsAttacker(unit) then
    res = CallCombatFunctions(CombatFunctions.ATTACKER_UNIT_MOVE, unit, res)
    if IsHero(unit) then
      res = CallCombatFunctions(CombatFunctions.ATTACKER_HERO_MOVE, unit, res)
    elseif IsCreature(unit) then
      res = CallCombatFunctions(CombatFunctions.ATTACKER_CREATURE_MOVE, unit, res)
    elseif IsWarMachine(unit) then
      res = CallCombatFunctions(CombatFunctions.ATTACKER_WARMACHINE_MOVE, unit, res)
    elseif IsBuilding(unit) then
      res = CallCombatFunctions(CombatFunctions.ATTACKER_BUILDING_MOVE, unit, res)
    end
  elseif IsDefender(unit) then
    res = CallCombatFunctions(CombatFunctions.DEFENDER_UNIT_MOVE, unit, res)
    if IsHero(unit) then
      res = CallCombatFunctions(CombatFunctions.DEFENDER_HERO_MOVE, unit, res)
    elseif IsCreature(unit) then
      res = CallCombatFunctions(CombatFunctions.DEFENDER_CREATURE_MOVE, unit, res)
    elseif IsWarMachine(unit) then
      res = CallCombatFunctions(CombatFunctions.DEFENDER_WARMACHINE_MOVE, unit, res)
    elseif IsBuilding(unit) then
      res = CallCombatFunctions(CombatFunctions.DEFENDER_BUILDING_MOVE, unit, res)
    end
  end
  return res
end

function UnitDeath(unit)
  CallCombatFunctions(CombatFunctions.UNIT_DEATH, unit)
  if IsAttacker(unit) then
    CallCombatFunctions(CombatFunctions.ATTACKER_UNIT_DEATH, unit)
    if IsCreature(unit) then
      CallCombatFunctions(CombatFunctions.ATTACKER_CREATURE_DEATH, unit)
    elseif IsWarMachine(unit) then
      CallCombatFunctions(CombatFunctions.ATTACKER_WARMACHINE_DEATH, unit)
    elseif IsBuilding(unit) then
      CallCombatFunctions(CombatFunctions.ATTACKER_BUILDING_DEATH, unit)
    end
  elseif IsDefender(unit) then
    CallCombatFunctions(CombatFunctions.DEFENDER_UNIT_DEATH, unit)
    if IsCreature(unit) then
      CallCombatFunctions(CombatFunctions.DEFENDER_CREATURE_DEATH, unit)
    elseif IsWarMachine(unit) then
      CallCombatFunctions(CombatFunctions.DEFENDER_WARMACHINE_DEATH, unit)
    elseif IsBuilding(unit) then
      CallCombatFunctions(CombatFunctions.DEFENDER_BUILDING_DEATH, unit)
    end
  end
end

startThread(GetCombatFunctions)
--AddCombatFunction(CombatFunctions.UNIT_MOVE,
--function(unit)
--  if reserved_turn == 1 then
--    print('turn skipped...')
--    reserved_turn = 0
--  end
--end)