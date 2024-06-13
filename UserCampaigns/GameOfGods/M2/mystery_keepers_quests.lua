--------------------------------------------------------------------------------
-- локальные квесты Хранителей Тайн


-- начало - главный кв. - Элмор дает наводку, что в клане есть гномы, которые могут помочь
-- расспрашиваем всех - дают намеки, но ничего конкретного, но один гном супер интересуется этой легендой тоже
-- рассказывает о мудреце, который может знать правду и о экспедиции к горе, которую проводили молодые гномы

MKeepersQ =
{
  -- базовая информация для стартовых настроек
  monsters_to_disable =
  {
    ['mk_dwarf_1'] = {name = 'mk_dwarf_01'},
    ['mk_dwarf_2'] = {name = 'mk_dwarf_02'}
  },
  
  objects_to_disable =
  {
    ['mk_seer_01'] = {name = 'mk_seer_01_n', desc = ''},
  },
  
  prim =
  {
    rep          = 'MYSTERY_KEEPERS_REP',
  },
  
  sec =
  {
    shrines      = 'MK_QUEST_01',
    watcher      = 'MK_QUEST_02',
    stranger     = 'MK_QUEST_03',
  },
  
  path = q_path..'Sec/MysteryKeepers/',
  
  Init =
  function()
    --
    StartQuest(MKeepersQ.prim.rep)
    --
    for monster, info in MKeepersQ.monsters_to_disable do
      Touch.DisableMonster(monster, DISABLED_INTERACT, 0, m_names_path..info.name..'.txt')
    end
    for object, info in MKeepersQ.objects_to_disable do
      Touch.DisableObject(object, nil, o_names_path..info.name..'.txt', o_names_path..info.desc..'.txt')
    end
    --
    Touch.SetFunction('mk_dwarf_1', '_talk', MKDwarfTalk01)
    Touch.SetFunction('mk_dwarf_2', '_talk', MKDwarfTalk02)
    Touch.SetFunction('mk_seer_01', '_talk', MKSeerTalk01)
    --
    for i = 1, 3 do
      Touch.DisableObject('mk_shrine_0'..i)
      Touch.SetFunction('mk_shrine_0'..i, '_touch', MK_RunicShrineTouch)
    end
    --
    SetGameVar('mk_q1_rune', 0)
  end,
  
  --
  ------------------------------------------------------------------------------
  -- основные переменные
  current_rep = 0, -- репутация в цифрах
  current_rep_lvl = 0, -- уровень репы (от -2(враждебная) до 3(уважительная))
  rep_to_lvl = {[0] = 0; 20, 40, 70, 100},
  
  --
  ------------------------------------------------------------------------------
  -- квестовые
  q1_runes = 0,
  q1_shrines_checked = {},
}

function MKRepThread()
  local saved_rep = 0
  while 1 do
    --
    local curr_rep = MKeepersQ.current_rep
    --
    if curr_rep ~= saved_rep then
      --
      if curr_rep > saved_rep then
        local new_lvl = -3
        for lvl, rep in MKeepersQ.rep_to_lvl do
          if curr_rep >= rep then
            new_lvl = lvl
          end
        end
        print('new_lvl: ', new_lvl)
        if new_lvl > MKeepersQ.current_rep_lvl then
          MKeepersQ.current_rep_lvl = new_lvl
          UpdateQuest(MKeepersQ.prim.rep, new_lvl)
          -- msg
        end
      --
      else
        local new_lvl = -3
        for lvl, rep in MKeepersQ.rep_to_lvl do
          if curr_rep < rep then
            new_lvl = lvl - 1
          end
        end
        if new_lvl < MKeepersQ.current_rep_lvl then
          MKeepersQ.current_rep_lvl = new_lvl
          UpdateQuest(MKeepersQ.prim.rep, new_lvl)
          -- msg
        end
      end
      --
      saved_rep = curr_rep
    end
    sleep()
  end
end

startThread(MKRepThread)

