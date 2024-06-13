--------------------------------------------------------------------------------
-- ������� - ������

listmur =
{
  --
  find_caravan = 'FIND_CARAVAN',
  --
  path = q_path..'Listmur/',
  
  knight_arena_talk = 0,
  knight_arena_double_bet = 0,
  knight_arena_bets = {},
  knight_fight_day = 0,
  
  road_pact = 0,
  
  barr_troops =
  {
    [1] = {[CREATURE_ARCHER] = 18, [CREATURE_KNECHT] = 7},
    [2] = {[CREATURE_MARKSMAN] = 10, [CREATURE_PEASANT] = 35},
    [3] = {[CREATURE_BOWMAN] = 12, [CREATURE_SWORDSMAN] = 5},
  },
  
  barr_troops_bought = 0,
  
  tavern_troops =
  {
    [1] = {[CREATURE_STOUT_DEFENDER] = 27, [CREATURE_BROWLER] = 8},
    [2] = {[CREATURE_AXE_FIGHTER] = 14, [CREATURE_BERSERKER] = 5, [CREATURE_BATTLE_RAGER] = 7}
  },
  
  tavern_troops_bought = 0,
}

function ListmurInit()
  --
  Touch.DisableMonster('kn_ferab', DISABLED_INTERACT, 0, o_path..'ferab.txt')
  Touch.DisableMonster('kn_trist', DISABLED_INTERACT, 0, o_path..'trist.txt')
  --
  local list_temple_monks = GetObjectsInRegion('listmur_temple_reg', 'CREATURE')
  AnimGroup['l_t_m'] = {actors = list_temple_monks, region = 'listmur_temple_reg'}
  for i, creature in list_temple_monks do
    Touch.DisableMonster(creature, DISABLED_INTERACT, 0)
  end
  PlayAnims('l_t_m', {'happy', 'cast', 'rangeattack'}, COND_HERO_IN_REGION)
  --
  local list_arena_knights = GetObjectsInRegion('listmur_arena_reg', 'CREATURE')
  AnimGroup['l_a_k'] = {actors = list_arena_knights, region = 'listmur_arena_reg'}
  for i, creature in list_arena_knights do
    Touch.DisableMonster(creature, DISABLED_INTERACT, 0)
  end
  PlayAnims('l_a_k', {'stir00', 'happy'}, COND_HERO_IN_REGION)
  --
  EnableHeroAI('ListmurCap', nil)
  Touch.DisableHero('ListmurCap')
  Touch.SetFunction('ListmurCap', '_knight_arena_talk', ListmurKnightArenaTalk)
  SetObjectQuestmark('ListmurCap', NO_OBJ_MARK)
  --
  Touch.DisableObject('listmur_major', nil, o_path..'list_major.txt')
  Touch.SetFunction('listmur_major', '_list_m_talk', ListmurMajorTalk)
  SetObjectQuestmark('listmur_major', NO_OBJ_MARK, 8)
  --
  Touch.DisableObject('listmur_temple', nil, o_path..'list_temple.txt')
  Touch.SetFunction('listmur_temple', '_as_start', ListmurTempleTalk)
  SetObjectQuestmark('listmur_temple', OBJ_NEW, 7)
  --
  Touch.DisableObject('listmur_tavern', nil, o_path..'list_tavern.txt')
  Touch.SetFunction('listmur_tavern', '_buy_tavern_troops', ListmurTavernTalk)
  listmur.tavern_troops_bought = random(2) + 1
  SetObjectQuestmark('listmur_tavern', NO_OBJ_MARK, 6)
  --
  Touch.DisableObject('listmur_barr', nil, o_path..'list_barr.txt')
  Touch.SetFunction('listmur_barr', '_buy_barr_troops', ListmurBarrTalk)
  listmur.barr_troops_bought = random(3) + 1
  SetObjectQuestmark('listmur_barr', NO_OBJ_MARK, 7)
  --
  Touch.DisableObject('listmur_camp', nil, o_path..'list_camp_n.txt', o_path..'list_camp_d.txt')
  --
  PlayThisMapAnimGroups()
