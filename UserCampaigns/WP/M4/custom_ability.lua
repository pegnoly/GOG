--------------------------------------------------------------------------------
-- обработка разговоров с Баалом в 4 миссии.
-- Актуально на 08.06.2019

function BaalDialogPerform(curr_state, answer, next_state)
  local return_state = next_state
  --
  if curr_state == 13 then
    UpdateQuest(ts_q.name, 3, Karlam)
    Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'lava_cavern_start', 'TS_LavaCavernMoveHandlerInit')
    TS_CheckDialogStartWhenHeroAlreadyInCavern()
  end
  -- перемещение по лавовой реке
  if next_state == -1 then
    if curr_state == 21 then
      if answer == 1 then
        TS_MoveToPoint(1)
        return_state = 22
      end
    else
      local current_point = TS_GetCurrentPoint()
      if curr_state == 22 then
        if answer == 1 then
          TS_MoveToPoint(current_point + 1)
          if current_point == 7 or current_point == 11 then
            return_state = 24
          else
            return_state = current_point == 3 and 23 or 22
          end
        elseif answer == 2 then
          if current_point == 9 then
            TS_MoveToPoint(4)
          else
            if current_point == 1 then
              BlockGame()
              SetObjectPosition('Karlam', 101, 151, 1)
              sleep(15)
              UnblockGame()
              return_state = 21
            else
              TS_MoveToPoint(current_point - 1)
            end
          end
        end
      elseif curr_state == 23 then
        if answer == 1 then
          TS_MoveToPoint(9)
        elseif answer == 2 then
          TS_MoveToPoint(5)
        else
          TS_MoveToPoint(3)
        end
        return_state = 22
      elseif curr_state == 24 then
        TS_MoveToPoint(current_point - 1)
        return_state = 22
      end
    end
  end
  return return_state
end
      

baal_dialog =
{
  path = m_path..'Custom/BaalDialog/',
  state = 1,
  --icon = GetIcon(Baal),
  perform_func = BaalDialogPerform,
  title = 'title_01',
  select_text = 'select_01',
  options =
  {
   [1] = {[0] = 'no_talk'; {'Выход', 0, 1}},
   -----------------------------------------------------------------------------
   [11] = {[0] = 'no_talk';            {'Поговорить о проходе по лавовой реке', 12, 1},      {'Выход', 0, 1}},
   [12] = {[0] = 'lava_river_talk_01'; {'Потребовать сделать свою кожу огнеупорной', 13, 1}, {'Выход', 0, 1}},
   [13] = {[0] = 'lava_river_talk_02'; {'Хорошо...', 1, 1}},
   -----------------------------------------------------------------------------
   [21] = {[0] = 'lava_move_start';    {'Вперед', -1, 1}},
   [22] = {[0] = 'lava_move';          {'Вперед', -1, 1}, {'Назад', -1, 1}},
   [23] = {[0] = 'lava_road_fork';     {'Направо', -1, 1}, {'Налево', -1, 1}, {'Назад', -1, 1}},
   [24] = {[0] = 'lava_move';          {'Назад', -1, 1}},
  },
  Open =
  function()
    Dialog.Action()
  end
}