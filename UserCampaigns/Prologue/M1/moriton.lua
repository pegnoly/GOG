--------------------------------------------------------------------------------
-- ��� ��������� � ���������: ��������� ������, ������ ����� � ������

moriton =
{
  names =
  {
    def = 'DEFEND_TOWN',
    u_at = 'UNDEAD_ATTACK',
    u_path = 'UNDERGROUND_PATH',
    kklem = 'KILL_KLEM',
    witch = 'WITCH_QUEST'
  },
  
  paths =
  {
    u_at = qPath..'UndeadAttack/',
    u_path = qPath..'UndergroundPath/',
    kklem = qPath..'KillKlem/',
    witch = qPath..'WitchQuest/'
  },
  
  -- ����� �������� ���������
  out_gar_units =
  {
    'archer1', 'archer2', 'archer3',
    'druid1', 'druid2', 'uni', 'treant'
  },
  
  -- �������� ��� �������� ������ PlayVisualEffects/CreateMonster � ������ ����� ������
  undead_units =
  {
    {CREATURE_VAMPIRE_LORD, 1, -4, 315},
    {CREATURE_ZOMBIE, 1, -5, 270},
    {CREATURE_VAMPIRE_LORD, 1, -6, 315},
    {CREATURE_SKELETON_WARRIOR, 2, -4, 305},
    {CREATURE_GHOST, 2, -5, 270},
    {CREATURE_BANSHEE, 3, -3, 270},
    {CREATURE_HORROR_DRAGON, 4, -5, 272},
    {CREATURE_WIGHT, 3, -7, 270}
  },
  
  -- ��� ���� �����������
  ainurAttack = 0,
  gilvaAttack = 0,
  orrisAttack = 0,
  klemAttack = 0,
  mordAttack = 0,
  
  reinfs = 0, -- ���� �������� ������������
  first_reinf = 0, -- ���� ������� ������������
  remove_def = 0, -- ���� ������ ������ � ������
  
  deadStacks = 0, -- ������� ������ ������ ������
  
  first_enter = 0, -- ���� ������� ����� � ��������
  
  wsp_learned = 0, -- ���� �������� ������ � ������
  
  -- ��� ������ ������ - ������
  test_day = 0,
  test_hero = 'Orris'
}

--------------------------------------------------------------------------------
-- �������� � ������ ������ ������
function looseTown(pOwner, nOwner)
  if nOwner == PLAYER_2 then
    failQuest(moriton.names.def)
    sleep(2)
    Loose()
  end
end

Trigger(OBJECT_CAPTURE_TRIGGER, 'Moriton', 'looseTown')

-- ��������, ����������� ������ �� 2 ����
function OutGarSetup()
  for i, unit in moriton.out_gar_units do
    local og_unit = 'out_gar_'..unit
    SetObjectEnabled(og_unit, nil)
    startThread(
    function()
      sleep()
      SetMonsterSelectionType(%og_unit, 0)
    end)
  end
  EnableHeroAI('Elleshar', nil)
  SetObjectEnabled('Elleshar', nil)
  Touch.SetFunction('Elleshar',
  function(hero, object)
    if hero == 'Karlam' then
      MessageBox(wPath..'out_gar_msg.txt')
    end
  end)
end

OutGarSetup()
--------------------------------------------------------------------------------
-- ����� ������ ��� ����� ������� �� ������

-- ������ �����
function MoritonAttackEvent()
  BlockGame()
  OpenCircleFog(30, 69, 0, 7, PLAYER_1)
  MoveCamera(30, 69, 0, 0, 0, 0, 1, 1, 1)
  sleep(5)
  PlayVisualEffect(USED_FX.FIREBALL_FX, '', '', 29, 66, 0, 0, 0)
  Play3DSound(USED_SOUNDS.FIREBALL_SOUND, 29, 66, 0)
  PlayVisualEffect(USED_FX.FIREBALL_FX, '', '', 29, 69, 0, 0, 0)
  Play3DSound(USED_SOUNDS.FIREBALL_SOUND, 29, 69, 0)
  PlayVisualEffect(USED_FX.FIREBALL_FX, '', '', 28, 72, 0, 0, 0)
  Play3DSound(USED_SOUNDS.FIREBALL_SOUND, 28, 72, 0)
  sleep(5)
  for i, unit in moriton.undead_units do
    startThread(
    function()
      local x, y = 30, 75 -- ���������� ���� ��������/�������� ����������� ������������ ������� �����
      local unit = %unit
      local i = %i
      PlayVisualEffect(USED_FX.ANIMATE_DEAD_FX, 'emitter1', ' ', unit[2], unit[3])
      Play3DSound(USED_SOUNDS.ANIMATE_DEAD_SOUND, x + unit[2], y + unit[3], 0)
      sleep(10)
      CreateMonster('u_at'..i, unit[1], 10, x + unit[2], y + unit[3], 0, 3, 1, unit[4])
      sleep()
      SetObjectEnabled('u_at'..i, nil)
    end)
  end
  repeat sleep() until IsObjectExists('u_at8')
  for i = 1, 8 do
    PlayObjectAnimation('u_at'..i, 'happy', ONESHOT)
  end
  sleep(20)
  MessageBox(wPath..'UndeadAttack.txt', 'UnblockGame')
