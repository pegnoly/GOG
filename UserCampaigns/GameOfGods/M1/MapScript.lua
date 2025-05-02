heroes_path = mainPath.."Heroes/"
regions_path = mainPath.."Regions/"
q_path = mainPath.."Quests/"

decorativePlayers = {PLAYER_5}

function LoadScripts()
    doFile(mainPath.."dialogs_paths.lua")
    doFile("/scripts/advmap/System/AISetup/ArtsDistribution/script.lua")
    sleep()
    doFile(heroes_path.."demons.lua")
    doFile(heroes_path.."advmap/Isfet/script.lua")
    doFile(regions_path.."Listmur/script.lua")
end

function StartMap()
    GiveHeroSkill("Karlam", SKILL_LEARNING)
    sleep()
    GiveHeroSkill("Karlam", PERK_EAGLE_EYE)
    OpenCircleFog(0, 0, 0, 999, 1)
    OpenCircleFog(0, 0, 1, 999, 1)
    LoadScripts()
    sleep()
    print("Start map")
    startThread(c2m1_listmur_region.Init)
end

startThread(StartMap)