DWELLING_PURGE_STATE_NOT_STARTED = 0
DWELLING_PURGE_STATE_ARMY_DEFEATED = 1
DWELLING_PURGE_STATE_DONE = 2

zone_common_cursed_dwellings = {

    dwells_types = {},
    dwells_purge_states = {},
    dwells_type_counts = {},

    armies_power = {
        ["FAIRIE_TREE"] = {
            [1] = {base = 32000, grow = 2400},
            [2] = {base = 28500, grow = 2400},
            [3] = {base = 26000, grow = 2500}
        },
        ["WOOD_GUARD_QUARTERS"] = {
            [1] = {base = 35000, grow = 3000},
            [2] = {base = 33500, grow = 3100},
            [3] = {base = 32000, grow = 2800},
            [4] = {base = 34000, grow = 3000}
        },
        ["HIGH_CABINS"] = {
            [1] = {base = 38000, grow = 3500},
            [2] = {base = 36500, grow = 3350},
            [3] = {base = 35000, grow = 3800},
            [4] = {base = 36000, grow = 3000},
            [5] = {base = 34000, grow = 3400}
        },
        ["PRESERVE_MILITARY_POST"] = {
            [1] = {base = 45000, grow = 4000},
            [2] = {base = 46500, grow = 4350},
            [3] = {base = 45000, grow = 4100},
            [4] = {base = 46000, grow = 3700},
            [5] = {base = 44000, grow = 4400},
            [6] = {base = 40000, grow = 5000},
            [7] = {base = 42000, grow = 4100}
        }
    },

    dwells_count_armies_coef = {
        ["FAIRIE_TREE"] = {base = 1.18, grow = 0.06},
        ["WOOD_GUARD_QUARTERS"] = {base = 1.23, grow = 0.09},
        ["HIGH_CABINS"] = {base = 1.28, grow = 0.12},
        ["PRESERVE_MILITARY_POST"] = {base = 1.4, grow = 0.15}
    },

    dwells_purge_resource_amount = {
        ["FAIRIE_TREE"] = {[WOOD] = 7, [ORE] = 7, [CRYSTAL] = 5, [GEM] = 5},
        ["WOOD_GUARD_QUARTERS"] = {[WOOD] = 11, [ORE] = 9, [CRYSTAL] = 6, [GEM] = 4, [SULFUR] = 7},
        ["HIGH_CABINS"] = {[WOOD] = 15, [ORE] = 16, [GEM] = 8, [SULFUR] = 4, [MERCURY] = 5},
        ["PRESERVE_MILITARY_POST"] = {[WOOD] = 20, [ORE] = 20, [CRYSTAL] = 9, [GEM] = 9, [SULFUR] = 9, [MERCURY] = 9}
    },

    Init = 
    function ()
        for _t, type in {"FAIRIE_TREE", "WOOD_GUARD_QUARTERS", "HIGH_CABINS", "PRESERVE_MILITARY_POST"} do
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
        local dwell_type_count = zone_common_cursed_dwellings.dwells_type_counts[dwell_type]
        local army = {}
        for tier, army_info in zone_common_cursed_dwellings.armies_power[dwell_type] do
            local coef_info = zone_common_cursed_dwellings.dwells_count_armies_coef[dwell_type]
            local coef_value = dwell_type_count == 0 and 1 or (coef_info.base + coef_info.grow * initialDifficulty) * dwell_type_count
            local actual_power = ceil((army_info.base + army_info.grow * initialDifficulty) * coef_value)
            local units = list_iterator.Join(TIER_TABLES[TOWN_INFERNO][tier], TIER_TABLES[TOWN_NECROMANCY][tier])
            local sorted_units = list_iterator.Filter(units, function (unit)
                local chk = Creature.Params.IsUpgrade(unit)
                return chk
            end)
            local actual_unit = Random.FromTable(sorted_units)
            local actual_count = floor(actual_power / Creature.Params.Power(actual_unit))
            army[actual_unit] = actual_count
        end
        local actual_army, n = {}, 1
        for creature, count in army do
            if creature and count then
                actual_army[n] = creature
                actual_army[n + 1] = count
                n = n + 2
            end
        end
        if MCCS_StartCombat(hero, nil, len(army), actual_army, 1) then
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