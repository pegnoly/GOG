--------------------------------------------------------------------------------
-- Мэйн - найти жезл

FindStaff =
{
  name = 'FIND_STAFF',
  path = q_path..'Prim/FindStaff/',
  
  p1_dwarves_talked = {},
  
  Init =
  function()
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'elmor_talk_2_reg', 'ElmorSecondTalk')
  end
}

--------------------------------------------------------------------------------
-- íà÷àëî - 2 ðàçãîâîð ñ Ýëìîðîì - êîãäà ïðîõîäèì åùå ÷àñòü ïóòè ïîñëå ïåðâîé âñòðå÷è

function ElmorSecondTalk(hero, region)
  -- StartDialogScene(DIALOG_SCENES.ELMOR_SECOND_TALK)
  print('mkeepers start info')
  StartQuest(FindStaff.name, hero)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'elmor_talk_2_reg', nil)
end
