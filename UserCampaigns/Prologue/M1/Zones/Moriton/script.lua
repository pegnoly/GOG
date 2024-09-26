moriton_zone = {

    path = 
    {
        text = zones_path.."Moriton/Texts/",
        -- dialog = primary_quest_path.."AshaTear/Dialogs/"
    },

    exp_sharing_blocked_for_hero = {},

    garrisons = {"moriton_garrison_01", "moriton_garrison_02", "moriton_garrison_02"},

    out_garrison_units = {
        "archer1", "archer2", "archer3",
        "druid1", "druid2", "uni", "treant"
    },

    Init = 
    function()
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "moritonEnter", moriton_zone.Enter)
        AddHeroEvent.AddListener("C1_M1_zone_moriton_add_preserve_hero_listener", moriton_zone.PreserveHeroAddListener)

        Touch.DisableObject("moriton_garrison_01")
        Touch.SetFunction("moriton_garrison_01", "_try_enter", moriton_zone.TryEnterInnerGarrison)
    end,

    PreserveHeroAddListener = 
    function (hero)
        while not GetObjectOwner(hero) == PLAYER_1 do
            sleep()
        end
        moriton_zone.exp_sharing_blocked_for_hero[hero] = nil
        XpTrackingEvent.AddListener("C1_M1_zone_moriton_exp_sharing_listener", moriton_zone.ExpSharingListener)
    end,

    -- логика общего получения экспы героями-эльфами в Моритоне.
    ExpSharingListener = 
    function (hero, curr_exp, new_exp)
        local exp_diff = new_exp - curr_exp
        if exp_diff > 0 and (not moriton_zone.exp_sharing_blocked_for_hero[hero]) then
            for i, _hero in GetPlayerHeroes(PLAYER_1) do
                if _hero ~= hero then
                    if Hero.Params.Town(_hero) == TOWN_PRESERVE then
                        moriton_zone.exp_sharing_blocked_for_hero[_hero] = 1
                        local final_exp = GetHeroStat(_hero, STAT_EXPERIENCE) + exp_diff
                        GiveExp(_hero, exp_diff)
                        startThread(
                        function ()
                            while GetHeroStat(%_hero, STAT_EXPERIENCE) ~= %final_exp do
                                sleep()
                            end
                            sleep()
                            moriton_zone.exp_sharing_blocked_for_hero[%_hero] = nil
                        end)
                    end
                end
            end
        end
    end,

    -- логика касаний внутренних гарнизонов Моритона
    TryEnterInnerGarrison = 
    function (hero, object)
        if HasArtefact(hero, ARTIFACT_RIGID_MANTLE, 1) then
            MessageBox(moriton_zone.path.text.."inner_garrison_enter_success.txt")
            Touch.RemoveFunctions(object)
            SetObjectEnabled(object, 1)
            sleep()
            ChangeHeroStat(hero, STAT_MOVE_POINTS, 400)
            MoveHeroRealTime(hero, 26, 46, 0)
            return
        else
            MessageBox(moriton_zone.path.text.."inner_garrison_enter_fail.txt")
        end
    end,

    -- регион первого контакта Карлама и Греты
    -- 1. Запустить сцену
    -- 2. Обновить базовый квест
    -- 3. Обновить квест на убийство Баала
    -- 4. Запустить квест на поиск фениксов
    -- 5. Запустить квест на поиск слезы
    -- 6. Назначить триггер выхода из Моритона
    Enter = 
    function (hero, region)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "tropa6", "moriton_zone.Leave")
        --
        StartDialogScene(DIALOG_SCENES.GRETA_MEETING)
        --
        SetPlayerTeam(PLAYER_3, PLAYERS_TEAM_1)
        Quest.Update(flaw_in_the_plan.name, 1, hero)
        Quest.Update(kill_baal.name, 2, hero)
        Quest.Start(phoenix_essence.name, hero)
        startThread(asha_tear.Start, hero)

        moriton_zone.BlockInnerGarrisons()
        moriton_zone.RemoveOutGarrison()
    end,

    -- блокировка гарнизонов до момента, пока игрок не будет готов к созданию Источника
    BlockInnerGarrisons = 
    function ()
        for _, garrison in moriton_zone.garrisons do
            FX.Play(FX.Effects["Ghost_guard"], garrison, garrison.."_block_fx", 0, 0, 0, 0, 0)
        end
        MessageBox(moriton_zone.path.text.."all_garrisons_blocked.txt")
    end,

    -- убирает заслон, закрывающий путь в зону, восточную от стартовой
    RemoveOutGarrison = 
    function ()
        Object.Show(PLAYER_1, "Elleshar", 1)
        sleep(5)
        local sleep_time = GetSoundTimeInSleeps(FX.Sounds["Town_portal"])
        for _, unit in moriton_zone.out_garrison_units do
            local og_unit = 'out_gar_'..unit
            startThread(
            function (object)
                FX.Play(FX.Effects["Town_portal"], object)
                Play3DSound(FX.Sounds["Town_portal"], GetObjectPosition(object))
                sleep(%sleep_time)
                RemoveObject(object)
            end, og_unit)
        end
        FX.Play(FX.Effects["Town_portal"], "Elleshar")
        Play3DSound(FX.Sounds["Town_portal"], GetObjectPosition("Elleshar"))
        sleep(sleep_time)
        RemoveObject("Elleshar")
        MessageBox(moriton_zone.path.text.."out_garrison_leaved.txt")
    end,

    Leave = 
    function (hero, region)
        
    end
}