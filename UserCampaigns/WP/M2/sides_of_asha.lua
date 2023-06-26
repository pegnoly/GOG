sides_of_asha =
{
  name = 'ASHA_SIDES',
  path = q_path..'AshaSides/',
}

--
--------------------------------------------------------------------------------
-- начало - храм в Листмуре

function ListmurTempleTalk(hero, object)
  if IsUnknown(sides_of_asha.name) then
    StartMiniDialog(q_path..'AshaSides/ListmurTempleDialog/', 1, 17, m_dialog_sets['l_t_d'])
    StartQuest(sides_of_asha.name, hero)
    ResetObjectQuestmark(object)
  end
end