--
--------------------------------------------------------------------------------
--
function MKDwarfTalk01(hero, object)
  --
  local check
  local name = GetDialogName(hero)
  -- разговор по 1 пункту поиска Жезла
  if GetProgress(FindStaff.name) == 0 and (not FindStaff.p1_dwarves_talked[object]) then
    FindStaff.p1_dwarves_talked[object] = 1
    MessageBox(FindStaff.path..'p0_dwarf_talk_0'..(random(5) + 1)..'.txt')
    check = 1
  end
  -- логика квеста с рунными святилищами
  if IsUnknown(MKeepersQ.sec.shrines) then
    MessageBox(MKeepersQ.path..'q1_start.txt')
    StartQuest(MKeepersQ.sec.shrines)
    sleep(10)
    for i = 1, 3 do
      ShowObject('mk_shrine_0'..i, 1)
      sleep(10)
    end
    check = 1
  end
  if IsActive(MKeepersQ.sec.shrines) and MKeepersQ.q1_runes == 3 then
    FinishQuest(MKeepersQ.sec.shrines)
    MKeepersQ.current_rep = MKeepersQ.current_rep + 20
    MessageBox({MKeepersQ.path..'q3_start.txt'; hero = name})
    StartQuest(MKeepersQ.sec.stranger)
    check = 1
  end
  --
  if not check then
    ShowFlyingSign(rtext('Приходи как-нибудь в другой раз...'), object, -1, 7.0)
  end
end

--

function MKDwarfTalk02(hero, object)
  --
  local check
  local name = GetDialogName(hero)
  -- разговор по 1 пункту поиска Жезла
  if GetProgress(FindStaff.name) == 0 and (not FindStaff.p1_dwarves_talked[object]) then
    FindStaff.p1_dwarves_talked[object] = 1
    MessageBox(FindStaff.path..'p0_dwarf_talk_0'..(random(5) + 1)..'.txt')
    check = 1
  end
  --
  if IsUnknown(MKeepersQ.sec.watcher) then
    MessageBox({MKeepersQ.path..'q2_start.txt'; hero = name})
    StartQuest(MKeepersQ.sec.watcher)
    check = 1
  end
  --
  if not check then
    ShowFlyingSign(rtext('Нет у меня времени с тобой болтать...'), object, -1, 7.0)
  end
end

function MKSeerTalk01(hero, object)
  --
  local check
  local name = GetDialogName(hero)
  -- разговор по 1 пункту поиска Жезла
  if GetProgress(FindStaff.name) == 0 and (not FindStaff.p1_dwarves_talked[object]) then
    FindStaff.p1_dwarves_talked[object] = 1
    MessageBox(FindStaff.path..'p0_dwarf_talk_0'..(random(5) + 1)..'.txt')
    check = 1
  end
  --
  if IsActive(MKeepersQ.sec.stranger) then
    if GetProgress(MKeepersQ.sec.stranger) == 0 then
      MessageBox(MKeepersQ.path..'q3_gardos_talk.txt')
      UpdateQuest(MKeepersQ.sec.stranger, 1)
    end
    check = 1
  end
  --
  if MKeepersQ.current_rep_lvl < 2 then
    MessageBox(rtext('Пока у тебя так мало репутации, я не могу доверить тебе свое задание!'))
    check = 1
  end
  --
  if not check then
    ShowFlyingSign(rtext('Пока у меня ничего нет для тебя...'), object, -1, 7.0)
  end
end

--
--------------------------------------------------------------------------------
-- КВЕСТЫ
--------------------------------------------------------------------------------
--

--
--------------------------------------------------------------------------------
-- рунные генераторы

function MK_RunicShrineTouch(hero, object)
  --
  local rune = 0
  if object == 'mk_shrine_01' then
    rune = GetRandFrom(249, 250, 251, 252)
  elseif object == 'mk_shrine_02' then
    rune = GetRandFrom(253, 254, 256)
  else
    rune = GetRandFrom(255, 257, 258)
  end
  SetGameVar('mk_q1_rune', rune)
  sleep()
  DeployReserveHero('DarkRunesKeeper', 20, 10, 0)
  sleep()
  -- добавление существ
  --
  local index = GetLastSavedCombatIndex()
  MakeHeroInteractWithObject(hero, 'DarkRunesKeeper')
  while GetLastSavedCombatIndex() == index do
    sleep()
  end
  SetGameVar('mk_q1_rune', 0)
  -- прогресс квеста
  if IsActive(MKeepersQ.sec.shrines) then
    if not MKeepersQ.q1_shrines_checked[object] then
      MKeepersQ.q1_shrines_checked[object] = 1
      MKeepersQ.q1_runes = MKeepersQ.q1_runes + 1
      UpdateQuest(MKeepersQ.sec.shrines, MKeepersQ.q1_runes)
    else
      MessageBox(rtext('У вас уже есть руна из этого святилища.'))
    end
  end
  -- выдача руны
  ShowFlyingSign(rtext('Получена Темная '..spell_info[rune].name), hero, -1, 7.0)
end


  