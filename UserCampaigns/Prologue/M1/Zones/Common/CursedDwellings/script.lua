DWELLING_PURGE_STATE_NOT_STARTED = 0
DWELLING_PURGE_STATE_ARMY_DEFEATED = 1
DWELLING_PURGE_STATE_DONE = 2

zone_common_cursed_dwellings = {

    path = zones_path.."Common/CursedDwellings/",
    dwells_types = {},
    dwells_purge_states = {},
    dwells_type_counts = {},

    dwells_count_armies_coef = {
        ["FAIRIE_TREE"] = 0.4,
        ["WOOD_GUARD_QUARTERS"] = 0.25,
        ["HIGH_CABINS"] = 0.18,
        ["PRESERVE_MILITARY_POST"] = 0.12
    },

    dwells_purge_resource_amount = {
        ["FAIRIE_TREE"] = {[WOOD] = 7, [ORE] = 7, [CRYSTAL] = 5, [GEM] = 5},
        ["WOOD_GUARD_QUARTERS"] = {[WOOD] = 11, [ORE] = 9, [CRYSTAL] = 6, [GEM] = 4, [SULFUR] = 7},
        ["HIGH_CABINS"] = {[WOOD] = 15, [ORE] = 16, [GEM] = 8, [SULFUR] = 4, [MERCURY] = 5},
        ["PRESERVE_MILITARY_POST"] = {[WOOD] = 20, [ORE] = 20, [CRYSTAL] = 9, [GEM] = 9, [SULFUR] = 9, [MERCURY] = 9}
    },

    dwells_fight_data = {},

    Load = 
    function ()
        doFile(zone_common_cursed_dwellings.path.."Fights/c1m1_cursed_dwells_t1.lua")
        doFile(zone_common_cursed_dwellings.path.."Fights/c1m1_cursed_dwells_t2.lua")
        doFile(zone_common_cursed_dwellings.path.."Fights/c1m1_cursed_dwells_t3.lua")
        doFile(zone_common_cursed_dwellings.path.."Fights/c1m1_cursed_dwells_outpost.lua")

        while not c1m1_cursed_dwells_outpost do
            sleep()
        end

        zone_common_cursed_dwellings.dwells_fight_data["FAIRIE_TREE"] = c1m1_cursed_dwells_t1
        zone_common_cursed_dwellings.dwells_fight_data["WOOD_GUARD_QUARTERS"] = c1m1_cursed_dwells_t2
        zone_common_cursed_dwellings.dwells_fight_data["HIGH_CABINS"] = c1m1_cursed_dwells_t3
        zone_common_cursed_dwellings.dwells_fight_data["PRESERVE_MILITARY_POST"] = c1m1_cursed_dwells_outpost
    end,

    Init = 
    function ()
        while not Touch do
            sleep()
        end
        print("Running init cursed dwells")
        for _t, type in {
            "FAIRIE_TREE", "WOOD_GUARD_QUARTERS", "HIGH_CABINS", "PRESERVE_MILITARY_POST"
        } do
            for _d, dwell in GetObjectNamesByType(type) do
                if GetObjectOwner(dwell) == PLAYER_NONE then
                    Touch.DisableObject(dwell, DISABLED_INTERACT)
                    zone_common_cursed_dwellings.dwells_types[dwell] = type
                    zone_common_cursed_dwellings.dwells_type_counts[type] = 0
                    zone_common_cursed_dwellings.dwells_purge_states[dwell] = DWELLING_PURGE_STATE_NOT_STARTED
                    Touch.SetFunction(dwell, "zone_common_cursed_dwelling_touch", zone_common_cursed_dwellings.TouchDwelling)
                    FX.Play("Ruined_tower", dwell, dwell.."_cursed_effect")
                    SetObjectFlashlight(dwell, "curse_fl")
                end
            end
        end    
    end,

    TouchDwelling =
    function (hero, object)
        local dwell_state = zone_common_cursed_dwellings.dwells_purge_states[object]
        if dwell_state == DWELLING_PURGE_STATE_NOT_STARTED then
            startThread(zone_common_cursed_dwellings.InitDwellFight, hero, object)
        elseif dwell_state == DWELLING_PURGE_STATE_ARMY_DEFEATED then
            startThread(zone_common_cursed_dwellings.TryPurgeDwell, hero, object)
        else
            MessageBox(zones_path.."Common/CursedDwellings/Texts/already_purged.txt")
        end
    end,

    InitDwellFight =
    function (hero, object)
        local dwell_type = zone_common_cursed_dwellings.dwells_types[object]
        local counts = zone_common_cursed_dwellings.dwells_type_counts[dwell_type]
        local fight_data = FightGenerator.SetupNeutralsCombat(zone_common_cursed_dwellings.dwells_fight_data[dwell_type])
        for i = 2, length(fight_data.stacks_info), 2 do
            fight_data.stacks_info[i] = ceil(fight_data.stacks_info[i] * (1 + zone_common_cursed_dwellings.dwells_count_armies_coef[dwell_type] * counts))
        end
        if MCCS_StartCombat(hero, nil, fight_data.stacks_count, fight_data.stacks_info, 1) then
            zone_common_cursed_dwellings.dwells_type_counts[dwell_type] = zone_common_cursed_dwellings.dwells_type_counts[dwell_type] + 1
            zone_common_cursed_dwellings.dwells_purge_states[object] = DWELLING_PURGE_STATE_ARMY_DEFEATED
            while zone_common_cursed_dwellings.dwells_purge_states[object] ~= DWELLING_PURGE_STATE_ARMY_DEFEATED do
                sleep()
            end
            MakeHeroInteractWithObject(hero, object)
        end
    end,

    TryPurgeDwell = 
    function (hero, object)
        local dwell_type = zone_common_cursed_dwellings.dwells_types[object]
        local res_values = {"blank.txt", "blank.txt", "blank.txt", "blank.txt", "blank.txt", "blank.txt", "blank.txt"}
        local count = 1
        for res, amount in zone_common_cursed_dwellings.dwells_purge_resource_amount[dwell_type] do
            res_values[count] = {zones_path.."Common/CursedDwellings/Texts/res_info.txt"; res_type = ResNames[res], amount = amount}
            count = count + 1
        end
        if MCCS_QuestionBox({zones_path.."Common/CursedDwellings/Texts/dwell_purge_question.txt";
            res1 = res_values[1],
            res2 = res_values[2],
            res3 = res_values[3],
            res4 = res_values[4],
            res5 = res_values[5],
            res6 = res_values[6],
            res7 = res_values[7],
        }) then
            local flag = 1
            for res, amount in zone_common_cursed_dwellings.dwells_purge_resource_amount[dwell_type] do
                if GetPlayerResource(PLAYER_1, res) < amount then
                    flag = nil
                    break
                end
            end
            if flag then
                startThread(zone_common_cursed_dwellings.PurgeDwelling, hero, object)
            else
                MessageBox(zones_path.."Common/CursedDwellings/Texts/not_enough_resources.txt")
            end
        end
    end,

    PurgeDwelling = 
    function (hero, object)
        local dwell_type = zone_common_cursed_dwellings.dwells_types[object]
        startThread(
        function ()
            local dwell_type = %dwell_type
            for res_type, amount in zone_common_cursed_dwellings.dwells_purge_resource_amount[dwell_type] do
                Resource.Change(%hero, res_type, -amount)
            end 
        end)
        local x, y, f = GetObjectPosition(object)
        FX.Play("Holy_word", object)
        --Play3DSound(FX.Sounds["Holy_word"], x, y, f)
        sleep(25)
        StopVisualEffects(object.."_cursed_effect")
        ResetObjectFlashlight(object)
        SetObjectOwner(object, PLAYER_3)
        zone_common_cursed_dwellings.dwells_purge_states[object] = DWELLING_PURGE_STATE_DONE
        MessageBox(zones_path.."Common/CursedDwellings/Texts/dwell_purged.txt")
    end
}