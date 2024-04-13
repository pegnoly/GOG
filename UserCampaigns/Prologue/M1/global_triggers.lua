--------------------------------------------------------------------------------
-- ���������� �������� - ������ ��� � ����������� ���

function NewDay()
  local Week_D = GetDate(DAY_OF_WEEK)
  local aDay = GetDate(DAY)

  -- ���� ����� �� ������� �������� �������
  if isActive(moriton.names.def) then
    CheckMoritonRemoveDef(aDay)  -- ������ ������
    CheckMoritonSiegeDates(aDay) -- ���� ����
    CheckMoritonReinforces(aDay) -- �������� ������������
  end
  -- ���� ������� ����� �������
  if isActive(mainQ.names.main) then
    print('Its a final countdown...', mainQ.eNightDay - aDay)
    CheckBaalFirstSpawn(aDay) -- ������������ ������ ��������� �����
    CheckBaalSpawnRules(aDay) -- � ������ ��� ���������
    mainQ.Destination = 0 -- ���������� ���� ������� ����� ���������� ��� �����
    mainQ.BaalTP = 0
    if Week_D == 1 then -- ���� ���� ������� � 1 ���� ������(������ ���� ��� �������)
      BaalAddMP() -- �������� ��� ���������
    end
    if getProgress(mainQ.names.main) == 4 then
      CheckSvetDestroy(aDay) -- ���������, �� ������ �� ����� ��������� ������
    end
  end
  -- ���� �� ��������� ������ ����
  if not isFailed(mainQ.names.enight) then
    CheckLights(Week_D) -- ������ ���������
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
  -- ������, ��� �������/�������� � ���
  local WinnerName = GetSavedCombatArmyHero(fightID, 1)
  local LooserName = GetSavedCombatArmyHero(fightID, 0)

  -- ��������� ����� - ������ ���������� ������
  if LooserName == 'Baal' then
    StartDialogScene(DIALOG_SCENES.BAAL_FIGHT)
    sleep()
    mainQ.isBaalActive = 0
    Save('victory?')
    SetupFinalQuest()
  end
  
  -- ��. ������ ������� - ��� � ��������
  if LooserName == 'Inagost' then
    TurgalDead(WinnerName)
  end

  -- ������ ����� ��� ���������� ������������
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
      MessageBox(rtext('������� ���� �� <color=green>��������<color_default> ������ �������'))
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
      moriton.remove_def = GetDate(DAY) + 7 -- ���� ���� �� ������ ������ � ����� ������
      GiveBorderguardKey(PLAYER_1, PURPLE_KEY)
      MessageBox(rtext('������� ���� �� <color=FFC800FF>����������<color_default> ������ �������'))
      if isActive(moriton.names.kklem) then
        updateQuest(moriton.names.kklem, 1, WinnerName)
      end
    end
    if LooserName == 'Baal_copy' then
      Loose()
    end
  end

  -- ���� ����� ������� ���������, ����� �������� ������� ������ ������� ��������������� ��� �����(����������, ���� ��� �����)
  if WinnerName == 'Baal' and (GetGameVar('svetoch') + 0) ~= 1 then
    GiveBaalNightBonus()
  end
end

Trigger(COMBAT_RESULTS_TRIGGER, 'CheckFightResults')