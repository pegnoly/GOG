--
--------------------------------------------------------------------------------
-- ????? ???

main_quests =
{
  main = 'MAIN_QUEST',
  generators = 'GENERATORS',
  find_gates = 'FIND_GATES',
  path = q_path..'Main/',

  -- починка генераторов --
  first_generator_touch = 0,
  generator_system_checked = 0, -- ??, ?????? ?????? ?????
  generators_count = 0,
  -- ?????????????
  generators_repaired =
  {
    ['run_gen_01'] = nil,
    ['run_gen_02'] = nil,
    ['run_gen_03'] = nil,
    ['run_gen_04'] = nil
  },
  -- ???????????????
  resources_to_repair =
  {
    ['run_gen_01'] = {[WOOD] = 15 + 5 * diff, [ORE] = 0, [MERCURY] = 8 + 4 * diff, [CRYSTAL] = 20 + 2 * diff, [SULFUR] = 0, [GEM] = 5 + 8 * diff, [GOLD] = 0},
    ['run_gen_03'] = {[WOOD] = 0, [ORE] = 30 + 4 * diff, [MERCURY] = 0, [CRYSTAL] = 0, [SULFUR] = 6 + 7 * diff, [GEM] = 10 + 4 * diff, [GOLD] = 0},
    ['run_gen_04'] = {[WOOD] = 10 + 7 * diff, [ORE] = 25 + 5 * diff, [MERCURY] = 2 + 5 * diff, [CRYSTAL] = 3 + 4 * diff, [SULFUR] = 11 + diff, [GEM] = 7 + 4 * diff, [GOLD] = 0}
  },

  -- генераторы в городах --
  portal_static = "/MapObjects/WP/M2/Portal_2Side_Shell.(AdvMapStaticShared).xdb#xpointer(/AdvMapStaticShared)",
  --
  Init =
  function()
    -- убрать!
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'run_gen_ulkeron_region', 'RunicGeneratorUlkeronEnter')
    
    EnableHeroAI('Elmor', nil)
    EnableHeroAI('Agulnobar', nil)
    EnableHeroAI('Malgumol', nil)
    Touch.DisableHero('Malgumol')
    Touch.SetFunction('Malgumol', '_talk', MalgumolTalk)
    DeployReserveHero('Agulnobar', RegionToPoint('elm_ambush_elm_demon_point'))
    -- ????
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'elm_ambush_fight_start_reg', 'ElmAmbushStartFight')
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'runic_generator_demons_ambush_region', 'GeneratorDemonAmbush')
    --
    for i, generator in {'run_gen_gologurs', 'run_gen_01', 'run_gen_02', 'run_gen_03', 'run_gen_04', 'run_gen_homodor', 'run_gen_ulkeron'} do
      Touch.DisableObject(generator, nil, q_path.."Generators/unknown_device_name.txt", q_path.."Generators/unknown_device_desc.txt") -- ???? ????, ?? ???????????
      Touch.SetFunction(generator, '_touch', RunicGeneratorTouch)
    end
    Touch.SetFunction('run_gen_homodor', '_touch', RunicGeneratorHomodorTouch)
	--
	Touch.DisableObject('bortard_tower', nil, q_path.."FindGates/bortard_tower_name.txt", q_path.."FindGates/bortard_tower_desc.txt")
	Touch.SetFunction('bortard_tower', '_talk', BortardTalk)
    --
    startThread(RunicGeneratorsFX, 'run_gen_gologurs')
  end
}

--
--------------------------------------------------------------------------------
-- ??? ?????????- ?????????

