DIALOG_LISTMUR_MAGISTRAT_GENERIC = "C2M1_DIALOG_06"
DIALOG_LISTMUR_GUARD_GENERIC = "C2M1_DIALOG_07"

while not c2m1_great_search do
    sleep()
end

c2m1_zone_listmur = {

    path = {
        text = mainPath.."Zones/Listmur/Texts/",
        dialog = mainPath.."Zones/Listmur/Dialogs/",
        fight = mainPath.."Zones/Listmur/Fights/"
    },

    street_guards_dialog_speakers_replaces = {
        ["listmur_street_guard_1"] = 2307,
        ["listmur_street_guard_2"] = 2306,
        ["listmur_street_guard_4"] = 2306,
        ["listmur_street_guard_5"] = 2307,
        ["listmur_magistrat_guard"] = 2306
    },

    Init = function ()
        doFile(c2m1_zone_listmur.path.fight.."c2m1_listmur_gates_fight.lua")
        -- zone buildings
        Interactable("listmur_temple")
            .AsBuilding(DISABLED_DEFAULT, c2m1_zone_listmur.path.text.."temple_name.txt")
        Interactable("listmur_magistrat")
            .AsBuilding(DISABLED_INTERACT, c2m1_zone_listmur.path.text.."magistrat_name.txt")

        -- zone npcs
        local guard_talk_interaction = Interaction(c2m1_zone_listmur.GuardGenericTalk, nil, INTERACTION_PRIORITY_DEFAULT)
        for i = 1, 5 do
            Interactable("listmur_street_guard_"..i).AsCreature(DISABLED_INTERACT, 0, c2m1_zone_listmur.path.text.."street_guard.txt")
                .AddInteraction("generic_talk", guard_talk_interaction)
        end
        Interactable("listmur_magistrat_guard").AsCreature(DISABLED_INTERACT, 0, c2m1_zone_listmur.path.text.."magistrat_guard.txt")
            .AddInteraction("generic_talk", guard_talk_interaction)
        Interactable("listmur_gates_guard").AsCreature(DISABLED_INTERACT, 0, c2m1_zone_listmur.path.text.."gates_guard.txt")
        -- regions 
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "listmur_exit_region", "c2m1_zone_listmur.TryLeaveTown")
        --
        PlayObjectAnimation("listmur_gates", "open", ONESHOT_STILL)
    end,

    MagistratGenericTalk = 
    function (_, _)
        local activate_alt_version = random(2) == 1 and 1 or nil
        local alt_set = nil
        if activate_alt_version then
            alt_set = Random.FromSelection("alt_1", "alt_2")
        end
        MiniDialog.Start(DIALOG_LISTMUR_MAGISTRAT_GENERIC, alt_set)
    end,

    GuardGenericTalk = 
    function (_, object)
        local activate_alt_version = random(2) == 1 and 1 or nil
        local alt_set = nil
        if activate_alt_version then
            alt_set = Random.FromSelection("alt_1", "alt_2", "alt_3")
        end
        if c2m1_zone_listmur.street_guards_dialog_speakers_replaces[object] then
            MiniDialog.Start(DIALOG_LISTMUR_GUARD_GENERIC, alt_set, PLAYER_1, {
                [2305] = c2m1_zone_listmur.street_guards_dialog_speakers_replaces[object]
            }) 
        else
            MiniDialog.Start(DIALOG_LISTMUR_GUARD_GENERIC, alt_set)
        end
    end,

    TryLeaveTown = function (hero, _)
        SetRegionBlocked("listmur_exit_block", 1)
        Dialog.NewDialog(leave_listmur_dialog, hero, PLAYER_1)
    end,

    RetreatFromGates = function (hero)
        SetRegionBlocked("listmur_exit_block", nil)
        local second_hero = hero == "Karlam" and "Noellie" or "Karlam"
        local x1, y1, f1 = RegionToPoint("listmur_retreat_first_hero_point")
        local hx, hy, hf = GetObjectPosition(second_hero)
        if x1 == hx and y1 == hy and f1 == hf then
            local x2, y2, f2 = RegionToPoint("listmur_retreat_second_hero_point")
            MoveHeroRealTime(hero, x2, y2, f2)
        else
            MoveHeroRealTime(hero, x1, y1, f1)
        end
    end,

    LeaveTownWithRoadPact = function ()
        ShowFlyingSign(c2m1_zone_listmur.path.text.."leave_town_ok.txt", "listmur_gates_guard", PLAYER_1, 8.0)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "listmur_exit_region", nil)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "listmur_exit_block", nil)
    end,

    FightWithGateGuards = function (hero)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "listmur_exit_region", nil)
        local stacks_data = FightGenerator.SetupNeutralsCombat(c2m1_listmur_gates_fight)
        if MCCS_StartCombat(hero, nil, stacks_data.stacks_count, stacks_data.stacks_info, 1, nil, nil, 1) then
            SetRegionBlocked("listmur_exit_block", nil)
            while IsRegionBlocked("listmur_exit_block", PLAYER_1) do
                sleep()
            end
            local x1, y1, f1 = RegionToPoint("listmur_after_fight_first_hero_point")
            MoveHeroRealTime(hero, x1, y1, f1)
            sleep(20)
            SetRegionBlocked("listmur_exit_block", 1)
            local x2, y2, f2 = RegionToPoint("listmur_after_fight_second_hero_point")
            SetObjectPosition(hero == "Karlam" and "Noellie" or "Karlam", x2, y2, f2)
            sleep(20)
            PlayObjectAnimation("listmur_gates", "close", ONESHOT_STILL)
            Quest.Update(c2m1_unfamiliar_country.name, 1)
        end
    end
}

---@type DialogDefinition
leave_listmur_dialog = {
    path = mainPath.."Zones/Listmur/Dialogs/GatesGuard/",
    icon = "/"..Creature.Params.Icon(2305),
    title = "title",
    select_text = "",
    state = 1,
    perform_func = function (player, _, _, next_state)
        if next_state == "show_pact" then
            startThread(c2m1_zone_listmur.LeaveTownWithRoadPact)
        elseif next_state == "attack" then
            startThread(c2m1_zone_listmur.FightWithGateGuards, Dialog.GetActiveHeroForPlayer(player))
        else
            startThread(c2m1_zone_listmur.RetreatFromGates, Dialog.GetActiveHeroForPlayer(player))
        end
        return 0
    end,

    options = {
        {[0] = "text", [1] = {
            answer = "retreat",
            next_state = 0,
            is_enabled = 1
        }}
    },

    Reset = function (player)
        local dialog = Dialog.GetActiveDialogForPlayer(player)
        dialog.options[1][2] = nil
        if dialog.options[1][3] then 
            dialog.options[1][3] = nil
        end
        local has_road_pact = Quest.GetProgress(c2m1_unfamiliar_country.name) == 1
        if has_road_pact then
            dialog.options[1][2] = { answer = "show_pact", next_state = "show_pact", is_enabled = 1 }
        end
        dialog.options[1][has_road_pact and 3 or 2] = { answer = "attack", next_state = "attack", is_enabled = 1 }
        Dialog.Action(player)
    end,

    Open = function (player)
        Dialog.Reset(player)
    end
}