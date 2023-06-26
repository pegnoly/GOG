main =
{
  name = 'KILL_BLACK_HAND',
  --
  alliance = 'ALLIANCE',
  def_rt   = 'DEF_RAINTEMPLE',
  def_cc   = 'DEF_CASTLECROSS',
  def_cn   = 'DEF_CARN',
  --
  catapult = 'CATAPULT',
  seal     = 'GATE_SEAL',
  --
  path = q_path..'Main/',
  --
  haven_towns = {'Raintemple', 'Castlecross', 'Carn'},
  first_stage_date = 0,
  villages_msg = 0,
  
  cats =
  {
    {x = 4, y = 20, f = GROUND, rot = 155},
    {x = 14, y = 24, f = GROUND, rot = 146},
    {x = 6, y = 50, f = GROUND, rot = 9},
    {x = 30, y = 62, f = GROUND, rot = 320}
  }
}

function MainInit()
  BlockTownsGarrisons(1)
  for i, town in GetObjectNamesByType('TOWN') do
    Trigger(OBJECT_CAPTURE_TRIGGER, town, 'CommonTownCapture')
  end
  ManageObject('necro_garrison_01', 1)
  --
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'river_block1', 'MeetEmpire')
  DeployReserveHero('BlackHand', RegionToPoint('IlshamAggar_spawn_point'))
  DeployReserveHero('BlueHand', RegionToPoint('rt_attack_move_point'))
  DeployReserveHero('GreenHand', RegionToPoint('cn_siege_point'))
  DeployReserveHero('Nemor', RegionToPoint('Castlecross_spawn_point'))
  --
  EnableHeroAI('BlueHand', nil)
  EnableHeroAI('GreenHand', nil)
  EnableHeroAI('Nemor', nil)
  --
  sleep(25)
  --
  SetObjectPosition('Nemor', GetObjectPosition('Castlecross'))
  startThread(NecroTownsCreaturesUpdate)
  startThread(HandsRespawnThread)
  --
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'necro_wall_show_reg', 'ShowNecroWall')
  -- перенести -> после снятия завесы
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'ig_gates_reg', 'CloseGates')
  for i = 1, 4 do
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'cat_0'..i..'_place_reg', 'PlaceCatapult')
  end
end

function CommonTownCapture(p_owner, new_owner, hero, object)
  if contains({PLAYER_2, PLAYER_3, PLAYER_4}, new_owner) and GetTownRace(object) ~= TOWN_NECROMANCY then
    TransformTown(object, TOWN_NECROMANCY)
  end
  if IsActive(main.def_rt) and object == 'Raintemple' and hero == 'BlueHand' then
    MessageBox(main.path.."stage_1_failed.txt")
    Loose()
  end
  if IsActive(main.def_cc) and object == 'Castlecross' and new_owner == PLAYER_1 then
    FinishQuest(main.def_cc)
  end
end

--
--------------------------------------------------------------------------------
-- первая стадия - остановить прорыв некромантов