function ElmAmbushStartFight(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  local px, py = 31, 88
  local shero = ''
  local sx, sy, sz = 0, 0, GROUND
  if hero == 'Karlam' then
    shero = 'Noellie'
    sx, sy, sz = GetObjectPosition('Noellie')
    SetObjectPosition('Noellie', px, py, GROUND)
  else
    shero = 'Karlam'
    sx, sy, sz = GetObjectPosition('Karlam')
    SetObjectPosition('Karlam', px, py, GROUND)
  end
  sleep(20)
  ShowObject('Elmor', 1, 1)
  sleep(20)
  SetObjectOwner('Elmor', PLAYER_1)
  sleep()
  local fight_id = GetLastSavedCombatIndex()
  MakeHeroInteractWithObject('Agulnobar', 'Elmor')
  while GetLastSavedCombatIndex() == fight_id do
    sleep()
  end
  if IsHeroAlive('Elmor') then
    startThread(ElmorAmbushSecondDemonsAttack, shero, sx, sy, sz, hero)
  else
    Loose()
  end
end

function ElmorAmbushSecondDemonsAttack(saved_hero, saved_x, saved_y, saved_z, hero)
  DeployReserveHero('Grok', RegionToPoint('elm_ambush_kar_demon_point'))
  DeployReserveHero('Grol', RegionToPoint('elm_ambush_noe_demon_point'))
  local kx, ky = RegionToPoint('elm_ambush_karlam_move_reg')
  local nx, ny = RegionToPoint('elm_ambush_noe_move_reg')
  sleep(10)
  ShowFlyingSign(rtext('?, ? ?! ????! ??? ?????? ?? ???!'), 'Elmor', -1, 10.0)
  sleep(20)
  ShowObject('Karlam', PLAYER_1, 1)
  startThread(
  function()
    MoveHeroRealTime('Karlam', %kx, %ky, GROUND)
    while 1 do
      local x, y, z = GetObjectPosition('Karlam')
      if x == %ky and y == %ky then
        SetObjectRotation('Karlam', 258)
        break
      end
      sleep()
    end
  end)
  sleep(25)
  ShowObject('Noellie', 1)
  startThread(
  function()
    MoveHeroRealTime('Noellie', %nx, %ny, GROUND)
    while 1 do
      local x, y = GetObjectPosition('Noellie')
      if x == %ny and y == %ny then
        SetObjectRotation('Noellie', 88)
        break
      end
      sleep()
    end
  end)
  sleep(25)
  ShowObject('Grok', PLAYER_1, 1)
  sleep(10)
  ShowObject('Karlam', PLAYER_1, 1)
  local fight_id = GetLastSavedCombatIndex()
  MoveHeroRealTime('Grok', GetObjectPosition('Karlam'))
  while GetLastSavedCombatIndex() == fight_id do
    sleep()
  end
  if IsHeroAlive(Karlam) then
    sleep(15)
    ShowObject('Grol', PLAYER_1, 1)
    sleep(10)
    ShowObject('Noellie', PLAYER_1, 1)
    fight_id = GetLastSavedCombatIndex()
    MoveHeroRealTime('Grol', GetObjectPosition('Noellie'))
    while GetLastSavedCombatIndex() == fight_id do
      sleep()
    end
    if IsHeroAlive('Noellie') then
      sleep(15)
      startThread(ElmorAmbushPostFight, saved_hero, saved_x, saved_y, saved_z, hero)
    end
  end
end

function ElmorAmbushPostFight(saved_hero, saved_x, saved_y, saved_z, hero)
  -- ???/???
  StartDialogScene(DIALOG_SCENES.FIRST_ELMOR_TALK)
  SetObjectPosition(saved_hero, saved_x, saved_y, saved_z)
  UpdateQuest(main_quests.main, 2, hero)
end

--
--------------------------------------------------------------------------------
--

function MalgumolTalk(hero, object)
  --
  if GetProgress(main_quests.main) == 2 then
    StartMiniDialog(main_quests.path..'MalgumolFirstDialog/', 1, 3, m_dialog_sets['m_f_d'])
    UpdateQuest(main_quests.main, 3, hero)
    sleep(10)
  end
  --
  if IsUnknown(main_quests.generators) then
    StartMiniDialog(q_path..'Generators/StartDialog/', 1, 7, m_dialog_sets['g_s_d'])
    StartQuest(main_quests.generators, hero)
    for i, generator in {'run_gen_gologurs', 'run_gen_01', 'run_gen_02', 'run_gen_03', 'run_gen_04', 'run_gen_homodor', 'run_gen_ulkeron'} do
      SetObjectQuestmark(generator, OBJ_IN_PROGRESS, 20)
      Touch.DisableObject(generator, nil, q_path.."Generators/runic_generator_name.txt", q_path.."Generators/runic_generator_desc.txt")
      ShowObject(PLAYER_1, generator)
    end
  else
    local progress = GetProgress(main_quests.generators)
    if progress < 6 then
      MessageBox(q_path.."Generators/generators_not_repaired.txt")
    else
      ResetObjectQuestmark('Malgumol')
      FinishQuest(main_quests.generators, hero)
	  --
	  StartQuest(main_quests.find_gates)
    end
  end
  --
end

--
--------------------------------------------------------------------------------
-- ?????


function RunicGeneratorsFX(generator)
  while 1 do
    --local curr_fx = GetRandFromT({'Battlerage_rune', 'Berserk_rune', 'Charge_rune', 'Dragonform_rune', 'Spellimmun_rune', 'Ethereal_rune', 'Exorcism_rune', 'Magcontrol_rune', 'Revive_rune', 'Stunning_rune'})
    PlayFX('Berserk_rune', generator, '', GetRandFrom(1, -1) * (0.5 + 0.1 * random(5)), GetRandFrom(1, -1) * (0.5 + 0.1 * random(5)), 11 +  random(4), 90)
    sleep(4)
  end
end

-- ?? ??? ?? ????
function RunicGeneratorTouch(hero, object)
  -- ?????????- ?? ??? ??????????
  if IsUnknown(main_quests.generators) then
    if main_quests.first_generator_touch == 0 then
      main_quests.first_generator_touch = 1
      StartMiniDialog(q_path.."Generators/FirstTouch/", 1, 5, m_dialog_sets['f_g_t'])
    else
      ShowFlyingSign(q_path.."Generators/unknown_device.txt", object, PLAYER_1, 7.0)
    end
  else
    -- ???
    if IsActive(main_quests.generators) then
	  local progress = GetProgress(main_quests.generators)
	  -- ????????????
      if progress == 0 then
	    -- ??????????????
        if object == 'run_gen_gologurs' then
          StartMiniDialog(q_path.."Generators/CheckingSystem/", 1, 6, m_dialog_sets['c_g_s'])
          UpdateQuest(main_quests.generators, 1, hero)
          ResetObjectQuestmark(object)
        else
          MessageBox(q_path.."Generators/generator_system_unknown.txt")
        end
       else
        if object == 'run_gen_gologurs' then
          MessageBox(q_path.."Generators/generator_already_checked.txt")
        else
		  -- ?? ??????? ?????????
            if not main_quests.generators_repaired[object] then
            if object == 'run_gen_02' then
			  -- ??, ? ??????????
              StartMiniDialog(q_path.."Generators/DemonicGenerator/", 1, 9, m_dialog_sets['d_g_n'])
              main_quests.generators_repaired[object] = 1
              UpdateQuest(main_quests.generators, GetProgress(main_quests.generators) + 1, hero)
              ResetObjectQuestmark(object)
              if GetProgress(main_quests.generators) == 5 then
                SetObjectQuestmark('Malgumol', OBJ_IN_PROGRESS)
                UpdateQuest(main_quests.generators, 6, hero)
              end
            else
              if MCCS_QuestionBox({q_path.."Generators/"..object.."_repair_msg.txt"; resource_list = GenerateResourceList(main_quests.resources_to_repair[object])}) then
                if HavePlayerResT(PLAYER_1, main_quests.resources_to_repair[object]) then
                  if RemovePlayerResT(PLAYER_1, main_quests.resources_to_repair[object]) then
                    ShowFlyingSign(q_path.."Generators/generator_repaired.txt", object, 1, 7.0)
                    main_quests.generators_repaired[object] = 1
                    ResetObjectQuestmark(object)
                    startThread(RunicGeneratorsFX, object)
                    UpdateQuest(main_quests.generators, GetProgress(main_quests.generators) + 1, hero)
                    if GetProgress(main_quests.generators) == 5 then
                      SetObjectQuestmark('Malgumol', OBJ_IN_PROGRESS)
                      UpdateQuest(main_quests.generators, 6, hero)
                    end
                  end
                else
                  MessageBox(q_path.."Generators/no_res_to_repair.txt")
                end
              end
            end
          else
            MessageBox(q_path.."Generators/generator_already_checked.txt")
          end
        end
      end
    elseif IsCompleted(main_quests.generators) then
      MessageBox(q_path.."Generators/generator_already_checked.txt")
    end
  end
end

-- ?? ??? ???? ????
function GeneratorDemonAmbush(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  BlockGame()
  local demons_types = {CREATURE_BALOR, CREATURE_INFERNAL_SUCCUBUS, CREATURE_ARCHDEVIL}
  for i = 1, 3 do
    startThread(
    function()
      local x, y, z = GetObjectPosition('runic_generator_spawn_0'..%i)
      PlayFX('Summon_balor', 'runic_generator_spawn_0'..%i)
      sleep(15)
      CreateMonster('demon_ambush_'..%i, %demons_types[%i], 1, x, y, z, 3, 1, 180)
      while not IsObjectExists('demon_ambush_'..%i) do
        sleep()
      end
      PlayObjectAnimation('demon_ambush_'..%i, 'happy', ONESHOT)
    end)
  end
  sleep(20)
  local tier_table = TIER_TABLES[TOWN_INFERNO]
  if MCCS_StartCombat(hero, nil, 6,
     GetRandFromT_ETbl({nil, tier_table[1][1]}, tier_table[1]), 250,
     GetRandFromT_ETbl({nil, tier_table[3][1]}, tier_table[3]), 110,
     GetRandFromT_ETbl({nil, tier_table[4][1]}, tier_table[4]), 59,
     GetRandFromT_ETbl({nil, tier_table[4][1]}, tier_table[4]), 43,
     GetRandFromT_ETbl({nil, tier_table[6][1]}, tier_table[6]), 16,
     GetRandFromT_ETbl({nil, tier_table[7][1]}, tier_table[7]), 9) then
    for i = 1, 3 do
      PlayObjectAnimation('demon_ambush_'..i, 'death', ONESHOT_STILL)
    end
    sleep(15)
    RemoveObjects('demon_ambush_1', 'demon_ambush_2', 'demon_ambush_3')
  end
  UnblockGame()
end

-- логика разговора с Ѕортардом в √ологурсе
function BortardTalk(hero, object)
  if IsUnknown(main_quests.find_gates) then
    StartMiniDialog(q_path.."FindGates/QuestUnknownDialog/", 1, 1, m_dialog_sets['fg_qu'], random(3) + 1)
  elseif IsActive(main_quests.find_gates) then
    local progress = GetProgress(main_quests.find_gates)
  	if progress == 0 then
      -- q init.
  	  StartMiniDialog(q_path.."FindGates/QuestStartDialog/", 1, 7, m_dialog_sets['fg_qs'])
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'run_gen_ulkeron_region', 'RunicGeneratorUlkeronEnter')
  	  for i, object in {'run_gen_homodor', 'run_gen_ulkeron'} do
    		SetObjectQuestmark(object, OBJ_IN_PROGRESS, 20)
    		ShowObject(PLAYER_1, object)
  	  end
  	  UpdateQuest(main_quests.find_gates, 1, hero)
  	elseif progress < 4 then
  	  StartMiniDialog(q_path.."FindGates/QuestTempDialog/", 1, 1, m_dialog_sets['fg_tmp'])
  	else
  	  StartMiniDialog(q_path.."FindGates/QuestFinalDialog/", 1, 17, m_dialog_sets['fg_fn'])
  	  FinishQuest(main_quests.find_gates)
  	end
  elseif IsCompleted(main_quests.find_gates) then
    -- ??: ????
  end
end

-- рунный генератор в ’омодоре
function RunicGeneratorHomodorTouch(hero, object)
  if IsUnknown(main_quests.find_gates) then
    MessageBox(q_path.."FindGates/cant_check.txt")
  elseif IsActive(main_quests.find_gates) then
    --
    local tier_table = TIER_TABLES[TOWN_INFERNO]
    local devil_type = GetRandFromT_ETbl({nil, tier_table[7][1]}, tier_table[7])
    local succub_type = GetRandFromT_ETbl({nil, tier_table[4][1]}, tier_table[4])
    --
    BlockGame()
    PlayFX("Summon_balor", "homodor_gen_summon_01")
    PlayFX("Summon_balor", "homodor_gen_summon_02")
    sleep(12)
    local x, y = GetObjectPosition("homodor_gen_summon_01")
    CreateMonster("run_gen_homodor_summon_1", devil_type, 1, x, y, GROUND, 3, 1, 172.419)
    x, y = GetObjectPosition("homodor_gen_summon_02")
    CreateMonster("run_gen_homodor_summon_2", succub_type, 1, x, y, GROUND, 3, 1, 210.8576)
    sleep(5)
    x, y = GetObjectPosition("homodor_gen_summon_03")
    MoveCamera(x, y, GROUND, 30, math.pi/4, 0)
    sleep(15)
    PlayFX("Summon_balor", "homodor_gen_summon_03")
    sleep(12)
    CreateMonster("run_gen_homodor_summon_3", CREATURE_H7_SUCCUB_01, 1, x, y, GROUND, 3, 1)
    sleep(5)
    PlayObjectAnimation("run_gen_homodor_summon_3", "happy", ONESHOT)
    sleep(15)
    local mult = IsActive(diversion.name) and 1 or 0
    if MCCS_StartCombat(hero, nil, 5,
                        devil_type, 18 * mult + 4,
                        succub_type, 65 * mult + 18,
                        GetRandFromT_ETbl({nil, tier_table[4][1]}, tier_table[4]), 71 * mult + 17,
                        GetRandFromT_ETbl({nil, tier_table[7][1]}, tier_table[7]), 20 * mult + 5,
                        CREATURE_H7_SUCCUB_01, 50 * mult + 14, nil, nil, nil, 1) then
      for i = 1, 3 do
        PlayObjectAnimation("run_gen_homodor_summon_"..i, "death", ONESHOT_STILL)
      end
      RemoveObjects("run_gen_homodor_summon_1", "run_gen_homodor_summon_2", "run_gen_homodor_summon_3")
      local progress = GetProgress(main_quests.find_gates) + 1
      UpdateQuest(main_quests.find_gates, progress, hero)
      MessageBox(q_path.."FindGates/homodor_gen_checked.txt", "UnblockGame")
      if progress == 3 then
        MessageBox(q_path.."FindGates/return_to_bortard.txt")
        UpdateQuest(main_quests.find_gates, 4, hero)
      end
      --
      Touch.OverrideFunction(object, "_touch",
      function(hero, object)
        ShowFlyingSign(q_path.."FindGates/coords_already_checked.txt", object, PLAYER_1, 7.0)
      end)
    end
  end
end

-- рунный генератор в ”лкероне
function RunicGeneratorUlkeronEnter(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  BlockGame()
  sleep(5)
  PlayFX('Firewall', 'run_gen_ulkeron', 'fw_01', 0.8, 2)
  PlayFX('Firewall', 'run_gen_ulkeron', 'fw_02', -0.2, 2)
  sleep(10)
  ShowObject(PLAYER_1, 'run_gen_ulkeron_summon_point_01', 1, 1)
  sleep(10)
  PlayFX('Exit_one_way', 'run_gen_ulkeron_summon_point_01', 'uk_portal_01', 0, 0, 0, 270)
  sleep(15)
  -- бой
  if MCCS_StartCombat(hero, nil, 1, 1, 1) then
    PlayFX('Implosion', 'run_gen_ulkeron_summon_point_01', '', 0.5, -0.5)
    sleep(15)
    StopVisualEffects('uk_portal_01')
    sleep(5)
    ShowObject(PLAYER_1, 'run_gen_ulkeron_summon_point_02', 1, 1)
    sleep(15)
    PlayFX('Exit_one_way', 'run_gen_ulkeron_summon_point_02', 'uk_portal_02')
    sleep(15)
    if MCCS_StartCombat(hero, nil, 1, 1, 1) then
      PlayFX('Implosion', 'run_gen_ulkeron_summon_point_02', '', 0.5, 0.5)
      sleep(15)
      StopVisualEffects('uk_portal_02')
      sleep(5)
      local x, y, z = RegionToPoint('ulkeron_gen_portal_spawn_02')
      MoveCamera(x, y, z, 30, math.pi/6, math.pi/2)
      sleep(20)
      CreateStatic('ulkeron_gen_portal_2side', main_quests.portal_static, x, y + 0.5, z, 90)
      while not IsObjectExists('ulkeron_gen_portal_2side') do
        sleep()
      end
      sleep(5)
      PlayFX('Big_fire_1', 'ulkeron_gen_portal_2side', '2side_portal_fire', -0.5, 0.5)
      sleep(10)
      PlayFX('Phantom_in', 'ulkeron_gen_portal_2side', '', 1, 1)
      sleep(5)
      CreateMonster('uk_destroyer', 2189, 1, 145, 18, GROUND, 3, 1, 90)
      while not IsObjectExists('uk_destroyer') do
        sleep()
      end
      --SetObjectPosition('uk_destroyer', 144.5, 18.5)
      sleep()
      PlayObjectAnimation('uk_destroyer', 'happy', ONESHOT)
      sleep(30)
      if MCCS_StartCombat(hero, nil, 1, 2189, 1) then
        -- диалог
        StopVisualEffects('fw_01')
        StopVisualEffects('fw_02')
        --
        PlayObjectAnimation('uk_destroyer', 'death', ONESHOT_STILL)
        sleep(35)
        RemoveObject('uk_destroyer')
        sleep(5)
        PlayFX('Dispel_fail', 'ulkeron_gen_portal_2side', '', 0.5, 0.5)
        sleep(3)
        StopVisualEffects('2side_portal_fire')
        sleep(3)
        for i = 1, 10 + random(10) do
          PlayFX('Arcane_crys_death', 'ulkeron_gen_portal_2side', '', 0.5 + (GetRandFrom(-1, 1) * 0.5), 0.5 + (GetRandFrom(-1, 1) * 0.5), random(3))
          sleep()
        end
        RemoveObject('ulkeron_gen_portal_2side')
        sleep(10)
        StartMiniDialog(q_path.."FindGates/DemolisherFightDialog/", 1, 3, m_dialog_sets['fg_dmf'])
        UnblockGame()
      end
    end
  end
end

--
--------------------------------------------------------------------------------
-- ???

function GatesFxThread()
  local x = 0
  while 1 do
    x = x + 1
    PlayFX('Gating_big', 'gates_emitter_01', 'gating_'..x, 3 + (random(6) * 0.5 * GetRandFrom(-1, 1)), 9 + (random(6) * 0.5 * GetRandFrom(-1, 1)), 1.5 + (-1 * random(16)) * 0.5)
    startThread(
    function()
      sleep(15 + random(15))
      StopVisualEffects('gating_'..%x)
    end)
    sleep(random(5))
  end
end