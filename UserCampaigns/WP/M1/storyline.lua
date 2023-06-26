

--------------------------------------------------------------------------------
-- глав. - Основной путь

MainQ =
{
  name = 'MAIN_QUEST',
  path = q_path..'Main/',
  
  posts = {ARENAS.POST_1, ARENAS.POST_2, ARENAS.POST_3},
  
  posts_units =
  {
    {
      'post1_archer1', 'post1_archer2', 'post1_archer3',
      'post1_treant1', 'post1_treant2', 'post1_druid',
      'post1_dancer', 'post1_uni'
    },
--    {
--      'post2_archer1', 'post2_archer2', 'post2_archer3',
--      'post2_treant', 'post2_druid1', 'post2_druid2',
--      'post2_fairy1', 'post2_fairy2', 'post2_uni'
--    },
--    {
--      'post3_archer1', 'post3_archer2', 'post3_fairy',
--      'post3_treant1', 'post3_treant2', 'post3_druid',
--      'post3_dancer', 'post3_uni', 'post3_dragon'
--    }
  },

  obelisk_msg = 0,
  
  dark_obelisks =
  {
    ['dark_obelisk_01'] = 'dark_portal_01',
    ['dark_obelisk_02'] = 'dark_portal_02',
    ['dark_obelisk_03'] = 'dark_portal_03',
    ['dark_obelisk_04'] = 'dark_portal_04',
  },
  
  transform_reg = 0,
  second_dialog = 0,
  templar_1 = Letos,
  templar_2 = Vaishan,
  templar_3 = Ohtar,
}

--------------------------------------------------------------------------------
-- глав. - Победить Ноэлли

def_noe =
{
  name = 'DEFEAT_NOELLI',
  path = q_path..'DefeatNoelli/',
  
  blood_altar_furies = {'fury_main_01', 'fury_main_02', 'fury_exec_01', 'fury_exec_02', 'fury_exec_03', 'fury_exec_04'},
  fury_fight_won = 0,
  fury_trap_cycle_flag = 0,
  
  prison_key = 0,
  got_bers_stick = 0,
  prisons_opened = 0,
  dragon_info = 0,
  dragon_bers = 0,
  matron_portal_opened = 1,
}

--------------------------------------------------------------------------------
-- втор. - Гаргульи - разведчики

scouts =
{
  name = 'SCOUTS',
  path = q_path..'Scouts/',
  
  gargoyles = {'scout_garg_01', 'scout_garg_02', 'scout_garg_03'},
  scouts_founded = 0
}

q_ghost =
{
  name = 'GHOST_QUEST',
  path = q_path..'GhostQuest/'
}

q_tavern =
{
  name = 'TAVERN_QUEST',
  path = q_path..'TavernQuest/',
  
  elem_trap_active = 0,
}

--
--------------------------------------------------------------------------------
-- базовые настройки и триггеры

function MainPathInit()
  startThread(DarkObelisksInit)
  for i, post in MainQ.posts_units do
    AnimGroup['post'..i] = {actors = post}
    for j, unit in post do
      Touch.DisableMonster(unit, nil, 0)
    end
  end
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post1', 'PostEnter')
--Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post2', 'PostEnter')
--Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post3', 'PostEnter')
end

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
  --
  for i, region in {'wind_trap', 'earth_trap', 'water_trap', 'fire_trap'} do
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, 'EmitterEnter')
  end
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
  Touch.DisableObject('tavern')
  Touch.SetFunction('tavern', '_q_tavern', TavernTalk)
  Touch.DisableObject('sealed_tomb')
  Touch.SetFunction('sealed_tomb', '_rock_fight', RockFight)
  --
  Touch.DisableObject('blood_temple_01')
  Touch.SetFunction('blood_temple_01', '_fight', BloodTempleFight)
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
  PlayFX('Elem_seal', 'sealed_tomb', 'tomb_seal_01', 2.5, -7.5, 0, 0)
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
--

function PostEnter(hero, region)
  if hero == Karlam then
    local num = string.spread(region)[7]
    SetGameVar('post', num)
    local index = GetLastSavedCombatIndex()
    SiegeTown(hero, MainQ.posts[num + 0])
    while GetLastSavedCombatIndex() == index do
      sleep()
    end
    if IsHeroAlive(hero) then
      SetObjectOwner('e_post'..num, PLAYER_1)
      SetGameVar('post', 0)
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post'..num, nil)
      PlayAnims('post'..num, {'death'}, COND_SINGLE, ONESHOT_STILL)
      sleep(15)
      RemoveObjectsT(AnimGroup['post'..num].actors)
    end
  else
  -- эльф в регионе
  end
