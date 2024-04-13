--------------------------------------------------------------------------------
-- глав. - Основной путь

MainQ =
{
  name = 'MAIN_QUEST',
  path = q_path..'Main/',

  -- боевые арены для эльфийских постов
  posts = {ARENAS.POST_1, ARENAS.POST_2, ARENAS.POST_3},

  -- юниты, охраняющие первые два поста
  posts_units =
  {
    {
      'post1_archer1', 'post1_archer2', 'post1_archer3',
      'post1_treant1', 'post1_treant2', 'post1_druid',
      'post1_dancer', 'post1_uni'
    },
    {
      'post2_archer1', 'post2_archer2', 'post2_archer3', 'post2_archer4',
      'post2_dancer1', 'post2_dancer2', 'post2_druid',
      'post2_treant1', 'post2_treant2', 'post2_uni1', 'post2_uni2',
      'post2_dragon1', 'post2_dragon2'
    },
  },
  
  -- засада энтов, ['дерево'] = {id и ротация призыва}
  post3_treants =
  {
    ['treant_tree_1'] = {CREATURE_ANGER_TREANT, 46},
    ['treant_tree_2'] = {CREATURE_TREANT, 153},
    ['treant_tree_3'] = {CREATURE_TREANT_GUARDIAN, 211},
    ['treant_tree_4'] = {CREATURE_ANGER_TREANT, 288}
  },
  
  -- флаг, что Карлам недостижим и Лойрен ожидает его в одной из назначенных точек
  loiren_waits = 0,
  -- состояние точек назначения для Лойрена(1 - еще не посещена)
  loiren_dest =
  {
    ['loiren_dest1'] = 1,
    ['loiren_dest2'] = 1,
    ['loiren_dest3'] = 1
  },
  -- флаг получения инфы об обелисках
  obelisk_msg = 0,
  -- таблица соответствий обелисков и порталов
  dark_obelisks =
  {
    ['dark_obelisk_01'] = 'dark_portal_01',
    ['dark_obelisk_02'] = 'dark_portal_02',
    ['dark_obelisk_03'] = 'dark_portal_03',
    ['dark_obelisk_04'] = 'dark_portal_04',
  },
  -- флаг достижения Баалом региона обратной трансформации
  transform_reg = 0,
  -- флаг того, что второй разговор с Баалом состоялся
  second_dialog = 0,
  -- стражи подземного храма
  templar_1 = Letos,
  templar_2 = Vaishan,
  templar_3 = Ohtar,
  -- запуск
  Init =
  function()
    startThread(MainPathInit)
    startThread(DarkObelisksInit)
    startThread(DungInit)
  end
}

--------------------------------------------------------------------------------
-- глав. - Победить Ноэлли

def_noe =
{
  name = 'DEFEAT_NOELLI',
  path = q_path..'DefeatNoelli/',
  -- фурии у ритуальных алтарей
  blood_altar_furies = {'fury_main_01', 'fury_main_02', 'fury_exec_01', 'fury_exec_02', 'fury_exec_03', 'fury_exec_04'},
  -- флаг, что бой с фуриями выигран
  fury_fight_won = 0,
  -- состояние потока анимаций фурий у алтаря
  fury_trap_cycle_flag = 0,
  -- флаг получения ключа от подземного каземата
  prison_key = 0,
  -- флаг получения палочки с берсерком
  got_bers_stick = 0,
  -- число открытых тюрем в каземате
  prisons_opened = 0,
  -- флаг получения инфы о драконах в каземате
  dragon_info = 0,
  -- флаг использования берсерка на драконов
  dragon_bers = 0,
  -- флаг доступности портала в палаты интриг
  matron_portal_opened = 1,
}

--
--------------------------------------------------------------------------------
-- настройка основного пути через гарнизоны
function MainPathInit()
  startThread(DarkObelisksInit)
  for i, post in MainQ.posts_units do
    AnimGroup['post'..i] = {actors = post}
    for j, unit in post do
      Touch.DisableMonster(unit, nil, 0)
    end
  end
  DeployReserveHero(Vingael, RegionToPoint('ving_point'))
  sleep()
  EnableHeroAI(Vingael, nil)
  SetObjectEnabled(Vingael, nil)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post1', 'PostEnter')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post2', 'PostEnter')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post3', 'PostEnter')
  --
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'loiren_dest1', 'LoirenDest')
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'loiren_dest2', 'LoirenDest')
  --
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'loiren_enable1', 'LoirenEnable')
  --
  for i = 1, 4 do
    SetRegionBlocked('ai_block'..i, 1, PLAYER_3)
  end
  --
end