end

--
--------------------------------------------------------------------------------
-- ����� �������� � ������ �� ���

-- ����������� ������� ������� ������
function KnightArenaPerform(curr_state, answer, next_state)
  local return_state = next_state
  if curr_state == 2 then
    if not listmur.knight_arena_bets[Dialog.active_hero] then
      listmur.knight_arena_bets[Dialog.active_hero] = {}
    end
    local first_bet = ''
    -- ���� ���� ����� ��� ��������, ��������� ��� ������
    for hero, info in listmur.knight_arena_bets do
      if hero and info and info.knight then
        first_bet = info.knight
      end
    end
    if answer == 1 then
      listmur.knight_arena_bets[Dialog.active_hero]['knight'] = 'kn_trist'
      if first_bet == 'kn_trist' then
        listmur.knight_arena_double_bet = 1 -- ����, ��� ��� ��������� �� ������
      end
    elseif answer == 2 then
      listmur.knight_arena_bets[Dialog.active_hero]['knight'] = 'kn_ferab'
      if first_bet == 'kn_ferab' then
        listmur.knight_arena_double_bet = 1
      end
    end
  elseif curr_state == 3 then
    if next_state ~= 0 then
      listmur.knight_arena_bets[Dialog.active_hero]['gold'] = next_state
      RemovePlayerRes(PLAYER_1, GOLD, next_state)
      return_state = 0
    end
  end
  return return_state
end

listmur_arena_dialog =
{
  state = 1,
  icon = '',
  path = q_path..'Listmur/',
  perform_func = KnightArenaPerform,
  title = 'listmur_arena_title',
  select_text = '',
  options =
  {
    [1] = {[0] = 'listmur_arena_default'; {'������� ������', 2, 1}, {'�����', 0, 1}},
    [2] = {[0] = 'listmur_arena_bet_hero'; {'��������� �� �������� �� ��������� ��������', 3, 1}, {'��������� �� ���������� �������������', 3, 1}, {'�����', 1, 1}},
    [3] = {[0] = 'listmur_arena_bet_money';},
    [4] = {[0] = 'listmur_arena_bet_active'; {'�����', 0, 1}},
  },
  
  Open =
  function()
    if listmur.knight_arena_bets[Dialog.active_hero] and listmur.knight_arena_bets[Dialog.active_hero].gold then
      listmur_arena_dialog.state = 4
    else
      Dialog.Reset()
      local base_bet, k = 5000, 0
      if not HavePlayerRes(PLAYER_1, GOLD, base_bet) then
        Dialog.SetText(listmur_arena_dialog, 3, 'knight_arena_nothing_to_bet')
        Dialog.SetAnswer(listmur_arena_dialog, 3, 1, '�����', 0, 1)
      else
        k = k + 1
         print('here?')
        while HavePlayerRes(PLAYER_1, GOLD, base_bet * k) do
          Dialog.SetAnswer(listmur_arena_dialog, 3, k, '��������� '..base_bet * k..' ������', base_bet * k, 1)
          k = k + 1
        end
         print('here??')
        Dialog.SetAnswer(listmur_arena_dialog, 3, k, '�����', 2, 1)
      end
    end
    Dialog.Action()
  end,
  
  Reset =
  function()
    listmur_arena_dialog.state = 1
    listmur_arena_dialog.options[3] = nil
    listmur_arena_dialog.options[3] = {[0] = 'listmur_arena_bet_money';}
  end
}

-- �������� � ��������� �������
function ListmurKnightArenaTalk(hero, object)
  if listmur.knight_arena_talk == 0 then
    MessageBox(listmur.path..'knight_arena_start.txt')
    listmur.knight_fight_day = GetDate(DAY) + 3
    listmur.knight_arena_talk = 1
  elseif listmur.knight_arena_talk == 1 then
    Dialog.Open(listmur_arena_dialog, hero)
  elseif listmur.knight_arena_talk == 2 then
    MessageBox(rtext('�������� ����� ���, �?'))
  end
