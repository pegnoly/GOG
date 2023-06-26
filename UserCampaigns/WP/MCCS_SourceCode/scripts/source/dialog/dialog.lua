Dialog = {}
-- ������� ������
Dialog.active_dialog_for_player = {}
Dialog.active_hero_for_player = {[PLAYER_1] = '', [PLAYER_2] = '', [PLAYER_3] = '', [PLAYER_4] = '', [PLAYER_5] = '', [PLAYER_6] = '', [PLAYER_7] = '', [PLAYER_8] = ''}
-- �������������� ������������ �����
answer_for_player = {[PLAYER_1] = 6, [PLAYER_2] = 6, [PLAYER_3] = 6, [PLAYER_4] = 6, [PLAYER_5] = 6, [PLAYER_6] = 6, [PLAYER_7] = 6, [PLAYER_8] = 6}

Dialog.NewDialog =
function(dialog, hero, player)
  local new_dialog = {}
  for k, v in dialog do
    new_dialog[k] = v
  end
  Dialog.Open(new_dialog, hero, player)
end

Dialog.GetActiveDialogForPlayer =
function(player)
  local answer = Dialog.active_dialog_for_player[player]
  return answer
end

Dialog.GetActiveHeroForPlayer =
function(player)
  local answer = Dialog.active_hero_for_player[player]
  return answer
end

-- �������� �������
Dialog.Open =
function(dialog, hero, player)
  Dialog.active_dialog_for_player[player] = dialog
  Dialog.active_hero_for_player[player] = hero
  Dialog.active_dialog_for_player[player].Open(player)
  --print(hero, ' in Open()')
end

-- ����� � ��������� �����������
Dialog.Action =
function(player)
  -- �������� ��������� ����� ���������� ����������
  local state = Dialog.GetActiveDialogForPlayer(player).state -- ��������� �������� �������
  local path = Dialog.GetActiveDialogForPlayer(player).path -- ����
  local icon = Dialog.GetActiveDialogForPlayer(player).icon -- ��� ������
  local perform_func = Dialog.GetActiveDialogForPlayer(player).perform_func -- �������, ����������� �� ��������� ��� ���������
  local title = Dialog.GetActiveDialogForPlayer(player).title -- ���������
  local select = Dialog.GetActiveDialogForPlayer(player).select_text -- ������ ������
  local curr_options = Dialog.GetActiveDialogForPlayer(player).options -- ����� - �������� ����� � ������

  -- ��������� ������� �������
  local options = {nil, nil, nil, nil, nil} -- ���������� ��� ������ ������
  -- ���������� ������ � ������� �����, ��������� � ������� ���������� �������
  -- [0] - ������ �����, [1][1] - [5][1] - ������ ������
  local ans_num = 0
  for i = 1, length(curr_options[state]) - 1 do
    if curr_options[state][i] and curr_options[state][i][3] == 1 then
      local msg = curr_options[state][i][1]
      ans_num = ans_num + 1
      if curr_options[state][i][4] then -- ��������, ��� ���� ���������
        options[ans_num] = msg
      else
        options[ans_num] = path..msg
      end
      print('<color=red>Dialog: <color=green>option: ', ans_num, ', msg: ', options[ans_num])
    end
  end
  print('<color=red>Dialog: <color=green>icon is ', icon)
  print('<color=red>Dialog: <color=green>main text is ', path..curr_options[state][0])
  Dialog.answer_for_player[player] = 6
  -- �������
  while not GetCurrentPlayer() == player do
    sleep()
  end
  TalkBoxForPlayers(player, icon, nil,
                   path..curr_options[state][0], nil,
                   'Dialog.Callback', 1,
                   path..title..'.txt',
                   path..select..'.txt', 0,
                   options[1],
                   options[2],
                   options[3],
                   options[4],
                   options[5])
  -- ���� ����� ������
  while Dialog.answer_for_player[player] == 6 do
    sleep()
  end
  local ans = Dialog.answer_for_player[player]
  local next_state
  -- ����� ����� ������� - ���������� ���������, ��� ������� ��������� ������
  if ans < 1 then
    next_state = 0
  else -- ����� �������� ��������� ���������
    local check = 0
    for i = 1, 5 do -- ���������� ������ �����, �������� ������ ���������� �����
      if curr_options[state][i] and curr_options[state][i][3] == 1 then
        check = check + 1
        if check == ans then
          next_state = curr_options[state][i][2]
          ans = i
        end
      end
    end
  end
  -- �������� ���������� ��������� � �������, ������� ��� - ���� ������ � ����������� �� ����
  -- ���� ������ �� ������ - ��� ������� �� ����������� � ������� �������
  next_state = perform_func(player, state, ans, next_state)
  print("next state is ", next_state)
  -- 0 - ������ ��������� ������
  if next_state == 0 then
    return
  else
    -- ���� ������ � ���������������� ���������
    -- ������������� ��� ��� �������� �������
    -- ������������� �� �������������(� ������� ������������ perform_func ��� �������� ������)
    if next_state > 0 then
      Dialog.GetActiveDialogForPlayer(player).state = next_state
    end
    -- ������� � ������������ � ����� ����������
    Dialog.Action(player)
  end
end

Dialog.SetState =
function(dialog, new_state)
  dialog.state = new_state
end

Dialog.SetText =
function(dialog, state, text)
  dialog.options[state][0] = text
end

Dialog.SetSelectText =
function(text, dialog)
  dialog = dialog or Dialog.current_dialog
  dialog.select_text = text
end

Dialog.SetAnswer =
function(dialog, state, option, answer, next_state, is_enabled, is_custom_path)
  is_enabled = is_enabled or 1
  is_custom_path = is_custom_path or nil
  dialog.options[state][option] = {answer, next_state, is_enabled, is_custom_path}
end

Dialog.SetPredefAnswer =
function(dialog, state, option, predef_answer)
  dialog.options[state][option] = {predef_answer[1], predef_answer[2], predef_answer[3]}
end

Dialog.DisableAnswer =
function(dialog, state, option)
  dialog.options[state][option][3] = 0
end

Dialog.EnableAnswer =
function(dialog, state, option)
  dialog.options[state][option][3] = 1
end

Dialog.IsAnswerEnabled =
function(dialog, state, option)
  local answer = dialog.options[state][option] == 1
  return answer
end

Dialog.Callback =
function(player, answer)
  Dialog.answer_for_player[player] = answer
end

Dialog.Reset =
function(player)
  Dialog.GetActiveDialogForPlayer(player).Reset(player)
end