--
--------------------------------------------------------------------------------
-- настройка подземного храма
function DungInit()
  for i = 1, 2 do
    Touch.DisableMonster('witch'..i, DISABLED_INTERACT, 0)
  end
  EnableHeroAI(Noelli, nil)
  EnableHeroAI(Kelodin, nil)
  Touch.DisableObject('dung_enter')
  Touch.SetFunction('dung_enter', '_enter', DungEnter)
  --
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'kelo_meet_region', 'KelodinMeet')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'baal_fight_reg', 'BaalFight')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'show_garg_reg', 'FirstGargMeeting')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'fury_fight_reg', 'FuryTrapShow')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'fury_fight_fog_reg', 'FuryFight')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'death_pit_enter_reg', 'DeathPitFight')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'ballista_info_reg', 'BallistaInfo')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'ballista_attack_reg', 'BallistaAttack')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'elem_trap_05', 'BreakSeal')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'templar_2_reg', 'Templar2Attack')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dragon_trap_info', 'DragonTrapInfo')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dragon_trap_enter', 'DragonTrapEnter')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'noelli_fight', 'NoelliFight')
  --
  for i, fury in def_noe.blood_altar_furies do
    Touch.DisableMonster(fury, DISABLED_ATTACK, 0)
  end
  AnimGroup['furies'] = {actors = def_noe.blood_altar_furies}
  --
  for i, creature in GetObjectsInRegion('death_pit_reg', 'CREATURE') do
    Touch.DisableMonster(creature, DISABLED_BLOCKED, 0)
  end
  for i, creature in GetObjectsInRegion('death_pit_fight_reg', 'CREATURE') do
    Touch.DisableMonster(creature, DISABLED_INTERACT, 0)
  end
  --
  Touch.DisableObject('matron_chambers_portal_in')
  Touch.SetFunction('matron_chambers_portal_in', '_matron_portal', MatronPortalEnter)
  --
  Touch.DisableObject('magic_room_portal_out')
  Touch.SetFunction('magic_room_portal_out', '_p_out',
  function(hero, object)
    ShowFlyingSign(rtext('Портал не работает. Вероятно, он заблокирован с другой стороны...'), object, -1, 7.0)
  end)
  --
  Touch.DisableObject('prison_portal_in')
  Touch.SetFunction('prison_portal_in', '_p_prison', PrisonPortalTouch)
  --
  for i, lib in {'lib_chaos', 'lib_dark', 'lib_light', 'lib_summon'} do
    Touch.DisableObject(lib, nil, o_path..lib..'_n.txt', o_path..lib..'_d.txt')
    Touch.SetFunction(lib, '_lib_touch', LibTouch)
  end
  --
  for i, prison in {'prison_01', 'prison_02', 'prison_03', 'prison_04'} do
    Touch.DisableObject(prison)
    Touch.SetFunction(prison, '_prison_touch', PrisonTouch)
  end
  --
  for i, dragon in {'red_dragon_01', 'red_dragon_02'} do
    Touch.DisableMonster(dragon, DISABLED_BLOCKED, 0)
  end
end

--
--------------------------------------------------------------------------------
-- логика действий Лойрена

-- установка дня появления
function LoirenEnable(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  DeployLoiren()
end

-- прибытие и настройка
function DeployLoiren()
  BlockGame()
  DeployReserveHero(Loiren, RegionToPoint('loiren_point'))
  while not IsObjectExists(Loiren) do
    sleep()
  end
  SetObjectRotation(Loiren, 180)
  local check
  local tiers = TIER_TABLES[TOWN_PRESERVE]
  local counts = {43 + 7 * diff, 25 + 6 * diff, 16 + 4 * diff, 8 + 2.5 * diff, 5 + diff, 1 + diff, diff - 2}
  for tier = 1, 6 + (1 * (diff > 2)) do
    local creature, count = GetRandFromT_E(tiers[tier][1], tiers[tier]), counts[tier]
    AddHeroCreatures(Loiren, creature, count)
    if not check then
      while GetHeroCreatures(Loiren, creature) ~= count do
        sleep()
      end
      RemoveHeroCreatures(Loiren, CREATURE_WOOD_ELF, 999)
      repeat
        sleep()
      until GetHeroCreatures(Loiren, CREATURE_WOOD_ELF) == 0
      check = 1
    end
  end
  WarpHeroExp(Loiren, LEVELS[10 + diff])
  for stat = STAT_ATTACK, STAT_KNOWLEDGE do
    ChangeHeroStat(Loiren, stat, 2 + DIFF)
  end
  ShowObject(Loiren, 1, 1)
  sleep(15)
  UnblockGame()
  startThread(LoirenMove)
end

-- логика перемещения
function LoirenMove()
  while IsHeroAlive(Loiren) do
    while not IsPlayerCurrent(PLAYER_3) do
      sleep()
    end
    if CanMoveHero(Loiren, GetObjectPosition(Karlam)) then
      if MainQ.loiren_waits == 1 then
        EnableHeroAI(Loiren, 1)
        MainQ.loiren_waits = 0
      end
      MoveHeroRealTime(Loiren, GetObjectPosition(Karlam))
    else
      if MainQ.loiren_waits == 0 then
        for reg, active in MainQ.loiren_dest do
          if active then
            print('Лойрен двигается в точку ', reg)
            MoveHeroRealTime(Loiren, RegionToPoint(reg))
            break
          end
        end
      end
    end
    sleep()
  end
end

-- не нужно(?)
function LoirenInPost(hero, region)
  if hero == Loiren then
    if region == 'post1_enter' then
      SetObjectPosition(Loiren, RegionToPoint('post1_out'))
    elseif region == 'post2_enter' then
      SetObjectPosition(Loiren, RegionToPoint('post2_out'))
    else
      SetObjectPosition(Loiren, RegionToPoint('post3_out'))
    end
  end
end

-- перевод Лойрена в режим ожидания Карлама
function LoirenDest(hero, region)
  if hero == Loiren then
    Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, region, nil)
    MainQ.loiren_dest[region] = nil
    MainQ.loiren_waits = 1
    EnableHeroAI(Loiren, nil)
  end
