ARTIFACT_STABILIZATION_AMULET = 174

while not ARTIFACT_STABILIZATION_AMULET do
    sleep()
end

NAF_stabilization_amulet = {
    active_for_hero = {}
}

AddHeroEvent.AddListener("NAF_stabilization_amulet_add_hero_listener", 
function(hero)
    NAF_stabilization_amulet.active_for_hero[hero] = nil
    startThread(
    function (hero)
        while 1 do
            if IsHeroAlive(hero) then
                if not NAF_stabilization_amulet.active_for_hero[hero] then
                    if HasArtefact(hero, ARTIFACT_STABILIZATION_AMULET, 1) then
                        NAF_stabilization_amulet.active_for_hero[hero] = 1
                        consoleCmd("@SetGameVar('"..hero.."_STABILIZATION_AMULET', 'active')")
                    end
                else
                    if not HasArtefact(hero, ARTIFACT_STABILIZATION_AMULET, 1) then
                        NAF_stabilization_amulet.active_for_hero[hero] = nil
                        consoleCmd("@SetGameVar('"..hero.."_STABILIZATION_AMULET', '')")
                    end
                end
            end
            sleep()
        end 
    end, hero)
end)

CombatConnection.combat_scripts_paths["ARTIFACT_STABILIZATION_AMULET"] = "/scripts/combat/Artifacts/StabilizationAmulet/script.lua"