end

--------------------------------------------------------------------------------
-- альтернативный путь

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
    Touch.SetFunction(obelisk, '_touch', DarkObeliskTouch)
  end
end

function DarkObeliskTouch(hero, object)
  -- 4 стелла - запуск квеста призрака
  if object == 'dark_obelisk_04' then
    StartMiniDialog(q_ghost.path..'ElfGhostDialog/', 1, 5, m_dialog_sets['e_g'])
    StartQuest(q_ghost.name, hero)
    UnblockDarkPortal('dark_portal_04')
  end
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
  SetWarfogBehaviour(0, 0)
  OpenRegionFog(PLAYER_1, 'kelo_meet_region')
  OpenRegionFog(PLAYER_1, 'dung_fog_enter')
  SetObjectEnabled(object, 1)
  sleep()
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
-- таверна + продолжение квеста призрака

function TavernTalk(hero, object)
  if IsUnknown(q_tavern.name) then
    MessageBox(q_tavern.path..'tq_start.txt')
    StartMiniDialog(q_tavern.path..'TavernDialogStart/', 1, 15, m_dialog_sets['tq_s'], (IsActive(q_ghost.name) and 1 or nil))
    StartQuest(q_tavern.name, hero)
    if not HasArtefact(hero, ARTIFACT_RING_OF_LIGHTING_PROTECTION) then
      Award(hero, nil, nil, {ARTIFACT_RING_OF_LIGHTING_PROTECTION})
    end
  else
    local progress = GetProgress(q_tavern.name)
    if progress == 1 then
      -- диалог
      FinishQuest(q_tavern.name, hero)
      sleep(5)
      PlayFX('Town_portal', hero)
      sleep(15)
      SetObjectPosition(hero, RegionToPoint('al_path_reg'))
    end
  end
end

function BloodTempleFight(hero, object)
  if object == 'blood_temple_01' and
     QuestionBox(rtext('Сокровища храма надежно охраняются. Желаете сразиться с охраной?')) and
     StartCombat(hero, nil, 4,
                 GetRandFromT_E(nil, {CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2, CREATURE_BLOOD_WITCH_NCF367}), 26 + random(5),
                 GetRandFromT_E(nil, {CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2, CREATURE_BLOOD_WITCH_NCF367}), 30 + random(5),
                 GetRandFromT_E(nil, {CREATURE_MINOTAUR_KING, CREATURE_MINOTAUR_CAPTAIN, CREATURE_BRUTAL_MINOTAUR}), 21 + random(5),
                 GetRandFromT_E(nil, {CREATURE_MATRIARCH, CREATURE_SHADOW_MISTRESS, CREATURE_FLYING_MISTRESS}), 6 + random(3)) then
    Award(hero, nil, nil, {ARTIFACT_ICEBERG_SHIELD, ARTIFACT_RING_OF_LIFE})
    MarkObjectAsVisited(object, hero)
    Touch.OverrideFunction(object, '_fight',
    function(hero, object)
      ShowFlyingSign(rtext('Храм пуст...'), object, -1, 7.0)
    end)
  end
end

--
--------------------------------------------------------------------------------
-- коридор элементов

-- поток, проверяющий наличие героев внутри коридора или около него
function CheckElemTrapActive()
  local answer
  for i, region in {'elem_trap_01', 'elem_trap_02', 'elem_trap_03', 'elem_trap_04',
                    'elem_trap_05', 'wind_trap', 'earth_trap', 'water_trap', 'fire_trap'}  do
    if length(GetObjectsInRegion(region, 'HERO')) > 0 then
      answer = 1
      return answer
    end
  end
  return answer
end

-- потоки эффектов на ловушках
function WindTrapThread()
  while q_tavern.elem_trap_active == 1 do
    for i, emitter in {'wind_01', 'wind_02', 'wind_03'} do
      PlayFX('Lightning_bolt', emitter)
      sleep(4)
    end
  sleep()
  end
end

function EarthTrapThread()
  while q_tavern.elem_trap_active == 1 do
    for i, emitter in {'earth_01', 'earth_02', 'earth_03'} do
      PlayFX('StoneSpikes', emitter)
      sleep(5)
    end
    sleep()
  end
end

function WaterTrapThread()
  while q_tavern.elem_trap_active == 1 do
    for i, emitter in {'water_01', 'water_02', 'water_03'} do
      PlayFX('Ice_bolt', emitter)
      sleep(5)
    end
    sleep()
  end