end

-- ��� � �������
function undeadAttackFight(hero)
  if hero == 'Greta' then
    if StartCombat(hero, nil, 7,
                   CREATURE_SKELETON_WARRIOR, 98  + random(5),
                   CREATURE_ZOMBIE, 77 + random(4),
                   CREATURE_GHOST, 28,
                   CREATURE_VAMPIRE_LORD, 19,
                   CREATURE_WIGHT, 4,
                   CREATURE_BANSHEE, 3,
                   CREATURE_HORROR_DRAGON, 2) then
      BlockGame()
      for i = 1, 8 do
        startThread(
        function()
          PlayObjectAnimation('u_at'..%i, 'death', ONESHOT_STILL)
          sleep(15)
          RemoveObject('u_at'..%i)
        end)
      end
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'undeadAttack', nil)
      UnblockGame()
    end
  end
end

--------------------------------------------------------------------------------

-- ��������� �� ����� -> � ������� ������ ���
function CheckMoritonSiegeDates(day)
  if isActive(mainQ.names.final) then return end
  
  -- -- ��� ������, ���� ����� ����� ������
-- if day == moriton.test_day then
--   DeployReserveHero(moriton.test_hero, 12, 107, 0, 0)
--   sleep()
--   SetupNecroHero(moriton.test_hero)
--   sleep()
--   SiegeTown(moriton.test_hero, 'Moriton')
--   --startThread(MoritonSiegeMove, moriton.test_hero)
-- end
  
  if day == moriton.ainurAttack then
    BlockGame()
    OpenCircleFog(14, 104, 0, 5, 1)
    MoveCamera(14, 104, 0, 0, 0, 0, 1, 1)
    sleep(20)
    PlayVisualEffect(USED_FX.ANIMATE_DEAD_FX, 'grave1', ' ', 1, -1, 0, 0, 0)
    Play3DSound(USED_SOUNDS.ANIMATE_DEAD_SOUND, GetObjectPosition('grave1'))
    sleep(20)
    DeployReserveHero('ainur', 12, 107, 0, 0)
    UnblockGame()
    sleep()
    SetupNecroHero('ainur')
    sleep()
    startThread(MoritonSiegeMove, 'ainur')
    if IsObjectExists('u_at1') then
      for i = 1, 8 do
        RemoveObject('u_at'..i)
      end
    end
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'undeadAttack', nil)
  end

  if day == moriton.gilvaAttack then
    DeployReserveHero('Gilva', 13, 100, 0, 0)
    sleep()
    SetupNecroHero('Gilva')
    sleep()
    startThread(MoritonSiegeMove, 'Gilva')
  end

  if day == moriton.orrisAttack then
    DeployReserveHero('Orris', 12, 107, 0, 0)
    sleep()
    SetupNecroHero('Orris')
    sleep()
    startThread(MoritonSiegeMove, 'Orris')
  end

  if day == moriton.klemAttack then
    DeployReserveHero('Klem', 13, 100, 0, 0)
    sleep()
    SetupNecroHero('Klem')
    sleep()
    startThread(MoritonSiegeMove, 'Klem')
  end

  if day == moriton.mordAttack then
    DeployReserveHero('Mordrakar', 12, 107, 0, 0)
    sleep()
    SetupNecroHero('Mordrakar')
    sleep()
    startThread(MoritonSiegeMove, 'Mordrakar')
  end
end

