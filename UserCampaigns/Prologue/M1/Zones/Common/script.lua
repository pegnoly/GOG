-- Скрипты, не относящиеся к конкретным квестам и зонам.

ARTIFACT_UNICORN_BOW_UNICORN_HORN = 403
ARTIFACT_UNICORN_BOW_TREANT_PART = 404
ARTIFACT_UNICORN_BOW_PIXIE_SILK = 405

zones_common = {

    Load = 
    function ()
        doFile(zones_path.."Common/CursedDwellings/script.lua")
    end,

    Init = function ()
        startThread(zone_common_cursed_dwellings.Init)
    end

    -- GiveUnicornHornPartCallback = 
    -- function (fight_id)
    --     local player = GetSavedCombatArmyPlayer(fight_id, 1)
    --     if CombatResultsEvent.fight_tag_for_player[player] ~= "c1m1_start_zone_treant_bank_fight" then
    --         return
    --     end
    -- end
}