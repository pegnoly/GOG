--------------------------------------------------------------------------------
-- ���� - �������������� �����
-- ��������� �� 08.06.2019

-- 1. ���� ������� ������� - ����� ������ � ����������� ���������� � ��������� �� ������� +
-- 2. � ��������� �������� ������� ���� �� ���� ���� �������� �� ����, ����� ������ � ��� ���� - ��� ���� ������� ��������(���������� �������, ��� ���� �������� ������ ���) +
-- 3. � ��������� �������, ��� ����� �������� ��� ��������� ������ �������� ��������� - ������ �������� � ��������� +
-- 4. ����� ����� ������� ���� ������� ��� ��������� ������� - ������ �� ����� +
-- 5. � ��������� �������� ���������� � ����������� � ���� +
-- 6. ��� �������, ��� ������� ���� � ���, ��� � ������� ������������ ����������� ���� �� ���� +
-- 7. ���������� ����� - ����������� +
-- 8. �����, ������� �����, ��� ����������, ���� � ���������� �� ������� +
-- 9. �� ���������� ����� �� ���������� ���� �����, ��� �� ������ ���������� ���� ���������� ��������� � �� ������� +
-- 10. ��������� � ����������� ����, ��������� ����� � ���������� +

plague =
{
  name = 'PLAGUE',
  path = q_path..'Plague/',
  hit_period = 1,
  hit_day = 0,
  start = 0,
  dead_bodies_touched = 0,
  first_purged_village = nil, -- ������ ��������� '������������' �������� �������
  deseased_hero = ' ',
  hero_desease_day = 0,
  gh_mode_state = 0,
  gh_creatures = {},
  gh_number = 0,
  gh_heroes = {},
  gh_towns = {},
  gh_buildings = {},
}

-- ������
function PlagueStart()
  PlagueHit()
  StartQuest(plague.name)
  MessageBox(plague.path..'start.txt')
  ShowObject('MonkTemple', 1)
end

-- ������� ������, ��������� �� ���
function PlagueNewDay(day)
  -- ���� �������
  if day == plague.start then
    PlagueStart()
  end
  -- ����, ����� ���������� �����, ����������� � �����
  if day == plague.hero_desease_day then
    BlockGame()
    if day == plague.hit_day then
      plague.hit_day = day + plague.hit_period
    end
    ShowObject(plague.deseased_hero)
    sleep()
    PlayFX('Plague', plague.deseased_hero)
    sleep(15)
    MessageBox(plague.path..'hero_deseased.txt', 'UnblockGame')
    UpdateQuest(plague.name, 8, plague.deseased_hero)
    return
  end
  -- ����, ����� ���� ������ ���������� � ��������� ���
  if day == plague.hit_day then
    -- ���������, ��� �� ����� ����������� ��������� �������
    if plague.first_purged_village ~= nil then
      PlagueHitPurgedVillage()
      plague.first_purged_village = nil
      MessageBox(plague.path..'plague_hits_purged_village.txt')
      UpdateQuest(plague.name, 4)
    else
      PlagueHit()
    end
  end
end

-- ������� ������� ��������� �������, � � ��� ���� ��� ����
function PlagueGetTargets()
  local temp_answer, temp_n, temp_targets = {}, 1, {}
  -- ��� ���� ��������� ��������
  for village, info in VILLAGES do
    local n = 0
    -- ��������� ���� ��������� ��������
    for i, actor in info.actors do
      -- �������� ��� ��������������?
      if not NON_INTERACT_ACTORS[actor] then
        print(actor)
        n = n + 1
        -- ������� ������������� �������, �������� ��������� ���� � ����������� �������
        if not temp_targets[temp_n] then
          temp_targets[temp_n] = {}
        end
        -- �������� ���� ��������� ����
        temp_targets[temp_n][n] = actor
      end
    end
    -- ���� ���� ���� � ������� ����?
    if n > 0 then
      -- ������� ������� � ������� ��������� �������
      temp_answer[temp_n] = village
      temp_n = temp_n + 1
    end
  end
  print('temp_n: ', temp_n)
  -- ������� ������� ����� - ��-�� ��� ������� �����, ��������� ���
  if length(temp_answer) == 0 then
    return nil
  else -- �����
    -- ������� ��������� ������� � ���������
    local prob = random(length(temp_answer)) + 1
    print('prob: ', prob)
    -- ������������� ������ - �������� ��������� ������� � �������� ��������� � ��� ����
    local answer, target = temp_answer[prob], GetRandFromT(temp_targets[prob])
    return answer, target
  end