-- ��������� ������ - ������. �������� ��������, � ��������, ����� ��������� �����
function SetupNecroHero(hero)
  EnableHeroAI(hero, nil)
  SetHeroLootable(hero, nil)
  sleep()
  if hero == 'ainur' then
    AddHeroCreatures('ainur', CREATURE_SKELETON_WARRIOR, 400 + 90 * diff + (random(20) - 10) * DIFF + random(17))
    AddHeroCreatures('ainur', getRandFrom(CREATURE_ZOMBIE, CREATURE_DISEASE_ZOMBIE), 300 + 51 * diff + (random(15) + 4) * DIFF + random(21))
    AddHeroCreatures('ainur', getRandFrom(CREATURE_GHOST, CREATURE_POLTERGEIST), 120 + 32 * diff + (random(10) + 5) * DIFF + (11 + DIFF) * 2)
    AddHeroCreatures('ainur', getRandFrom(CREATURE_VAMPIRE_LORD, CREATURE_NOSFERATU), 32 + 12 * diff + (random(10 + DIFF) * 2))
    AddHeroCreatures('ainur', getRandFrom(CREATURE_VAMPIRE_LORD, CREATURE_NOSFERATU), 30 + 13 * diff + (random(12 + DIFF) * 2))
    AddHeroCreatures('ainur', CREATURE_BANSHEE, 9 * diff - 2 *(5 - diff) + random(4))
    AddHeroCreatures('ainur', CREATURE_WRAITH, 10 * diff - 3 * (4 - diff) + random(5))
    ChangeHeroStat('ainur', 0, LEVELS[21 + diff])
    SetGameVar('destruction_lvl', 0)
  elseif hero == 'Gilva' then
    AddHeroCreatures('Gilva', CREATURE_SKELETON_WARRIOR, 307 + 53 * DIFF + 17 * (diff + 3) + random(8))
    AddHeroCreatures('Gilva', getRandFrom(CREATURE_ZOMBIE, CREATURE_DISEASE_ZOMBIE), 217 + 42 * DIFF + (random(10) + 6) * (diff + 5))
    AddHeroCreatures('Gilva', getRandFrom(CREATURE_GHOST, CREATURE_POLTERGEIST), 115 + 25 * DIFF + 6 * (diff + 2) + random(6))
    AddHeroCreatures('Gilva', getRandFrom(CREATURE_GHOST, CREATURE_POLTERGEIST), 121 + 23 * DIFF + (random(16) + 1) * DIFF)
    AddHeroCreatures('Gilva', getRandFrom(CREATURE_VAMPIRE_LORD, CREATURE_NOSFERATU), 39 + 15 * diff + random(5))
    AddHeroCreatures('Gilva', CREATURE_LICH_MASTER, 28 + 6 * (DIFF + 2) + random(5))
    AddHeroCreatures('Gilva', CREATURE_WRAITH, 23 + 6 * DIFF + random(4))
    ChangeHeroStat('Gilva', 0, LEVELS[23 + diff])
  elseif hero == 'Orris' then
    AddHeroCreatures('Orris', CREATURE_SKELETON_ARCHER, 480 + 105 * DIFF + (random(21) + 10) * DIFF)
    AddHeroCreatures('Orris', getRandFrom(CREATURE_ZOMBIE, CREATURE_DISEASE_ZOMBIE), 310 + 62 * DIFF + (random(15) + 4) * diff + random(27))
    AddHeroCreatures('Orris', getRandFrom(CREATURE_VAMPIRE_LORD, CREATURE_NOSFERATU), 60 + 13 * diff + (random(5) + 2) * diff)
    AddHeroCreatures('Orris', CREATURE_DEMILICH, 40 + 12 * DIFF + random(5))
    AddHeroCreatures('Orris', CREATURE_LICH_MASTER, 38 + 13 * DIFF + random(5))
    AddHeroCreatures('Orris', getRandFrom(CREATURE_WRAITH, CREATURE_BANSHEE), 20 + 7 * (DIFF + 2) + random(5))
    AddHeroCreatures('Orris', getRandFrom(CREATURE_SHADOW_DRAGON, CREATURE_HORROR_DRAGON), 15 + 5 * DIFF + random(4))
    ChangeHeroStat('Orris', 0, LEVELS[25 + diff])
  elseif hero == 'Klem' then
    AddHeroCreatures('Klem', CREATURE_SKELETON_WARRIOR, 600 + 115 * DIFF + 23 * (diff + 5) + random(15))
    AddHeroCreatures('Klem', CREATURE_DISEASE_ZOMBIE, 363 + 83 * (DIFF + 2) + random(8))
    AddHeroCreatures('Klem', getRandFrom(CREATURE_GHOST, CREATURE_POLTERGEIST), 222 + 41 * DIFF + 7 * (diff + random(3)))
    AddHeroCreatures('Klem', CREATURE_LICH_MASTER, 55 + 14 * diff + random(6))
    AddHeroCreatures('Klem', CREATURE_BANSHEE, 72 + 11 * DIFF + random(9))
    AddHeroCreatures('Klem', CREATURE_HORROR_DRAGON, 20 + 6 * diff + random(4))
    AddHeroCreatures('Klem', CREATURE_SHADOW_DRAGON, 25 + 5 * diff + random(4))
    ChangeHeroStat('Klem', 0, LEVELS[27 + diff])
  elseif hero == 'Mordrakar' then
    AddHeroCreatures('Mordrakar', CREATURE_MUMMY, 232 + 57 * DIFF + (15 - diff) * (random(diff) + 5))
    AddHeroCreatures('Mordrakar', CREATURE_GHOST, 403 + 49 * DIFF + 11 * (random(7) + DIFF))
    AddHeroCreatures('Mordrakar', CREATURE_VAMPIRE_LORD, 211 + 44 * DIFF + random(diff) * (random(5) + 2))
    AddHeroCreatures('Mordrakar', CREATURE_NOSFERATU, 192 + 51 * DIFF + random(10))
    AddHeroCreatures('Mordrakar', CREATURE_SHADOW_DRAGON, 55 + 8 * diff + random(6))
    AddHeroCreatures('Mordrakar', CREATURE_DEATH_KNIGHT, 140 + 17 * diff + random(4))
    AddHeroCreatures('Mordrakar', 89, 160 + 23 * diff + random(5))
    GiveHeroBattleBonus('Mordrakar', HERO_BATTLE_BONUS_SPEED, 2)
    ChangeHeroStat('Mordrakar', 0, LEVELS[29 + diff])
  end
