c1m1_concealed_paths = {
    name = "CONCEALED_PATHS",
    path = {
        base = "UserCampaigns/Prologue/M1/Quests/Secondary/ConcealedPaths/",
        text = "UserCampaigns/Prologue/M1/Quests/Secondary/ConcealedPaths/Texts/",
        dialog = "UserCampaigns/Prologue/M1/Quests/Secondary/ConcealedPaths/Dialogs/"
    },

    paths_count = 5,
    npc_to_region_map = {},

    base_exp = 1500,
    exp_per_difficulty = 500,

    paths_used_this_turn = {},
    base_mp_bonus = 500,
    mp_multiplier_on_complete = 2,

    secret_place_pos = { x = 98, y = 83 },

    Init =
    function ()
        Quest.Names["CONCEALED_PATHS"] = "UserCampaigns/Prologue/M1/Quests/Secondary/ConcealedPaths/name.txt"
        doFile(c1m1_concealed_paths.path.base.."c1m1_concealed_paths_secret_place_fight_data.lua")
        
        for i = 1, c1m1_concealed_paths.paths_count do
            c1m1_concealed_paths.npc_to_region_map["concealed_path_pixie_"..i] = "concealed_path_region_"..i
            SetRegionBlocked("concealed_path_region_"..i, 1)
            Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, "concealed_path_region_"..i, "c1m1_concealed_paths.EnterPath")

            Touch.DisableMonster("concealed_path_pixie_"..i, DISABLED_INTERACT, 0, c1m1_concealed_paths.path.text.."pixie_name.txt")
            Touch.SetFunction("concealed_path_pixie_"..i, "interact", c1m1_concealed_paths.TouchPixie)
            Npc.Init("concealed_path_pixie_"..i)
            Npc.AddInteraction(
                "concealed_path_pixie_"..i,
                "start_quest",
                function (_hero, _object)
                    local result = Quest.IsUnknown(c1m1_concealed_paths.name)
                    return result
                end,
                function (hero, object)
                    startThread(c1m1_concealed_paths.Start, hero, object)
                end
            )
            Npc.AddInteraction(
                "concealed_path_pixie_"..i,
                "try_unblock",
                function (_hero, _object)
                    local result = Quest.IsActive(c1m1_concealed_paths.name)
                    return result
                end,
                function (hero, object)
                    startThread(c1m1_concealed_paths.TryUnblockPath, hero, object)
                end
            )
            Quest.SetObjectQuestmark("concealed_path_pixie_"..i, QUESTMARK_OBJ_NEW, 2)
        end

        NewDayEvent.AddListener("C1M1_concealed_paths_renew_paths",
        function (day)
            for path, visited in c1m1_concealed_paths.paths_used_this_turn do
                if path and visited then
                    c1m1_concealed_paths.paths_used_this_turn[path] = nil
                end
            end
        end)
    end,

    TouchPixie = 
    function (hero, object)
        Npc.RunInteractions(hero, object)
    end,

    Start = 
    function (hero, object)
        Npc.RemoveInteraction(object, "start_quest")
        MiniDialog.Start("C1M1_DIALOG_19")
        Quest.Start(c1m1_concealed_paths.name, hero)
        startThread(c1m1_concealed_paths.TryUnblockPath, hero, object)
    end,

    TryUnblockPath =
    function (hero, object)
        local base_exp = c1m1_concealed_paths.base_exp + c1m1_concealed_paths.exp_per_difficulty * initialDifficulty
        local progress = Quest.GetProgress(c1m1_concealed_paths.name)
        local exp_to_take = base_exp + base_exp * (progress == -1 and 0 or progress)
        if MCCS_QuestionBox({c1m1_concealed_paths.path.text.."exp_to_take.txt"; exp_amount = exp_to_take}) then
            if GetHeroStat(hero, STAT_EXPERIENCE) < exp_to_take then
                MessageBox(c1m1_concealed_paths.path.text.."not_enough_exp.txt")
            else
                startThread(c1m1_concealed_paths.UnblockPath, hero, object, exp_to_take)
            end
        end
    end,

    UnblockPath =
    function (hero, object, exp_to_take)
        Npc.RemoveInteraction(object, "try_unblock")
        TakeAwayHeroExp(hero, exp_to_take)
        MessageQueue.AddMessage(PLAYER_1, {c1m1_concealed_paths.path.text.."exp_lost.txt"; exp_amount=exp_to_take}, hero, 5.0)
        Quest.ResetObjectQuestmark(object)
        PlayObjectAnimation(object, "cast", ONESHOT)
        sleep(100)
        RemoveObject(object)
        SetRegionBlocked(c1m1_concealed_paths.npc_to_region_map[object], nil, PLAYER_1)
        local new_progress = Quest.GetProgress(c1m1_concealed_paths.name) + 1
        if new_progress == 1 then
            startThread(c1m1_concealed_paths.ShowAdditionalMovementInfo)
        end
        Quest.Update(c1m1_concealed_paths.name, new_progress, hero)
        
        if new_progress == c1m1_concealed_paths.paths_count then
            startThread(c1m1_concealed_paths.Complete, hero)
        end
    end,

    ShowAdditionalMovementInfo = 
    function ()
        MiniDialog.Start("C1M1_DIALOG_20")
    end,

    EnterPath = 
    function (hero, region)
        if not c1m1_concealed_paths.paths_used_this_turn[region] then
            c1m1_concealed_paths.paths_used_this_turn[region] = 1
            local mp_to_add = c1m1_concealed_paths.base_mp_bonus * 
                (Quest.IsCompleted(c1m1_concealed_paths.name) and c1m1_concealed_paths.mp_multiplier_on_complete or 1)
            ChangeHeroStat(hero, STAT_MOVE_POINTS, mp_to_add)
            MessageQueue.AddMessage(PLAYER_1, {c1m1_concealed_paths.path.text.."movement_bonus.txt"; mp_amount=mp_to_add}, hero, 5.0)
        end
    end,

    Complete =
    function (hero)
        Quest.Finish(c1m1_concealed_paths.name, hero)
        MiniDialog.Start("C1M1_DIALOG_21")
        CreateDwelling(
            "concealed_paths_pixies_secret_place", 
            TOWN_PRESERVE, 
            1, 
            PLAYER_NONE,
            c1m1_concealed_paths.secret_place_pos.x,
            c1m1_concealed_paths.secret_place_pos.y,
            GROUND,
            270
        )
        while not IsObjectExists("concealed_paths_pixies_secret_place") do
            sleep()
        end
        Touch.DisableObject(
            "concealed_paths_pixies_secret_place", 
            DISABLED_INTERACT, 
            c1m1_concealed_paths.path.text.."secret_place_name.txt",
            c1m1_concealed_paths.path.text.."secret_place_desc.txt"
        )
        Touch.SetFunction("concealed_paths_pixies_secret_place", 'touch', c1m1_concealed_paths.EnterSecretPlace)
        Object.Show(PLAYER_1, "concealed_paths_pixies_secret_place", 1)
        sleep(20)
    end,


    EnterSecretPlace = 
    function (hero, object)
        local stacks_data = FightGenerator.SetupNeutralsCombat(c1m1_concealed_paths_secret_place_fight_data)
        if MCCS_StartCombat(hero, nil, stacks_data.stacks_count, stacks_data.stacks_info, 1, nil, nil, 1) then
            Art.Distribution.Give(hero, ARTIFACT_ROBE_OF_MAGI, 1)
            Touch.RemoveFunction(object, "touch")
        end
    end
}