end

-- ������ ������������ ����
function PlagueHit()
  --print(target)
  local village, actor = PlagueGetTargets()
  print('actor: ', actor)
  if village and actor then
    PlagueHitAction(actor, village)
  end
end

-- ���������������� ������������ ���� - ���������� ���� � �������, � ������� ��� ���������
function PlagueHitAction(actor, village)
  local x, y, z = GetObjectPosition(actor)
  BlockGame()
  MoveCamera(x, y, z, 60, 0, 0, 0, 1, 1)
  Touch.OverrideFunction(actor, '_talk',
  function(hero, object)
    ShowFlyingSign(rtext('�� ����� �������� �����...'), object, -1, 5.0)
  end)
  Touch.SetPriorityFunction(actor, PlagueDeadBodyTouch)
  -- � �������� ������ ������ ��������� �����������������
  NON_INTERACT_ACTORS[actor] = 1
  -- ��������� ����� ������� � ������ ������� ��������
  VILLAGES[village].dead_peasants = VILLAGES[village].dead_peasants + 1
  PlayFX('Plague', actor)
  sleep(5)
  PlayObjectAnimation(actor, 'death', ONESHOT_STILL) -- �������� ���������, �.�. ��� ��������� � NON_ESSENTIAL, ������, ��
  sleep(10)
  print('next plague hit in: ', plague.hit_period, ' days')
  plague.hit_day = GetDate(DAY) + plague.hit_period
  UnblockGame()
  startThread(UpdateVillageInfo, village)
end

-- ������� ���������� �������� � ����������� �� ����� ������� � ������� ��������
function UpdateVillageInfo(village)
  -- ����������� ����� �������� � �������
  local initial_peasants = length(VILLAGES[village].actors)
  -- ����������� ����� ������
  local initial_builds   = length(VILLAGES[village].huts) + length(VILLAGES[village].mines)
  -- ������ ��������� �� ������� ������
  local sum = VILLAGES[village].ruined_huts + VILLAGES[village].ruined_mines
  -- ��������� �������/����������� ��������� ����� �����, ��������� �� �����������/����������� ������
  if ((VILLAGES[village].dead_peasants / initial_peasants) >= (0.2 + sum / initial_builds)) then
    -- ����������� ����������� �����
    if VILLAGES[village].ruined_mines < length(VILLAGES[village].mines) then
      local temp_mines, n = {}, 0
      -- ����� ������������� �����
      for i, mine in VILLAGES[village].mines do
        if not RUINED_BUILDS[mine] then
          n = n + 1
          temp_mines[n] = mine
        end
      end
      local target = GetRandFromT(temp_mines)
      print('target: ', target)
      -- ��������� ���������
      CurseMine(target, village)
    else
      -- ��� ����� �������� - ���������� � ������������� ������
      local temp_huts, n = {}, 0
      for i, hut in VILLAGES[village].huts do
        if not RUINED_BUILDS[hut] then
          n = n + 1
          temp_huts[n] = hut
        end
      end
      local target = GetRandFromT(temp_huts)
      CurseHut(target, village)
    end
  end
end