end
  
-- �������� ������������ � �����
function CheckMoritonReinforces(day)
  if day == moriton.reinfs then
    moriton.reinfs = moriton.reinfs + 7
    if moriton.first_reinf == 0 then -- ���� ������������ ��� �� ����
      BlockGame()
      MoveCamera(21, 67, 0, 0, 0, 0, 1, 1, 1)
      sleep(5)
      MessageBox(wPath..'Dwells/reinfs_msg.txt', 'UnblockGame') -- ���� ���� � ���
      moriton.first_reinf = 1
    end
    if not IsObjectExists('reinfs') then -- ���� ������� ������������ ��� ���
      CreateMonster('reinfs', CREATURE_PIXIE, 10 * dwells.counts[1], 21, 67, 0, 0, 0, 0, not nil) -- ������� ���
      sleep()
      AddObjectCreatures('reinfs', CREATURE_BLADE_JUGGLER, 8 * dwells.counts[2]) -- ��������� ������� � ����������� �� ����� ����������
      AddObjectCreatures('reinfs', CREATURE_WOOD_ELF, 6 * dwells.counts[3])
      AddObjectCreatures('reinfs', CREATURE_DRUID, 4 * dwells.counts[4])
      AddObjectCreatures('reinfs', CREATURE_UNICORN, 2 * dwells.counts[4])
      AddObjectCreatures('reinfs', CREATURE_TREANT, 1 * dwells.counts[4])
      if 0.5 * dwells.counts[4] >= 1 then -- �������� ��, ������ ��� quanity cannot be negative?
        AddObjectCreatures('reinfs', CREATURE_GREEN_DRAGON, 0.5 * dwells.counts[4])
      end
    else -- ���� ��� ����������
      AddObjectCreatures('reinfs', CREATURE_PIXIE, 10 * dwells.counts[1]) -- ������ ��������� �������
      AddObjectCreatures('reinfs', CREATURE_BLADE_JUGGLER, 8 * dwells.counts[2])
      AddObjectCreatures('reinfs', CREATURE_WOOD_ELF, 6 * dwells.counts[3])
      AddObjectCreatures('reinfs', CREATURE_DRUID, 4 * dwells.counts[4])
      AddObjectCreatures('reinfs', CREATURE_UNICORN, 2 * dwells.counts[4])
      AddObjectCreatures('reinfs', CREATURE_TREANT, 1 * dwells.counts[4])
      if 0.5 * dwells.counts[4] >= 1 then
        AddObjectCreatures('reinfs', CREATURE_GREEN_DRAGON, 0.5 * dwells.counts[4])
      end
    end
  end
end

-- �������� �� ������������ ���������� �����������
function MoritonSiegeMove(currentEnemy)
  while 1 do
    if not IsHeroAlive(currentEnemy) then return end
    if GetCurrentPlayer() == PLAYER_2 then
--      if not CanMoveHero(currentEnemy, 19, 70, 0) then
--        sleep(5)
--        SiegeTown(currentEnemy, 'Moriton')
--      else
      MoveHeroRealTime(currentEnemy, 19, 70, 0)
     -- end
    end
    sleep(2)
  end
end

