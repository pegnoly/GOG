--------------------------------------------------------------------------------
-- глобальные триггеры - нового дня и результатов боя

function NewDay()
  local Week_D = GetDate(DAY_OF_WEEK)
  local aDay = GetDate(DAY)

  -- если квест на оборону Моритона активен
  if isActive(moriton.names.def) then
    CheckMoritonRemoveDef(aDay)  -- снятие защиты
    CheckMoritonSiegeDates(aDay) -- даты атак
    CheckMoritonReinforces(aDay) -- прибытия подкреплений
  end
  -- если главный квест активен
  if isActive(mainQ.names.main) then
    print('Its a final countdown...', mainQ.eNightDay - aDay)
    CheckBaalFirstSpawn(aDay) -- обрабатываем первое появление Баала
    CheckBaalSpawnRules(aDay) -- и логику его респавнов
    mainQ.Destination = 0 -- сбрасываем флаг наличия точки назначения для Баала
    mainQ.BaalTP = 0
    if Week_D == 1 then -- если Баал активен в 1 день недели(вечная ночь уже активна)
      BaalAddMP() -- добавить ему мувпоинты
    end
    if getProgress(mainQ.names.main) == 4 then
      CheckSvetDestroy(aDay) -- проверяем, не пришло ли время разрушить Светоч
    end
  end
  -- пока не наступила вечная ночь
  if not isFailed(mainQ.names.enight) then
    CheckLights(Week_D) -- меняем освещение
  end
end

Trigger(NEW_DAY_TRIGGER, 'NewDay')

function CheckLights(weekday)
  if weekday == 1 then
    SetAmbientLight(GROUND, 'morning', not nil, 1)
    SetCombatLight(COMBAT_LIGHTS.MORNING)
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.MORNING
  end

  if weekday == 2 then
    SetAmbientLight(GROUND, 'day', not nil, 1)
    SetCombatLight(COMBAT_LIGHTS.DAY)
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.DAY
  end

  if weekday == mainQ.nightTime then
    SetAmbientLight(GROUND, 'deepnight', not nil, 1)
    SetCombatLight(COMBAT_LIGHTS.NIGHT)
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.NIGHT
  end
end

--------------------------------------------------------------------------------

function CheckFightResults(fightID)
  -- узнаем, кто победил/проиграл в бою
  local WinnerName = GetSavedCombatArmyHero(fightID, 1)
  local LooserName = GetSavedCombatArmyHero(fightID, 0)

  -- поражение Баала - запуск финального квеста
  if LooserName == 'Baal' then
    StartDialogScene(DIALOG_SCENES.BAAL_FIGHT)
    sleep()
    mainQ.isBaalActive = 0
    Save('victory?')
    SetupFinalQuest()
  end
  
  -- см. квесты Карлама - бой с Тургалом
  if LooserName == 'Inagost' then
    TurgalDead(WinnerName)
  end

  -- победы Греты над атакующими некромантами
  if WinnerName == 'Greta' then
    local object = GetHeroTown('Greta') or 'Greta'
    if LooserName == 'ainur' then
      Award(WinnerName, nil, nil,
           {
             ARTIFACT_NIGHTMARISH_RING,
             --ARTIFACT_RING_OF_MACHINE_AFFINITY,
             ARTIFACT_DRAGON_TALON_CROWN,
             ARTIFACT_TITANS_TRIDENT
           })
      PostSiegeMoritonDestroy()
    end
    if LooserName == 'Gilva' then
      Award(WinnerName, nil, nil,
           {
             ARTIFACT_RING_OF_LIFE,
             ARTIFACT_ICEBERG_SHIELD,
             ARTIFACT_GOLDEN_HORSESHOE,
             ARTIFACT_PHOENIX_FEATHER_CAPE
           })
      GiveBorderguardKey(PLAYER_1, GREEN_KEY)
      MessageBox(rtext('Получен ключ от <color=green>Зеленого<color_default> стража границы'))
    end
    if LooserName == 'Orris' then
      Award(WinnerName, nil, nil,
           {
             --ARTIFACT_RUNIC_WAR_HARNESS,
             ARTIFACT_HELM_OF_CHAOS,
             ARTIFACT_TREEBORN_QUIVER,
             ARTIFACT_EARTHSLIDERS
           })
    end
    if LooserName == 'Klem' then
      moriton.remove_def = GetDate(DAY) + 7 -- даем флаг на снятие защиты в любом случае
      GiveBorderguardKey(PLAYER_1, PURPLE_KEY)
      MessageBox(rtext('Получен ключ от <color=FFC800FF>Пурпурного<color_default> стража границы'))
      if isActive(moriton.names.kklem) then
        updateQuest(moriton.names.kklem, 1, WinnerName)
      end
    end
    if LooserName == 'Baal_copy' then
      Loose()
    end
  end

  -- Баал может убивать нейтралов, когда пытается догнать игрока поэтому восстанавливаем его бонус(разумеется, если это нужно)
  if WinnerName == 'Baal' and (GetGameVar('svetoch') + 0) ~= 1 then
    GiveBaalNightBonus()
  end
end

Trigger(COMBAT_RESULTS_TRIGGER, 'CheckFightResults')