end

function FireTrapThread()
  while q_tavern.elem_trap_active == 1 do
    PlayFX('Firewall', 'fire_02', 'fire_02_fx')
    sleep(10)
    PlayFX('Firewall_end', 'fire_02')
    StopVisualEffects('fire_02_fx')
    sleep()
  end
end

-- поток включающий/выключающий эффекты, в зависимости от наличия героев поблизости
function ElemTrapThread()
  while 1 do
    if (q_tavern.elem_trap_active == 0) and CheckElemTrapActive() then
      q_tavern.elem_trap_active = 1
      startThread(WindTrapThread)
      startThread(EarthTrapThread)
      startThread(WaterTrapThread)
      startThread(FireTrapThread)
    elseif (not CheckElemTrapActive()) then
      q_tavern.elem_trap_active = 0
    end
    sleep()
  end
end


function EmitterEnter(hero, region)
  if region == 'wind_trap' and (not HasArtefact(hero, ARTIFACT_RING_OF_LIGHTING_PROTECTION)) then
    print('wind trap worked!')
    return
  end
  if region == 'earth_trap' and (not HasArtefact(hero, ARTIFACT_RIGID_MANTLE)) then
    print('earth trap worked!')
    return
  end
  if region == 'water_trap' and (not HasArtefact(hero, ARTIFACT_ARTIFACT_DRAGON_FLAME_TONGUE)) then
    print('water trap worked!')
    return
  end
  if region == 'fire_trap' and (not HasArtefact(hero, ARTIFACT_ICEBERG_SHIELD)) then
    print('fire trap worked!')
    return
  end
end

-- диалог около печати
function BreakSeal(hero, region)
  if hero == Karlam then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
    consoleCmd('setvar adventure_speed_human = 2')
    MoveCamera(90, 11, UNDERGROUND, 30, math.pi/4, math.pi/8)
    startThread(
    function()
      CreateMonster('terhiz', CREATURE_ARCH_MAGI, 1, 1, 1, GROUND, 3, 1, 180)
      sleep()
      Touch.DisableMonster('terhiz', DISABLED_BLOCKED, 0)
      sleep()
    end)
    MoveHeroRealTime(Karlam, 89, 12, UNDERGROUND)
    while 1 do
      local kx, ky = GetObjectPosition(Karlam)
      if kx == 89 and ky == 12 then
        SetObjectRotation(Karlam, 180)
        break
      end
      sleep()
    end
    sleep(7)
    PlayFX('Unsummon', Karlam, '', 2)
    sleep(8)
    SetObjectPosition('terhiz', 91, 12, UNDERGROUND)
    sleep(7)
    SetRegionBlocked('fire_trap', 1, PLAYER_1)
    --
    StartMiniDialog(q_tavern.path..'BreakSealDialog/', 1, 7, m_dialog_sets['b_s'], (IsActive(q_ghost.name) and 1 or nil))
    --
    sleep(5)
    PlayObjectAnimation('terhiz', 'cast', ONESHOT)
    sleep(30)
    PlayFX('Phantom_out', Karlam)
    sleep(10)
    PlayFX('Phantom_in', Karlam, '', 2, 2)
    sleep(8)
    DeployReserveHero('KarlamPh', 91, 14, GROUND)
    sleep()
    SetObjectOwner(Karlam, PLAYER_3)
    SetObjectRotation('KarlamPh', 180)
    --
    local check = 1
    for slot = 0, 6 do
      local creature, count = GetObjectArmySlotCreature(Karlam, slot)
      if not (creature == 0 or count == 0) then
        AddHeroCreatures('KarlamPh', creature, count)
        if check then
          repeat
            sleep()
          until GetHeroCreatures('KarlamPh', creature) == count
          check = nil
          RemoveHeroCreatures('KarlamPh', CREATURE_PEASANT, 999)
        end
      end
    end
    --
    --local skills = {}
    for skill = 1, 171 do
      while GetHeroSkillMastery('KarlamPh', skill) ~= GetHeroSkillMastery(Karlam, skill) do
        GiveHeroSkill('KarlamPh', skill)
      end
      --skills[skill] = GetHeroSkillMastery(Karlam, skill)
    end