-- ��������� �����
function CurseMine(mine, village)
  BlockGame()
  ShowObject(mine, 1)
  sleep()
  SetObjectOwner(mine, PLAYER_8)
  PlayFX('Curse', mine)
  sleep(5)
  PlayFX('Dragon_grave', mine, mine..'_fx')
  SetObjectFlashlight(mine, 'ruined_build_fl')
  sleep()
  ShowFlyingSign(rtext('������ ��������!'), mine, -1, 5.5)
  UnblockGame()
  -- ������ � ������� ����������� ������
  RUINED_BUILDS[mine] = 1
  -- ��� ������ ������� �������� ������� ����������� ����
  VILLAGES[village].ruined_mines = VILLAGES[village].ruined_mines + 1
end

-- ��������� ����� - ���������� ��������
function CurseHut(hut, village)
  BlockGame()
  ShowObject(hut, 1)
  sleep()
  SetObjectOwner(hut, PLAYER_8)
  PlayFX('Curse', hut, '', -1, 1)
  sleep(5)
  PlayFX('Dragon_grave', hut, hut..'_fx', -1, 1)
  SetObjectFlashlight(hut, 'ruined_build_fl')
  sleep()
  ShowFlyingSign(rtext('������ ��������!'), hut, -1, 5.5)
  UnblockGame()
  RUINED_BUILDS[hut] = 1
  VILLAGES[village].ruined_huts = VILLAGES[village].ruined_huts + 1
  if length(VILLAGES[village].huts) == VILLAGES[village].ruined_huts then
    MessageBox(rtext('���� �� �������� ��������� ������� �� ����!'))
    -- ����� ������� ����� ������� ��������� �������
  end
end

-- ���� ���� �� ��������� �������
function PlagueHitPurgedVillage()
  local village = plague.first_purged_village
  local targets, n = {}, 0
  for i, actor in VILLAGES[village].actors do
    if not NON_INTERACT_ACTORS[actor] then
      n = n + 1
      targets[n] = actor
    end
  end
  local target = GetRandFromT(targets)
  PlagueHitAction(target, village)
  -- �.�. ��� '��������' �������� ����������������� ������, ��������� �� �������
  for i, mine in VILLAGES[village].mines do
    if RUINED_BUILDS[mine] then
      PlayFX('Dragon_grave', mine)
      SetObjectFlashlight(mine, 'ruined_build_fl')
      SetObjectOwner(mine, PLAYER_8)
    end
  end
  for i, hut in VILLAGES[village].huts do
    if RUINED_BUILDS[hut] then
      PlayFX('Dragon_grave', hut)
      SetObjectFlashlight(hut, 'ruined_build_fl')
      SetObjectOwner(hut, PLAYER_8)
    end
  end
end

-- ������������� � ���� �������� �� ����
function PlagueDeadBodyTouch(hero, object)
  if GetProgress(plague.name) == 1 then
    plague.dead_bodies_touched = plague.dead_bodies_touched + 1 -- �������� ����� ���, � ������� ������������
    if plague.dead_bodies_touched == 3 then -- ���� ��� ������ ����
      MessageBox(plague.path..'ghost_attack.txt')
      if StartCombat(hero, nil, 3,
                     CREATURE_GHOST, 100,
                     CREATURE_MANES, 140,
                     CREATURE_POLTERGEIST, 150) then -- �������� ��������
        UpdateQuest(plague.name, 2, hero)
        MessageBox(plague.path..'got_ghost_essence.txt') -- �������� ��������� '���������'
        for actor, info in NON_INTERACT_ACTORS do
          Touch.SetPriorityFunction(actor, nil)
        end
      end
    elseif plague.dead_bodies_touched == 2 then -- ����� ������...
      MessageBox(plague.path..'dead_body_touch2.txt')
    else
      MessageBox(plague.path..'dead_body_touch1.txt') -- ...� ������
    end
    Touch.SetPriorityFunction(object, nil)
  else
    ShowFlyingSign(rtext('�� ����� �������� �����...'), object, -1, 5.0)
    if GetProgress(plague.name) > 1 then
      Touch.SetPriorityFunction(object, nil)
    end
  end
end