-- ���������� ������ ����� ����� ��������
function PostSiegeMoritonDestroy()
  local d_lvl = GetGameVar('destruction_lvl') + 0 -- �������� ���� �� �������
  print('������� ����������: ', d_lvl)
  if d_lvl == 0 then return end -- ������ �� ���������/����� ���� �� � ������ - �����
  ShowObject('Moriton', 1)
  for i = 1, d_lvl do
    for i = 1, 6 do
      startThread(
      function()
        PlayVisualEffect(USED_FX.EARTHQUAKE_FX, 'Moriton', '', 0, 0, 0, random(360), 0)
        Play3DSound(USED_SOUNDS.EARTHQUAKE_SOUND, GetObjectPosition('Moriton'))
      end)
    end
    sleep(10)
  end
  MessageBox(wPath..'moriton_destroy.txt')
  if d_lvl == 1 then -- ������ ������� ����������
    DestroyTownBuildingToLevel('Moriton', TOWN_BUILDING_FORT, 1) -- �������� ���������� �� ��������
  elseif d_lvl == 2 then -- ������� ����������
    DestroyTownBuildingToLevel('Moriton', TOWN_BUILDING_FORT, 0) -- ����� ��� ����������
    DestroyTownBuildingToLevel('Moriton', TOWN_BUILDING_TOWN_HALL, 2) -- ������ �� ������
  elseif d_lvl == 3 then -- ��������� ����������
    DestroyTownBuildingToLevel('Moriton', TOWN_BUILDING_FORT, 0) -- ����� ����������
    DestroyTownBuildingToLevel('Moriton', TOWN_BUILDING_TOWN_HALL, 1) -- ����� ��� �� ���� ���������
    for i = TOWN_BUILDING_DWELLING_1, TOWN_BUILDING_DWELLING_3 + diff do -- �������� ����� ��������� ���������
      if GetTownBuildingLevel('Moriton', i) == 2 then
        DestroyTownBuildingToLevel('Moriton', i, 1)
      end
    end
  end
end

--------------------------------------------------------------------------------
-- ������ �����

-- ������ ��������� � ����������� ������ ��������
SetObjectEnabled('war_lord', nil)
Touch.SetFunction('war_lord',
function(hero, object)
  if hero == 'Greta' then
    -- � ������ ����� ����� ������� ��� ������� ������, ��� ��� ����� ���������� ��� ��������
    if moriton.remove_def ~= 0 and not isActive(moriton.names.kklem) then
      -- ���� ����� - ������ �� ���������� ������� �������(����� ��, � ������ ����� ������ �� ������ ������ �� �����)
      if isActive(moriton.names.u_at) then
        finishQuest(moriton.names.u_at, hero) -- ������ ��������� ���
      end
      if isActive(moriton.names.u_path) then
        finishQuest(moriton.names.u_path, hero)
      end
      -- ������� ����������� ��������������
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        ShowFlyingSign(rtext('���������� ���������, �������!'), object, -1, 7.0)
      end)
      return
    end
    ----------------------------------------------------------------------------
    if isUnknown(moriton.names.u_at) then -- ������ ��� �����?
      MessageBox(moriton.paths.u_at..'keyKeeper_start.txt')
      startQuest(moriton.names.u_at, hero)
      sleep()
      if moriton.deadStacks > 0 then
        updateQuest(moriton.names.u_at, moriton.deadStacks)
      end
      startThread(checkDeadStacks)
    elseif getProgress(moriton.names.u_at) == 8 then -- ��� ����� �����?
      MessageBox(moriton.paths.u_at..'keyKeeper_temp.txt')
      finishQuest(moriton.names.u_at, hero)
      local town = TOWN_PRESERVE
      local func = function(hero) addCreaturesByTier(hero, %town, 1, 35, %town, 2, 17, %town, 3, 10, %town, 4, 5, %town, 6, 2) end
      Award(hero, func, {[0] = 12000})
      sleep()
      startQuest(moriton.names.u_path)
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'uPath_exit', 'uExitBlock')
    elseif getProgress(moriton.names.u_path) == 2 then -- ����������� �������?
      MessageBox(moriton.paths.u_path..'keyKeeper_temp2.txt')
      finishQuest(moriton.names.u_path, hero)
      local func = function(hero) addArmy(hero, 0.1) end
      Award(hero, func, nil,
           {
             ARTIFACT_EVERCOLD_ICICLE,
             ARTIFACT_RUNIC_WAR_AXE
           })
      sleep()
      startQuest(moriton.names.kklem, hero)
    elseif getProgress(moriton.names.kklem) == 1 then -- ����� �������?
      MessageBox(moriton.paths.kklem..'keyKeeper_end.txt')
      finishQuest(moriton.names.kklem, hero)
      local func = function(hero) addArmy(hero, 0.15) end
      Award(hero, func, {[0] = 0; 2, 2, 2, 2},
           {
             ARTIFACT_CROWN_OF_MAGI,
             ARTIFACT_TWISTING_NEITHER,
             ARTIFACT_STAFF_OF_VEXINGS
           })
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        ShowFlyingSign(rtext('���������� ���������, �������!'), object, -1, 7.0)
      end)
    end
  end
