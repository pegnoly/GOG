--------------------------------------------------------------------------------
-- WP.M5: Битва между небом и землей v. 0.01 -----------------------------------
-- by Gerter(owafe001@gmail.com; pegn0ly#9113) ---------------------------------
--------------------------------------------------------------------------------

q_path = m_path..'Quests/'
w_path = m_path..'Warnings/'
o_path = m_path..'Overrides/'
sleep(2)

--
--------------------------------------------------------------------------------
--

value = 123

--test_dialog =
--{
--  state = 1,
--  path = m_path.."scripts/test/",
--  icon = "/UI/MessageBox/Warning.xdb#xpointer(/Texture)",
--  title = " ",
--  select_text = " ",
--  perform_func =
--  function(player, curr_state, answer, next_state)
--    return 0
--  end,
--  --
--  options = {[1] = {[0] = {m_path.."scripts/test/test_big.txt"; test = value}; {m_path.."scripts/test/OK.txt", 1, 1}}},
--  --
--  Reset =
--  function(player)
--  end,
--  Open =
--  function(player)
--  end,
--  Action =
--  function(player)
--  end
--}
--
--Dialog.NewDialog(test_dialog, GetPlayerHeroes(PLAYER_1)[0], PLAYER_1)
--Dialog.Action(PLAYER_1)

TalkBoxForPlayers(GetPlayerFilter(PLAYER_1),
                  "/UI/MessageBox/Warning.xdb#xpointer(/Texture)", "",
                  {m_path.."scripts/test/test_big.txt"; test = value},
                  "", nil, 1, "", "", 0, m_path.."scripts/test/OK.txt")

doFile(m_path..'enemy_heroes.lua')