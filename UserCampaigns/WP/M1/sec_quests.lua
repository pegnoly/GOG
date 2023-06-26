--------------------------------------------------------------------------------
-- втор. - эльфийские двеллы

elf_dwells =
{
  name = 'ELF_DWELLS',
  path = q_path..'ElfDwells/',

  dwell_type = {},
  dwell_count = {},
  dwell_creatures =
  {
    ['e_dwell1'] = {TOWN_PRESERVE, 1, 9 + 5 * diff},
    ['e_dwell2'] = {TOWN_PRESERVE, 3, 3 + 2 * diff},
    ['e_dwell3'] = {TOWN_PRESERVE, 4, 3 + DIFF, TOWN_PRESERVE, 5, 1 + diff / 2, TOWN_PRESERVE, 6, DIFF - 1},
    ['e_dwell4'] = {TOWN_PRESERVE, 1, 12 + 5 * diff},
    ['e_dwell5'] = {TOWN_PRESERVE, 3, 3 + 3 * diff},
    ['e_dwell6'] = {TOWN_PRESERVE, 2, 6 + 4 * diff},
    ['e_dwell7'] = {TOWN_PRESERVE, 2, 11 + 4 * diff},
    ['e_dwell8'] = {TOWN_PRESERVE, 4, 4 + diff, TOWN_PRESERVE, 5, 1 + diff, TOWN_PRESERVE, 6, 1 + diff / 2, TOWN_PRESERVE, 7, diff - 3},
  },

  region_to_dwell =
  {
    ['elf_dwells_start'] = {'e_dwell1'},
    ['elf_dwells_1'] = {'e_dwell2', 'e_dwell3'},
    ['elf_dwells_2'] = {'e_dwell4'},
    ['elf_dwells_3'] = {'e_dwell7', 'e_dwell8'},
    ['elf_dwells_4'] = {'e_dwell5', 'e_dwell6'},
  },
  
  Init =
  function()
    startThread(ElfDwellsInit)
    for reg, _ in elf_dwells.region_to_dwell do
      Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, reg, 'ElfDwellsEnter')
    end
  end
}

--------------------------------------------------------------------------------
-- втор. - √аргульи - разведчики

scouts =
{
  name = 'SCOUTS',
  path = q_path..'Scouts/',

  gargoyles = {'scout_garg_01', 'scout_garg_02', 'scout_garg_03'},
  scouts_founded = 0,
  
  Init =
  function()
    startThread(GargoylesInit)
  end
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

  Init =
  function()
    for i, region in {'wind_trap', 'earth_trap', 'water_trap', 'fire_trap'} do
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, 'EmitterEnter')
    end
    --
    Touch.DisableObject('tavern')
    Touch.SetFunction('tavern', '_q_tavern', TavernTalk)
    --
    Touch.DisableObject('sealed_tomb')
    Touch.SetFunction('sealed_tomb', '_rock_fight', RockFight)
    --
    Touch.DisableObject('blood_temple_01')
    Touch.SetFunction('blood_temple_01', '_fight', BloodTempleFight)
    --
    PlayFX('Elem_seal', 'sealed_tomb', 'tomb_seal_01', 2.5, -7.5, 0, 0)
  end
}

--
--------------------------------------------------------------------------------
-- двеллы эльфов

function ElfDwellsInit()
  for i, type in {'FAIRIE_TREE', 'WOOD_GUARD_QUARTERS', 'HIGH_CABINS', 'PRESERVE_MILITARY_POST'} do
    elf_dwells.dwell_count[type] = 0
    for j, dwell in GetObjectNamesByType('BUILDING_'..type) do
      elf_dwells.dwell_type[dwell] = type
      Touch.DisableObject(dwell)
      Touch.SetFunction(dwell, '_touch', ElfDwellTouch)
    end
  end
end

-- вход в регионы около двеллов
function ElfDwellsEnter(hero, region)
  if hero == Karlam then
    if region == 'elf_dwells_start' and IsUnknown(elf_dwells.name) then
      BlockGame()
      ShowObject('e_dwell1', 1, 1)
      sleep(15)
      MessageBox(elf_dwells.path..'start.txt', 'UnblockGame')
      StartQuest(elf_dwells.name, hero)
    end
  else
    ShowObject(hero, 1)
    Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, region, nil)
    for i, dwell in elf_dwells.region_to_dwell[region] do
      if elf_dwells.dwell_type[dwell] then
        AddCreaturesByTier(hero, table.unpack(elf_dwells.dwell_creatures[dwell]))
      end
    end
  end
end