-- ���������� ������� ���������
Touch.DisableObject('MonkTemple')
Touch.SetFunction('MonkTemple', '_talk',
function(hero, object)
  local dialog_name = GetDialogName(hero)
  local progress = GetProgress(plague.name)
  if progress == 0 then -- ���� ������ ��������?
    MessageBox({plague.path..'monk_start.txt'; name = dialog_name})
    UpdateQuest(plague.name, 1, hero)
  elseif progress == 2 then -- ���������� ��������� � ������� ����?
    MessageBox({plague.path..'monk_ritual_prepare.txt'; name = dialog_name})
    UpdateQuest(plague.name, 3, hero)
    GiveArtifact(hero, ARTIFACT_RING_OF_UNSUMMONING, 1)
  elseif progress == 4 then -- ��������� ������ �� ��������?
    MessageBox({plague.path..'monk_find_river_seer.txt'; name = dialog_name})
    ShowObject('RiverSeer', 1)
    UpdateQuest(plague.name, 5, hero)
  end
end)

-- ������� �������� ������� �������� �������
-- ����������� ��� ����� � ����� �������, ��� �������, ��� �������� ������ �������� � �������
function PlagueTryToPurgeVillage(hero, village)
  if QuestionBox(plague.path..'want_to_purge.txt') then
    if GetPlayerResource(PLAYER_1, 3) > 4 then
      SetPlayerResource(PLAYER_1, 3, GetPlayerResource(PLAYER_1, 3) - 5)
      BlockGame()
      -- �������� ��������������� ����������� ������ � �����
      for i, mine in VILLAGES[village].mines do
        PlayFX('Divine_venge', mine)
        if RUINED_BUILDS[mine] then
          StopVisualEffects(mine..'_fx')
          ResetObjectFlashlight(mine)
          SetObjectOwner(mine, PLAYER_1)
        end
      end
      sleep(5)
      for i, hut in VILLAGES[village].huts do
        PlayFX('Bless', hut)
        if RUINED_BUILDS[hut] then
          StopVisualEffects(hut..'_fx')
          ResetObjectFlashlight(hut)
          SetObjectOwner(hut, PLAYER_1)
        end
      end
      UnblockGame()
      ShowFlyingSign(plague.path..'purge_success.txt', hero, -1, 5.0)
      if not plague.first_purged_village then
        plague.first_purged_village = village -- ��������� ������ ��������� �������, ����� ���� ����������� ����� ������� �� ���
        print('first purged village saved')
      end
    end
  end
end

-- ������ ��������� � ������ �����������
Touch.DisableObject('RiverSeer')
Touch.SetFunction('RiverSeer', '_talk',
function(hero, object)
  local dialog_name = GetDialogName(hero)
  local progress = GetProgress(plague.name)
  if progress == 5 then -- ������ ��� �����?
    MessageBox({plague.path..'river_seer_start.txt'; name = dialog_name})
    UpdateQuest(plague.name, 6, hero)
    sleep()
    MessageBox(plague.path..'river_find_liches.txt')
  else
    if hero == plague.deseased_hero then
      if progress == 8 and plague.gh_mode_state == 0 then -- ���������� ����� ����� �������?
        MessageBox({plague.path..'river_seer_temp.txt'; name = dialog_name})
        plague.gh_mode_state = 1
        MakeHeroInteractWithObject(hero, object)
      elseif progress == 8 and plague.gh_mode_state == 1 and -- ������ ����� � ����������� ���?
             QuestionBox(rtext('������� ������� �� ���������� ����?')) then
        startThread(PlagueGhostModeFirstEnter)
        UpdateQuest(plague.name, 9, hero)
        local func = function() return GetProgress(plague.name) == 9 end
        startThread(UnlimMove, hero, func)
      elseif progress == 10 then -- ����� ��������?
        MessageBox({plague.path..'river_seer_end.txt'; name = dialog_name})
        FinishQuest(plague.name, hero)
        Touch.OverrideFunction(object, '_talk',
        function(hero, object)
          ShowFlyingSign(rtext('����� ������ ���...'), object, -1, 5.0)
        end)
      end
    end
  end
end)