end)

-- ��������� ������, ������� ����� ����� �� ������
function InitUndeadStacks()
  for i = 1, 7 do
    SetObjectEnabled('stack'..i, nil)
    Touch.SetFunction('stack'..i,
    function(hero, object)
      local index = GetLastSavedCombatIndex()
      Touch.RemoveFunctions(object)
      SetObjectEnabled(object, not nil)
      sleep()
      MakeHeroInteractWithObject(hero, object)
      while GetLastSavedCombatIndex() == index do sleep() end
      moriton.deadStacks = moriton.deadStacks + 1
      if isActive(moriton.names.u_at) then
        updateQuest(moriton.names.u_at, moriton.deadStacks, hero)
      end
    end)
  end
end

InitUndeadStacks()

-- �������� ����� ������ ������. ������ ���, ����� �������� �� ���������, ����
-- � ������� ������ ������ ��� ��� �����
function checkDeadStacks()
  while isActive(moriton.names.u_at) and moriton.deadStacks < 7 do sleep() end
  updateQuest(moriton.names.u_at, 8, 'Greta')
  MessageBox(moriton.paths.u_at..'all_dead.txt')
end

-- � ������� ������ ���
function CheckMoritonRemoveDef(day)
  if day == moriton.remove_def then
    moriton.remove_def = -1 -- ����, ��� ������ ����� ������ ��������� � ������
    for i = 1, 3 do
      ShowObject('garnison'..i, 1)
      PlayVisualEffect(USED_FX.TOWN_PORTAL_FX, 'garnison'..i)
      Play3DSound(USED_SOUNDS.TOWN_PORTAL_SOUND, GetObjectPosition('garnison'..i))
      sleep(5)
      StopVisualEffects('blockEffect'..i)
      sleep(5)
    end
    MessageBox(rtext('�������� ���� ������� ������ � �����. ������ ����� ����� ��������.'))
  end
end

--------------------------------------------------------------------------------
-- �������� ��������

-- ����
SetObjectEnabled('qMine', nil)
SetDisabledObjectMode('qMine', DISABLED_INTERACT)
Touch.SetFunction('qMine',
function(hero, object)
  if isUnknown(moriton.names.u_path) then -- ���� ������ ���
    MessageBox(moriton.paths.u_path..'cant_enter.txt') -- �� ����� ������
  else
    SetObjectPosition(hero, 29, 52, 1, 0)
    if moriton.first_enter == 0 then -- ��������� �� ������ ����
      moriton.first_enter = 1
      updateQuest(moriton.names.u_path, 1, hero)
    end
  end
end)

-- �����
SetObjectEnabled('qMine_out', nil)
SetDisabledObjectMode('qMine_out', DISABLED_INTERACT)
Touch.SetFunction('qMine_out',
function(hero, object)
  SetObjectPosition(hero, 36, 69, 0, 0)
end)

-- ����� �� ������ - �����, ��� �� ������������
function uExitBlock(hero)
  if hero == 'Greta' then
    MessageBox(moriton.paths.u_path..'uPath_blocked.txt', nil)
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'uPath_exit', nil)
    updateQuest(moriton.names.u_path, 2, hero)
  end
end

-- ����� �������
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'SoM', 'SoMFight')

function SoMFight(hero)
  if hero == 'Greta' then
    if StartCombat(hero, nil, 7,
                  getRandFrom(CREATURE_SKELETON_ARCHER, CREATURE_SKELETON_WARRIOR), 922 + random(8),
                  getRandFrom(CREATURE_ZOMBIE, CREATURE_DISEASE_ZOMBIE), 698 + random(7),
                  getRandFrom(CREATURE_GHOST, CREATURE_POLTERGEIST), 321 + random(6),
                  getRandFrom(CREATURE_VAMPIRE_LORD, CREATURE_NOSFERATU), 228 + random(5),
                  getRandFrom(CREATURE_DEMILICH, CREATURE_LICH_MASTER), 107 + random(4),
                  getRandFrom(CREATURE_WRAITH, CREATURE_BANSHEE), 52 + random(3),
                  getRandFrom(CREATURE_SHADOW_DRAGON, CREATURE_HORROR_DRAGON), 31 + random(2)) then
      StopVisualEffects('scull_fx')
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'SoM', nil)
    end
  end
end

