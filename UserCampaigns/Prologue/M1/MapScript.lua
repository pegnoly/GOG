-------------------------������ ���� by Gerter----------------------------------
--------------------------owafe001@gmail.com------------------------------------
primary_quest_path = mainPath.."Quests/Primary/"
secondary_quest_path = mainPath.."Quests/Secondary/"
zones_path = mainPath.."Zones/"
heroes_path = mainPath.."Heroes/"

DIALOG_SCENES = {
    GRETA_MEETING = "/DialogScenes/Prologue/M1/GretaMeeting/DialogScene.xdb#xpointer(/DialogScene)"
}

function LoadScripts()
    doFile(heroes_path.."script.lua")
    doFile(zones_path.."Common/script.lua")
    doFile(zones_path.."Moriton/script.lua")
    doFile(zones_path.."ForestEdge/script.lua")
    doFile(primary_quest_path.."FlawInThePlan/script.lua")
    doFile(primary_quest_path.."KillBaal/script.lua")
    doFile(primary_quest_path.."AshaTear/script.lua")
    doFile(secondary_quest_path.."HiddenPath/script.lua")
    doFile(secondary_quest_path.."ContractKiller/script.lua")
    doFile(secondary_quest_path.."TreasuresAndSecrets/script.lua")
    sleep()
    startThread(c1m1_heroes.Load)
    startThread(zones_common.Load)
end

function StartMap()
    LoadScripts()
    sleep(10)
    startThread(c1m1_heroes.Init)
    startThread(moriton_zone.Init)
    startThread(forest_edge_zone.Init)
    startThread(flaw_in_the_plan.Init)
    startThread(hidden_path.Init)
    startThread(c1m1_q_contract_killer.Init)
    startThread(c1m1_q_treasures_and_secrets.Init)
    startThread(zones_common.Init)
    --
    startThread(stacks_generator.Init)
    startThread(Test)
end

function Test()
    consoleCmd("enable_cheats")
    OpenCircleFog(0, 0, 0, 999, 1)
    WarpHeroExp("Karlam", Levels[20])
    ChangeHeroStat("Karlam", STAT_SPELL_POWER, 30)
    ChangeHeroStat("Karlam", STAT_KNOWLEDGE, 30)
    for i = 1, 3 do
        GiveHeroSkill("Karlam", SKILL_DESTRUCTIVE_MAGIC)
    end
    GiveHeroSkill("Karlam", SKILL_LEARNING)
    sleep()
    GiveHeroSkill("Karlam", PERK_EAGLE_EYE)
    GiveArtefact("Karlam", ARTIFACT_TOME_OF_DESTRUCTION, 1)
    AddHeroCreatures("Karlam", CREATURE_PHOENIX, 100)
end
--StartDialogSceneInt("")
startThread(StartMap)