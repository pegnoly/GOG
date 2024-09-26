--
--------------------------------------------------------------------------------
--
q_path = m_path..'Quests/'
n_path = m_path..'Names/'
w_path = m_path..'Warnings/'
--
--------------------------------------------------------------------------------
--
doFile(m_path..'new_ideas_do_not_forget.lua')
doFile(m_path..'custom_ability.lua')
doFile(m_path..'enemy_heroes.lua')
doFile(m_path..'global_triggers.lua')
doFile(m_path..'main_quest.lua')
doFile(m_path..'map_areas.lua')
doFile(m_path..'q_plague.lua')
doFile(m_path..'q_tavern_stranger.lua')
doFile(m_path..'other_quests.lua')
doFile(m_path..'dialogs.lua')
doFile(m_path..'arena_of_heroes.lua')

DECORATIVE_PLAYERS = {}

combat_scripts_paths['karlam_spec'] = 	'/scripts/combat/KarlamSpec.lua'
combat_scripts_paths['tests'] = 	'/scripts/combat/tests.lua'
combat_scripts_paths['m4_other'] =   '/scripts/combat/M4/WP_M4_Other.lua'
combat_scripts_paths['arena_of_heroes'] =   '/scripts/combat/M4/WP_M4_Arena_of_heroes.lua'

DIALOG_SCENES =
{
  BLACK_HAND_INTRO = '/DialogScenes/M4/BlackHandIntro/DialogScene.xdb#xpointer(/DialogScene)',
  FINAL_SIEGE      = '/DialogScenes/M4/FinalSiege/DialogScene.xdb#xpointer(/DialogScene)',
  ALLENORA_ARRIVE  = '/DialogScenes/M4/AllenoraStart/DialogScene.xdb#xpointer(/DialogScene)',
}

ARENAS =
{
  NECRO_BARRIER = '/Arenas/CombatArena/M4/Barrier.(AdvMapTownCombat).xdb#xpointer(/AdvMapTownCombat)',
}

Q_NAMES =
{
  ['PLAGUE']          = 'Чума',
  ['TAVERN_STRANGER'] = 'Огненное таинство',
  ['ALLIANCE']        = 'Новый старый альянс',
  ['KILL_BLACK_HAND'] = 'Сила не в тех руках',
  ['VARIS_QUEST']     = 'Àòàêà ñ âîçäóõà'
}

T_NAMES =
{
  ['Raintemple']  = 'Ðåéíòåìïë',
  ['Carn']        = 'Êàðí',
  ['Castlecross'] = 'Êàñòëêðîññ',
  ['Freymia']     = 'Ôðåéìèÿ',
  ['Crianna']     = 'Êðèàííà-Óëèàð',
  ['Lernur']      = 'Ëåðíóð',
  ['IlshamAggar'] = 'Èëüøàì-Àããàð'
}

COMBAT_LIGHTS =
{
  ['WP_M4_Foggy_morning']      = '/Lights/_(AmbientLight)/M4/WP_M4_Foggy_morning.(AmbientLight).xdb#xpointer(/AmbientLight)',
  ['WP_M4_Foggy_morning_Rain'] = '/Lights/_(AmbientLight)/M4/WP_M4_Foggy_morning_Rain.(AmbientLight).xdb#xpointer(/AmbientLight)',
  ['WP_M4_Grey_day']           = '/Lights/_(AmbientLight)/M4/WP_M4_Grey_day.(AmbientLight).xdb#xpointer(/AmbientLight)',
  ['WP_M4_Grey_day_Rain']      = '/Lights/_(AmbientLight)/M4/WP_M4_Grey_day_Rain.(AmbientLight).xdb#xpointer(/AmbientLight)',
  ['WP_M4_Dark_night']         = '/Lights/_(AmbientLight)/M4/WP_M4_Dark_night.(AmbientLight).xdb#xpointer(/AmbientLight)',
  ['WP_M4_Dark_night_Rain']    = '/Lights/_(AmbientLight)/M4/WP_M4_Dark_night_Rain.(AmbientLight).xdb#xpointer(/AmbientLight)',
  UGROUND                      = '/Lights/_(AmbientLight)/Scenes/dungeon (3) (4).xdb#xpointer(/AmbientLight)',
  CURRENT                      = '/Lights/_(AmbientLight)/M4/WP_M4_Foggy_morning.(AmbientLight).xdb#xpointer(/AmbientLight)',
}

do
 local oldMessageBox = MessageBox
 function MessageBox(msg, callback)
   msg_box_answer = -1
   %oldMessageBox(msg, 'MsgBoxCallback')
   return msg_box_answer == 1
 end
 
 function MsgBoxCallback()
   msg_box_answer = 1
 end
end

if MessageBox(m_path..'name.txt') then
   print('oksadasd')
end

function Test()
  SetAmbientLight(GROUND, 'WP_M4_Foggy_morning')
  consoleCmd('enable_cheats')
  consoleCmd('setvar console_size = 10000')
  OpenCircleFog(0, 0, 0, 999, 1)
  OpenCircleFog(0, 0, 1, 999, 1)
  --SetGameVar('test', 'spec_test')
  --TestVillages()
  AddHeroCreatures('Noellie', CREATURE_BLOOD_WITCH, 300)
  --startThread(Player2RespawnThread)
end

function StartMap()
  PlayObjectAnimation('ig_gates', 'open', ONESHOT_STILL)
  Player2SortHeroes()
  startThread(MainInit)
  startThread(varis_q.Init)
  startThread(InitVillages)
  startThread(NecroTownsSiegeThread)
  SetCombatLight(COMBAT_LIGHTS.CURRENT)
  PlayFX('Necro_wall', 'IlshamAggar', 'necro_wall', 33, 0, 0, 90)
  --InitThisMapAnimGroups()
  InitNegGarrison('WP_M4_neg_garrison')
  startThread(SetupNecroTowns)
  --
  SetGameVar('mission', 4)
  --
  SetGameVar('karlam_lvl', GetHeroLevel('Karlam'))
  SetGameVar('karlam_soldier_luck', 0)
  --
  SetGameVar('noe_spec_witches_count', 10)
  SetGameVar('noe_spec_current_kills', 0)
  SetGameVar('noe_spec_current_up', 0)
  SetGameVar('noe_spec_kills_to_up', 10)
  --
  SetGameVar('fire_ring', 0)
  SetGameVar('fire_power', 0)
  SetGameVar('combat_mode', 'quick_combat')
  --SetGameVar('necro_barrier_fight', 'off')
  SetGameVar('enchanted_catapult', 0)
  --
  SetRegionBlocked('river_block1', 1, PLAYER_2)
  SetRegionBlocked('river_block2', 1, PLAYER_2)
end

startThread(StartMap)
startThread(Test)

StartDialogScene(DIALOG_SCENES.ALLENORA_ARRIVE)
-- StartDialogScene(DIALOG_SCENES.FINAL_SIEGE)

Touch.DisableObject('neg')
Touch.SetFunction('neg', '_neg_dialog',
function(hero, object)
  Dialog.Open(neg_dialog, hero)
  Dialog.Action()
end)