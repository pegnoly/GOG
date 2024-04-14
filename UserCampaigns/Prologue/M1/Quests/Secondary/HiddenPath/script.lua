-- @quest 
-- Кампания. Личный демон.
-- Миссия. Сердце ночи.
-- Тип квеста. Второстепенный.
-- Имя квеста. Тайные тропы.

hidden_path = {
        --*ПЕРЕМЕННЫЕ*--
    
    -- техническая информация --
    name = "C1_M1_HIDDEN_PATH",
    path = 
    {
        text = secondary_quest_path.."HiddenPath/Texts/",
        dialog = secondary_quest_path.."HiddenPath/Dialogs/"
    },
    dialogs = 
    {
        Start = "C1_M1_Q_HIDDEN_PATH_START",
        Finish = "C1_M1_Q_HIDDEN_PATH_FINISH"
    },

    paths_count = 21,
    fairy_to_path_mapping = {},
    base_exp_to_remove = 1000,
    exp_remove_per_difficulty = 500,
    move_points_complete_bonus = 500,
    this_turn_path_bonus_gained = {},

        --*ФУНКЦИИ*--

    Init = function ()
        errorHook(
        function()
            print("<color=red>Error: <color=green>C1_M1_Q_HiddenPath.Init")
        end)

        Quest.Names["C1_M1_HIDDEN_PATH"] = secondary_quest_path.."HiddenPath/name.txt"

        for i = 1, hidden_path.paths_count do
            SetRegionBlocked("tropa"..i, 1)
            Touch.DisableMonster("fairy"..i, DISABLED_INTERACT, 0, hidden_path.path.text.."fairy_name.txt")
            hidden_path.fairy_to_path_mapping["fairy"..i] = "tropa"..i
            Quest.SetObjectQuestmark("fairy"..i, QUESTMARK_OBJ_NEW, 2)
            Touch.SetFunction("fairy"..i, "_C1_M1_q_hidden_path_fairy_touch", hidden_path.FairyTouch)
        end
    end,

    FairyTouch = function (hero, object) 
        errorHook(
        function()
            print("<color=red>Error: <color=green>C1_M1_Q_HiddenPath.FairyTouch")
        end)
        
        if not (hero == "Karlam") then
            return
        end

        -- квест не взят
        if Quest.IsUnknown(hidden_path.name) then
            MiniDialog.Start(
                hidden_path.path.dialog.."Start/",
                PLAYER_1,
                hidden_path.dialogs.Start
            )
            Quest.Start(hidden_path.name, hero)
            startThread(
            function ()
                for i = 1, hidden_path.paths_count do
                    Quest.SetObjectQuestmark("fairy"..i, QUESTMARK_OBJ_NEW_PROGRESS)
                end
            end)
            MakeHeroInteractWithObject(hero, object)
            return
        end
        -- квест взят
        if Quest.IsActive(hidden_path.name) then
            local progress = Quest.GetProgress(hidden_path.name) + 1
            local exp_to_remove = (hidden_path.base_exp_to_remove + hidden_path.exp_remove_per_difficulty * initialDifficulty) * progress
            local current_exp = GetHeroStat(hero, STAT_EXPERIENCE)
            if current_exp >= exp_to_remove then
                if MCCS_QuestionBoxForPlayers(PLAYER_1, {hidden_path.path.text.."give_exp_to_fairy.txt"; exp_count = exp_to_remove}) then
                    Quest.ResetObjectQuestmark(object)
                    TakeAwayHeroExp(hero, exp_to_remove)
                    Quest.Update(hidden_path.name, progress, hero)
                    ShowFlyingSign({hidden_path.path.text.."exp_lost.txt"; exp_lost = exp_to_remove}, hero, PLAYER_1, 7.0)
                    PlayObjectAnimation(object, "cast", ONESHOT)
                    SetRegionBlocked(hidden_path.fairy_to_path_mapping[object], nil, PLAYER_1)
                    sleep(15)
                    RemoveObject(object)
                    hidden_path.CheckFinish(hero, progress)
                    return
                end
            else
                ShowFlyingSign(hidden_path.path.text.."not_enough_exp.txt", hero, PLAYER_1, 7.0)
                return
            end
        end
    end,

    CheckFinish = function (hero, progress)
        errorHook(
        function()
            print("<color=red>Error: <color=green>C1_M1_Q_HiddenPath.CheckFinish")
        end)

        if progress == hidden_path.paths_count then
            MiniDialog.Start(
                hidden_path.path.dialog.."Finish/",
                PLAYER_1,
                hidden_path.dialogs.Finish
            )
            Quest.Finish(hidden_path.name, hero)
            for i = 1, hidden_path.paths_count do
                Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, "tropa"..i, "hidden_path.PathMovePointsBonus")
            end
            NewDayEvent.AddListener("C1_M1_q_hidden_path_path_bonus_new_day_listener",
            function(day)
                for path, active in hidden_path.this_turn_path_bonus_gained do
                    if path and active then
                        hidden_path.this_turn_path_bonus_gained[path] = nil
                    end
                end
            end)
            MessageBox(hidden_path.path.text.."move_bonus_info.txt")
        end
    end,

    PathMovePointsBonus = function (hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>C1_M1_Q_HiddenPath.PathEnter")
        end)

        if hidden_path.this_turn_path_bonus_gained[region] then
            return
        end

        hidden_path.this_turn_path_bonus_gained[region] = 1
        ChangeHeroStat(hero, STAT_MOVE_POINTS, hidden_path.move_points_complete_bonus)
    end
}