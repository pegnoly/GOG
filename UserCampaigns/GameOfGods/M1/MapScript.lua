q_path = m_path..'Quests/'
w_path = m_path..'Warnings/'
o_path = m_path..'Overrides/'

doFile(m_path..'global_triggers.lua')
doFile(m_path..'main_quests.lua')
doFile(m_path..'other_quests.lua')
doFile(m_path..'sides_of_asha.lua')
doFile(m_path..'q_diversion.lua')
doFile(m_path..'dialogs.lua')

DECORATIVE_PLAYERS = {PLAYER_5}
ANIM_GROUP_DEAD_COUNT = 39

COMBAT_FUNCTIONS_PATHS =
{
	'/scripts/combat/KarlamSpec.lua',
	'/scripts/combat/tests.lua',
}

DIALOG_SCENES =
{
  START            = '/DialogScenes/M2/FacelessIntro/DialogScene.xdb#xpointer(/DialogScene)',
  FIRST_ELMOR_TALK = '/DialogScenes/M2/FirstElmorTalk/DialogScene.xdb#xpointer(/DialogScene)',
}

ARENAS = {}

Q_NAMES =
{
  ['ASHA_SIDES'] = 'Восемь аспектов',
  ['MAIN_QUEST'] = 'Чужая страна',
  ['FIND_CARAVAN'] = 'Потерявшиеся во льдах',
  ['GENERATORS'] = 'Энергетический кризис',
  ['FIND_GATES'] = 'Координаты вторжения',
  ['ALIVE'] = 'Герои не умирают',
  ['DIVERSION'] = 'Диверсия'
}

T_NAMES =
{
  ['bastion_town_1'] = 'Твердыня1',
  ['academy_town_1'] = 'Академия1'
}

function InitThisMapAnimGroups()
  local deads = {}
  for i = 1, ANIM_GROUP_DEAD_COUNT do
    deads[i] = 'dead'..i
  end
  --
  for i, obj in deads do
    Touch.DisableMonster(obj, DISABLED_BLOCKED, 0)
  end
  --
  AnimGroup['dead'] = {actors = deads}
end

function PlayThisMapAnimGroups()
  PlayAnims('dead', {'death'}, COND_SINGLE, ONESHOT_STILL)
end

function Test()
  StartDialogScene(DIALOG_SCENES.FIRST_ELMOR_TALK)
  consoleCmd('setvar console_size = 10000')
  OpenCircleFog(0, 0, 0, 999, 1)
  OpenCircleFog(0, 0, 1, 999, 1)
  consoleCmd('enable_cheats')
  SetPlayerStartResources(1, 1000, 1000, 1000, 1000, 1000, 1000, 100000)
  --SetAmbientLight(GROUND, 'WP_M2_Foggy_day')
end

function StartMap()
  while not CreateCombatFunctionsList do
    sleep()
  end
  CreateCombatFunctionsList(COMBAT_FUNCTIONS_PATHS)
  DoNotGiveTurnToPlayerAIIfNoTownsAndActiveHeroes(PLAYER_5, 1)
  InitThisMapAnimGroups()
  startThread(main_quests.Init)
  startThread(ListmurInit)
  startThread(diversion.Init)
  for i = 1, 3 do
    startThread(GatesFxThread)
  end
  SetGameVar('mission', 2)
  --
  SetGameVar('karlam_lvl', GetHeroLevel('Karlam'))
  SetGameVar('karlam_soldier_luck', 0)
  --
  SetGameVar('noe_spec_witches_count', 10)
  SetGameVar('noe_spec_current_kills', 0)
  SetGameVar('noe_spec_current_up', 0)
  SetGameVar('noe_spec_kills_to_up', 10)
  --
  InitNegGarrison('WP_M2_neg_garrison')
end

startThread(Test)
startThread(StartMap)
StartDialogScene(DIALOG_SCENES.START)

SetObjectEnabled('neg', nil)
Touch.SetFunction('neg', '_neg_dialog',
function(hero, object)
  Dialog.Open(neg_dialog, hero)
  Dialog.Action()
end)