end

-- ������ ���
function ListmurKnightArenaPrefight()
  BlockGame()
  AbortAnimThread('l_a_k')
  MoveCamera(9, 6, GROUND, 60, math.pi/4, math.pi, 0, 0, 1)
  sleep(20)
  SetObjectRotation('kn_1', 238)
  SetObjectRotation('kn_2', 285)
  SetObjectRotation('kn_3', 325)
  SetObjectRotation('kn_4', 325)
  PlayAnims('l_a_k', {'idle00'}, COND_SINGLE)
  SetObjectRotation('ListmurCap', 13.5)
  sleep(5)
  ShowFlyingSign(rtext('������ �������� ������ ��������!'), 'ListmurCap', -1, 7.0)
  sleep(25)
  ShowFlyingSign(rtext('������� �� ���������, ����� ������� ������������ ���!'), 'ListmurCap', -1, 7.0)
  sleep(25)
  ShowFlyingSign(rtext('�������������� ���������� �������!'), 'ListmurCap', -1, 7.0)
  sleep(25)
  ShowFlyingSign(rtext('� � ������ ����� �����...'), 'ListmurCap', -1, 7.0)
  sleep(20)
  ShowFlyingSign(rtext('...������� �������...'), 'ListmurCap', -1, 7.0)
  sleep(20)
  ShowFlyingSign(rtext('...�������� ������� ��������...'), 'ListmurCap', -1, 7.0)
  sleep(20)
  ShowFlyingSign(rtext('...������������ ������� �� �������� �������!'), 'ListmurCap', -1, 7.0)
  sleep(7)
  PlayAnims('l_a_k', {'happy'}, COND_SINGLE)
  sleep(10)
  SetObjectPosition('kn_trist', 5.5, 6, GROUND)
  sleep(10)
  PlayObjectAnimation('kn_trist', 'specability', ONESHOT)
  PlayAnims('l_a_k', {'happy'}, COND_SINGLE)
  sleep(15)
  ShowFlyingSign(rtext('� ��� ���������...'), 'ListmurCap', -1, 7.0)
  sleep(20)
  ShowFlyingSign(rtext('...������� �������� �� �������...'), 'ListmurCap', -1, 7.0)
  sleep(20)
  ShowFlyingSign(rtext('...�� ���������� �����������...'), 'ListmurCap', -1, 7.0)
  sleep(20)
  ShowFlyingSign(rtext('...� ������ �� ����� ��������� ������������!'), 'ListmurCap', -1, 7.0)
  sleep(7)
  PlayAnims('l_a_k', {'happy'}, COND_SINGLE)
  sleep(10)
  SetObjectPosition('kn_ferab', 11, 6, GROUND)
  sleep(10)
  PlayObjectAnimation('kn_ferab', 'specability', ONESHOT)
  PlayAnims('l_a_k', {'happy'}, COND_SINGLE)
  sleep(15)
  ShowFlyingSign(rtext('���������� �������� � ������������ ���� �����...'), 'ListmurCap', -1, 7.0)
  sleep(15)
  SetObjectPosition('kn_ferab', 9, 6, GROUND)
  SetObjectPosition('kn_trist', 7.5, 6, GROUND)
  sleep(10)
  PlayObjectAnimation('kn_trist', 'specability', ONESHOT)
  PlayObjectAnimation('kn_ferab', 'specability', ONESHOT)
  sleep(20)
  ShowFlyingSign(rtext('� �� ������ ��������! � ���!'), 'ListmurCap', -1, 7.0)
  sleep(15)
  PlayAnims('l_a_k', {'happy'}, COND_SINGLE)
  ListmurKnightArenaFightMain()
end

