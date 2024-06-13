--
--------------------------------------------------------------------------------
-- триггер результатов боя

function CombatResult(fight_id)
  local winner = GetSavedCombatArmyHero(fight_id, 1)
  local looser = GetSavedCombatArmyHero(fight_id, 0)

  if winner == 'Karlam' then
    if (GetGameVar('fire_ring') + 0) == 1 then
      TS_CalculateFirePower(fight_id)
    end
  end

  if looser == 'BlueHand' then
    if IsActive(main.def_rt) then
      FinishQuest(main.def_rt)
    end
    enemy.active_heroes['BlueHand'].days_alive = 0
  end
  if looser == 'GreenHand' then
    if IsActive(main.def_cn) then
      FinishQuest(main.def_cn)
    end
    enemy.active_heroes['GreenHand'].days_alive = 0
  end
--  if GetObjectOwner(looser) == PLAYER_2 then
--    EnemyHeroLoose(looser)
--  end
--  if GetGameVar('combat_mode') == 'real_combat' then
--    SetGameVar('combat_mode', 'quick_combat')
--  end
end

Trigger(COMBAT_RESULTS_TRIGGER, 'CombatResult')

--
--------------------------------------------------------------------------------
-- триггер нового дня

time =
{
  week = 1
}

function NewDay()
  local day = GetDate(DAY)
  local dow = GetDate(DAY_OF_WEEK)

  CheckLights(day, dow)
  UpdateNecrosInfo()
  --PowerUpEnemyHeroes()

--  if not IsHeroAlive('BlueHand') then
--    mainQ.bh_alive = mainQ.bh_alive + 1
--    if mainQ.bh_alive == 1 then
--      DeployReserveHero('BlueHand', RegionToPoint('necro_point'..random(3) + 1))
--      mainQ.bh_alive = 1
--    end
--  end
--  if not IsHeroAlive('GreenHand') then
--    mainQ.gh_alive = mainQ.gh_alive + 1
--    if gh_alive == 1 then
--      DeployReserveHero('GreenHand', RegionToPoint('necro_point'..random(3) + 1))
--      mainQ.gh_alive = 1
--    end
--  end
  --
  if day == main.villages_msg then
    VillagesInfoMessage()
  end
  --
  if day == ts_q.new_dragon_place_found_day then
    TS_RitualPlaceFound()
  end

  if dow == 1 then
    time.week = time.week + 1
    NecroTownsCreaturesSetup()
    if GetProgress(ts_q.name) == 3 then
      TS_BurnHero()
    end
  end

  -- в пятый день недели нужно прочекать, не нужно ли активировать проход по лавовой реке, чтобы не перезаходить в регион
  if dow == 5 then
    if IsActive(ts_q.name) then
      TS_CheckDialogStartWhenHeroAlreadyInCavern()
    end
  end

  if not (IsCompleted(plague.name) or GetProgress(plague.name) == 9) then
    PlagueNewDay(day)
  end
end

Trigger(NEW_DAY_TRIGGER, 'NewDay')

--
--------------------------------------------------------------------------------
-- настройки освещения и дождя

weather =
{
  lights = {[1] = 'WP_M4_Foggy_morning', [2] = 'WP_M4_Grey_day', [3] = 'WP_M4_Grey_day', [4] = 'WP_M4_Grey_day',
            [5] = 'WP_M4_Dark_night', [6] = 'WP_M4_Dark_night', [7] = 'WP_M4_Dark_night'},
  -- curr_light = 'WP_M4_Foggy_morning',
  
  rain_is_active = nil,
  rain_day_to_stop = 0,
  rain_day_to_active = 2
}

function CheckLights(day, dow)
  -- день, когда нужно остановить дождь
  if day == weather.rain_day_to_stop then
    SetAmbientLight(GROUND, weather.lights[dow], 1, 1.2 + 0.1 * random(5))
    SetCombatLight(COMBAT_LIGHTS[weather.lights[dow]])
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS[weather.lights[dow]]
    weather.rain_is_active = nil
    return
  end
  -- день, когда нужно запустить дождь
  if day == weather.rain_day_to_active then
    -- шанс сработал?
    if random(3) == 1 then
      weather.rain_is_active = 1 -- поставить флаг включения
      weather.rain_day_to_stop = day + 4 + random(5) -- установить день остановки...
      weather.rain_day_to_active = weather.rain_day_to_stop + 3 + random(5) -- ... и следующего запуска
      SetAmbientLight(GROUND, weather.lights[dow]..'_Rain', 1, 1.2 + 0.1 * random(5))
      SetCombatLight(COMBAT_LIGHTS[weather.lights[dow]..'_Rain'])
      COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS[weather.lights[dow]..'_Rain']
      return
    else -- шанс не сработал?
      -- попытаться на следующий день
      weather.rain_day_to_active = weather.rain_day_to_active + 1
    end
  end
  -- дождь активен?
  if weather.rain_is_active then
    -- обновить освещение, если сменилось время дня
    if dow == 1 or (weather.lights[dow] ~= weather.lights[dow - 1]) then
      SetAmbientLight(GROUND, weather.lights[dow]..'_Rain', 1, 1.2 + 0.1 * random(5))
      SetCombatLight(COMBAT_LIGHTS[weather.lights[dow]..'_Rain'])
      COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS[weather.lights[dow]..'_Rain']
    end
  else -- аналогично, если дождь неактивен
    if dow == 1 or (weather.lights[dow] ~= weather.lights[dow - 1]) then
      SetAmbientLight(GROUND, weather.lights[dow], 1, 1.2 + 0.1 * random(5))
      SetCombatLight(COMBAT_LIGHTS[weather.lights[dow]])
      COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS[weather.lights[dow]]
    end
  end
end