--------------------------------------------------------------------------------
-- ������
SetObjectEnabled('uGrave1', nil)
Touch.SetFunction('uGrave1',
function(hero, object)
  if hero == 'Greta' then
    if StartCombat(hero, nil, 7,
                  getRandFrom(CREATURE_SKELETON_ARCHER, CREATURE_SKELETON_WARRIOR), 377 + random(8),
                  getRandFrom(CREATURE_ZOMBIE, CREATURE_DISEASE_ZOMBIE), 279 + random(7),
                  getRandFrom(CREATURE_GHOST, CREATURE_POLTERGEIST), 131 + random(6),
                  getRandFrom(CREATURE_VAMPIRE_LORD, CREATURE_NOSFERATU), 97 + random(5),
                  getRandFrom(CREATURE_DEMILICH, CREATURE_LICH_MASTER), 48 + random(4),
                  getRandFrom(CREATURE_WRAITH, CREATURE_BANSHEE), 24 + random(3),
                  getRandFrom(CREATURE_SHADOW_DRAGON, CREATURE_HORROR_DRAGON), 15 + random(2)) then
      Award(hero, nil, nil,
            {
              ARTIFACT_SWORD_OF_RUINS,
              ARTIFACT_LION_HIDE_CAPE,
              ARTIFACT_BOOTS_OF_SWIFTNESS,
              --ARTIFACT_SKULL_HELMET
            },
            {
              {SPELL_CHAIN_LIGHTNING, SPELL_METEOR_SHOWER},
              {SPELL_WEAKNESS, SPELL_FORGETFULNESS},
              {SPELL_RESURRECT, SPELL_TELEPORT},
              {SPELL_ARCANE_CRYSTAL, SPELL_SUMMON_ELEMENTALS}
            })
      sleep(5)
      addGold(7000, hero)
      Touch.RemoveFunctions(object)
      SetObjectEnabled(object, not nil)
    end
  end
end)

SetObjectEnabled('uGrave2', nil)
Touch.SetFunction('uGrave2',
function(hero, object)
  if hero == 'Greta' then
    if StartCombat(hero, nil, 7,
                  getRandFrom(CREATURE_SKELETON_ARCHER, CREATURE_SKELETON_WARRIOR), 611 + random(8),
                  getRandFrom(CREATURE_ZOMBIE, CREATURE_DISEASE_ZOMBIE), 478 + random(7),
                  getRandFrom(CREATURE_GHOST, CREATURE_POLTERGEIST), 232 + random(6),
                  getRandFrom(CREATURE_VAMPIRE_LORD, CREATURE_NOSFERATU), 133 + random(5),
                  getRandFrom(CREATURE_DEMILICH, CREATURE_LICH_MASTER), 71 + random(4),
                  getRandFrom(CREATURE_WRAITH, CREATURE_BANSHEE), 35 + random(3),
                  getRandFrom(CREATURE_SHADOW_DRAGON, CREATURE_HORROR_DRAGON), 22 + random(2)) then
      Award(hero, nil, {[0] = 0; 1, 1, 1, 1},
           {
             ARTIFACT_WEREWOLF_CLAW_NECKLACE,
             --ARTIFACT_DRAGON_WING_MANTLE,
             ARTIFACT_DWARVEN_MITHRAL_CUIRASS,
             ARTIFACT_SANDALS_OF_THE_SAINT
           },
           {
             {SPELL_IMPLOSION},
             {SPELL_BERSERK},
             {SPELL_ANTI_MAGIC},
             {SPELL_CELESTIAL_SHIELD}
           })
      sleep(5)
      addGold(15000, hero)
      Touch.RemoveFunctions(object)
      SetObjectEnabled(object, not nil)
    end
  end
end)

SetObjectEnabled('uGrave3', nil)
Touch.SetFunction('uGrave3',
function(hero, object)
  if hero == 'Greta' then
    if StartCombat(hero, nil, 7,
                  getRandFrom(CREATURE_SKELETON_ARCHER, CREATURE_SKELETON_WARRIOR), 1299 + random(8),
                  getRandFrom(CREATURE_ZOMBIE, CREATURE_DISEASE_ZOMBIE), 919 + random(7),
                  getRandFrom(CREATURE_GHOST, CREATURE_POLTERGEIST), 423 + random(6),
                  getRandFrom(CREATURE_VAMPIRE_LORD, CREATURE_NOSFERATU), 216 + random(5),
                  getRandFrom(CREATURE_DEMILICH, CREATURE_LICH_MASTER), 111 + random(4),
                  getRandFrom(CREATURE_WRAITH, CREATURE_BANSHEE), 73 + random(3),
                  getRandFrom(CREATURE_SHADOW_DRAGON, CREATURE_HORROR_DRAGON), 47 + random(2)) then
      Award(hero, nil, {[0] = 0; 3, 3, 3, 3},
           {
             ARTIFACT_DRAGON_SCALE_SHIELD,
             ARTIFACT_CLOAK_OF_MOURNING,
             ARTIFACT_RING_OF_MAGI,
             ARTIFACT_CROWN_OF_COURAGE,
            --ARTIFACT_BOOK_OF_POWER
           },
           {
             {SPELL_DEEP_FREEZE},
             {SPELL_VAMPIRISM},
             {SPELL_DIVINE_VENGEANCE},
             {SPELL_BLADE_BARRIER}
           })
      sleep(5)
      addGold(25000, hero)
      Touch.RemoveFunctions(object)
      SetObjectEnabled(object, not nil)
    end
  end
end)

