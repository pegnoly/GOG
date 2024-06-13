function NewDay()
  local day, dow, month = GetDate(DAY), GetDate(DAY_OF_WEEK), GetDate(MONTH)
  if day == listmur.knight_fight_day then
    ListmurKnightArenaPrefight()
  end
  if day == listmur.road_pact then
    listmur.road_pact = 1
    MessageBox(rtext('¬аша подорожна€ готова, заберите ее в магистрате.'))
    SetObjectQuestmark('listmur_major', NO_OBJ_MARK, 8)
  end
end

Trigger(NEW_DAY_TRIGGER, 'NewDay')