--    for skill, mast in skills do
--      if mast > 0 then
--        for i = 1, mast do
--          GiveHeroSkill('KarlamPh', skill)
--        end
--      end
--    end
    --
    for spell, info in spell_info do
      if not (spell == 238 or spell == 239 or spell == 285) and KnowHeroSpell(Karlam, spell) then
        TeachHeroSpell('KarlamPh', spell)
      end
    end
    --
    for art, info in art_info do
      if HasArtefact(Karlam, art) then
        for i = 1, GetHeroArtifactsCount(Karlam, art) do
          GiveArtefact('KarlamPh', art, 1)
        end
      end
    end
    --
    WarpHeroExp('KarlamPh', GetHeroStat(Karlam, STAT_EXPERIENCE))
    --
    sleep()
    SetObjectPosition('KarlamPh', 91, 14, UNDERGROUND, 0)
    sleep(10)
    Touch.DisableHero(Karlam)
    EnableHeroAI(Karlam, nil)
    consoleCmd('setvar adventure_speed_human = 5')
  end
end

-- гробница
function RockFight(hero, object)
  SetGameVar('dung_fight', 'cursed_rock')
  AddCreatures(hero, 605, 1000)
  if StartCombat(hero, nil, 1, CREATURE_CURSED_ROCK, 1, nil, nil, nil, 1) then
    Touch.OverrideFunction(object, '_rock_fight',
    function(hero, object)
      ShowFlyingSign(rtext('Схрон пуст...'), object, -1, 7.0)
    end)
    BlockGame()
    PlayFX('Phantom_out', hero)
    sleep(15)
    ShowObject(Karlam, 1)
    sleep()
    PlayFX('Phantom_in', Karlam)
    sleep(10)
    SetObjectOwner(Karlam, PLAYER_1)
    sleep()
    RemoveObject('KarlamPh')
    SetObjectEnabled(Karlam, 1)
    SetRegionBlocked('fire_trap', nil, PLAYER_1)
    sleep(5)
    MoveCamera(91, 16, UNDERGROUND, 45, math.pi/4)
    sleep(5)
    for i = 1, 30 do
      PlayFX('Arcane_crys_death', 'sealed_tomb', '', 2.5 + (random(3) * GetRandFrom(1, -1)), -7.5, random(15) + 1)
      sleep()
    end
    StopVisualEffects('tomb_seal_01')
    sleep(5)
    if IsActive(q_ghost.name) then
      MessageBox(q_ghost.path..'seal_broken.txt')
      FinishQuest(q_ghost.name, Karlam)
    else
      MessageBox(q_tavern.path..'seal_broken.txt')
    end
    if IsActive(q_tavern.name) then
      UpdateQuest(q_tavern.name, 1, Karlam)
    end
    -- диалог
    StartMiniDialog(q_tavern.path..'SealBrokenDialog/', 1, 6, m_dialog_sets['s_b'], (IsActive(q_tavern.name) and 1 or nil))
    sleep()
    Award(Karlam, nil, nil, {ARTIFACT_146})
    RemoveObject('terhiz')
    UnblockGame()
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
      UnblockGame()
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
  if StartCombat(hero, Noelli, 1,
                 CREATURE_BLACK_DRAGON, 100, nil, nil,
                 ARENAS.MATRON_CHAMBERS, 1) then
    StartDialogScene(DIALOG_SCENES.FINAL, 'Win')
  end
end

Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'noelli_fight', 'NoelliFight')

--
--------------------------------------------------------------------------------
-- гаргульи - разведчики

function GargoylesInit()
  for i, object in scouts.gargoyles do
    Touch.DisableMonster(object, DISABLED_INTERACT, 0)
    Touch.SetFunction(object, '_talk', ScoutTalk)
  end
end

function ScoutTalk(hero, object)
  scouts.scouts_founded = scouts.scouts_founded + 1
  MessageBox(scouts.path..object..'_talk.txt')
  if object == 'scout_garg_01' then
    StartQuest(scouts.name, hero)
    UpdateQuest(def_noe.name, 1, hero)
  else
    UpdateQuest(scouts.name, scouts.scouts_founded - 1, hero)
  end
  AddCreatures(hero, CREATURE_OBSIDIAN_GARGOYLE, 1)
  RemoveObject(object)
end

function FirstGargMeeting(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  BlockGame()
  sleep(3)
  ShowObject(hero, 1)
  PlayFX('Bless', 'scout_garg_01')
  ShowFlyingSign(rtext('Хммм...'), hero, 1, 5.0)
  sleep(10)
  MoveHeroRealTime(hero, GetObjectPosition('scout_garg_01'))
  UnblockGame()
end
  
startThread(GargoylesInit)

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