--------------------------------------------------------------------------------
-- ����� ������

-- ������ ��������� � �������
SetObjectEnabled('witch2', nil)
Touch.SetFunction('witch2',
function(hero, object)
  if hero == 'Greta' then
    if isUnknown(moriton.names.witch) then -- ������ ��� �����?
      MessageBox(moriton.paths.witch..'witch2_start.txt')
      startQuest(moriton.names.witch, hero)
      sleep()
      startThread(CheckWitchArtifacts)
      MarkObjectAsVisited(object, hero)
    elseif getProgress(moriton.names.witch) == 1 then -- ��������� ������?
      MessageBox(moriton.paths.witch..'witch2_end.txt')
      finishQuest(moriton.names.witch, hero)
      local func = function(hero) addCreaturesByTier(hero, TOWN_PRESERVE, 1, 130) end
      Award(hero, func, {[0] = 0; 0, 0, 0, 0, 0, 5})
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        ShowFlyingSign(rtext('�� �� ������� ��������� ����� ������, �������!'), object, -1, 7.0)
      end)
    end
  end
end)

Touch.SetFunction('witch2',
function(hero, object)
  if hero == 'Greta' and moriton.wsp_learned == 0 then
    TalkBoxForPlayers(PLAYER_1,
                     '/Textures/Interface/CombatArena/Faces/Dungeon/ico_Priestess_128.xdb#xpointer(/Texture)',
                     moriton.paths.witch..'w_name.txt',
                     moriton.paths.witch..'w_def_text.txt',
                     nil,
                     'wCallback',
                     0, moriton.paths.witch..'w_name.txt',
                     nil, 0,
                     moriton.paths.witch..'w_opt1.txt',
                     moriton.paths.witch..'w_opt2.txt',
                     moriton.paths.witch..'w_opt4.txt',
                     moriton.paths.witch..'w_opt3.txt')
  end
end)

function wCallback(player, answer)
  if answer < 1 then
    return
  else
    if answer == 1 then
      if GetHeroSkillMastery('Greta', SKILL_SORCERY) < 3 then
        GiveHeroSkill('Greta', SKILL_SORCERY)
        ShowFlyingSign(rtext('<color=red>�� ��������� �����������!'), 'Greta', -1, 5.0)
        moriton.wsp_learned = 1
      else
        ShowFlyingSign(rtext('<color=red>�� ��� �������� �������� ����!'), 'Greta', -1, 5.0)
      end
    elseif answer == 2 then
      if GetHeroSkillMastery('Greta', SKILL_SUMMONING_MAGIC) < 3 then
        GiveHeroSkill('Greta', SKILL_SUMMONING_MAGIC)
        ShowFlyingSign(rtext('<color=green>�� ��������� ����� �������!'), 'Greta', -1, 5.0)
        moriton.wsp_learned = 1
      else
        ShowFlyingSign(rtext('<color=green>�� ��� �������� �������� ����!'), 'Greta', -1, 5.0)
      end
    elseif answer == 3 then
      if GetHeroSkillMastery('Greta', SKILL_WAR_MACHINES) < 3 then
        GiveHeroSkill('Greta', SKILL_WAR_MACHINES)
        ShowFlyingSign(rtext('<color_neutral>�� ��������� ���������� ��������!'), 'Greta', -1, 5.0)
        moriton.wsp_learned = 1
      else
        ShowFlyingSign(rtext('<color_neutral>�� ��� �������� �������� ����!'), 'Greta', -1, 5.0)
      end
    else
      ShowFlyingSign(rtext('<color_default>���-������ � ������ ���...'), 'Greta', -1, 5.0)
    end
  end
end

-- �������� ������� ���������� � �����
function CheckWitchArtifacts()
  while 1 do
    if HasArtefact('Greta', ARTIFACT_SKULL_OF_MARKAL) and
       HasArtefact('Greta', ARTIFACT_NIGHTMARISH_RING) then
      MessageBox(moriton.paths.witch..'both_arts.txt')
      updateQuest(moriton.names.witch, 1, 'Greta')
      sleep()
      return
    end
    sleep(2)
  end
end

--print('moriton quests loaded')