--------------------------------------------------------------------------------
-- обработка специализации Карлама - Взаимная поддержка
-- условие запуска - Карлам участвует в бою

karlam_spec =
{
  SHOOTERS =
  {
    CREATURE_GREMLIN, CREATURE_MASTER_GREMLIN, CREATURE_GREMLIN_SABOTEUR, 374,
    CREATURE_MAGI, CREATURE_ARCH_MAGI, CREATURE_COMBAT_MAGE, 350,
    CREATURE_TITAN, CREATURE_STORM_LORD
  },

  MELEE =
  {
    CREATURE_STONE_GARGOYLE, CREATURE_OBSIDIAN_GARGOYLE, CREATURE_MARBLE_GARGOYLE, 366,
    -- CREATURE_IRON_GOLEM, CREATURE_STEEL_GOLEM, CREATURE_OBSIDIAN_GOLEM,
    CREATURE_GENIE, CREATURE_MASTER_GENIE, CREATURE_DJINN_VIZIER, 342,
    CREATURE_RAKSHASA, CREATURE_RAKSHASA_RUKH, CREATURE_RAKSHASA_KSHATRI, 334,
    CREATURE_GIANT, 326
  },

  [ATTACKER] =
  {
    -- lvl
    -- soldier_luck
    -- buff_info
  },
  
  [DEFENDER] = {}
}

if GetHeroName(GetHero(ATTACKER)) == Karlam then
  karlam_spec[ATTACKER] =
  {
    lvl = GetGameVar('karlam_lvl') + 0,
    soldier_luck = GetGameVar('karlam_soldier_luck') + 0,
    buff_info = {}
  }
  --
  AddCombatFunction(CombatFunctions.START,
  function()
    KarlamSpec_BuffInfoInit(ATTACKER)
  end)
  --
  AddCombatFunction(CombatFunctions.ATTACKER_CREATURE_MOVE,
  function(creature)
    KarlamSpec_TryToEncourage(creature, ATTACKER)
  end)
  --
end

if GetHero(DEFENDER) and
   (GetHeroName(GetHero(DEFENDER)) == Karlam) then
  karlam_spec[DEFENDER] =
  {
    lvl = GetGameVar('karlam_lvl') + 0,
    soldier_luck = GetGameVar('karlam_soldier_luck') + 0,
    buff_info = {}
  }
  --
  AddCombatFunction(CombatFunctions.START,
  function()
    KarlamSpec_BuffInfoInit(DEFENDER)
  end)
  --
  AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE,
  function(creature)
    KarlamSpec_TryToEncourage(creature, DEFENDER)
  end)
  --
end

--
--------------------------------------------------------------------------------
--
function KarlamSpec_BuffInfoInit(side)
  for i, creature in GetCreatures(side) do
    if GetCreatureTown(GetCreatureType(creature)) == TOWN_ACADEMY then
      karlam_spec[side].buff_info[creature] = 0
    end
  end
end

function KarlamSpec_GetTargets(unit_type, side)
  local answer, n = {}, 0
  for i, creature in GetCreatures(side) do
    local type = GetCreatureType(creature)
    if contains(unit_type, type) then
      n = n + 1
      answer[n] = creature
    end
  end
  if n > 0 then
    return answer
  else
    return nil
  end
end

function KarlamSpec_TryToEncourage(creature, side)
  local type = GetCreatureType(creature)
  -- не существо Академии - сразу выход
  if (not (GetCreatureTown(type) == TOWN_ACADEMY)) then return end
  -- новое существо, не записанное в таблицу?
  if (not karlam_spec[side].buff_info[creature]) then
    karlam_spec[side].buff_info[creature] = 0 -- записать
  end
  -- этот юнит уже бафал кого-то?
  if karlam_spec[side].buff_info[creature] == 1 then
    karlam_spec[side].buff_info[creature] = 0 -- сбросить флаг
    return
  else
    -- существо - стрелок?
    if contains(karlam_spec.SHOOTERS, type) then
      local targets = KarlamSpec_GetTargets(karlam_spec.MELEE, side) -- найти милишные цели
      if targets then -- если они есть
        local chance = 0.15 + 0.01 * karlam_spec[side].lvl -- рассчитать шанс
        local success
        if random() < chance then -- шанс прокнул
          success = 1
        elseif karlam_spec[side].soldier_luck == 1 then -- солдатская удача
          print('2nd try')
          if random() < chance then
            success = 1
          end
        end
        if success and pcall(UnitCastAimedSpell, creature, SPELL_ENCOURAGE, targets[random(length(targets))]) then -- и каст прошел
          karlam_spec[side].buff_info[creature] = 1 -- поставить флаг, чтобы предотвратить двойной баф
          setATB(creature, 1)
        end
      end
    elseif contains(karlam_spec.MELEE, type) then
      -- аналогично для милишников
      local targets = KarlamSpec_GetTargets(karlam_spec.SHOOTERS, side)
      if targets then
        local chance = 0.15 + 0.01 * karlam_spec[side].lvl -- рассчитать шанс
        local success
        if random() < chance then -- шанс прокнул
          success = 1
        elseif karlam_spec[side].soldier_luck == 1 then -- солдатская удача
          print('2nd try')
          if random() < chance then
            success = 1
          end
        end
        if success and pcall(UnitCastAimedSpell, creature, SPELL_ENCOURAGE, targets[random(length(targets))]) then -- и каст прошел
          karlam_spec[side].buff_info[creature] = 1 -- поставить флаг, чтобы предотвратить двойной баф
          setATB(creature, 1)
        end
      end
    end
  end
end