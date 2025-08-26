
c1m2_intriguer = {

    --#region Data
    name = "INTRIGUER",
    path = {
        main = "UserCampaigns/Prologue/M2/Quests/Primary/Intriguer",
        text = "UserCampaigns/Prologue/M2/Quests/Primary/Intriguer/Texts/",
        dialog = "UserCampaigns/Prologue/M2/Quests/Primary/Intriguer/Dialogs/",
        fight = "UserCampaigns/Prologue/M2/Quests/Primary/Intriguer/Fights/"
    },

    --#endregion

    --#region Init

    Load = 
    function()
        Quest.Names["INTRIGUER"] = "UserCampaigns/Prologue/M2/Quests/Primary/Intriguer/name.txt"
    end,

    Init = 
    function ()
        DeployReserveHero("Noellie", RegionToPoint("noe_return"))
        DeployReserveHero("Inagost", RegionToPoint("kelo_return"))
        while not (IsObjectExists("Inagost") and IsObjectExists("Noellie")) do
            sleep()
        end
        EnableHeroAI("Noellie", nil)
        EnableHeroAI("Inagost", nil)
        --
        Touch.DisableObject("dungeon_enter")
        Touch.SetFunction("dungeon_enter", "enter", c1m2_intriguer.EnterDungeon)
        --
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'kelo_meet_region', 'c1m2_intriguer.MeetDarkElves')
        for i = 1, 2 do
            Touch.DisableMonster("witch"..i, DISABLED_DEFAULT, 0)
        end
    end,

    --#endregion

    --#region Start

    EnterDungeon = 
    function (hero, object)
        Touch.RemoveFunctions(object)
        SetWarfogBehaviour(0, 0, PLAYER_1)
        OpenRegionFog(PLAYER_1, 'kelo_meet_region')
        OpenRegionFog(PLAYER_1, 'dung_fog_enter')
        SetObjectEnabled(object, 1)
        sleep()
        RazeTown("c1m2_post_town")
        sleep()
        RemoveObject("c1m2_post_town")
        MakeHeroInteractWithObject(hero, object)
    end,

    MeetDarkElves = 
    function (_, region)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        for i = 1, 9 do
            OpenRegionFog(PLAYER_1, 'dung_fog_reg_0'..i)
        end
        for _, region in {'dung_gates', 'kelo_meet_point', 'noe_meet_point'} do
            OpenRegionFog(PLAYER_1, region)
        end
        sleep()

        consoleCmd('setvar adventure_speed_ai = 1')
        BlockGame()
        MoveCamera(79, 81, 1, 40, math.pi/6, math.pi/2)
        sleep(80)
        PlayObjectAnimation('dung_gates', 'open', ONESHOT_STILL)
        sleep(50)
        local kx, ky, kz = RegionToPoint('kelo_meet_point')
        -- only this trash code allows to rotate heroes correct in final point
        startThread(
        function()
            local kx = %kx 
            local ky = %ky 
            local kz = %kz
            MoveHeroRealTime("Inagost", kx, ky, kz)
            while 1 do
                local x, y, z = GetObjectPosition("Inagost")
                if x == kx and y == ky and z == kz then
                    SetObjectRotation("Inagost", 90)
                    break
                end
                sleep()
            end
        end)
        sleep(50)
        local nx, ny, nz = RegionToPoint('noe_meet_point')
        -- same
        startThread(
        function()
            local nx = %nx 
            local ny = %ny 
            local nz = %nz
            MoveHeroRealTime("Noellie", nx, ny, nz)
            while 1 do
                local x, y, z = GetObjectPosition("Noellie")
                if x == nx and y == ny and z == nz then
                    SetObjectRotation("Noellie", 90)
                    break
                end
                sleep()
            end
        end)
        sleep(40)
        PlayObjectAnimation('dung_gates', 'close', ONESHOT_STILL)
        sleep(20)
        StartDialogScene(DIALOG_SCENES.DUNGEON_GATES)
        sleep(5)
        PlayObjectAnimation('dung_gates', 'open', ONESHOT_STILL)
        sleep(40)
        MoveHeroRealTime("Noellie", RegionToPoint('noe_return'))
        sleep(40)
        MoveHeroRealTime("Inagost", RegionToPoint('kelo_return'))
        sleep(40)
        Object.RemoveSelection("Noellie", "Inagost")
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dung_gates', 'c1m2_intriguer.ProcessWitchesAmbush')
        UnblockGame()
        UnblockGame() -- nival so good
        consoleCmd('setvar adventure_speed_ai = 5')
    end,

    ProcessWitchesAmbush = 
    function (hero, region)
        if hero == "Karlam" then
            BlockGame()
            MoveCamera(74, 81, 1, 40, math.pi/4, -math.pi/2)
            CreateMonster('witch3', CREATURE_MATRIARCH, 1, 72, 81, GROUND, 3, 1, 90)
            sleep(5)
            Touch.DisableMonster('witch3', DISABLED_INTERACT, 0)
            sleep(60)
            SetObjectPosition('witch3', 72, 81, UNDERGROUND)
            sleep(10)
            for i = 1, 3 do
                startThread(
                function()
                    OpenRegionFog(PLAYER_1, 'witch'..%i)
                    sleep(40)
                    PlayObjectAnimation('witch'..%i, 'cast', ONESHOT)
                end)
            end
            sleep(50)
            SetObjectFlashlight('ambush_lamp1', 'matron_lamp')
            SetObjectFlashlight('ambush_lamp2', 'matron_lamp')
            sleep(15)
            FX.Play('Forgetfulness', hero, '', 0, 0, 0)
            sleep(100)
            startThread(
            function()
                StartDialogSceneInt(DIALOG_SCENES.WITCHES_RITUAL, "c1m2_intriguer.SetupBaalFormFight")
                UnblockGame()
                local x, y, z = RegionToPoint('karlam_ritual')
                DeployReserveHero("Baal", x, y, z)
                while not IsObjectExists("Baal") do
                    sleep()
                end
                SetObjectOwner("Baal", PLAYER_1)
                while not GetObjectOwner("Baal") do
                    sleep()
                end
                SetObjectOwner("Karlam", PLAYER_3)
                sleep()
                EnableHeroAI("Karlam", nil)
                SetObjectPosition("Karlam", 1, 1, 1)
                Object.Show(PLAYER_1, "Baal", 1)
                ResetObjectFlashlight('ambush_lamp1')
                ResetObjectFlashlight('ambush_lamp2')
                Object.RemoveSelection('witch1', 'witch2', 'witch3')
            end)
        end
    end,

    SetupBaalFormFight = 
    function ()
        doFile(c1m2_intriguer.path.fight.."c1m2_baal_form_fight_data.lua")
        DeployReserveHero("Noellie", RegionToPoint("noe_escape_start"))
        while not (IsObjectExists("Noellie") and c1m2_baal_form_fight_data) do
            sleep()
        end
        EnableHeroAI("Noellie", nil)
        SetObjectRotation("Noellie", 90)
        OpenRegionFog(PLAYER_1, "noe_escape_bridge")
        OpenRegionFog(PLAYER_1, "baal_fight_reg")
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "baal_fight_reg", "c1m2_intriguer.StartBaalFormFight")
    end,

    StartBaalFormFight = 
    function (hero, region)
        Object.Show(PLAYER_1, "Noellie")
        local fight_data = FightGenerator.SetupNeutralsCombat(c1m2_baal_form_fight_data)
        print("Stacks data: ", fight_data)
        sleep(50)
        if MCCS_StartCombat(hero, "Noellie_copy", fight_data.stacks_count, fight_data.stacks_info, 1, nil) then
            RemoveObject("Noellie")
        end
    end,
    --#endregion
}