-- ���������� ���������� ������ �����, ����� ����� �������� � �������� �� �����
function PlagueShowLiches(hero)
  ShowObject('liches_ritual_place', 1)
  AnimGroup['liches'] = {actors = {'ritual_lich1', 'ritual_lich2', 'ritual_lich3'}}
  PlayAnims(AnimGroup['liches'],{'rangeattack', 'cast', 'happy'}, COND_OBJECT_EXISTS)
  sleep(20)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'showLiches', nil)
end
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'showLiches', 'PlagueShowLiches')

-- ����� � ������. ������� ������ ������ � ������� ���������� ��� ����������� ����� ���
function PlagueLichesCombat(hero)
  if StartCombat(hero, nil, 3,
                 CREATURE_LICH, 100,
                 CREATURE_LICH, 220,
                 CREATURE_LICH, 114) then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'lichesFight', nil)
    sleep(5)
    PlayAnims(AnimGroup['liches'], {'death'}, COND_SINGLE, ONESHOT_STILL)
    sleep(15)
    for i = 1, 3 do
      RemoveObject('ritual_lich'..i)
    end
    StopVisualEffects('liches_posses_fx')
    StopVisualEffects('liches_curse_fx')
    plague.deseased_hero = hero
    plague.hero_desease_day = GetDate(DAY) + 1
    UpdateQuest(plague.name, 7)
  end
end
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'lichesFight', 'PlagueLichesCombat')

-- ������ ��������� � ��� ���������
function PlagueGhostModeFirstEnter()
  BlockGame()
  local all_creatures = GetObjectNamesByType('CREATURE') -- ����� ���� ������� �� �����
  for i, creature in all_creatures do
    print(creature)
    if creature and IsObjectExists(creature) then -- ��� ���� �������
      PlayObjectAnimation(creature, 'idle00', ONESHOT_STILL) -- ����������� �������� � ONESHOT_STILL, ����� �������� �������
      if IsObjectEnabled(creature) then
        SetObjectEnabled(creature, nil)
      end -- �� ����������� ���������
      plague.gh_creatures[creature] = nil -- ���� ���� ���� ��� ���� �������, ���� ���� � ��������� ������� ���� �����
      Touch.SetPriorityFunction(creature, PlagueGhMsg) -- ������ �������
      if (not NON_INTERACT_ACTORS[creature]) then -- ����� ����������� ������������� �������
        local x, y, z = GetObjectPosition(creature)
        -- � ������� � ���������� �����
        if y > 75 and z ~= 1 then
          -- �� ���� ���������� �������� ���������
          if random(2) == 1 then
            if not IsObjectVisible(PLAYER_1, creature) then -- ���� �������� �� ����� ������
              ShowObject(creature) -- ��������, �� �� ������� ������
            end
            PlayFX('Ghost_posses', creature, creature..'_fx')
            SetObjectFlashlight(creature, 'ghosted_fl')
            plague.gh_number = plague.gh_number + 1 -- ����������� ������� ���������� �������
            plague.gh_creatures[creature] = 1
            Touch.SetPriorityFunction(creature, PlagueGhostModeFight) -- ������������ ��� ���
          end
        end
      end
    end
  end
  -- ��������� ���� �� ���������� ������
  SetRegionBlocked('river_block1', not nil)
  SetRegionBlocked('river_block2', not nil)
  startThread(SetAmbientLight, 0, 'ghost_light', not nil, 10)
  sleep(20)
  PlagueManageBuildings()
  sleep(20)
  PlagueManageTowns()
  sleep(20)
  PlagueManageHeroes()
  UnblockGame()
end

-- ������� ��������� ��� ���� � �������� �� ���������� �����
function PlagueGhMsg(hero, object)
  ShowFlyingSign(rtext('�������� ����� �� ��������� �� ���� �����������...'), object, -1, 7.0)
