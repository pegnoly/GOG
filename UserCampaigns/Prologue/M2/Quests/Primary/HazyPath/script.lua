
c1m2_hazy_path = {
    name = "HAZY_PATH",
    path = {
        main = "UserCampaigns/Prologue/M2/Quests/Primary/HazyPath",
        text = "UserCampaigns/Prologue/M2/Quests/Primary/HazyPath/Texts/",
        dialog = "UserCampaigns/Prologue/M2/Quests/Primary/HazyPath/Dialogs/"
    },

    first_garrison_units = {
        "first_garrison_treant_1", "first_garrison_treant_2",
        "first_garrison_pixie_1", "first_garrison_pixie_2", "first_garrison_pixie_3",
        "first_garrison_dancer_1", "first_garrison_dancer_2",
        "first_garrison_archer_1", "first_garrison_archer_2", "first_garrison_archer_3"
    },

    second_garrison_units = {
        "second_garrison_archer_1", "second_garrison_archer_2", "second_garrison_archer_3",
        "second_garrison_archer_4", "second_garrison_archer_5", "second_garrison_archer_6", "second_garrison_archer_7",
        "second_garrison_unicorn_1", "second_garrison_unicorn_2", "second_garrison_unicorn_3",
        "second_garrison_druid_1", "second_garrison_druid_2", "second_garrison_druid_3"
    },

    loiren_enabled = nil,
    posts_visited_by_loiren = 0,

    ossir_levels = {
        [DIFFICULTY_EASY] = 4,
        [DIFFICULTY_NORMAL] = 5,
        [DIFFICULTY_HARD] = 6,
        [DIFFICULTY_HEROIC] = 7
    },

    linaas_levels = {
        [DIFFICULTY_EASY] = 6,
        [DIFFICULTY_NORMAL] = 7,
        [DIFFICULTY_HARD] = 8,
        [DIFFICULTY_HEROIC] = 9
    },

    dark_obelisks_map = {
        ["first_dark_obelisk"] = "first_dark_portal",
        ["second_dark_obelisk"] = "second_dark_portal",
        ["third_dark_obelisk"] = "third_dark_portal",
        ["fourth_dark_obelisk"] = "fourth_dark_portal"
    },

    dark_obelisks_used = 0,

    Load =
    function ()
        Quest.Names["HAZY_PATH"] = "UserCampaigns/Prologue/M2/Quests/Primary/HazyPath/name.txt"
        doFile(c1m2_hazy_path.path.main.."/Fights/c1m2_hazy_path_first_garrison.lua")
        while not c1m2_hazy_path_first_garrison do
            sleep()
        end
    end,

    Init =
    function ()
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "first_garrison_enter", "c1m2_hazy_path.EnterFirstPost")
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "second_garrison_enter", "c1m2_hazy_path.EnterSecondPost")

        RemoveObjectCreatures("c1m2_post_town", CREATURE_PIXIE, 9999)
        Trigger(OBJECT_CAPTURE_TRIGGER, "c1m2_post_town", "c1m2_hazy_path.CapturePost")

        for _, object in c1m2_hazy_path.first_garrison_units do
            Touch.DisableMonster(object, DISABLED_ATTACK, 0)
        end
        Animation.NewGroup("first_garrison_units", c1m2_hazy_path.first_garrison_units)

        for _, object in c1m2_hazy_path.second_garrison_units do
            Touch.DisableMonster(object, DISABLED_ATTACK, 0)
        end
        Animation.NewGroup("second_garrison_units", c1m2_hazy_path.second_garrison_units)

        startThread(c1m2_hazy_path.SetupOssir)
        startThread(c1m2_hazy_path.SetupLinaas)

        for obelisk, portal in c1m2_hazy_path.dark_obelisks_map do
            Touch.DisableObject(obelisk, DISABLED_INTERACT, c1m2_hazy_path.path.text.."obelisk_name.txt", c1m2_hazy_path.path.text.."obelisk_desc.txt")
            Touch.DisableObject(portal, DISABLED_INTERACT)
            Npc.Init(obelisk)
            Npc.Init(portal)
            Npc.AddInteraction(obelisk, "first_dialog",
                function (_hero, _object)
                    return c1m2_hazy_path.dark_obelisks_used == 0
                end,
                function (hero, object)
                    startThread(c1m2_hazy_path.ShowFirstDarkObeliskDialog, hero, object)
                end
            )
            Npc.AddInteraction(obelisk, "second_dialog",
                function (_hero, _object)
                    return c1m2_hazy_path.dark_obelisks_used == 1
                end,
                function (hero, object)
                    startThread(c1m2_hazy_path.ShowSecondDarkObeliskDialog, hero, object)
                end
            )
            Npc.AddInteraction(obelisk, "use",
                function (_hero, _object)
                    return 1
                end,
                function (hero, object)
                    startThread(c1m2_hazy_path.UseDarkObelisk, hero, object)
                end
            )
            Npc.AddInteraction(portal, "use",
                function (_hero, _object)
                    return 1
                end,
                function (hero, object)
                    startThread(c1m2_hazy_path.TryUseDarkPortal, hero, object)
                end
            )
            Npc.PrioritizeInteraction(obelisk, "first_dialog")
            Npc.PrioritizeInteraction(obelisk, "second_dialog")
            Touch.SetFunction(obelisk, "touch", c1m2_hazy_path.TouchDarkObelisk)
            Touch.SetFunction(portal, "touch", c1m2_hazy_path.TouchDarkPortal)
            print("Setting up obelisk: ", obelisk)
        end
    end,

    SetupOssir =
    function ()
        doFile(c1m2_hazy_path.path.main.."/Fights/c1m2_hazy_path_second_garrison.lua")
        DeployReserveHero("Ossir", RegionToPoint("hazy_path_ossir_point"))
        while not (IsObjectExists("Ossir") and c1m2_hazy_path_second_garrison) do
            sleep()
        end
        local fight_data = FightGenerator.GenerateHeroSetupData(c1m2_hazy_path_second_garrison)
        startThread(FightGenerator.ProcessHeroSetup, "Ossir", fight_data)
        GiveExp("Ossir", Levels[c1m2_hazy_path.ossir_levels[initialDifficulty]])
        EnableHeroAI("Ossir", nil)
    end,

    SetupLinaas =
    function ()
        doFile(c1m2_hazy_path.path.main.."/Fights/c1m2_hazy_path_third_garrison.lua")
        DeployReserveHero("Linaas", RegionToPoint("hazy_path_ving_point"))
        while not (IsObjectExists("Linaas") and c1m2_hazy_path_third_garrison) do
            sleep()
        end
        local fight_data = FightGenerator.GenerateHeroSetupData(c1m2_hazy_path_third_garrison)
        startThread(FightGenerator.ProcessHeroSetup, "Linaas", fight_data)
        GiveExp("Linaas", Levels[c1m2_hazy_path.linaas_levels[initialDifficulty]])
        EnableHeroAI("Linaas", nil)
    end,

    SetupLoiren =
    function ()
        c1m2_hazy_path.loiren_enabled = 1
    end,

    CapturePost =
    function (previous_owner, new_owner, hero, object)
        if new_owner == PLAYER_1 then
            SetObjectOwner(object, PLAYER_NONE)
        end
    end,

    EnterFirstPost =
    function (hero, region)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        if hero == "Karlam" then
            for i = 1, 2 do
                UpgradeTownBuilding("c1m2_post_town", TOWN_BUILDING_FORT)
            end
            local stacks_data = FightGenerator.GenerateStacksData(c1m2_hazy_path_first_garrison)
            FightGenerator.ProcessObjectSetup("c1m2_post_town", stacks_data)
            sleep()
            if MCCS_SiegeTown(hero, "c1m2_post_town") then
                Animation.PlayGroup("first_garrison_units", {"death"}, Animation.PLAY_CONDITION_SINGLEPLAY, ONESHOT_STILL)
                sleep(75)
                Object.RemoveTable(c1m2_hazy_path.first_garrison_units)
            end
            DestroyTownBuildingToLevel("c1m2_post_town", TOWN_BUILDING_FORT, 0)
            if not c1m2_hazy_path.loiren_enabled then

            end
            return
        end
        --
        if hero == "Loiren" or hero == "Loiren_Heroic" then
            Object.Show(PLAYER_1, hero, 1)
            c1m2_hazy_path.posts_visited_by_loiren = c1m2_hazy_path.posts_visited_by_loiren + 1
            Hero.CreatureInfo.AddByTier(hero,
                TOWN_PRESERVE, 1, 10 * defaultDifficulty,
                TOWN_PRESERVE, 2, 5 * defaultDifficulty,
                TOWN_PRESERVE, 3, 3 * defaultDifficulty,
                TOWN_PRESERVE, 6, initialDifficulty
            )
        end
    end,

    EnterSecondPost =
    function(hero, region)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        if hero == "Karlam" then
            for i = 1, 3 do
                UpgradeTownBuilding("c1m2_post_town", TOWN_BUILDING_FORT)
            end
            local x, y, f = GetObjectPosition("c1m2_post_town")
            SetObjectPosition("Ossir", x, y, f, 0)
            sleep()
            if MCCS_SiegeTown(hero, "c1m2_post_town") then
                Animation.PlayGroup("second_garrison_units", {"death"}, Animation.PLAY_CONDITION_SINGLEPLAY, ONESHOT_STILL)
                sleep(75)
                Object.RemoveTable(c1m2_hazy_path.second_garrison_units)
            end
            DestroyTownBuildingToLevel("c1m2_post_town", TOWN_BUILDING_FORT, 0)
            return
        end
    end,

    TouchDarkObelisk =
    function (hero, object)
        startThread(Npc.RunInteractions, hero, object)
    end,

    TouchDarkPortal =
    function (hero, object)
        startThread(Npc.RunInteractions, hero, object)
    end,

    ShowFirstDarkObeliskDialog =
    function (_hero, object)
        for _object, _ in c1m2_hazy_path.dark_obelisks_map do
            Npc.RemoveInteraction(_object, "first_dialog")
        end
        Npc.RemoveInteraction(object, "second_dialog")
        MiniDialog.Start("C1M2_DIALOG_1")
        Npc.FinishInteraction("first_dialog")
    end,

    ShowSecondDarkObeliskDialog =
    function (_hero, _object)
        for object, _ in c1m2_hazy_path.dark_obelisks_map do
            Npc.RemoveInteraction(object, "second_dialog")
        end
        MiniDialog.Start("C1M2_DIALOG_2")
        Npc.FinishInteraction("second_dialog")
    end,

    UseDarkObelisk =
    function(hero, object)
        local portal_to_unblock = c1m2_hazy_path.dark_obelisks_map[object]
        Object.Show(PLAYER_1, portal_to_unblock, 1, 1)
        sleep(100)
        FX.Play('Monolith_one_way', portal_to_unblock)
        -- manage portal
        FX.Play('Monolith_one_way', portal_to_unblock)
        Npc.RemoveInteraction(portal_to_unblock, "use")
        Touch.RemoveFunctions(portal_to_unblock)
        Touch.ResetTrigger(portal_to_unblock)
        SetObjectEnabled(portal_to_unblock, 1)
        -- manage obelisk
        Npc.RemoveInteraction(object, "use")
        Npc.AddInteraction(object, "already_used",
            function (_, _)
                return 1
            end,
            function (hero, object)
                startThread(c1m2_hazy_path.InformObeliskAlreadyUsed, hero, object)
            end
        )
        c1m2_hazy_path.dark_obelisks_used = c1m2_hazy_path.dark_obelisks_used + 1
        Npc.FinishInteraction("use")
    end,

    InformObeliskAlreadyUsed =
    function (hero, object)
        MessageBox(c1m2_hazy_path.path.text.."obelisk_already_used.txt")
        Npc.FinishInteraction("already_used")
    end,

    TryUseDarkPortal =
    function (hero, object)
        MessageBox(c1m2_hazy_path.path.text.."cant_use_portal.txt")
        Npc.FinishInteraction("use")
    end
}