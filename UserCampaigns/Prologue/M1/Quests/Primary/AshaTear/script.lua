-- @quest 
-- Кампания. Личный демон.
-- Миссия. Сердце ночи.
-- Тип квеста. Основной.
-- Имя квеста. Божественная частица.

asha_tear = {
        --*ПЕРЕМЕННЫЕ*--
    
    -- техническая информация --
    name = "C1_M1_ASHA_TEAR",
    path = 
    {
        text = primary_quest_path.."AshaTear/Texts/",
        dialog = primary_quest_path.."AshaTear/Dialogs/"
    },
    dialogs = 
    {
        TreeStart = "C1_M1_Q_ASHA_TEAR_TREE_START",
        TreeTemp = "C1_M1_Q_ASHA_TEAR_TREE_TEMP",
        TreeFinish = "C1_M1_Q_ASHA_TEAR_TREE_FINISH"
    },

    obelisks_count = 15,
    obelisks_visited = {},
    obelisks_known_by_seer = {7, 15, 10, 11, 6},

    Init = 
    function()
        for i = 1, asha_tear.obelisks_count do
            SetObjectFlashlight('obelisk'..i, 'obelisk_fl')
            Touch.DisableObject("obelisk"..i, DISABLED_INTERACT)
            Touch.SetFunction("obelisk"..i, "C1_M1_q_asha_tear_obelisk_touch", asha_tear.ObeliskTouch)
        end
        --
        -- Touch.DisableObject("sylanna_tree", DISABLED_INTERACT)
        -- Touch.SetFunction("sylanna_tree", "C1_M1_q_asha_tear_sylanna_tree_touch", asha_tear.SylannaTreeTouch)
    end,

    StartZoneSeerTalk = function (hero, object)
        MiniDialog.Start("C1M1_DIALOG_08")
        for _, obelisk_num in asha_tear.obelisks_known_by_seer do
            Object.Show(PLAYER_1, "obelisk"..obelisk_num, 1)
        end
    end

    -- Start = 
    -- function (hero)
    --     Quest.Start(asha_tear.name, hero)
    --     Quest.SetObjectQuestmark("sylanna_tree", QUESTMARK_OBJ_NEW_PROGRESS, 4)
    --     startThread(asha_tear.ObelisksCountCheckThread)
    --     startThread(asha_tear.TearCheckThread)
    --     if asha_tear.obelisks_count > 0 then
    --         Quest.Update(asha_tear.name, 1, hero)
    --     end
    -- end,

    -- ObelisksCountCheckThread = 
    -- function ()
    --     while 1 do
    --         if len(asha_tear.obelisks_visited) == asha_tear.obelisks_count then
    --             MessageBox(asha_tear.path.."all_obelisks.txt")
    --             Quest.Update(asha_tear.name, 2, "Karlam")
    --             Quest.SetObjectQuestmark("sylanna_tree", QUESTMARK_OBJ_NEW_PROGRESS, 4)
    --             return
    --         end
    --     end
    -- end,

    -- TearCheckThread = 
    -- function ()
    --     while 1 do
    --         if HasArtefact("Karlam", ARTIFACT_GRAAL) then
    --             Quest.Finish(asha_tear.name, "Karlam")
    --             return
    --         end
    --     end
    -- end,

    -- -- логика касания обелисков
    -- ObeliskTouch = 
    -- function (hero, object)
    --     if asha_tear.obelisks_visited[object] then
    --         MessageBox(asha_tear.path.text.."obelisk_already_visited.txt")
    --         return
    --     end
    --     --
    --     asha_tear.obelisks_visited[object] = 1
    --     local message = "obelisk_text_"..(random(2) + 1)..".txt"
    --     MessageBox(asha_tear.path.text..message)
    -- end,

    -- -- логика касания древнего энта
    -- SylannaTreeTouch = 
    -- function (hero, object)
    --     -- квест не взят
    --     if Quest.IsUnknown(asha_tear.name) then
    --         MessageBox(asha_tear.path.."treant_no_reaction.txt")
    --         return
    --     end
    --     -- квест завершен
    --     if Quest.IsCompleted(asha_tear.name) then
    --         MessageBox(asha_tear.path.."treant_completed.txt")
    --         return
    --     end
    --     --
    --     local progress = Quest.GetProgress(asha_tear.name)
    --     if progress == 0 then
    --         MiniDialog.Start(asha_tear.path.dialog.."TreeStart/", PLAYER_1, asha_tear.dialogs.TreeStart)
    --         Quest.SetObjectQuestmark(object, QUESTMARK_OBJ_IN_PROGRESS, 4)
    --         Quest.Update(asha_tear.name, 1, hero)
    --         return
    --     end
    --     --
    --     if progress == 1 then
    --         MiniDialog.Start(asha_tear.path.dialog.."TreeTemp/", PLAYER_1, asha_tear.dialogs.TreeTemp)
    --         return
    --     end
    --     --
    --     if progress == 2 then
    --         MiniDialog.Start(asha_tear.path.dialog.."TreeFinish/", PLAYER_1, asha_tear.dialogs.TreeFinish)
    --         OpenPuzzleMap(PLAYER_1, asha_tear.obelisks_count)
    --         Quest.ResetObjectQuestmark(object)
    --         Quest.Update(asha_tear.name, 3, hero)
    --         Quest.Update(kill_baal.name, 3, hero)
    --         startThread(asha_tear.TearCheckThread)
    --         return
    --     end
    --     --
    --     if progress == 3 then
    --         MessageBox(asha_tear.path.."treant_completed.txt")
    --         return
    --     end
    -- end
}