end

-- ��� �� ���������� ��������
function PlagueGhostModeFight(hero, object)
  if StartCombat(hero, nil, 1,
                 CREATURE_MANES, 100) then -- �������� ��������. ���� �������� ���...
    StopVisualEffects(object..'_fx') -- ������� � �������� ������
    ResetObjectFlashlight(object)
    ShowFlyingSign(rtext('���������� �������� ����������...'), object, -1, 7.0)
    Touch.SetPriorityFunction(object, PlagueGhMsg) -- ������ ������������ ������� �� ����������� ��� ����������� ����
    plague.gh_creatures[object] = nil -- ������� �������� �� ������� ����������
    plague.gh_number = plague.gh_number - 1 -- ��������� �������
    if plague.gh_number == 0 then -- ��������� ����������
      MessageBox(rtext('��� ���������� �������� ����������!'))
      sleep(15)
      startThread(PlagueNaadirFight)
    end
  end
end

-- ����������� ����� � ���������� ���
-- �� �� �����, �� ���������� ��� �������������� ������� ���������� ������� ��� �������� � �������
--function  plagueEnterGhostMode()
--  BlockGame()
--  for creature, ghosted in plague.gh_creatures do
--    if creature and IsObjectExists(creature) then
--      PlayObjectAnimation(creature, 'idle00', ONESHOT_STILL)
--      if IsObjectEnabled(creature) then
--        SetObjectEnabled(creature, nil)
--      end
--      if ghosted then
--        PlayVisualEffect(GHOST_POSSES_FX, creature, creature..'_fx')
--        Touch.SetPriorityFunction(creature, plagueGhostModeFight)
--      else
--        Touch.SetPriorityFunction(creature, plagueGhMsg)
--      end
--    end
--  end
--  startThread(SetAmbientLight, 0, 'ghost_light', not nil, 10)
--  sleep(20)
--  plagueManageBuildings()
--  sleep(20)
--  plagueManageTowns()
--  sleep(20)
--  plagueManageHeroes()
--  UnblockGame()
--end

-- ����� �� ���� ���������
function PlagueLeaveGhostMode()
  print('started')
  BlockGame()
  for i, creature in GetObjectNamesByType('CREATURE') do
    print('creature: ', creature)
    if creature and IsObjectExists(creature) then
      Touch.SetPriorityFunction(creature, nil) -- ������� ������������ �������
      PlayObjectAnimation(creature, 'idle00', ONESHOT) -- ������ �������� � ONESHOT, ����� �������� ��������� � ������� ��������� � �������������� ���������
      local table = Touch.GetHandlersTable(creature) -- ����������, ����� �� �����-���� ������� �� ��������
      if not table.funcs[1] then -- ���� �� ������� ���
        SetObjectEnabled(creature, not nil) -- �������� ��������
        Touch.RemoveFunctions(creature)
      end
    end
  end
  print('here')
  SetRegionBlocked('river_block1', nil)
  SetRegionBlocked('river_block2', nil)
  startThread(SetAmbientLight, 0, 'main_light', not nil, 10)
  sleep(20)
  PlagueRestoreBuildings()
  sleep(10)
  PlagueRestoreHeroes()
  sleep(10)
  PlagueRestoreTowns()
  print('ok')
  UnblockGame()
end

function PlagueNaadirFight()
  -- StartDialogScene() ����� � �������� �����
  DeployReserveHero(Naadir, 67, 169, 0)
  sleep(10)
  ShowObject(Naadir, 1)
  sleep(15)
  MessageBox(plague.path..'naadir.txt')
  if StartCombat(plague.deseased_hero, Naadir, 1, 30, 400) then
    UpdateQuest(plague.name, 10, plague.deseased_hero)
    MessageBox(plague.path..'naadir_dead.txt')
--    startThread(
--    function()
--      errorHook(function() UnblockGame() end) -- ����� ���������� ������ � �������������� �������� '3'. �� �����, ��� ���������, �������...
    PlagueLeaveGhostMode()
--    end)
  end
