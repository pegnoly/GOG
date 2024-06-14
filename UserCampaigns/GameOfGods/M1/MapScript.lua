heroes_path = mainPath.."Heroes/"

decorativePlayers = {PLAYER_5}

function LoadScripts()
    doFile("/scripts/advmap/System/AISetup/ArtsDistribution/script.lua")
    sleep()
    doFile(heroes_path.."demons.lua")
    doFile(heroes_path.."advmap/Isfet/script.lua")
end

function StartMap()
    GiveHeroSkill("Karlam", SKILL_LEARNING)
    sleep()
    GiveHeroSkill("Karlam", PERK_EAGLE_EYE)
    LoadScripts()
    sleep(10)
end

startThread(StartMap)