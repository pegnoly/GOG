function NewDay()
  local day, dow = GetDate(DAY), GetDate(DAY_OF_WEEK)
  CheckLights(dow)
end

function CheckLights(dow)
  if dow == 1 then
    SetAmbientLight(GROUND, 'WP_M1_Ground_morning', 1, 1)
    SetCombatLight(COMBAT_LIGHTS.MORNING)
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.MORNING
  elseif dow == 2 then
    SetAmbientLight(GROUND, 'WP_M1_Ground_dark_day', 1, 1)
    SetCombatLight(COMBAT_LIGHTS.DAY)
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.DAY
  elseif dow == 5 then
    SetAmbientLight(GROUND, 'WP_M1_Foggy_night', 1, 1)
    SetCombatLight(COMBAT_LIGHTS.NIGHT)
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.NIGHT
  end
end

Trigger(NEW_DAY_TRIGGER, 'NewDay')

function CombatResult(fight_id)
  local winner = GetSavedCombatArmyHero(fight_id, 1)
  local looser = GetSavedCombatArmyHero(fight_id, 0)
  if winner == Karlam and looser and
     (looser == MainQ.templar_1 or looser == MainQ.templar_2) then
    if def_noe.prison_key == 0 then
      def_noe.prison_key = 1
      ShowFlyingSign(rtext('Получен магический ключ от портала'), winner, -1, 7.0)
    end
    if not HasArtefact(winner, ARTIFACT_DRAGON_FLAME_TONGUE) then
      Award(winner, nil, nil, {ARTIFACT_DRAGON_FLAME_TONGUE})
    end
  end
end

Trigger(COMBAT_RESULTS_TRIGGER, 'CombatResult')

function CommonAddHeroFunc(hero)
end