function MeetEmpire(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  UpdateQuest(main.alliance, 1, hero)
  StartQuest(main.def_rt)
  StartQuest(main.def_cc)
  StartQuest(main.def_cn)
  main.first_stage_date = GetDate(DAY) + 11
  startThread(CheckFirstStageCompleted)
  startThread(BlueHandRTMove)
end

function BlueHandRTMove()
  local day, mp_remove_flag = GetDate(DAY), nil
  while IsHeroAlive('BlueHand') do
    while not IsPlayerCurrent(3) do
      sleep()
    end
    if not mp_remove_flag then
      ChangeHeroStat('BlueHand', STAT_MOVE_POINTS, GetHeroStat('BlueHand', STAT_MOVE_POINTS) * 0.5 + 0.1 * diff)
      mp_remove_flag = 1
    end
    MoveHero('BlueHand', GetObjectPosition('Raintemple'))
    while GetDate(DAY) == day do
      sleep()
    end
    day, mp_remove_flag = GetDate(DAY), nil
    sleep()
  end
end

function CheckFirstStageCompleted()
  while 1 do
    if GetDate(DAY) == main.first_stage_date then
      MessageBox(rtext('Вы не успели остановить продвижение армии некромантов! Армия Империи окружена и разгромлена...'))
      Loose()
    end
    if IsCompleted(main.def_rt) and
       IsCompleted(main.def_cc) and
       IsCompleted(main.def_cn) then
      startThread(SecondStageStart)
      break
    end
    sleep()
  end
end
    
function SecondStageStart()
  --
  for i, town in main.haven_towns do
    SetObjectOwner(town, PLAYER_1)
  end
  main.villages_msg = GetDate(DAY) + 1
  plague.start = GetDate(DAY) + 3
  --
  startThread(NecroTownsCreaturesSetup)
  startThread(Player2RespawnThread)
  --
--  for i, town in {'Freymia', 'Lernur', 'Crianna'} do
--    UpgradeTownBuilding(town, TOWN_BUILDING_TAVERN)
--  end
  --
  local necro_active = GetDate(DAY) + 3 + 5 - diff
  startThread(
  function()
    while GetDate(DAY) ~= %necro_active do
      sleep()
    end
    SetRegionBlocked('river_block1', nil, PLAYER_2)
    SetRegionBlocked('river_block2', nil, PLAYER_2)
  end)
end

--
--------------------------------------------------------------------------------
-- вторая стадия - продержаться до подхода войск

function VillagesInfoMessage()
  main.villages_msg = 0
  for i = 1, length(VILLAGES) do
    OpenRegionFog(PLAYER_1, 'village'..i)
  end
  MessageBox(main.path..'villages_info.txt')
end



--
--------------------------------------------------------------------------------
-- прорвать оборону Ильшам-Аггара

-- завеса тьмы
function ShowNecroWall(hero, region)
  if not GetObjectOwner(hero) == PLAYER_1 then
    return
  end
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  BlockGame()
  OpenRegionFog(PLAYER_1, 'necro_wall')
  MoveCamera(43, 25, GROUND, 15, 0, math.pi / 2)
  sleep(20)
  MoveCamera(43, 48, GROUND, 15, 0, math.pi / 2)
  sleep(50)
  ShowObject(hero, 1)
  sleep()
  UpdateQuest(main.name, 2, hero)
  UnblockGame()
end

-- регион перед воротами
function CloseGates(hero, region)
  if not GetObjectOwner(hero) == PLAYER_1 then
    return
  end
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  BlockGame()
  ShowObject('ig_gates', 1, 1)
  sleep(25)
  PlayObjectAnimation('ig_gates', 'close', ONESHOT_STILL)
  sleep(20)
  for i = 1, 4 do
    ShowObject('ig_tower_0'..i, 1)
    sleep(10)
  end
  UnblockGame()
end
  
-- катапульты
function PlaceCatapult(hero, region)
  local cat_obj = '/MapObjects/Catapult.(AdvMapStaticShared).xdb#xpointer(/AdvMapStaticShared)'
  local cat_num = 0
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  --
  if region == 'cat_01_place_reg' then
    cat_num = 1
  elseif region == 'cat_02_place_reg' then
    cat_num = 2
  elseif region == 'cat_03_place_reg' then
    cat_num = 3
  else
    cat_num = 4
  end
  --
  local ig_x, ig_y, ig_z = GetObjectPosition('IlshamAggar')
  CreateStatic('cat_0'..cat_num, cat_obj, main.cats[cat_num].x, main.cats[cat_num].y, main.cats[cat_num].f, main.cats[cat_num].rot)
  repeat
    sleep()
  until IsObjectExists('cat_0'..cat_num)
  sleep(8)
  for i = 1, 2 + random(2) do
    PlayObjectAnimation('cat_0'..cat_num, 'rangeattack', ONESHOT)
    sleep(3)
    PlayFX('Fireball', 'ig_tower_0'..cat_num)
    sleep(10 + random(10))
  end
  local tx, ty = GetObjectPosition('ig_tower_0'..cat_num)
  MoveCamera(tx, ty, GROUND, 30, 0, 0, 0, 1, 1)
  sleep()
  PlayFX('Fireball', 'ig_tower_0'..cat_num)
  sleep(5)
  PlayFX('Big_fire_1', 'ig_tower_0'..cat_num)
end