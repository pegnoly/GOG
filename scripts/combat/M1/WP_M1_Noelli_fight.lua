if not(GetHero(enemy_side) and GetHeroName(GetHero(enemy_side)) == Noelli) then return end

MASS   = 0
SINGLE = 1
REPEAT = 2

function ChaosSpellCast(spell)
  DisableCombat()
  local alive_witches = GetAliveWitches()
  local num = length(alive_witches) + 1
  local l = length(GetAttackerCreatures())
  if l <= num then
    num = l
  end
  local type = GetSpellType(spell)
  for i, witch in alive_witches do
    playAnimation(witch, 'cast', ONESHOT)
  end
  sleep(150)
  if type == GLOBAL then
    pcall(UnitCastGlobalSpell, NOELLI, spell)
  else
    for i = 1, num do
      local n = exrand(l, ex_table, 1)
      local target = GetAttackerCreatures()[n - 1]
      ex_table[i] = n
      if type == AIMED then
        pcall(UnitCastAimedSpell, NOELLI, spell, target)
      else
        pcall(UnitCastAreaSpell, NOELLI, spell, pos(target))
      end
    end
  end
  EnableCombat()
  -- EndTurn(NOELLI, 0.4)
  return not nil
end

-- спелл, раунд боя
chaos_spells =
{
  [1] =
  {
    SPELL_EMPOWERED_ICE_BOLT,
    SPELL_EMPOWERED_MAGIC_ARROW
  },
  [2] =
  {
    SPELL_EMPOWERED_LIGHTNING_BOLT,
    SPELL_EMPOWERED_STONE_SPIKES,
  },
  [3] =
  {
    SPELL_EMPOWERED_FIREBALL,
    SPELL_FIREWALL
  },
  [4] =
  {
    SPELL_EMPOWERED_METEOR_SHOWER,
    SPELL_EMPOWERED_CHAIN_LIGHTNING,
  },
  [5] =
  {
    SPELL_EMPOWERED_IMPLOSION,
    SPELL_EMPOWERED_DEEP_FREEZE
  },
  [6] =
  {
    SPELL_EMPOWERED_ARMAGEDDON
  }
}

noelli_spells =
{
  [1] =
  {
    [SPELL_MASS_FORGETFULNESS]    =   MASS,
    [SPELL_EMPOWERED_STONE_SPIKES] = REPEAT,
    [SPELL_EMPOWERED_ICE_BOLT]     = REPEAT,
  },

}

witches_info =
{
  ['witch1'] = {type = CREATURE_MATRON,    x = 8,  y = 4},
  ['witch2'] = {type = CREATURE_MATRIARCH, x = 9,  y = 2},
  ['witch3'] = {type = CREATURE_MATRON,    x = 8,  y = 11},
  ['witch4'] = {type = CREATURE_MATRIARCH, x = 9,  y = 13},
}

function SummonWitches()
  for witch, info in witches_info do
    if not exist(witch) then
      --pcall(UnitCastAreaSpell, NOELLI, SPELL_EFFECT_DIMENSION_DOOR_END, info.x, info.y)
      pcall(SummonCreature, enemy_side, info.type, 8 + 2 * diff, info.x, info.y, 1, witch)
    end
  end
end

--function GetAliveWitches()
--  local answer, n = {}, 0
--  for witch, info in witches_info do
--    if exist(witch) then
--      n = n + 1
--      answer[n] = witch
--    end
--  end
--  if n > 0 then
--    return answer
--  else
--    return nil
--  end
--end

AddCombatFunction(CombatFunctions.START,
function()
  sleep(50)
  SummonWitches()
  sleep(50)
end)

--function CheckUnusedSpells(step)
--  for spell, info in noelli_spells[step] do
--    if info == MASS or info == SINGLE then
--      local c
--      for n_spell, n_info in noelli_spells[step + 1] do
--        if n_spell == spell then
--          c = not nil
--          break
--        end
--      end
--      if not c then
--        noelli_spells[step + 1][spell] = info
--      end
--    end
--  end
--end
--
--current_step = 0
--noelli_turn = 0
--channel_witch = ''
--turns_to_channel = 0
--
--addCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE,
--function(unit)
--  if ((not contains({'witch1', 'witch2', 'witch3', 'witch4', 'witch5', 'witch6'}, unit)) or
--         (channel_witch ~= '')) then return nil end
--  if random(5 - turns_to_channel) == 1 then
--    DisableCombat()
--    sleep(50)
--    ShowFlyingSign(path..'witch_buff.txt', unit, 30)
--    if pcall(commandDoSpecial, unit, SPELL_ABILITY_POWER_FEED) then
--      channel_witch = unit
--      turns_to_channel = 0
--      EnableCombat()
--      return not nil
--    end
--  else
--    turns_to_channel = turns_to_channel + 1
--    return nil
--  end
--end)
--
--addCombatFunction(CombatFunctions.DEFENDER_CREATURE_DEATH,
--function(unit)
--  if unit == channel_witch then
--    channel_witch = ''
--  end
--end)
--
--function NoelliTurn(hero)
--  DisableCombat()
--  for i, unit in GetCreatures(enemy_side) do
--    SetUnitManaPoints(unit, GetUnitMaxManaPoints(unit))
--  end
--
--  ------------------------------------------------------------------------------
--  --if channel_witch ~= '' then
--    local l = length(GetAliveWitches())
--    local spell = chaos_spells[l][random(length(chaos_spells[l]))]
--    ChaosSpellCast(spell)
--    EnableCombat()
--    sleep(100)
--    startThread(SummonWitches)
--    sleep(100)
--    SetUnitManaPoints(hero, GetUnitMaxManaPoints(hero))
--    EndTurn(hero, 0.4)
--    return not nil
-- -- end
--  ------------------------------------------------------------------------------
--end
----  if noelli_turn == steps[current_step + 1] then
----    CheckUnusedSpells(current_step)
----    current_step = current_step + 1
----  end
----  local avaliable_spells, n = {}, 0
--
--addCombatFunction(CombatFunctions.DEFENDER_HERO_MOVE, NoelliTurn)