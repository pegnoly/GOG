--------------------------------------------------------------------------------
-- ��������: WP
-- ������:   3
-- ��������: ��������� ���������
-- ������:   0.1 alpha
-- �����:    Gerter

--------------------------------------------------------------------------------
-- ����

q_path = m_path..'Quests/'
w_path = m_path..'Warnings/'
o_path = m_path..'Overrides/'

m_names_path = o_path..'MonsterNames/'
o_names_path = o_path..'ObjectNames/'

--
--------------------------------------------------------------------------------
-- ��������� ������� ��� ������ �����


doFile(m_path..'q_find_staff.lua')
doFile(m_path..'q_tavern_stranger.lua')
doFile(m_path..'mystery_keepers_quests.lua')
doFile(m_path..'golden_rivers_quests.lua')

--
--------------------------------------------------------------------------------
-- ��������� ������� ��� ������ �����
DECORATIVE_PLAYERS = {}

COMBAT_FUNCTIONS_PATHS =
{
	'/scripts/combat/KarlamSpec.lua',
	'/scripts/combat/tests.lua',
  '/scripts/combat/NoelliSpec.lua',
  '/scripts/combat/M3/WP_M3_Malgumol_fight.lua',
  '/scripts/combat/M3/WP_M3_DarkRunesFight.lua',
}

DIALOG_SCENES =
{
  KING_MEETING = '/DialogScenes/M3/KingMeeting/DialogScene.xdb#xpointer(/DialogScene)',
  ELMOR_AMBUSH = '/DialogScenes/M3/ElmorAmbush/DialogScene.xdb#xpointer(/DialogScene)',
  ELMOR_SECOND_TALK = '',
}

ARENAS        =
{
}

Q_NAMES       =
{
  ['ALIVE']           = '����� �� �������',
  ['MAIN_QUEST']      = '���������� ������',
  ['FIND_STAFF']      = '������� ����� �������',
  ['TAVERN_STRANGER'] = '���������� �������',
}

T_NAMES       =
{
}

--------------------------------------------------------------------------------
-- ������� ����������

--------------------------------------------------------------------------------
-- ��������� �������

--------------------------------------------------------------------------------
-- �������� �������
function Test()
  OpenCircleFog(0, 0, 0, 999, 1)
  OpenCircleFog(0, 0, 1, 999, 1)
  consoleCmd('enable_cheats')
  consoleCmd('setvar console_size = 10000')
end

function KarlamAlive()
  while IsHeroAlive(Karlam) do
    sleep()
  end
  Loose()
end

function NoelliAlive()
  while IsHeroAlive(Noelli) do
    sleep()
  end
  Loose()
end

--------------------------------------------------------------------------------
-- ������ �����
function StartMap()
  CreateCombatFunctionsList(COMBAT_FUNCTIONS_PATHS)
  --
  SetGameVar('mission', 3)
  SetGameVar('karlam_lvl', GetHeroLevel(Karlam))
  SetGameVar('karlam_soldier_luck', 0)
  startThread(FindStaff.Init)
  startThread(MKeepersQ.Init)
  startThread(GRiversQ.Init)
  startThread(ts_q.Init)
end

--SetAmbientLight(GROUND, 'WP_M3_Snow_test')
StartDialogScene(DIALOG_SCENES.KING_MEETING)
startThread(Test)
startThread(StartMap)
startThread(KarlamAlive)
startThread(NoelliAlive)