end

--
--------------------------------------------------------------------------------
-- гарнизоны

function PostEnter(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  local num = string.spread(region)[7] -- определить номер
  -- Карлам зашел в регион?
  if hero == Karlam then
    SetGameVar('post', num)
    -- третий пост - засада энтов
    if num == '3' then
      TreantsAttack(hero)
      sleep(6)
    end
    -- запуск осады гарнизона
    local index = GetLastSavedCombatIndex()
    SiegeTown(hero, MainQ.posts[num + 0])
    while GetLastSavedCombatIndex() == index do
      sleep()
    end
    if IsHeroAlive(hero) then
      UnblockGame()
      SetObjectOwner('e_post'..num, PLAYER_1)
      SetGameVar('post', 0)
      if num ~= '3' then
        PlayAnims('post'..num, {'death'}, COND_SINGLE, ONESHOT_STILL)
        sleep(15)
        RemoveObjectsT(AnimGroup['post'..num].actors)
      else
        SetObjectEnabled(Karlam, 1)
        RemoveObject(Vingael)
        PlayAnims('post_3_treants', {'death'}, COND_SINGLE, ONESHOT_STILL)
        sleep(15)
        RemoveObjectsT(AnimGroup['post_3_treants'].actors)
      end
    end
  else
    -- Лойрен в регионе - добавить ему войска из гарнизонов
    if num == '1' then
      RemoveObjectsT(AnimGroup['post1'].actors)
      local counts = {[2] = 3 * diff, [3] = 2 * diff, [4] = 2 + diff, [5] = diff, [6] = (diff > 2 and 1 or 0)}
      for i, count in counts do
        AddCreaturesByTier(Loiren, TOWN_PRESERVE, i, count)
      end
    elseif num == '2' then
      RemoveObjectsT(AnimGroup['post2'].actors)
      local counts = {[1] = 6 * diff, [2] = 5 * diff, [3] = 3.5 * diff, [4] = 2 * diff, [5] = 1 + diff, [6] = (diff > 2 and 2 or 1)}
      for i, count in counts do
        AddCreaturesByTier(Loiren, TOWN_PRESERVE, i, count)
      end
    else
      RemoveObject(Vingael)
      local counts = {[1] = 7 * diff, [2] = 6 * diff, [3] = 4.5 * diff, [4] = 3 * diff, [5] = 3 + diff, [6] = 1 + diff, [7] = (diff > 3 and 2 or 1)}
      for i, count in counts do
        AddCreaturesByTier(Loiren, TOWN_PRESERVE, i, count)
      end
    end
  end
end

-- засада энтов
function TreantsAttack(hero)
  BlockGame()
  SetObjectEnabled(Karlam, nil)
  MoveCamera(85, 61, GROUND, 30, math.pi / 4, 0)
  sleep(15)
  local actors = {}
  for tree, info in MainQ.post3_treants do
    startThread(
    function()
      local x, y = GetObjectPosition(%tree)
      for i = 1, 5 + random(4) do
        PlayFX('Treant_hit', %tree, '', 0.1 * GetRandFrom(1, -1) * random(4), 0.1 * GetRandFrom(1, -1) * random(4), 1)
      end
      sleep(5)
      RemoveObject(%tree)
      sleep()
      CreateMonster('post_treant_'..%tree, %info[1], 1, x, y, GROUND, 3, 1, %info[2])
      while not IsObjectExists('post_treant_'..%tree) do
        sleep()
      end
      Touch.DisableMonster('post_treant_'..%tree, DISABLED_ATTACK, 0)
      %actors[length(%actors) + 1] = 'post_treant_'..%tree
    end)
  end
  AnimGroup['post_3_treants'] = {actors = actors}
  sleep(10)
  PlayAnims('post_3_treants', {'attack00'}, COND_SINGLE, ONESHOT)
  PlayFX('Roots_start', hero)
  sleep(10)
  MoveHeroRealTime(Vingael, 86, 69)
  sleep(5)
  SetObjectPosition(Vingael, 86, 68, GROUND, 0)
  sleep()
  MoveHeroRealTime(Vingael, GetObjectPosition(Karlam))
  sleep(5)
  --UnblockGame()
end

--
--------------------------------------------------------------------------------
-- альтернативный путь

-- настройка черных обелисков и порталов
function DarkObelisksInit()
  for obelisk, portal in MainQ.dark_obelisks do
    startThread(
      function()
      Touch.DisableObject(%portal)
      Touch.SetFunction(%portal, '_portal_close',
      function(hero, object)
        ShowFlyingSign(rtext('Магия портала бездействует...'), object, -1, 5.0)
      end)
    end)
    Touch.DisableObject(obelisk)
    Touch.SetFunction(obelisk, '_msg', DarkObeliskMsg)
    Touch.SetFunction(obelisk, '_touch', DarkObeliskTouch)
  end
end

function DarkObeliskMsg(hero, object)
  Touch.RemoveFunction(object, '_msg')
  -- 1 стелла - запустить Лойрена при отходе от нее, если еще не запущен
  if object == 'dark_obelisk_01' then
    StartMiniDialog(MainQ.path..'ObeliskDialog/', 1, 4, m_dialog_sets['o_d'])
  end
  if object == 'dark_obelisk_02' then
    StartMiniDialog(MainQ.path..'RitualDialog/', 1, 4, m_dialog_sets['r_d'])
  end
  -- 4 стелла - запуск квеста призрака
  if object == 'dark_obelisk_04' then
    StartMiniDialog(q_ghost.path..'ElfGhostDialog/', 1, 5, m_dialog_sets['e_g'])
    StartQuest(q_ghost.name, hero)
  end
  --
  MakeHeroInteractWithObject(hero, object)
end

-- касание обелиска
function DarkObeliskTouch(hero, object)
  -- включение портала
  if QuestionBox(rtext('Активация алтаря потребует кровь 5 живых существ(будут выбраны самые слабые из имеющихся) или '..
                       'часть крови героя(будет потеряно 15% опыта героя). Нажмите ОК для первого варианта или Отмена для второго')) then
    local possible_creatures = {}
    for slot = 0, 6 do
      local creature, count = GetObjectArmySlotCreature(hero, slot)
      if not (creature == 0 or count == 0) then
        if (not possible_creatures[creature]) and
           (not contains(ELEMS, creature)) and
           (not contains(MECHS, creature)) and
           (not contains(NEUTRAL_UNDEAD, creature)) and
           (GetCreatureTown(creature) ~= TOWN_NECROMANCY) then
          possible_creatures[creature] = {tier = GetCreatureTier(creature), count = GetHeroCreatures(hero, creature)}
        end
      end
    end
    local sum = 0
    for creature, info in possible_creatures do
      sum = sum + info.count
    end
    if sum < 5 then
      MessageBox(rtext('Недостаточно живых существ!'))
      return
    else
      local cr_to_remove = 5
      local curr_tier = 1
      --
      while cr_to_remove > 0 do
        for creature, info in possible_creatures do
          if info.tier == curr_tier then
            local curr_removed = 0
            if info.count < 5 then
              curr_removed = info.count
            else
              curr_removed = 5
            end
            AddCreatures(hero, creature, -curr_removed)
            cr_to_remove = cr_to_remove - curr_removed
            if cr_to_remove <= 0 then
              break
            end
          end
        end
        if cr_to_remove > 0 then
          curr_tier = curr_tier + 1
        end
      end
    end
  else
    local xp = GetHeroStat(hero, STAT_EXPERIENCE)
    TakeAwayHeroExp(hero, xp * 0.15)
  end
  --
  PlayFX('Bloodlust', object)
  sleep(5)
  SetObjectFlashlight(object, 'blood_fl')
  --
  sleep(10)
  --
  MarkObjectAsVisited(object, hero)
  UnblockDarkPortal(MainQ.dark_obelisks[object])
  Touch.RemoveFunction(object, '_touch')
end

function UnblockDarkPortal(portal)
  ShowObject(portal, 1)
  if portal == 'dark_portal_05' then
    sleep(5)
    PlayFX('Monolith_two_way', portal)
    SetObjectEnabled('magic_room_portal_out', 1)
    Touch.RemoveFunctions('magic_room_portal_out')
  else
    SetObjectEnabled(portal, 1)
    Touch.RemoveFunctions(portal)
    sleep(5)
    PlayFX('Monolith_one_way', portal)
  end
end

--
--------------------------------------------------------------------------------
-- подземка

function DungEnter(hero, object)
  Touch.RemoveFunctions(object)
  SetWarfogBehaviour(0, 0)
  OpenRegionFog(PLAYER_1, 'kelo_meet_region')
  OpenRegionFog(PLAYER_1, 'dung_fog_enter')
  SetObjectEnabled(object, 1)
  sleep()
  if IsObjectExists(Loiren) then
    RemoveObject(Loiren)
  end
  MakeHeroInteractWithObject(hero, object)
end

-- регион у ворот данжа
function KelodinMeet(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  BlockGame()
  for i = 1, 9 do
    OpenRegionFog(PLAYER_1, 'dung_fog_reg_0'..i)
  end
  for i, region in {'dung_gates', 'kelo_meet_point', 'noe_meet_point'} do
    OpenRegionFog(PLAYER_1, region)
  end
  sleep()
  -- для адекватной скорости перемещения героев
  consoleCmd('setvar adventure_speed_ai = 2')
  MoveCamera(79, 81, 1, 40, math.pi/6, math.pi/2)
  sleep(20)
  PlayObjectAnimation('dung_gates', 'open', ONESHOT_STILL)
  sleep(12)
  local kx, ky, kz = RegionToPoint('kelo_meet_point')
  -- поток проверяет достижение героем нужного тайла и разворачивает его лицом к игроку
  -- иначе разворачивается неправильно
  startThread(
  function()
    MoveHeroRealTime(Kelodin, %kx, %ky, %kz)
    while 1 do
      local x, y, z = GetObjectPosition(Kelodin)
      if x == %kx and y == %ky and z == %kz then
        SetObjectRotation(Kelodin, 90)
        break
      end
      sleep()
    end
  end)
  sleep(5)
  local nx, ny, nz = RegionToPoint('noe_meet_point')
  -- аналогично предыдущему
  startThread(
  function()
    MoveHeroRealTime(Noelli, %nx, %ny, %nz)
    while 1 do
      local x, y, z = GetObjectPosition(Noelli)
      if x == %nx and y == %ny and z == %nz then
        SetObjectRotation(Noelli, 90)
        break
      end
      sleep()
    end
  end)
  sleep(10)
  PlayObjectAnimation('dung_gates', 'close', ONESHOT_STILL)
  sleep(5)
  StartDialogScene(DIALOG_SCENES.DUNGEON_GATES)
  sleep()
  PlayObjectAnimation('dung_gates', 'open', ONESHOT_STILL)
  sleep(10)
  MoveHeroRealTime(Noelli, RegionToPoint('noe_return'))
  sleep(10)
  MoveHeroRealTime(Kelodin, RegionToPoint('kelo_return'))
  sleep(10)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dung_gates', 'Ambush')
  -- вернуть ии макс. скорость
  consoleCmd('setvar adventure_speed_ai = 5')
  UnblockGame()
end

-- засада за воротами
function Ambush(hero)
  if hero == Karlam then
    BlockGame()
    MoveCamera(74, 81, 1, 40, math.pi/4, -math.pi/2)
    CreateMonster('witch3', CREATURE_MATRIARCH, 1, 72, 81, GROUND, 3, 1, 90)
    sleep()
    Touch.DisableMonster('witch3', DISABLED_INTERACT, 0)
    sleep(15)
    SetObjectPosition('witch3', 72, 81, UNDERGROUND)
    sleep(2)
    for i = 1, 3 do
      startThread(
      function()
        OpenRegionFog(PLAYER_1, 'witch'..%i)
        sleep(10)
        PlayObjectAnimation('witch'..%i, 'cast', ONESHOT)
      end)
    end
    sleep(3)
    SetObjectFlashlight('ambush_lamp1', 'matron_lamp')
    SetObjectFlashlight('ambush_lamp2', 'matron_lamp')
    sleep(15)
    PlayFX('Forgetfulness', hero, '', 0, 0, 0)
    sleep(23)
    startThread(
    function()
      StartDialogSceneInt(DIALOG_SCENES.WITCHES_RITUAL)
      UnblockGame()
      local x, y, z = RegionToPoint('karlam_ritual')
      DeployReserveHero(Baal, x, y, z)
      sleep()
      SetWarfogBehaviour(1, 1)
      --SetObjectOwner(Baal, PLAYER_1)
      SetObjectOwner(Karlam, PLAYER_3)
      sleep()
      EnableHeroAI(Karlam, nil)
      SetObjectPosition(Karlam, 1, 1, 1)
      ShowObject(Baal, 1)
      --ShowObject('ritual_out_portal')
      --SetObjectPosition(Karlam, 1, 1, 1)
      ResetObjectFlashlight('ambush_lamp1')
      ResetObjectFlashlight('ambush_lamp2')
      RemoveObjects('witch1', 'witch2', 'witch3')
--      RemoveObject(Kelodin)
--      RemoveObject(Noelli)
    end)
  end
end

--
function BaalFight(hero)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'baal_fight_reg', nil)
  if StartCombat(hero, nil, 1, CREATURE_STALKER, 1000, nil, nil, nil, 1) then
    startThread(ReverseTransform)
  end
end

-- обратное превращение
function ReverseTransform()
  BlockGame()
  ShowObject(Baal)
  local x, y, z = GetObjectPosition(Baal)
  PlayFX('Implosion', Baal)
  sleep(20)
  SetObjectPosition(Karlam, x, y, z)
  sleep()
  SetObjectOwner(Karlam, PLAYER_1)
  sleep()
  RemoveObject(Baal)
  UnblockGame()
  StartMiniDialog(def_noe.path..'AfterRitualDialog/', 1, 9, m_dialog_sets['a_r'])
  MainQ.second_dialog = GetDate(DAY) + 7 + (5 - GetDate(DAY_OF_WEEK))
  StartQuest(def_noe.name, Karlam)
  -- запуск событий в храме
  --startThread(ElemTrapThread)
end

--
--------------------------------------------------------------------------------
--
-- бешеные фурии(фемки сосатЪ)
function FuryTrapAnimsThread()
  startThread(
  function()
    sleep(random(5))
    while def_noe.fury_fight_won == 0 and def_noe.fury_trap_cycle_flag == 0 do
      local gr_type = GetRandFrom(CREATURE_GREMLIN, CREATURE_MASTER_GREMLIN, CREATURE_GREMLIN_SABOTEUR)
      CreateMonster('rit_grem_01', gr_type, 1, 1, 1, 0, 3, 1, random(360) + 1)
      sleep()
      Touch.DisableMonster('rit_grem_01', DISABLED_INTERACT, 0)
      sleep()
      SetObjectPosition('rit_grem_01', RegionToPoint('furies_grem_spawn_reg_1'))
      sleep(5)
      PlayObjectAnimation('fury_exec_01', 'attack00', NON_ESSENTIAL)
      sleep(3)
      PlayObjectAnimation('rit_grem_01', 'hit', ONESHOT)
      sleep(5)
      PlayObjectAnimation('fury_exec_02', 'attack00', NON_ESSENTIAL)
      sleep(5)
      PlayObjectAnimation('rit_grem_01', 'death', ONESHOT_STILL)
      sleep(5)
      PlayFX('Big_fire_1', 'rit_grem_01', 'rit_grem_fire_01')
      sleep(10)
      StopVisualEffects('rit_grem_fire_01')
      RemoveObject('rit_grem_01')
      PlayFX('Bloodlust', 'blood_altar_01')
      sleep()
      PlayObjectAnimation('fury_main_01', 'happy', NON_ESSENTIAL)
      repeat
        sleep()
      until not IsObjectExists('rit_grem_01')
      def_noe.fury_trap_cycle_flag = 1
      sleep(15)
      if def_noe.fury_trap_cycle_flag == 1 then
        def_noe.fury_trap_cycle_flag = 0
      else
        return
      end
    end
  end)
  startThread(
  function()
    sleep(random(12))
    while def_noe.fury_fight_won == 0 and def_noe.fury_trap_cycle_flag == 0 do
      local gr_type = GetRandFrom(CREATURE_GREMLIN, CREATURE_MASTER_GREMLIN, CREATURE_GREMLIN_SABOTEUR)
      CreateMonster('rit_grem_02', gr_type, 95, 1, 1, 0, 3, 1, random(360) + 1)
      sleep()
      Touch.DisableMonster('rit_grem_02', DISABLED_INTERACT, 0)
      sleep()
      SetObjectPosition('rit_grem_02', RegionToPoint('furies_grem_spawn_reg_2'))
      sleep(5)
      PlayObjectAnimation('fury_exec_03', 'attack00', NON_ESSENTIAL)
      sleep(3)
      PlayObjectAnimation('rit_grem_02', 'hit', ONESHOT)
      sleep(5)
      PlayObjectAnimation('fury_exec_04', 'attack00', NON_ESSENTIAL)
      sleep(5)
      PlayObjectAnimation('rit_grem_02', 'death', ONESHOT_STILL)
      sleep(5)
      PlayFX('Big_fire_1', 'rit_grem_02', 'rit_grem_fire_02')
      sleep(10)
      StopVisualEffects('rit_grem_fire_02')
      RemoveObject('rit_grem_02')
      PlayFX('Bloodlust', 'blood_altar_02')
      sleep()
      PlayObjectAnimation('fury_main_02', 'happy', NON_ESSENTIAL)
      repeat
        sleep()
      until not IsObjectExists('rit_grem_02')
      def_noe.fury_trap_cycle_flag = 1
      sleep(15)
      if def_noe.fury_trap_cycle_flag == 1 then
        def_noe.fury_trap_cycle_flag = 0
      else
        return
      end
    end
  end)
end

function FuryTrapShow(hero, region)
  startThread(FuryTrapAnimsThread)
  --
  startThread(
  function()
    while 1 do
      if def_noe.fury_trap_cycle_flag < 2 then
        if (length(GetObjectsInRegion('fury_fight_reg', 'HERO')) + length(GetObjectsInRegion('fury_fight_fog_reg', 'HERO'))) == 0 then
          print('fury trap anims aborted')
          def_noe.fury_trap_cycle_flag = 2
        end
      elseif def_noe.fury_trap_cycle_flag == 2 then
        if (length(GetObjectsInRegion('fury_fight_reg', 'HERO')) + length(GetObjectsInRegion('fury_fight_fog_reg', 'HERO'))) > 0 then
          print('fury trap anims started again')
          def_noe.fury_trap_cycle_flag = 0
          startThread(FuryTrapAnimsThread)
        end
      end
      sleep()
    end
  end)
  --
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  --
  OpenRegionFog(PLAYER_1, 'fury_fight_fog_reg')
  sleep()
  MoveCamera(10, 52, UNDERGROUND, 50, 0, 0, 0, 1)
  sleep(50)
  MessageBox(rtext('Фурии приносят в жертву пленных гремлинов! Остановите этот безумный ритуал!'))
end

function FuryFight(hero, region)
  if hero == Karlam then
    SetGameVar('dung_fight', 'fury')
    if StartCombat(hero, nil, 3,
                   CREATURE_BLOOD_WITCH, 150,
                   CREATURE_BLOOD_WITCH, 200,
                   CREATURE_BLOOD_WITCH_2, 134,
                   nil, nil, nil, 1) then
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
      SetGameVar('dung_fight', 'none')
      def_noe.fury_fight_won = 1
      sleep(5)
      --
      PlayAnims('furies', {'death'}, ONESHOT_STILL)
      sleep(15)
      RemoveObjectsT(def_noe.blood_altar_furies)
      --
      MessageBox(rtext('Спасенные гремлины пополняют армию Карлама!'))
      AddCreatures(hero, CREATURE_GREMLIN_SABOTEUR, 130 - 10 * diff)
    end
  end
end

function DeathPitFight(hero, region)
  PlayAnims('dp_st', {'hit'}, COND_OBJECT_EXISTS)
  PlayAnims('dp_u', {'attack00'}, COND_OBJECT_EXISTS)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  OpenRegionFog(PLAYER_1, 'death_pit_fight_reg')
  OpenRegionFog(PLAYER_1, 'death_pit_reg')
  MoveCamera(6, 28, UNDERGROUND, 40, 0, 0, 1, 1)
  sleep(30)
  if StartCombat(hero, nil, 4,
                 CREATURE_MUMMY, 18,
                 CREATURE_MUMMY, 16,
                 CREATURE_ZOMBIE, 42,
                 CREATURE_WALKING_DEAD, 55,
                 nil, nil, nil, 1) then
     AbortAnimThread('dp_st')
     PlayAnims('dp_u', {'death'}, COND_SINGLE, ONESHOT_STILL)
     sleep(15)
     RemoveObjectsT(AnimGroup['dp_u'].actors)
     sleep(5)
     MessageBox(MainQ.path..'asassin_1.txt')
     RemoveObjectsT(AnimGroup['dp_st'].actors)
     AddCreatures(hero, CREATURE_STALKER, 7 - DIFF)
  end
end

--
--------------------------------------------------------------------------------
-- баллисты

function BallistaInfo(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  ShowObject('ballista_02', 1, 1)
  sleep(15)
  MessageBox(def_noe.path..'ballista_info.txt')
end

function BallistaAttack(hero, region)
  if HasHeroSkill(hero, WIZARD_FEAT_REMOTE_CONTROL) and
     QuestionBox(def_noe.path..'control_ballista.txt') then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
    --
    MessageBox(def_noe.path..'ballista_controled.txt', 'UnblockGame')
  elseif GetHeroCreatures(Karlam, CREATURE_GREMLIN_SABOTEUR) > 0 and
         QuestionBox(def_noe.path..'disable_ballista.txt') then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
    BlockGame()
    MoveCamera(22, 13, 1, 30, math.pi/8, -math.pi, 0, 1)
    sleep(15)
    CreateMonster('grem_01', CREATURE_GREMLIN_SABOTEUR, 1, 1, 1, GROUND, 3, 1, 0)
    CreateMonster('grem_02', CREATURE_GREMLIN_SABOTEUR, 1, 5, 5, GROUND, 3, 1, 0)
    sleep()
    Touch.DisableMonster('grem_01', DISABLED_BLOCKED, 0)
    Touch.DisableMonster('grem_02', DISABLED_BLOCKED, 0)
    sleep()
    SetObjectPosition('grem_01', RegionToPoint('grem_01_reg'))
    SetObjectPosition('grem_02', RegionToPoint('grem_02_reg'))
    sleep()
    PlayObjectAnimation('grem_01', 'specability', ONESHOT)
    PlayObjectAnimation('grem_02', 'specability', ONESHOT)
    sleep(10)
    for i = 1, 3 do
      PlayFX('Sabotage', 'ballista_0'..i)
      PlayObjectAnimation('ballista_0'..i, 'hit', ONESHOT)
      sleep()
    end
    sleep(5)
    RemoveObjects('grem_01', 'grem_02')
    MessageBox(def_noe.path..'ballista_disabled.txt', 'UnblockGame')
  else
    BlockGame()
    for i = 1, 3 do
      PlayObjectAnimation('ballista_0'..i, 'rangeattack', ONESHOT)
      sleep(5)
      for i = 1, 2 + random(4) do
        PlayFX('Fireball', hero, '', (0.1 * random(4)) * (random(2) == 1 and 1 or -1), (0.1 * random(4)) * (random(2) == 1 and 1 or -1))
        sleep()
      end
    end
    MessageBox(def_noe.path..'ballista_attack.txt', 'UnblockGame')
    RemoveObject(hero)
    Loose()
  end
end

--
--------------------------------------------------------------------------------
-- заклинательный покой

function LibTouch(hero, object)
  if object == 'lib_chaos' then
    -- StartCombat()
    MakeHeroInteractWithObject(hero, 'meteor_scroll')
    MakeHeroInteractWithObject(hero, 'chain_scroll')
  elseif object == 'lib_dark' then
    MakeHeroInteractWithObject(hero, 'bers_stick')
    MakeHeroInteractWithObject(hero, 'blind_scroll')
    --
    def_noe.got_bers_stick = 1
    --
  elseif object == 'lib_light' then
    MakeHeroInteractWithObject(hero, 'anti_m_scroll')
  elseif object == 'lib_summon' then
    MakeHeroInteractWithObject(hero, 'summon_h_scroll')
  end
  Touch.OverrideFunction(object, '_lib_touch',
  function(hero, object)
    ShowFlyingSign(rtext('Не осталось ничего интересного...'), object, -1, 7.0)
  end)
end

--
--------------------------------------------------------------------------------
-- каземат

function PrisonPortalTouch(hero, object)
  if def_noe.prison_key == 0 then
    ShowFlyingSign(rtext('Портал заблокирован. Чтобы открыть его необходим магический ключ'), object, -1, 7.0)
  else
    ShowFlyingSign(rtext('Ключ сработал. Работа портала восстановлена'), object, -1, 7.0)
    SetObjectEnabled(object, 1)
    Touch.RemoveFunctions(object)
    sleep()
    MakeHeroInteractWithObject(hero, object)
  end
end

function PrisonTouch(hero, object)
  --AddCreatures()
  def_noe.prisons_opened = def_noe.prisons_opened + 1
  if def_noe.prisons_opened == 3 then
    BlockGame()
    DeployReserveHero(MainQ.templar_3, 44, 92, UNDERGROUND)
    sleep()
    ShowObject(MainQ.templar_3, 1)
    sleep(7)
    MessageBox(MainQ.path..'templar_3_attack.txt', 'UnblockGame')
    sleep()
    MoveHeroRealTime(MainQ.templar_3, GetObjectPosition(hero))
  end
  Touch.OverrideFunction(object, '_prison_touch',
  function(hero, object)
    ShowFlyingSign(rtext('Тюрьма пуста...'), object, -1, 7.0)
  end)
end

function DragonTrapInfo(hero, region)
  if hero == Karlam then
    if def_noe.dragon_info == 0 then
      def_noe.dragon_info = 1
      ShowObject('red_dragon_01')
      MoveCamera(50, 87, UNDERGROUND, 20, 0, 0, 0, 1)
      sleep(18)
      MessageBox(def_noe.path..'dragon_trap_info.txt')
      DragonTrapInfo(hero, region)
    end
    if def_noe.got_bers_stick == 1 and HasArtefact(hero, ARTIFACT_WAND_OF_X) and
       def_noe.dragon_bers == 0 and
       QuestionBox(def_noe.path..'use_bers_on_dragons.txt') then
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
      ShowObject('red_dragon_02', 1)
      sleep(5)
      for i, dragon in {'red_dragon_01', 'red_dragon_02'} do
        PlayFX('Berserk', dragon)
        sleep()
      end
      def_noe.dragon_bers = 1
    end
  end
end

function DragonTrapEnter(hero, region)
  BlockGame()
  if hero == Karlam then
    if def_noe.dragon_bers == 2 and
       StartCombat(Karlam, nil, 2, CREATURE_RED_DRAGON, 3, CREATURE_RED_DRAGON, 3) then
      RemoveObjects('red_dragon_01', 'red_dragon_02')
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
      UnblockGame()
    else
      for i, dragon in {'red_dragon_01', 'red_dragon_02'} do
        PlayObjectAnimation(dragon, 'attack00', ONESHOT)
      end
      sleep(10)
      RemoveObject(Karlam)
    end
  else
    if def_noe.dragon_bers == 1 then
      for i, dragon in {'red_dragon_01', 'red_dragon_02'} do
        PlayObjectAnimation(dragon, 'attack00', ONESHOT)
      end
      sleep(10)
      RemoveObject(hero)
      local prob = random(2) + 1
      PlayObjectAnimation('red_dragon_0'..prob, 'death', ONESHOT_STILL)
      sleep(15)
      --RemoveObject('red_dragon_0'..prob)
      sleep(5)
      MessageBox(def_noe.path..'templar_3_dead.txt', 'UnblockGame')
      def_noe.dragon_bers = 2
    end
  end
  UnblockGame()
end

--
--------------------------------------------------------------------------------
-- уровень интриг

function MatronPortalEnter(hero, object)
  if def_noe.matron_portal_opened == 0 then
    MessageBox(rtext('Портал в палаты интриг надежно заблокирован...'))
  else
    SetWarfogBehaviour(0, 0)
    SetObjectEnabled(object, 1)
    Touch.RemoveFunctions(object)
    OpenRegionFog(PLAYER_1, 'noelli_fight')
    OpenRegionFog(PLAYER_1, 'noe_fight_portal')
    sleep()
    MakeHeroInteractWithObject(hero, object)
  end
end

-- бой с Ноэлли
function NoelliFight(hero)
  BlockGame()
  ------------------------------------------------------------------------------
  -- эффекты при входе в зал
  MoveCamera(16, 81, UNDERGROUND, 55, math.pi/9, math.pi/3)
  sleep(20)
  for i = 1, 3 do
    OpenRegionFog(PLAYER_1, 'matron_fog_reg_'..i)
  end
  for i = 1, 6 do
    PlayFX('Fakel_dbl', 'm_ch_lamp_'..i)
    SetObjectFlashlight('m_ch_lamp_'..i, 'm_ch_fl')
    sleep(10)
  end
  ------------------------------------------------------------------------------
  if StartCombat(hero, 'Noellie', 1,
                 CREATURE_BLACK_DRAGON, 100, nil, nil,
                 ARENAS.MATRON_CHAMBERS, 1) then
    StartDialogScene(DIALOG_SCENES.FINAL, 'Win')
  end
end

--
--------------------------------------------------------------------------------
-- охрана храма

function Templar2Attack(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  BlockGame()
  UnblockDarkPortal('dark_portal_05')
  sleep(5)
  PlayFX('Dimension_door', 'dark_portal_05', '', 1, 1)
  sleep(5)
  DeployReserveHero(MainQ.templar_2, 73, 29,  UNDERGROUND)
  sleep(10)
  MoveHeroRealTime(MainQ.templar_2, GetObjectPosition(hero))
  UnblockGame()
end

--
--------------------------------------------------------------------------------
--

function KarlamAlive()
  while IsHeroAlive(Karlam) do
    sleep()
  end
  Loose()
end