function ElfDwellTouch(hero, object)
  local args = {[1] = hero, [2] = nil}
  local type = elf_dwells.dwell_type[object]
  print('type: ', type)
  local stack_count = 0
  if type == 'FAIRIE_TREE' then
    local base_count = 146 + 14 * elf_dwells.dwell_count[type]
    stack_count = 3 + random(3)
    local curr_div = stack_count
    for i = 4, (2 + stack_count * 2), 2 do
      local curr_type = GetRandFromT(TIER_TABLES[TOWN_PRESERVE][1])
      local curr_v = base_count / curr_div + (curr_div == 1 and 0 or (GetRandFrom(1, -1) * (5 + random(8))))
      args[i] = curr_type
      args[i + 1] = curr_v
      curr_div = curr_div - 1
      base_count = base_count - curr_v
    end
  elseif type == 'WOOD_GUARD_QUARTERS' then
    local base_count = 82 + 8 * elf_dwells.dwell_count[type]
    stack_count = 2 + random(3)
    local curr_div = stack_count
    for i = 4, (2 + stack_count * 2), 2 do
      local curr_type = GetRandFromT(TIER_TABLES[TOWN_PRESERVE][2])
      local curr_v = base_count / curr_div + (curr_div == 1 and 0 or (GetRandFrom(1, -1) * (4 + random(5))))
      args[i] = curr_type
      args[i + 1] = curr_v
      curr_div = curr_div - 1
      base_count = base_count - curr_v
    end
  elseif type == 'HIGH_CABINS' then
    local base_count = 45 + 5 * elf_dwells.dwell_count[type]
    stack_count = 2 + random(2)
    local curr_div = stack_count
    for i = 4, (2 + stack_count * 2), 2 do
      local curr_type = GetRandFromT(TIER_TABLES[TOWN_PRESERVE][3])
      local curr_v = base_count / curr_div + (curr_div == 1 and 0 or (GetRandFrom(1, -1) * (3 + random(4))))
      args[i] = curr_type
      args[i + 1] = curr_v
      curr_div = curr_div - 1
      base_count = base_count - curr_v
    end
  else
    --
    local curr_arg = 4
    --
    local lvl4_stacks = 1 + elf_dwells.dwell_count[type] + random(2)
    local lvl4_count = 22 + 4 * elf_dwells.dwell_count[type]
    local curr_div = lvl4_stacks
    stack_count = stack_count + lvl4_stacks
    for i = 1, lvl4_stacks do
      local curr_type = GetRandFromT(TIER_TABLES[TOWN_PRESERVE][4])
      local curr_v = lvl4_count / curr_div + (curr_div == 1 and 0 or (GetRandFrom(1, -1) * (3 + random(3))))
      args[curr_arg] = curr_type
      args[curr_arg + 1] = curr_v
      curr_arg = curr_arg + 2
      curr_div = curr_div - 1
      lvl4_count = lvl4_count - curr_v
    end
    --
    local lvl5_stacks = 1 + random(2)
    local lvl5_count = 11 + 2 * elf_dwells.dwell_count[type]
    curr_div = lvl5_stacks
    stack_count = stack_count + lvl5_stacks
    for i = 1, lvl5_stacks do
      local curr_type = GetRandFromT(TIER_TABLES[TOWN_PRESERVE][5])
      local curr_v = lvl5_count / curr_div + (curr_div == 1 and 0 or (GetRandFrom(1, -1) * (1 + random(3))))
      args[curr_arg] = curr_type
      args[curr_arg + 1] = curr_v
      curr_arg = curr_arg + 2
      curr_div = curr_div - 1
      lvl5_count = lvl5_count - curr_v
    end
    --
    local lvl6_stacks = 1 + random(2)
    local lvl6_count = 4 + 2 * elf_dwells.dwell_count[type]
    curr_div = lvl6_stacks
    stack_count = stack_count + lvl6_stacks
    for i = 1, lvl6_stacks do
      local curr_type = GetRandFromT(TIER_TABLES[TOWN_PRESERVE][6])
      local curr_v = lvl6_count / curr_div + (curr_div == 1 and 0 or (GetRandFrom(1, -1)))
      args[curr_arg] = curr_type
      args[curr_arg + 1] = curr_v
      curr_arg = curr_arg + 2
      curr_div = curr_div - 1
      lvl6_count = lvl6_count - curr_v
    end
    --
    if object == 'e_dwell8' then
      stack_count = stack_count + 1
      args[curr_arg] = GetRandFromT(TIER_TABLES[TOWN_PRESERVE][7])
      args[curr_arg + 1] = diff / 2
    end
  end
  args[3] = stack_count
  if StartCombat(args[1], args[2], args[3], args[4], args[5], args[6], args[7],
                 args[8], args[9], args[10], args[11], args[12], args[13], args[14],
                 args[15], args[16], args[17]) then
    elf_dwells.dwell_type[object] = nil
    Touch.RemoveFunctions(object)
    PlayFX('Fireball', object)
    sleep(8)
    PlayFX('Big_fire_1', object)
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
     QuestionBox(rtext('—окровища храма надежно охран€ютс€. ∆елаете сразитьс€ с охраной?')) and
     StartCombat(hero, nil, 4,
                 GetRandFromT_E(nil, {CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2, CREATURE_BLOOD_WITCH_NCF367}), 26 + random(5),
                 GetRandFromT_E(nil, {CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2, CREATURE_BLOOD_WITCH_NCF367}), 30 + random(5),
                 GetRandFromT_E(nil, {CREATURE_MINOTAUR_KING, CREATURE_MINOTAUR_CAPTAIN, CREATURE_BRUTAL_MINOTAUR}), 21 + random(5),
                 GetRandFromT_E(nil, {CREATURE_MATRIARCH, CREATURE_SHADOW_MISTRESS, CREATURE_FLYING_MISTRESS}), 6 + random(3)) then
    Award(hero, nil, nil, {ARTIFACT_ICEBERG_SHIELD, ARTIFACT_RING_OF_LIFE})
    MarkObjectAsVisited(object, hero)
    Touch.OverrideFunction(object, '_fight',
    function(hero, object)
      ShowFlyingSign(rtext('’рам пуст...'), object, -1, 7.0)
    end)
  end
end

--
--------------------------------------------------------------------------------
-- коридор элементов

-- поток, провер€ющий наличие героев внутри коридора или около него
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

-- поток включающий/выключающий эффекты, в зависимости от наличи€ героев поблизости
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
      ShowFlyingSign(rtext('—хрон пуст...'), object, -1, 7.0)
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
  ShowFlyingSign(rtext('’ммм...'), hero, 1, 5.0)
  sleep(10)
  MoveHeroRealTime(hero, GetObjectPosition('scout_garg_01'))
  UnblockGame()
end