
sl_quests =
{
  Init =
  function()
    Touch.DisableMonster('sl_main_test')
    Touch.SetFunction('sl_main_test', '_talk', SL_MainTalk)
    --
    EnableHeroAI('SL_Mother', nil)
    EnableHeroAI('SL_Father', nil)
  end
}

function SL_MainTalk(hero, object)
  --
  SetObjectOwner('SL_Mother', PLAYER_1)
  SetObjectOwner('SL_Father', PLAYER_1)
  startThread(
  function()
    sleep()
    while GetObjectOwner('SL_Father') == PLAYER_1 do
      ChangeHeroStat('SL_Father', STAT_MOVE_POINTS, -9999)
      ChangeHeroStat('SL_Mother', STAT_MOVE_POINTS, -9999)
      sleep(10)
    end
  end)
  --
end