-------------------------������ ���� by Gerter----------------------------------
--------------------------owafe001@gmail.com------------------------------------

--------------------------------------------------------------------------------
-- ��������� ���� � ������ ������ ����, ������� ������ ������ ��������

-- mPath = GetMapDataPath()
-- qPath = mPath..'Quests/'
-- wPath = mPath..'Warnings/'
-- oPath = mPath..'Overrides/'

-- -- ����������
-- doFile('lualib.lua')
-- doFile('global.lua')
-- doFile('touch.lua')
-- doFile('qBase.lua')
-- doFile('advMapFX.lua')
-- doFile('common_funcs.lua')

-- doFile(mPath..'main_quest.lua')
-- doFile(mPath..'karlamQuests.lua')
-- doFile(mPath..'moriton.lua')
-- doFile(mPath..'global_triggers.lua')

-- SetHeroCombatScript('Karlam', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Baal', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Karlam_copy', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Baal_copy', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Greta', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('ainur', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Gilva', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Orris', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Klem', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Mordrakar', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Inagost', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Keeper', '/BaseCombatScript.xdb#xpointer(/Script)')
-- SetHeroCombatScript('Linaas', '/BaseCombatScript.xdb#xpointer(/Script)')

-- SetGameVar('svetoch', 0) -- ������� �������
-- SetGameVar('sandro_cape', 0) -- ������� ����� ������
-- SetGameVar('greta_coef', 0) -- ������� �����
-- SetGameVar('karlam_coef', 0) -- ����������� �������

-- SetRegionBlocked('crystal1', not nil, PLAYER_2) -- ��������� ��� �����(���� ����������� ������ �� ���� ������ ��������)
-- SetRegionBlocked('crystal2', not nil, PLAYER_2)
-- SetRegionBlocked('crystal3', not nil, PLAYER_2)
-- SetRegionBlocked('townBlock1', not nil, PLAYER_2) -- ���������� �������� ��� ��(� �������� ��� ������)
-- SetRegionBlocked('townBlock2', not nil, PLAYER_2)
-- SetRegionBlocked('townBlock3', not nil, PLAYER_2)
-- SetRegionBlocked('townBlock4', not nil, PLAYER_2)
-- SetRegionBlocked('undeadAttack', not nil)
-- SetRegionBlocked('cemeteryBlock', not nil, PLAYER_1)
-- SetRegionBlocked('ai_block1', not nil, PLAYER_2) -- ����� �� ����� ���������� ������� ��������, ����� ���������

-- -- ��������� ����� ��� �����
-- SetRegionBlocked('portalBlock2', not nil, PLAYER_2)
-- SetRegionBlocked('portalBlock1', not nil, PLAYER_2)
-- for i = 1, 6 do
--   SetRegionBlocked('bblock'..i, not nil, PLAYER_2)
-- end

-- -- ��������� ��������...
-- OverrideObjectTooltipNameAndDescription('enter_artTown', oPath..'Art_name.txt', oPath..'Art_desc.txt')
-- OverrideObjectTooltipNameAndDescription('war_lord', oPath..'ranger_name.txt', oPath..'ranger_desc.txt')
-- OverrideObjectTooltipNameAndDescription('witch2', oPath..'witch2_name.txt', oPath..'witch2_desc.txt')
-- OverrideObjectTooltipNameAndDescription('baal_point', oPath..'crypt_name.txt', oPath..'crypt_desc.txt')
-- OverrideObjectTooltipNameAndDescription('mageTower', oPath..'mageTower_name.txt', oPath..'mageTower_desc.txt')
-- OverrideObjectTooltipNameAndDescription('tavern1', oPath..'tavern_name.txt', oPath..'tavern_desc.txt')
-- OverrideObjectTooltipNameAndDescription('libraryTui', oPath..'lib_name.txt', oPath..'lib_desc.txt')
-- OverrideObjectTooltipNameAndDescription('qAstro', oPath..'astro_desc.txt', oPath..'astro_name.txt')

-- -- �������� ������
-- DIALOG_SCENES =
-- {
--   START = '/DialogScenes/HON/hn_StartScene/DialogScene.xdb#xpointer(/DialogScene)',
--   BAAL_SPAWN = '/DialogScenes/HON/hn_BaalResScene/DialogScene.xdb#xpointer(/DialogScene)',
--   MORITON_ENTER = '/DialogScenes/HON/hn_EnterMoritonScene/DialogScene.xdb#xpointer(/DialogScene)',
--   CREATE_SVET = '/DialogScenes/HON/hn_createSvetScene/DialogScene.xdb#xpointer(/DialogScene)',
--   BAAL_FIGHT = '/DialogScenes/HON/hn_BaalFightScene/DialogScene.xdb#xpointer(/DialogScene)',
--   MIND_CONTROL = '/DialogScenes/HON/hn_MindControlScene/DialogScene.xdb#xpointer(/DialogScene)',
--   FINAL = '/DialogScenes/HON/hn_FinalScene/DialogScene.xdb#xpointer(/DialogScene)',
--   TURGAL = '/DialogScenes/HON/hn_TurgalRitualScene/DialogScene.xdb#xpointer(/DialogScene)',
--   TURGAL2 = '/DialogScenes/HON/hn_TurgalRitualScene2/DialogScene.xdb#xpointer(/DialogScene)'
-- }

-- -- �������� ��������� ������
-- ARENAS =
-- {
--   -- KEEPER_ARENA = '/Scenes/CombatArenas/heartofnight/keeperArena.xdb#xpointer(/AdventureFlybyScene)',
--   MIND_FIGHT = '/Scenes/CombatArenas/heartofnight/mindBattleArena.(AdventureFlybyScene).xdb#xpointer(/AdventureFlybyScene)'
-- }

-- -- ��������� ��� ������ ����
-- COMBAT_LIGHTS =
-- {
--   MORNING = '/Lights/_(AmbientLight)/Town/Day_light_Haven01(VicTest).xdb#xpointer(/AmbientLight)',
--   DAY = '/Lights/_(AmbientLight)/Town/Day_light_Haven01(PanovTest).xdb#xpointer(/AmbientLight)',
--   NIGHT = '/Lights/_(AmbientLight)/AdvMap/Addon/A1SM3.xdb#xpointer(/AmbientLight)',
--   UGROUND = '/Lights/_(AmbientLight)/Scenes/dungeon (3) (4).xdb#xpointer(/AmbientLight)',
--   FINAL = '/Lights/_(AmbientLight)/Scenes/Taiga_Forest_Fog.xdb#xpointer(/AmbientLight)',
--   CURRENT = ' '
-- }

-- -- ���������� - ��������� ����� �������(��. qBase)
-- Q_NAMES =
-- {
--   ['INTRO_QUEST'] = '������ � ��������',
--   ['KILL_BAAL'] = '������ �����',
--   ['STAY_ALIVE'] = '����� �� �������',
--   ['ASHA_TEAR'] = '������������ �������',
--   ['PHOENIX'] = '�������� �����',
--   ['ETERNAL_NIGHT'] = '����������� ����',
--   ['FINAL_QUEST'] = '����� �������',
--   ['TAVERN_QUEST1'] = '�������� ��������',
--   ['TAVERN_QUEST2'] = '���� � �����',
--   ['MAGE_QUEST'] = '��������� ���',
--   ['SECRET_PATH'] = '������ �����',
--   ['DRAGON_QUEST'] = '��������� �������',
--   ['ASTRO_QUEST'] = '������ ������������',
--   ['MAID_QUEST'] = '�������� ���������',
--   ['DEFEND_TOWN'] = '����� �����',
--   ['UNDEAD_ATTACK'] = '����� ���������',
--   ['UNDERGROUND_PATH'] = '���� ��� �����',
--   ['KILL_KLEM'] = '���������� �����',
--   ['WITCH_QUEST'] = '����� �������'
-- }

-- -- �������� � ������ ������ ���������� � ������ ���������� ������
-- function UpdateCombatStats()
--   while 1 do
--     if HasArtefact('Karlam', ARTIFACT_SHAWL_OF_GREAT_LICH, 1) then
--       SetGameVar('sandro_cape', 1)
--     else
--       SetGameVar('sandro_cape', 0)
--     end
--     if HasArtefact('Karlam', ARTIFACT_PRINCESS, 1) then
--       SetGameVar('svetoch', 1)
--     else
--       SetGameVar('svetoch', 0)
--     end
--     if HasHeroSkill('Karlam', PERK_LUCKY_STRIKE) then
--       SetGameVar('karlam_soldier_luck', 1)
--     else
--       SetGameVar('karlam_soldier_luck', 0)
--     end
--     SetGameVar('greta_coef', GetHeroLevel('Greta'))
--     SetGameVar('karlam_coef', GetHeroLevel('Karlam'))
--     sleep()
--   end
-- end

-- -- ����� ����� ������� ������ � 3 ������, ����� �� ��� �������
-- function RemovePlayer3Gold()
--   while GetObjectOwner('Moriton') == PLAYER_3 do
--     local gold = GetPlayerResource(PLAYER_3, 6)
--     if gold > 0 then
--       -- print(gold, ' gold removed')
--       SetPlayerResource(PLAYER_3, 6, 0)
--     end
--     sleep()
--   end
-- end

-- -- ���������� ��������� ��������� ������, ������� ��� �����
-- function SetupHeroes()
--   EnableHeroAI('Baal', nil)
--   -- EnableHeroAI('Baal_copy', nil)
--   -- EnableHeroAI('Karlam_copy', nil)
--   EnableHeroAI('Greta', nil)
--   EnableHeroAI('Inagost', nil)
--   -- EnableHeroAI('Keeper', nil)
  
--   SetHeroLootable('Baal', nil)
--   SetHeroLootable('Inagost', nil)
--   SetHeroLootable('Greta', nil)
--   SetHeroLootable('Keeper', nil)
  
--   AddHeroCreatures('Karlam', CREATURE_GREMLIN_SABOTEUR, 74 + random(5))
--   AddHeroCreatures('Karlam', CREATURE_OBSIDIAN_GARGOYLE, 18 + random(3))
--   AddHeroCreatures('Karlam', CREATURE_IRON_GOLEM, 12 + random(4))

--   AddHeroCreatures('Greta', CREATURE_DRYAD, 80)
--   AddHeroCreatures('Greta', CREATURE_WAR_DANCER, 55)
--   AddHeroCreatures('Greta', CREATURE_GRAND_ELF, 42)
--   AddHeroCreatures('Greta', CREATURE_HIGH_DRUID, 17)
--   AddHeroCreatures('Greta', CREATURE_WHITE_UNICORN, 6)

--   AddHeroCreatures('Inagost', CREATURE_STALKER, 97 + 37 * diff + random(8))
--   AddHeroCreatures('Inagost', CREATURE_BLOOD_WITCH_2, 72 + 29 * diff + random(7))
--   AddHeroCreatures('Inagost', CREATURE_BLADE_SINGER, 75 + 43 * diff + random(6))
--   AddHeroCreatures('Inagost', CREATURE_BLACK_RIDER, 29 + 15 * diff + random(5))
--   AddHeroCreatures('Inagost', CREATURE_CHAOS_HYDRA, 25 + 10 * DIFF + random(4))
--   AddHeroCreatures('Inagost', CREATURE_MATRIARCH, 9 + 5 * diff + random(3))
--   AddHeroCreatures('Inagost', CREATURE_BLACK_DRAGON, 2 + 2 * diff + random(2))
--   ChangeHeroStat('Inagost', 0, LEVELS[25 + diff])
  
--   AddHeroCreatures('Baal', CREATURE_IMP, 750 + 75 * diff + random(8))
--   AddHeroCreatures('Baal', CREATURE_HORNED_LEAPER, 475 + 40 * diff + random(7))
--   AddHeroCreatures('Baal', CREATURE_FIREBREATHER_HOUND, 300 + 25 * diff + random(6))
--   AddHeroCreatures('Baal', CREATURE_SUCCUBUS_SEDUCER, 92 + 12 * diff + random(5))
--   AddHeroCreatures('Baal', CREATURE_HELLMARE, 48 + 8 * diff + random(4))
--   AddHeroCreatures('Baal', CREATURE_PIT_SPAWN, 25 + 4 * diff + random(3))
--   AddHeroCreatures('Baal', CREATURE_ARCHDEVIL, 17 + 2 * diff + random(3))
--   WarpHeroExp('Baal', LEVELS[40])
-- end

-- function KarlamAlive()
--   while IsHeroAlive('Karlam') do sleep(10) end
--   Loose()
-- end

-- --
-- --------------------------------------------------------------------------------
-- -- �������� �������
-- --
-- unlim_move = 1

-- function KarlamTest()
--   OpenCircleFog(33, 27, 0, 9999, 1)
--   OpenCircleFog(33, 27, 1, 9999, 1)
--   consoleCmd('enable_cheats')
--   consoleCmd('add_army 3 2 1000')
--   WarpHeroExp('Karlam', LEVELS[25])
--   startThread(
--    function()
--      while 1 do
--       if unlim_move == 1 then
--         ChangeHeroStat('Karlam', STAT_MOVE_POINTS, 10000)
--       end
--       sleep()
--     end
--   end)
--   --GiveArtifact('Karlam', ARTIFACT_PRINCESS)
--   --MakeHeroInteractWithObject('Karlam', 'Baal')
-- end

-- function SpecTest()
--   consoleCmd('enable_cheats')
--   consoleCmd('add_army 3 2 100')
--   for i = 1, 2 do
--     GiveHeroSkill('Karlam', SKILL_LEADERSHIP)
--     GiveHeroSkill('Karlam', SKILL_LIGHT_MAGIC)
--     GiveArtifact('Karlam', ARTIFACT_RING_OF_HASTE)
--   end
--   sleep()
--   --GiveHeroSkill('Karlam', HERO_SKILL_EMPATHY)
--   GiveHeroSkill('Karlam', SKILL_WAR_MACHINES)
--   sleep()
--   GiveHeroSkill('Karlam', PERK_BALLISTA)
--   WarpHeroExp('Karlam', LEVELS[25])
--   ChangeHeroStat('Karlam', 3, 100)
--   SetGameVar('spec_test', 1)
-- end
-- -- ����: ������������� ��������� ����� � ������� � ������� ������� ���������� ��� ������� boss
-- --function GretaTest(boss)
-- --  GiveArtifact('Greta', ARTIFACT_DRAGON_EYE_RING)
-- --  for i, spell in {SPELL_REGENERATION, SPELL_BLESS, SPELL_SLOW, SPELL_HASTE, SPELL_DISPEL} do
-- --    TeachHeroSpell('Greta', spell)
-- --  end
-- --  SetObjectOwner('ore_m', PLAYER_1)
-- --  SetObjectOwner('wood_m', PLAYER_1)
-- --  SetObjectOwner('gold_m', PLAYER_1)
-- --  moriton.deadStacks = 7
-- --  if boss == 1 then
-- --    ChangeHeroStat('Greta', 0, LEVELS[19])
-- --    AddHeroCreatures('Greta', CREATURE_DRYAD, 180)
-- --    AddHeroCreatures('Greta', CREATURE_BLADE_SINGER, 130)
-- --    AddHeroCreatures('Greta', CREATURE_SHARP_SHOOTER, 125)
-- --    AddHeroCreatures('Greta', CREATURE_HIGH_DRUID, 50)
-- --    AddHeroCreatures('Greta', CREATURE_UNICORN, 12)
-- --    AddHeroCreatures('Greta', CREATURE_TREANT, 3)
-- --  elseif boss == 2 then
-- --    AddHeroCreatures('Greta', CREATURE_DRYAD, 250)
-- --    AddHeroCreatures('Greta', CREATURE_BLADE_SINGER, 90)
-- --    AddHeroCreatures('Greta', CREATURE_SHARP_SHOOTER, 170)
-- --    AddHeroCreatures('Greta', CREATURE_HIGH_DRUID, 60)
-- --    AddHeroCreatures('Greta', CREATURE_WAR_UNICORN, 16)
-- --    AddHeroCreatures('Greta', CREATURE_TREANT_GUARDIAN, 4)
-- --    Award('Greta', nil, {[0] = LEVELS[26]},
-- --         {
-- --           ARTIFACT_SWORD_OF_RUINS,
-- --           ARTIFACT_LION_HIDE_CAPE,
-- --           ARTIFACT_BOOTS_OF_SWIFTNESS,
-- --           ARTIFACT_SKULL_HELMET
-- --         },
-- --         {
-- --           {SPELL_FIREBALL, SPELL_CHAIN_LIGHTNING, SPELL_METEOR_SHOWER},
-- --           {SPELL_WEAKNESS, SPELL_FORGETFULNESS},
-- --           {SPELL_DEFLECT_ARROWS, SPELL_RESURRECT},
-- --           {SPELL_PHANTOM, SPELL_CELESTIAL_SHIELD}
-- --         })
-- --  end
-- --end

-- -- ������������ �������� �� ������ �����
-- function InitThisMapStartFX()
--   PlayVisualEffect(USED_FX.GHOST_CURSE_FX, 'baal_point')
--   PlayVisualEffect(USED_FX.AMPLIFIER_FX, 'SoM', 'scull_fx', 0, 0, 0, 0, 1)
--   PlayVisualEffect(USED_FX.TITAN_FX, 'portal1', 'portal1_fx', -0.5, 0, 0, 0, 0)
--   PlayVisualEffect(USED_FX.BIG_CRYS_FX, 'darkPath_Portal', 'dpp_fx', 1, 0, 0, 0, 1)
--   PlayVisualEffect(USED_FX.GHOST_HAUNT_FX, 'lake_temple', 'lt_fx1', -1.2, 1.85, 1, 0)
--   PlayVisualEffect(USED_FX.GHOST_POSSES_FX, 'lake_temple', 'lt_fx2', -1, -2, 2, 0)
--   -- PlayVisualEffect(USED_FX.MATRON_FX, 'libTui_portal', 'lib_p_fx', -5.74, 4.45, -4)
-- end

-- -- ������������� ���������
-- function InitThisMapAnimGroups()
--   local deads = {}
--   for i = 1, 31 do
--     deads[i] = 'dead'..i
--   end
--   AnimGroup[1] = {actors = deads}
--   AnimGroup[2] = {actors = {'moriton_treant1', 'moriton_treant2'}}
--   AnimGroup[3] = {actors = {'moriton_g1_a', 'moriton_g1_dru'}, region = 'moriton_anims1'}
--   AnimGroup[4] = {actors = {'moriton_g1_drag', 'moriton_g1_uni'}, region = 'moriton_anims1'}
--   AnimGroup[5] = {actors = {'moriton_g2_a1', 'moriton_g2_a2', 'moriton_g2_dru'}, region = 'moriton_anims2'}
--   AnimGroup[6] = {actors = {'moriton_g2_treant', 'moriton_g2_uni', 'moriton_g2_drag'}, region = 'moriton_anims2'}
--   AnimGroup[7] = {actors = {'moriton_g2_fairy1', 'moriton_g2_fairy2'}, region = 'moriton_anims2'}
--   AnimGroup[8] = {actors = {'moriton_g3_fairy1', 'moriton_g3_fairy2', 'moriton_g3_fairy3', 'moriton_g3_fairy4', 'moriton_g3_fairy5'}, region = 'moriton_anims3'}
--   AnimGroup[9] = {actors = {'moriton_g3_dancer1', 'moriton_g3_dancer2', 'moriton_g3_drag'}, region = 'moriton_anims3'}
--   AnimGroup[10] = {actors = {'dp_hydra1', 'dp_hydra2', 'dp_hydra3'}}
--   AnimGroup[11] = {actors = {'dp_mino1', 'dp_mino2', 'dp_mino3', 'dp_mino4', 'dp_mino5'}}
--   AnimGroup[12] = {actors = {'dp_fury1', 'dp_fury2', 'dp_fury3', 'dp_fury4', 'dp_fury5'}}
--   AnimGroup[13] = {actors = {'dp_drag1', 'dp_drag2', 'dp_drag3'}}
-- end

-- -- ��������� �������� �� ��������� � �� ������
-- function SetupThisMapAnimGroups()
--   for i = 1, 13 do
--     for i, actor in AnimGroup[i].actors do
--       SetObjectEnabled(actor, nil)
--       SetDisabledObjectMode(actor, DISABLED_BLOCKED)
--       startThread(
--       function()
--         sleep()
--         SetMonsterSelectionType(%actor, 0)
--       end)
--     end
--   end
--   sleep(2)
--   PlayAnims(AnimGroup[1], {'death'}, COND_SINGLE, ONESHOT_STILL)
--   PlayAnims(AnimGroup[2], {'specability'}, COND_SINGLE, ONESHOT_STILL)
--   PlayAnims(AnimGroup[3], {'attack00', 'happy', 'rangeattack'}, COND_HERO_IN_REGION)
--   PlayAnims(AnimGroup[4], {'stir00', 'attack00', 'happy'}, COND_HERO_IN_REGION)
--   PlayAnims(AnimGroup[5], {'attack00', 'happy', 'rangeattack'}, COND_HERO_IN_REGION)
--   PlayAnims(AnimGroup[6], {'stir00', 'attack00', 'happy'}, COND_HERO_IN_REGION)
--   PlayAnims(AnimGroup[7], {'stir00', 'attack00', 'happy', 'cast'}, COND_HERO_IN_REGION)
--   PlayAnims(AnimGroup[8], {'stir00', 'attack00', 'happy', 'cast'}, COND_HERO_IN_REGION)
--   PlayAnims(AnimGroup[9], {'stir00', 'attack00', 'happy'}, COND_HERO_IN_REGION)
--   for i = 10, 13 do
--     PlayAnims(AnimGroup[i], {'stir00'}, COND_OBJECT_EXISTS)
--   end
-- end

-- function StartMap() -- ��������� ��������� � ���� ��� �����
--   SetHeroesExpCoef(0.55 + (0.2 - 0.05 * diff))
--   SetCombatLight(COMBAT_LIGHTS.MORNING)
--   COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.MORNING
--   startQuest(mainQ.names.intro)
--   --startQuest(mainQ.names.main, 'Karlam')
--   SetGameVar('svetoch', 0)
--   SetGameVar('sandro_cape', 0)
--   SetGameVar('karlam_soldier_luck', 0)
--   --SetGameVar('spec_test', 0)
--   --SetGameVar('spec_max_coef', 0)
--   --SetGameVar('spec_init_coef', 0)
--   --SetTownBuildLimit('Moriton', {2, 2, 1, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1, -1, 0, -1, 0, 0})
--   SetPlayerStartResources(PLAYER_1, 14 - diff, 14 - diff, 7 - DIFF, 7 - DIFF, 7 - DIFF, 7 - DIFF, 13000 - 1000 * DIFF)
--   SetPlayerStartResources(PLAYER_3, 0, 0, 0, 0, 0, 0, 0)
--   InitThisMapStartFX()
--   InitThisMapAnimGroups()
--   SetupThisMapAnimGroups()
--   sleep(5)
--   UGCombatLightInit()
--   --SpecTest()
-- end
-- StartDialogScene(DIALOG_SCENES.START)
-- startThread(StartMap)
-- startThread(UpdateCombatStats)
-- startThread(SetupHeroes)
-- startThread(KarlamAlive)
-- startThread(RemovePlayer3Gold)
--startThread(KarlamTest)

primary_quest_path = mainPath.."Quests/Primary/"
secondary_quest_path = mainPath.."Quests/Secondary/"
zones_path = mainPath.."Zones/"

DIALOG_SCENES = {
    GRETA_MEETING = "/DialogScenes/Prologue/M1/GretaMeeting/DialogScene.xdb#xpointer(/DialogScene)"
}

function LoadScripts()
    doFile(zones_path.."Moriton/script.lua")
    doFile(zones_path.."ForestEdge/script.lua")
    doFile(primary_quest_path.."FlawInThePlan/script.lua")
    doFile(secondary_quest_path.."HiddenPath/script.lua")
    doFile(secondary_quest_path.."ContractKiller/script.lua")
end

function StartMap()
    consoleCmd("enable_cheats")
    OpenCircleFog(0, 0, 0, 999, 1)
    WarpHeroExp("Karlam", Levels[20])
    LoadScripts()
    sleep(10)
    startThread(moriton_zone.Init)
    startThread(forest_edge_zone.Init)
    startThread(flaw_in_the_plan.Init)
    startThread(hidden_path.Init)
    startThread(c1m1_q_contract_killer.Init)
end

--StartDialogSceneInt("")
startThread(StartMap)