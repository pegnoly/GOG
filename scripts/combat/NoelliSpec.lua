--------------------------------------------------------------------------------
-- специализация Ноэлли - Кровавый Пакт. Условие запуска - Ноэлли участвует в бою(но не в 1 миссии)

if not (GetPlayerHeroName() == Noelli or GetEnemyHeroName() == Noelli) then return end

noe_side = GetHeroName(GetAttackerHero()) == Noelli and ATTACKER or DEFENDER -- сторона, на которой сражается Ноэлли
noe_witches_count = GetGameVar('noe_spec_witches_count') + 0 -- число ведьм, которое должно быть призвано
noe_current_kills = GetGameVar('noe_spec_current_kills') + 0 -- текущее число убийств, совершенное женскими юнитами Ноэлли
--noe_current_up    = GetGameVar('noe_spec_current_up') + 0
noe_kills_to_up   = GetGameVar('noe_spec_kills_to_up') + 0 -- число убийств до повышения уровня Пакта
noe_last_unit = '' -- последнее существо, совершавшее ход
-- типы женских существ ТЭ - альты учитываются(но альт фурий имеет одинаковое скриптовое имя)
noe_witches_types = {CREATURE_WITCH, CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2, CREATURE_MATRON, CREATURE_MATRIARCH, CREATURE_SHADOW_MISTRESS, 335, 367}

-- призыв ведьм в начале боя
function WitchesSummon()
  local x, y = 0
  if noe_side == ATTACKER then
    x, y = 2, 2
  else
    x, y = 11, 11
  end
  pcall(SummonCreature, noe_side, CREATURE_MATRIARCH, noe_witches_count, x, y, 1, 'noe_witch')
end

-- при смерти существа вражеской стороны, проверяется, чей ход привел к этому
function CheckWitchesKilledUnit(unit)
  -- если это существо Ноэлли
  if GetUnitSide(noe_last_unit) == noe_side then
    local type = GetCreatureType(noe_last_unit)
    -- и входит в число женских
    if contains(noe_witches_types, type) then
      -- обновить число убийств
      noe_current_kills = noe_current_kills + 1
      local msg = '+1 убийство. '
      -- если не достигли нового уровня Пакта
      if noe_current_kills < noe_kills_to_up then
        -- просто вывести число убийств
        msg = msg..noe_current_kills..' из '..noe_kills_to_up..' до уровня пакта.'
      -- новый уровень?
      elseif noe_current_kills == noe_kills_to_up then
        -- обнулить текущие убийства
        noe_current_kills = 0
        -- рассчитать число убийств до следующего уровня
        noe_kills_to_up = noe_kills_to_up + noe_kills_to_up / 2
        -- установить их в глобальные переменные
        SetGameVar('noe_spec_kills_to_up', noe_kills_to_up)
        SetGameVar('noe_spec_witches_count', noe_witches_count + 1)
        msg = msg..'Уровень пакта повышен!'
      end
      startThread(CombatFlyingSign, rtext(msg), GetHero(noe_side), 60.0)
      SetGameVar('noe_spec_current_kills', noe_current_kills)
    end
  end
end

function SaveUnit(unit)
  if IsCreature(unit) then
    noe_last_unit = unit
  end
end

AddCombatFunction(CombatFunctions.START, WitchesSummon)
AddCombatFunction(CombatFunctions.UNIT_MOVE, SaveUnit)
AddCombatFunction(CombatFunctions[noe_side == ATTACKER and 'DEFENDER_CREATURE_DEATH' or 'ATTACKER_CREATURE_DEATH'], CheckWitchesKilledUnit)