-- ����������� ���������� � ����������� ������
function ListmurKnightArenaFightMain()
  ResetObjectQuestmark('ListmurCap')
  listmur.knight_arena_talk = 2
  local kn_names = {['kn_trist'] = '������� �� �������� �������', ['kn_ferab'] = '��������� ������������'}
  local fight_winner = ''
  local bet_winner = ''
  local bet_looser = ''
  -- ���� �������� ������ ���� - ���������� ������ ������, ��������������� ������
  if length(listmur.knight_arena_bets) == 1 then
    for hero, _ in listmur.knight_arena_bets do
      bet_looser = hero
    end
    fight_winner = listmur.knight_arena_bets[bet_looser].knight == 'kn_trist' and 'kn_ferab' or 'kn_trist'
    ListmurKnightArenaFightThread(fight_winner)
    RemoveObjects('kn_trist', 'kn_ferab')
    MessageBox(rtext(kn_names[fight_winner]..' ��������� � ���!\n\n'..GetNameAsString(bet_looser)..' ����������� ������!'))
  elseif length(listmur.knight_arena_bets) == 2 then
    -- ���� ��� ��������� �� ������ - ��� �����������
    if listmur.knight_arena_double_bet == 1 then
      for hero, info in listmur.knight_arena_bets do
        fight_winner = info.knight == 'kn_trist' and 'kn_ferab' or 'kn_trist'
        break
      end
      print('�����: ��� ��������� �� ������ �����')
    else
      -- �������, ���� ��������� �� ������, ���� �������������� ����������
      fight_winner = GetRandFrom('kn_trist', 'kn_ferab')
      print('�����: ��������� �����')
      for hero, info in listmur.knight_arena_bets do
        if fight_winner == info.knight then
          bet_winner = hero
        else
          bet_looser = hero
        end
      end
    end
    print('�������� ������: ', bet_winner)
    print('��������� ������: ', bet_looser)
    ListmurKnightArenaFightThread(fight_winner)
    RemoveObjects('kn_trist', 'kn_ferab')
    if listmur.knight_arena_double_bet == 1 then
      MessageBox(rtext(kn_names[fight_winner]..' ��������� � ���!\n\n ������ ����������� ������!\n\n ������ ����������� ������!'))
    else
      MessageBox(rtext(kn_names[fight_winner]..' ��������� � ���!\n\n'..GetNameAsString(bet_looser)..' ����������� ������!\n\n'..GetNameAsString(bet_winner)..' ���������� ������!'))
      local gold_to_add = listmur.knight_arena_bets[bet_winner].gold * 3
      SetPlayerResource(PLAYER_1, GOLD, GetPlayerResource(PLAYER_1, GOLD) + gold_to_add)
      ShowFlyingSign(rtext('+'..gold_to_add..' ������'), bet_winner, -1, 7.0)
    end
  else
    fight_winner = GetRandFrom('kn_trist', 'kn_ferab')
    ListmurKnightArenaFightThread(fight_winner)
    RemoveObjects('kn_trist', 'kn_ferab')
    MessageBox(rtext(kn_names[fight_winner]..' ��������� � ���!'))
  end
end

function ListmurKnightArenaFightThread(winner)
  local looser = winner == 'kn_ferab' and 'kn_trist' or 'kn_ferab'
  local cycle_counter = 6
  while cycle_counter > 0 do
    PlayObjectAnimation(looser, 'attack00', ONESHOT)
    sleep(6)
    PlayObjectAnimation(winner, 'hit', ONESHOT)
    sleep(13)
    winner, looser = looser, winner
    cycle_counter = cycle_counter - 1
  end
  sleep()
  PlayObjectAnimation(winner, 'attack00', ONESHOT)
  sleep(7)
  PlayObjectAnimation(looser, 'death', ONESHOT_STILL)
  sleep(15)
  PlayObjectAnimation(winner, 'happy', ONESHOT)
  sleep(15)
  UnblockGame()
