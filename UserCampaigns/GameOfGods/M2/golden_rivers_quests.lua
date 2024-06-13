--------------------------------------------------------------------------------
-- локальные квесты клана Золотых Рек

GRiversQ =
{
  rep = 'GOLDEN_RIVERS_REP',
  
  Init =
  function()
    Touch.DisableObject('gr_tavern')
    --
    while not TS_Start do
      sleep()
    end
    Touch.SetFunction('gr_tavern', '_ts_q', TS_Start)
  end
}