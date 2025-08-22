
c1m2_hazy_path = {

    --#region Data

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
    loiren_current_dest_point = "loiren_dest_point1",
    loiren_waiting = nil,

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

    loiren_levels = {
        [DIFFICULTY_EASY] = 5,
        [DIFFICULTY_NORMAL] = 7,
        [DIFFICULTY_HARD] = 9,
        [DIFFICULTY_HEROIC] = 11
    },

    dark_obelisks_map = {
        ["first_dark_obelisk"] = "first_dark_portal",
        ["second_dark_obelisk"] = "second_dark_portal",
        ["third_dark_obelisk"] = "third_dark_portal",
        ["fourth_dark_obelisk"] = "fourth_dark_portal"
    },

    dark_obelisks_used = 0,

    --#endregion

    --#region Setup

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
        startThread(c1m2_hazy_path.SetupOssir)
        startThread(c1m2_hazy_path.SetupLinaas)
        startThread(c1m2_hazy_path.InitLoiren)
        startThread(c1m2_hazy_path.InitPosts)
        startThread(c1m2_hazy_path.InitObelisks)
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

    --#endregion

    --#region Loiren logic

    InitLoiren =
    function ()
        for i = 1, 6 do
            Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, "loiren_dest_point"..i, "c1m2_hazy_path.ProcessLoirenDestPoint")
        end

        for i = 1,2 do
            SetRegionBlocked("ai_block"..i, 1, PLAYER_3)
        end
    end,

    PrepareLoirenArrival =
    function ()
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "enable_loiren_region", "c1m2_hazy_path.SetupLoirenArrival")
    end,

    SetupLoirenArrival =
    function (_, region)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        startThread(c1m2_hazy_path.EnableLoiren)
    end,

    EnableLoiren =
    function ()
        c1m2_hazy_path.loiren_enabled = 1
        --
        doFile(c1m2_hazy_path.path.main.."/Fights/loiren_fight_data.lua")
        local hero = initialDifficulty == DIFFICULTY_HEROIC and "Loiren_Heroic" or "Loiren"
        DeployReserveHero(hero, RegionToPoint("loiren_spawn_point"))
        while not (IsObjectExists(hero) and loiren_fight_data) do
            sleep()
        end
        local fight_data = FightGenerator.GenerateHeroSetupData(loiren_fight_data)
        FightGenerator.ProcessHeroSetup(hero, fight_data)
        sleep(10)
        local base_level = hero == "Loiren" and 3 or 5
        if GetHeroCreatures(hero, CREATURE_GRAND_ELF) ~= 0 then
            GiveHeroSkill(hero, PERK_MASTER_OF_ICE)
            base_level = base_level + 1
            if initialDifficulty == DIFFICULTY_HEROIC then
                sleep()
                GiveHeroSkill(hero, NECROMANCER_FEAT_DEADLY_COLD)
                base_level = base_level + 1
            end
        elseif GetHeroCreatures(hero, CREATURE_SHARP_SHOOTER) ~= 0 then
            GiveHeroSkill(hero, PERK_MASTER_OF_FIRE)
            base_level = base_level + 1
            if initialDifficulty == DIFFICULTY_HEROIC then
                sleep()
                GiveHeroSkill(hero, RANGER_FEAT_SOIL_BURN)
                base_level = base_level + 1
            end
        end
        WarpHeroExp(hero, base_level)
        sleep(10)
        if base_level < c1m2_hazy_path.loiren_levels[initialDifficulty] then -- weird but only way to give correct level considering base perks
            GiveExp(hero, Levels[c1m2_hazy_path.loiren_levels[initialDifficulty]] - Levels[base_level])
            sleep()
            WarpHeroExp(hero, Levels[c1m2_hazy_path.loiren_levels[initialDifficulty]])
        end
        sleep()
        startThread(c1m2_hazy_path.LoirenMovementThread, hero)
    end,

    LoirenMovementThread =
    function (hero)
        while IsHeroAlive(hero) do
            while not IsPlayerCurrent(PLAYER_3) do
                sleep()
            end
            local kx, ky, kf = GetObjectPosition("Karlam")
            if CanMoveHero(hero, kx, ky, kf) then
                print"Can move to Karlam"
                if c1m2_hazy_path.loiren_waiting then
                    c1m2_hazy_path.loiren_waiting = nil
                    EnableHeroAI(hero, 1)
                end
                MoveHeroRealTime(hero, kx, ky, kf)
            else
                if not c1m2_hazy_path.loiren_waiting then
                    local x, y, f = RegionToPoint(c1m2_hazy_path.loiren_current_dest_point)
                    MoveHero(hero, x, y, f)
                end
            end
            sleep()
        end
    end,

    ProcessLoirenDestPoint =
    function (hero, region)
        if hero == "Loiren" or hero == "Loiren_Heroic" then
            local x, y, f = GetObjectPosition("Karlam")
            if not CanMoveHero(hero, x, y, f) then
                if region == "loiren_dest_point1" then
                    SetObjectPosition(hero, 42, 30, GROUND, 0) -- move through first post enter garrison
                    c1m2_hazy_path.loiren_current_dest_point = "loiren_dest_point2"
                    sleep()
                    MoveHeroRealTime(hero, RegionToPoint(c1m2_hazy_path.loiren_current_dest_point))
                    return
                end
                if region == "loiren_dest_point2" then
                    SetObjectPosition(hero, 52, 29, GROUND, 0) -- move through first post exit garrison
                    c1m2_hazy_path.loiren_current_dest_point = "loiren_dest_point3"
                    sleep()
                    MoveHeroRealTime(hero, RegionToPoint(c1m2_hazy_path.loiren_current_dest_point))
                    return
                end
                if region == "loiren_dest_point4" then
                    SetObjectPosition(hero, 87, 29, GROUND, 0) -- move through second post enter garrison
                    c1m2_hazy_path.loiren_current_dest_point = "loiren_dest_point5"
                    sleep()
                    MoveHeroRealTime(hero, RegionToPoint(c1m2_hazy_path.loiren_current_dest_point))
                    return
                end
                if region == "loiren_dest_point5" then
                    SetObjectPosition(hero, 86, 70, GROUND, 0) -- move through second post enter garrison
                    c1m2_hazy_path.loiren_current_dest_point = "loiren_dest_point6"
                    sleep()
                    MoveHeroRealTime(hero, RegionToPoint(c1m2_hazy_path.loiren_current_dest_point))
                    return
                end
                if region ~= "loiren_dest_point6" then
                    EnableHeroAI(hero, nil)
                    c1m2_hazy_path.loiren_waiting = 1
                    Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, region, nil)
                    if region == "loiren_dest_point3" then
                        c1m2_hazy_path.loiren_current_dest_point = "loiren_dest_point4"
                    end
                end
            end
        end
    end,

    --#endregion

    --#region Elf posts logic

    InitPosts =
    function ()
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "first_garrison_enter", "c1m2_hazy_path.EnterFirstPost")
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "second_garrison_enter", "c1m2_hazy_path.EnterSecondPost")
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "third_garrison_enter", "c1m2_hazy_path.EnterThirdPost")

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
    end,

    CapturePost =
    function (_, new_owner, _, object)
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
                startThread(c1m2_hazy_path.EnableLoiren)
            end
            return
        end
        --
        if hero == "Loiren" or hero == "Loiren_Heroic" then
            Object.Show(PLAYER_1, hero, 1)
            c1m2_hazy_path.posts_visited_by_loiren = c1m2_hazy_path.posts_visited_by_loiren + 1
            Object.RemoveTable(c1m2_hazy_path.first_garrison_units)
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

        if hero == "Loiren" or hero == "Loiren_Heroic" then
            Object.RemoveTable(c1m2_hazy_path.second_garrison_units)
            RemoveObject("Ossir")
            Hero.CreatureInfo.Add(hero, CREATURE_UNICORN, 2 + 2 * defaultDifficulty)
            local grand_elves_count = GetHeroCreatures(hero, CREATURE_GRAND_ELF)
            local sharp_shooters_count = GetHeroCreatures(hero, CREATURE_SHARP_SHOOTER)
            if grand_elves_count ~= 0 then
                Hero.CreatureInfo.Add(hero, CREATURE_SHARP_SHOOTER, grand_elves_count + ((random(5) + 1) * Random.FromSelection(1, -1)))
                return
            end
            if sharp_shooters_count ~= 0 then
                Hero.CreatureInfo.Add(hero, CREATURE_GRAND_ELF, sharp_shooters_count + ((random(5) + 1) * Random.FromSelection(1, -1)))
                return
            end
        end
    end,

    EnterThirdPost =
    function (hero, region)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        if hero == "Karlam" then
            BlockGame()
            sleep(30)
            MoveHeroRealTime("Linaas", 86, 69, GROUND)
            sleep(5)
            SetObjectPosition("Linaas", 86, 68, GROUND, 0)
            sleep()
            MoveHeroRealTime("Linaas", GetObjectPosition(hero))
            return
        end
        if hero == "Loiren" or hero == "Loiren_Heroic" then
            RemoveObject("Linaas")
            Hero.CreatureInfo.AddByTier(
                hero,
                TOWN_PRESERVE, 1, 10 + 12 * defaultDifficulty,
                TOWN_PRESERVE, 2, 7 + 8 * defaultDifficulty,
                TOWN_PRESERVE, 6, defaultDifficulty
            )
            return
        end
    end,

    --#endregion

    --#region Dark obelisks logic

    InitObelisks =
    function ()
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
            -- print("Setting up obelisk: ", obelisk)
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

        if object == "first_dark_obelisk" then
            startThread(c1m2_hazy_path.PrepareLoirenArrival)
        end

        Npc.FinishInteraction("use")
    end,

    InformObeliskAlreadyUsed =
    function (_, _)
        MessageBox(c1m2_hazy_path.path.text.."obelisk_already_used.txt")
        Npc.FinishInteraction("already_used")
    end,

    TryUseDarkPortal =
    function (_, _)
        MessageBox(c1m2_hazy_path.path.text.."cant_use_portal.txt")
        Npc.FinishInteraction("use")
    end,

    --#endregion
}