end

--
--------------------------------------------------------------------------------
--

function ListmurMajorTalk(hero, object)
  if listmur.road_pact == 0 then
    if QuestionBox(rtext('��������� �������� ����� ������� ��� ���������� ������� ������� ����� �� 1000 �������.'..
                         ' ������ ����� ������ ����� 2 ���. ������� �������� ����������?')) then
      if HavePlayerRes(PLAYER_1, GOLD, 1000) then
        RemovePlayerRes(PLAYER_1, GOLD, 1000)
        MessageBox(rtext('������������� ����� 2 ��� � �������� ����������.'))
        listmur.road_pact = GetDate(DAY) + 1 -- 2
        ResetObjectQuestmark(object)
      else
        MessageBox(rtext('������������ ������ ��� �������!'))
      end
    end
  elseif listmur.road_pact == 1 then
    MessageBox(rtext('���������� ������� ������� ��������!'))
    UpdateQuest(main_quests.main, 1, hero)
    -- ������ � �����������
    StartQuest(listmur.find_caravan, hero)
    listmur.road_pact = -1
    SetObjectQuestmark(object, OBJ_IN_PROGRESS, 8)
  elseif listmur.road_pact == -1 then
    print('find caravan progress')
  end
end

function ListmurBarrTalk(hero, object)
  if listmur.barr_troops_bought < 4 then
    local msg = ' '
    local x = 0
    for creature, count in listmur.barr_troops[listmur.barr_troops_bought] do
      x = x + 1
      msg = msg..'\n'..'-'..count..' '..GetCreatureName(creature)
      if x == 1 then
        msg = msg..', '
      else
        msg = msg..')'
      end
    end
    local main_msg = '��������� ������� �� ��������� �������� �������� ������������ ��� � ������ ����� �� 5000 �������.'..
                     ' ������� �������� �� ������(�������������'..msg..'?'
    if QuestionBox(rtext(main_msg)) then
      if HavePlayerRes(PLAYER_1, GOLD, 5000) then
        RemovePlayerRes(PLAYER_1, GOLD, 5000)
        for creature, count in listmur.barr_troops[listmur.barr_troops_bought] do
          AddCreatures(hero, creature, count)
        end
        listmur.barr_troops_bought = 10
        ResetObjectQuestmark(object)
      else
        MessageBox(rtext('������������ ������!'))
      end
    end
  else
    ShowFlyingSign(rtext('������ ��� ������ ������...'), hero, -1, 6.0)
  end
end
  
function ListmurTavernTalk(hero, object)
  if listmur.tavern_troops_bought < 3 then
    local msg = ' '
    local l, k = length(listmur.tavern_troops), 0
    for creature, count in listmur.tavern_troops[listmur.tavern_troops_bought] do
      k = k + 1
      msg = msg..'\n -'..count..' '..GetCreatureName(creature)
      if k == l then
        msg = msg..')'
      else
        msg = msg..', '
      end
    end
    local main_msg = '� ������� ��� ������������ ����� ������, ������� ������ ����������� ��� � ������,'..
                     '�� ��� �������� �������� �� ����������(2500 ������). �� �������� ��� �������(�������������'..msg..'?'
    if QuestionBox(rtext(main_msg)) then
      if HavePlayerRes(PLAYER_1, GOLD, 2500) then
        RemovePlayerRes(PLAYER_1, GOLD, 2500)
        for creature, count in listmur.tavern_troops[listmur.tavern_troops_bought] do
          AddCreatures(hero, creature, count)
        end
        listmur.tavern_troops_bought = 10
        ResetObjectQuestmark(object)
      else
        MessageBox(rtext('������������ ������!'))
      end
    end
  else
    ShowFlyingSign(rtext('�� ����� ��� �������...'), hero, -1, 6.0)
  end
end

function ListmurArtTalk(hero, object)

end

--
--------------------------------------------------------------------------------
--