end

-- ��������� ������ ��� ����������� �����
function PlagueManageBuildings()
  -- ��������� ���
  for i, build in GetObjectNamesByType('BUILDING') do
    if IsObjectEnabled(build) then
      SetObjectEnabled(build, nil)
    end
    -- ��������� ��������� �������
    Touch.SetPriorityFunction(build,
    function(hero, object)
      ShowFlyingSign(rtext('������ ������� ���������� ������...'), object, -1, 7.0)
    end)
  end
  -- ������ ���������� ��� ������, ������� ����� ����� ���������
  for i, type in {'SAWMILL', 'ORE_PIT', 'ALCHEMIST_LAB', 'CRYSTAL_CAVERN',
                  'GEM_POND', 'SULFUR_DUNE', 'GOLD_MINE', 'ABANDONED_MINE',
                  'PEASANT_HUT', 'ARCHERS_HOUSE', 'BARRACKS', 'MILITARY_POST',
                  'GRAVEYARD', 'FORGOTTEN_CRYPT', 'RUINED_TOWER'} do
    for i, build in GetObjectNamesByType(type) do
      plague.gh_buildings[build] = GetObjectOwner(build)
      SetObjectOwner(build, PLAYER_NONE)
    end
  end
end

-- �������������� ������
function PlagueRestoreBuildings()
  for i, build in GetObjectNamesByType('BUILDING') do
    Touch.SetPriorityFunction(build, nil) -- ������ ������������
    local table = Touch.GetHandlersTable(build) -- ����������, ���� �� ������� �������
    if not table.funcs[1] then -- ���� ��� -
      SetObjectEnabled(build, not nil) -- ��������
    end
  end
  -- ������������ ����������
  for build, owner in plague.gh_buildings do
    SetObjectOwner(build, owner)
  end
end

-- ��������� ������
-- ������ ��������� ������ ����� ������ - ��������� ������ ���������
function PlagueManageHeroes()
  for i, hero in GetObjectNamesByType('HERO') do
    if hero ~= plague.deseased_hero then
      if GetObjectOwner(hero) == PLAYER_1 then
        SetObjectOwner(hero, PLAYER_6) -- ����������� ��������������� ������, ���� ������ ������������, ����� ������
      end
      sleep()
      EnableHeroAI(hero, nil)
      SetObjectEnabled(hero, nil)
      Touch.SetFunction(hero,
      function(hero, object)
        ShowFlyingSign(rtext('����� ������� � ����������, ������ ��������� ������...'), object, -1, 7.0)
      end)
    end
  end
end

-- �������������� ������
function PlagueRestoreHeroes()
  for i, hero in GetObjectNamesByType('HERO') do
    if hero ~= plague.deseased_hero then
      EnableHeroAI(hero, nil)
      SetObjectEnabled(hero, not nil)
      Touch.SetPriorityFunction(hero, nil)
      if GetObjectOwner(hero) == PLAYER_6 then
        SetObjectOwner(hero, PLAYER_1)
      end
    end
  end
end

-- ��������� �������
function PlagueManageTowns()
  for i, town in GetObjectNamesByType('TOWN') do
    if GetObjectOwner(town) == PLAYER_1 then
      SetObjectOwner(town, PLAYER_NONE)
    end
    SetObjectEnabled(town, nil)
    Touch.SetFunction(town,
    function(hero, object)
      ShowFlyingSign(rtext('��������� ������ ������������ � ���������� ����...'), object, -1, 7.0)
    end)
  end
end

-- �������������� �������
function PlagueRestoreTowns()
  for i, town in GetObjectNamesByType('TOWN') do
    if GetObjectOwner(town) == PLAYER_NONE then
      SetObjectOwner(town, PLAYER_1)
    end
    SetObjectEnabled(town, not nil)
    Touch.RemoveFunctions(town)
  end
end