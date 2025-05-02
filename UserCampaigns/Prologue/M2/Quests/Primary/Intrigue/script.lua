-- @quest
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Квест: Интриганка.
-- Тип квеста: Основной.

    --*КОНСТАНТЫ*--
ARTIFACT_DUNGEON_TEMPLE_PRISON_KEY = 400

intrigue =
{
        -- *Переменные* --
    
    -- техническая информация --
    name = "INTRIGUE",
    path = 
    {
        text = q_path.."Primary/Intrigue/Texts/",
        dialog = q_path.."Primary/Intrigue/Dialogs/"
    },

    dialogs =
    {
        BaalStart = "GOG_M1_Q_UNKNOWN_PATH_FIRST_OBELISK_DIALOG",
        BaalFirstNight = "GOG_M1_Q_UNKNOWN_PATH_SECOND_OBELISK_DIALOG",
        ScoutsTrapCorridor = "GOG_M1_SCOUTS_TRAP_CORRIDOR_DIALOG"
    },

    -- таблица фурий у кровавого алтаря
    blood_altar_furies = {'fury_main_01', 'fury_main_02', 'fury_exec_01', 'fury_exec_02', 'fury_exec_03', 'fury_exec_04'},
    -- флаг, что бой с фуриями был выигран
    fury_fight_won = 0,
    -- флаг активности цикла анимаций фурий у алтаря
    fury_trap_cycle_flag = 0,
    -- флаг, что ключ от каземата получен(сделать артефакт)
    prison_key = 0,
    -- флаг, что палочка с берсерком получена
    got_bers_stick = 0,
    -- число открытых тюрем
    prisons_opened = 0,
    -- флаг получения инфы о возможности кастануть берса в драконов
    dragon_info = 0,
    -- флаг, что применили берса на драконов
    dragon_bers = 0,
    -- флаг доступности портала в палаты интриг
    matron_portal_opened = 1,

    Init = 
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.Init")
        end)
        -- вход в подземку
        for i = 1, 2 do
            Touch.DisableMonster('witch'..i, DISABLED_INTERACT, 0)
        end
        EnableHeroAI("Noellie", nil)
        EnableHeroAI("Kelodin", nil)
        Touch.DisableObject('dung_enter')
        Touch.SetFunction('dung_enter', '_enter', intrigue.DungEnter)
        --
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'kelo_meet_region', 'intrigue.KelodinMeet')
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'fury_fight_reg', 'intrigue.FuryTrapShow')
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'fury_fight_fog_reg', 'intrigue.FuryFight')
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'death_pit_enter_reg', 'intrigue.DeathPitFight')
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dragon_trap_info', 'intrigue.intrigue.DragonTrapInfo')
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dragon_trap_enter', 'intrigue.DragonTrapEnter')
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'noelli_fight', 'intrigue.NoelliFight')
        -- кровавый алтарь
        for i, fury in intrigue.blood_altar_furies do
            Touch.DisableMonster(fury, DISABLED_ATTACK, 0)
        end
        Animation.NewGroup("furies", intrigue.blood_altar_furies)
        -- яма смерти
        for i, creature in GetObjectsInRegion('death_pit_reg', 'CREATURE') do
            Touch.DisableMonster(creature, DISABLED_BLOCKED, 0)
        end
        for i, creature in GetObjectsInRegion('death_pit_fight_reg', 'CREATURE') do
            Touch.DisableMonster(creature, DISABLED_INTERACT, 0)
        end
        -- портал в заклинательный покой
        Touch.DisableObject('magic_room_portal_out')
        Touch.SetFunction('magic_room_portal_out', '_p_out', intrigue.MagicRoomPortalEnter)
        -- каземат: портал
        Touch.DisableObject('prison_portal_in')
        Touch.SetFunction('prison_portal_in', '_p_prison', intrigue.PrisonPortalTouch)
        --
        -- for i, lib in {'lib_chaos', 'lib_dark', 'lib_light', 'lib_summon'} do
        --     Touch.DisableObject(lib, nil, o_path..lib..'_n.txt', o_path..lib..'_d.txt')
        --     Touch.SetFunction(lib, '_lib_touch', LibTouch)
        -- end
        -- каземат: тюрьмы
        for i, prison in {'prison_01', 'prison_02', 'prison_03', 'prison_04'} do
            Touch.DisableObject(prison)
            Touch.SetFunction(prison, '_prison_touch', intrigue.PrisonTouch)
        end
        -- каземат: драконы
        for i, dragon in {'red_dragon_01', 'red_dragon_02'} do
            Touch.DisableMonster(dragon, DISABLED_BLOCKED, 0)
        end

        print("<color=green>M1_Q_Intrigue.Init successfull")
    end,

    -- касание входа в подземный храм
    DungEnter =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.DungEnter")
        end)
        Touch.RemoveFunctions(object)
        SetWarfogBehaviour(0, 0)
        OpenRegionFog(PLAYER_1, 'kelo_meet_region')
        OpenRegionFog(PLAYER_1, 'dung_fog_enter')
        SetObjectEnabled(object, 1)
        sleep()
        if IsObjectExists("Loiren") then
            RemoveObject("Loiren")
        end
        MakeHeroInteractWithObject(hero, object)
    end,

    -- регион у ворот данжа
    KelodinMeet = 
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.KelodinMeet")
        end)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        BlockGame()
        for i = 1, 9 do
            OpenRegionFog(PLAYER_1, 'dung_fog_reg_0'..i)
        end
        for i, region in {'dung_gates', 'kelo_meet_point', 'noe_meet_point'} do
            OpenRegionFog(PLAYER_1, region)
        end
        sleep()
        -- для адекватной скорости перемещения героев
        consoleCmd('setvar adventure_speed_ai = 2')
        MoveCamera(79, 81, 1, 40, math.pi/6, math.pi/2)
        sleep(20)
        PlayObjectAnimation('dung_gates', 'open', ONESHOT_STILL)
        sleep(12)
        local kx, ky, kz = RegionToPoint('kelo_meet_point')
        -- поток проверяет достижение героем нужного тайла и разворачивает его лицом к игроку
        -- иначе разворачивается неправильно
        startThread(
        function()
            local kx = %kx 
            local ky = %ky 
            local kz = %kz
            MoveHeroRealTime("Kelodin", kx, ky, kz)
            while 1 do
                local x, y, z = GetObjectPosition("Kelodin")
                if x == kx and y == ky and z == kz then
                    SetObjectRotation("Kelodin", 90)
                    break
                end
                sleep()
            end
        end)
        sleep(5)
        local nx, ny, nz = RegionToPoint('noe_meet_point')
        -- аналогично предыдущему
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
        sleep(10)
        PlayObjectAnimation('dung_gates', 'close', ONESHOT_STILL)
        sleep(5)
        StartDialogScene(DIALOG_SCENES.DUNGEON_GATES)
        sleep()
        PlayObjectAnimation('dung_gates', 'open', ONESHOT_STILL)
        sleep(10)
        MoveHeroRealTime("Noellie", RegionToPoint('noe_return'))
        sleep(10)
        MoveHeroRealTime("Kelodin", RegionToPoint('kelo_return'))
        sleep(10)
        Object.RemoveSelection("Noellie", "Kelodin")
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dung_gates', 'Ambush')
        -- вернуть ии макс. скорость
        consoleCmd('setvar adventure_speed_ai = 5')
        UnblockGame()
    end,

    -- засада ведьм за воротами
    WitchAmbush =
    function(hero)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.WitchAmbush")
        end)
        if hero == "Karlam" then
            BlockGame()
            MoveCamera(74, 81, 1, 40, math.pi/4, -math.pi/2)
            CreateMonster('witch3', CREATURE_MATRIARCH, 1, 72, 81, GROUND, 3, 1, 90)
            sleep()
            Touch.DisableMonster('witch3', DISABLED_INTERACT, 0)
            sleep(15)
            SetObjectPosition('witch3', 72, 81, UNDERGROUND)
            sleep(2)
            for i = 1, 3 do
                startThread(
                function()
                    OpenRegionFog(PLAYER_1, 'witch'..%i)
                    sleep(10)
                    PlayObjectAnimation('witch'..%i, 'cast', ONESHOT)
                end)
            end
            sleep(3)
            SetObjectFlashlight('ambush_lamp1', 'matron_lamp')
            SetObjectFlashlight('ambush_lamp2', 'matron_lamp')
            sleep(15)
            FX.Play('Forgetfulness', hero, '', 0, 0, 0)
            sleep(23)
            startThread(
            function()
                StartDialogSceneInt(DIALOG_SCENES.WITCHES_RITUAL, "intrigue.NoeEscapeStart")
                UnblockGame()
                local x, y, z = RegionToPoint('karlam_ritual')
                DeployReserveHero("Baal", x, y, z)
                sleep()
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

    -- начинает демонстрацию побега Ноэлли игроку.
    -- 1. Выставить Ноэлли на карту.
    -- 2. Показать перемещение к первой контрольной точке
    -- 3. В процессе пути Ноэлли проходит по некоторым регионам, которые должны быть интерактивны только для игрока,
    --    включить их, когда она прошла через них.
    NoeEscapeStart =
    function()
        -- 1
        local x, y, f = RegionToPoint("noe_escape_start")
        DeployReserveHero("Noellie", x, y, f)
        while not IsObjectExists("Noellie") do
            sleep()
        end
        SetObjectRotation("Noellie", 270)
        sleep()
        -- 2
        OpenRegionFog(PLAYER_1, "noe_escape_bridge")
        sleep()
        MoveHeroRealTime("Noellie", RegionToPoint("noe_escape_point_1"))
        sleep(10)
        -- 3
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'baal_fight_reg', 'intrigue.BaalFight')
        SetWarfogBehaviour(1, 1)
    end,

    -- бой Баала с армией отступающей Ноэлли
    BaalFight =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.BaalFight")
        end)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        if MCCS_StartCombat(hero, nil, 1, {CREATURE_STALKER, 1000}, nil, nil, nil, 1) then
            startThread(intrigue.ReverseTransform)
        end
    end,

    -- обратное превращение Баала в Карлама
    ReverseTransform =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.ReverseTransform")
        end)
        BlockGame()
        Object.Show(PLAYER_1, "Baal", 1)
        local x, y, z = GetObjectPosition("Baal")
        FX.Play('Implosion', "Baal")
        sleep(20)
        SetObjectPosition("Karlam", x, y, z)
        sleep()
        SetObjectOwner("Karlam", PLAYER_1)
        sleep()
        RemoveObject("Baal")
        UnblockGame()
        MiniDialog.Start(intrigue.path.dialog..'AfterRitualDialog/', PLAYER_1)
        -- !добавить второй диалог с Баалом
        Quest.Start(intrigue.name, "Karlam")
        intrigue.ShowNoellieMovement("noe_escape_point_2")
    end,

    -- показывает перемещение Ноэлли в следующую контрольную точку, активирует логику пройденных ей регионов для игрока.
    ShowNoellieMovement =
    function(next_point)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.ShowNoellieMovement")
        end)
        Object.Show(PLAYER_1, "Noellie", 1, 1)
        sleep(5)
        if next_point == "noe_escape_point_2" then
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'show_garg_reg', 'scouts.FirstGargMeeting')
            MoveHeroRealTime("Noellie", RegionToPoint(next_point))
        elseif next_point == "noe_escape_point_3"
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'ballista_info_reg', 'intrigue.BallistaInfo')
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'ballista_attack_reg', 'intrigue.BallistaAttack')
            MoveHeroRealTime("Noellie", RegionToPoint(next_point))
        elseif next_point == "noe_escape_point_4" then
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, "trap_corridor_info_reg", "intrigue.TrapCorridorStart")
            MoveHeroRealTime("Noellie", 63, 24, UNDERGROUND)
            sleep(5)
            local x, y, f = RegionToPoint(next_point)
            SetObjectPosition("Noellie", x, y, f)
        elseif next_point == "noe_escape_point_5" then
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'templar_2_reg', 'intrigue.Templar2Attack')
            MoveHeroRealTime("Noellie", RegionToPoint(next_point))
            sleep(10)
            RemoveObject("Noellie")
            Touch.DisableObject('matron_chambers_portal_in')
            Touch.SetFunction('matron_chambers_portal_in', '_matron_portal', intrigue.MatronPortalEnter)
        end
    end,

    -- логика анимаций фурий у кровавого алтаря
    FuryTrapAnimsThread =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.FuryTrapAnimsThread")
        end)
        startThread(
        function()
            sleep(random(5))
            while intrigue.fury_fight_won == 0 and intrigue.fury_trap_cycle_flag == 0 do
                local gr_type = Random.FromTable(TIER_TABLES[TOWN_ACADEMY][1])
                CreateMonster('rit_grem_01', gr_type, 1, 1, 1, 0, 3, 1, random(360) + 1)
                sleep()
                Touch.DisableMonster('rit_grem_01', DISABLED_INTERACT, 0)
                sleep()
                SetObjectPosition('rit_grem_01', RegionToPoint('furies_grem_spawn_reg_1'))
                sleep(5)
                PlayObjectAnimation('fury_exec_01', 'attack00', NON_ESSENTIAL)
                sleep(3)
                PlayObjectAnimation('rit_grem_01', 'hit', ONESHOT)
                sleep(5)
                PlayObjectAnimation('fury_exec_02', 'attack00', NON_ESSENTIAL)
                sleep(5)
                PlayObjectAnimation('rit_grem_01', 'death', ONESHOT_STILL)
                sleep(5)
                FX.Play('Big_fire_1', 'rit_grem_01', 'rit_grem_fire_01')
                sleep(10)
                StopVisualEffects('rit_grem_fire_01')
                RemoveObject('rit_grem_01')
                FX.Play('Bloodlust', 'blood_altar_01')
                sleep()
                PlayObjectAnimation('fury_main_01', 'happy', NON_ESSENTIAL)
                repeat
                    sleep()
                until not IsObjectExists('rit_grem_01')
                def_noe.fury_trap_cycle_flag = 1
                sleep(15)
                if def_noe.fury_trap_cycle_flag == 1 then
                    def_noe.fury_trap_cycle_flag = 0
                else
                    return
                end
            end
        end)
        --
        startThread(
        function()
            sleep(random(12))
            while intrigue.fury_fight_won == 0 and intrigue.fury_trap_cycle_flag == 0 do
                local gr_type = Random.FromTable(TIER_TABLES[TOWN_ACADEMY][1])
                CreateMonster('rit_grem_02', gr_type, 95, 1, 1, 0, 3, 1, random(360) + 1)
                sleep()
                Touch.DisableMonster('rit_grem_02', DISABLED_INTERACT, 0)
                sleep()
                SetObjectPosition('rit_grem_02', RegionToPoint('furies_grem_spawn_reg_2'))
                sleep(5)
                PlayObjectAnimation('fury_exec_03', 'attack00', NON_ESSENTIAL)
                sleep(3)
                PlayObjectAnimation('rit_grem_02', 'hit', ONESHOT)
                sleep(5)
                PlayObjectAnimation('fury_exec_04', 'attack00', NON_ESSENTIAL)
                sleep(5)
                PlayObjectAnimation('rit_grem_02', 'death', ONESHOT_STILL)
                sleep(5)
                FX.Play('Big_fire_1', 'rit_grem_02', 'rit_grem_fire_02')
                sleep(10)
                StopVisualEffects('rit_grem_fire_02')
                RemoveObject('rit_grem_02')
                FX.Play('Bloodlust', 'blood_altar_02')
                sleep()
                PlayObjectAnimation('fury_main_02', 'happy', NON_ESSENTIAL)
                repeat
                    sleep()
                until not IsObjectExists('rit_grem_02')
                def_noe.fury_trap_cycle_flag = 1
                sleep(15)
                if def_noe.fury_trap_cycle_flag == 1 then
                    def_noe.fury_trap_cycle_flag = 0
                else
                    return
                end
            end
        end)
    end,

    -- регион рядом с кровавым алтарем
    FuryTrapShow =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.FuryTrapShow")
        end)
        startThread(intrigue.FuryTrapAnimsThread)
        --
        startThread(
        function()
            while 1 do
                if intrigue.fury_trap_cycle_flag < 2 then
                    if (length(GetObjectsInRegion('fury_fight_reg', 'HERO')) + length(GetObjectsInRegion('fury_fight_fog_reg', 'HERO'))) == 0 then
                        print('fury trap anims aborted')
                        intrigue.fury_trap_cycle_flag = 2
                    end
                elseif def_noe.fury_trap_cycle_flag == 2 then
                    if (length(GetObjectsInRegion('fury_fight_reg', 'HERO')) + length(GetObjectsInRegion('fury_fight_fog_reg', 'HERO'))) > 0 then
                        print('fury trap anims started again')
                        intrigue.fury_trap_cycle_flag = 0
                        startThread(intrigue.FuryTrapAnimsThread)
                    end
                end
                sleep()
            end
        end)
        --
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        --
        OpenRegionFog(PLAYER_1, 'fury_fight_fog_reg')
        sleep()
        MoveCamera(10, 52, UNDERGROUND, 50, 0, 0, 0, 1)
        sleep(50)
        MessageBox(intrigue.path.text.."bloody_altar_show_msg.txt")
    end,

    -- бой с фуриями у алтаря
    FuryFight =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.FuryFight")
        end)
        if hero == "Karlam" then
            SetGameVar('dung_fight', 'fury')
            if MCCS_StartCombat(hero, nil, 3,
                            {CREATURE_BLOOD_WITCH, 150,
                            CREATURE_BLOOD_WITCH, 200,
                            CREATURE_BLOOD_WITCH_2, 134},
                            nil, nil, nil, 1) then
                Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
                SetGameVar('dung_fight', 'none')
                intrigue.fury_fight_won = 1
                sleep(5)
                --
                Animation.PlayGroup('furies', {'death'}, Animation.PLAY_CONDITION_SINGLEPLAY, ONESHOT_STILL)
                sleep(15)
                Object.RemoveTable(intrigue.blood_altar_furies)
                --
                MessageBox(intrigue.path.text.."bloody_altar_gremlins_add.txt")
                Hero.CreatureInfo.Add(hero, CREATURE_GREMLIN_SABOTEUR, 130 - 10 * initialDifficulty)
            end
        end
    end,
    
    -- бой у ямы смерти
    DeathPitFight =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.DeathPitFight")
        end)
        Animation.PlayGroup('dp_st', {'hit'}, COND_OBJECT_EXISTS)
        Animation.PlayGroup('dp_u', {'attack00'}, COND_OBJECT_EXISTS)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        OpenRegionFog(PLAYER_1, 'death_pit_fight_reg')
        OpenRegionFog(PLAYER_1, 'death_pit_reg')
        MoveCamera(6, 28, UNDERGROUND, 40, 0, 0, 1, 1)
        sleep(30)
        if MCCS_StartCombat(hero, nil, 4,
                       {CREATURE_MUMMY, 18,
                       CREATURE_MUMMY, 16,
                       CREATURE_ZOMBIE, 42,
                       CREATURE_WALKING_DEAD, 55},
                       nil, nil, nil, 1) then
            Animation.AbortThread('dp_st')
            Animation.PlayGroup('dp_u', {'death'}, COND_SINGLE, ONESHOT_STILL)
            sleep(15)
            Object.RemoveTable(Animation.Groups['dp_u'].actors)
            sleep(5)
            -- MessageBox(MainQ.path..'asassin_1.txt') -- добавить диалог
            Object.RemoveTable(Animation.Groups['dp_st'].actors)
            Hero.CreatureInfo.Add(hero, CREATURE_STALKER, 7 - DefaultDifficulty)
        end
    end,

    -- регион рядом с зачарованными баллистами
    BallistaInfo =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.BallistaInfo")
        end)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        Object.Show(PLAYER_1, 'ballista_02', 1, 1)
        sleep(15)
        MessageBox(intrigue.path.text..'ballista_info.txt')
    end,
      
    BallistaAttack =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.BallistaAttack")
        end)
        if HasHeroSkill(hero, WIZARD_FEAT_REMOTE_CONTROL) and
            MCCS_QuestionBox(intrigue.path.text..'control_ballista.txt') then
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
            --
            MessageBox(intrigue.path.text..'ballista_controled.txt', 'UnblockGame')
        elseif GetHeroCreatures(Karlam, CREATURE_GREMLIN_SABOTEUR) > 0 and
               MCCS_QuestionBox(intrigue.path.text..'disable_ballista.txt') then
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
            BlockGame()
            MoveCamera(22, 13, 1, 30, math.pi/8, -math.pi, 0, 1)
            sleep(15)
            CreateMonster('grem_01', CREATURE_GREMLIN_SABOTEUR, 1, 1, 1, GROUND, 3, 1, 0)
            CreateMonster('grem_02', CREATURE_GREMLIN_SABOTEUR, 1, 5, 5, GROUND, 3, 1, 0)
            sleep()
            Touch.DisableMonster('grem_01', DISABLED_BLOCKED, 0)
            Touch.DisableMonster('grem_02', DISABLED_BLOCKED, 0)
            sleep()
            SetObjectPosition('grem_01', RegionToPoint('grem_01_reg'))
            SetObjectPosition('grem_02', RegionToPoint('grem_02_reg'))
            sleep()
            PlayObjectAnimation('grem_01', 'specability', ONESHOT)
            PlayObjectAnimation('grem_02', 'specability', ONESHOT)
            sleep(10)
            for i = 1, 3 do
                FX.Play('Sabotage', 'ballista_0'..i)
                PlayObjectAnimation('ballista_0'..i, 'hit', ONESHOT)
                sleep()
            end
            sleep(5)
            Object.RemoveSelection('grem_01', 'grem_02')
            MessageBox(intrigue.path.text..'ballista_disabled.txt', 'UnblockGame')
        else
            BlockGame()
            for i = 1, 3 do
                PlayObjectAnimation('ballista_0'..i, 'rangeattack', ONESHOT)
                sleep(5)
                for i = 1, 2 + random(4) do
                FX.Play('Fireball', hero, '', (0.1 * random(4)) * (random(2) == 1 and 1 or -1), (0.1 * random(4)) * (random(2) == 1 and 1 or -1))
                sleep()
                end
            end
            MessageBox(intrigue.path.text..'ballista_attack.txt', 'UnblockGame')
            RemoveObject(hero)
            Loose()
        end
    end,

    -- портал в подземный каземат
    PrisonPortalTouch =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.PrisonPortalTouch")
        end)
        if not HasArtefact(hero, ARTIFACT_DUNGEON_TEMPLE_PRISON_KEY) then
            ShowFlyingSign(intrigue.path.text.."no_key_for_prison.txt", object, -1, 7.0)
        else
            ShowFlyingSign(intrigue.path.text.."prison_key_used.txt", object, -1, 7.0)
            RemoveArtefact(hero, ARTIFACT_DUNGEON_TEMPLE_PRISON_KEY)
            SetObjectEnabled(object, 1)
            Touch.RemoveFunctions(object)
            sleep()
            MakeHeroInteractWithObject(hero, object)
        end
    end,

    -- касания тюрем в каземате
    PrisonTouch =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.PrisonTouch")
        end)
        --AddCreatures()
        intrigue.prisons_opened = intrigue.prisons_opened + 1
        if intrigue.prisons_opened == 3 then
            BlockGame()
            DeployReserveHero("Ohtar", 44, 92, UNDERGROUND)
            sleep()
            Object.Show(PLAYER_1, "Ohtar", 1)
            sleep(7)
            MessageBox(intrigue.path.text..'templar_3_attack.txt', 'UnblockGame')
            sleep()
            MoveHeroRealTime("Ohtar", GetObjectPosition(hero))
        end
        Touch.OverrideFunction(object, '_prison_touch',
        function(hero, object)
            ShowFlyingSign(intrigue.path.text.."prison_empty.txt", object, -1, 7.0)
        end)
    end,

    -- регион рядом с красными драконами
    DragonTrapInfo =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.DragonTrapInfo")
        end)
        if hero == "Karlam" then
            if intrigue.dragon_info == 0 then
                intrigue.dragon_info = 1
                Object.Show(PLAYER_1, 'red_dragon_01')
                MoveCamera(50, 87, UNDERGROUND, 20, 0, 0, 0, 1)
                sleep(18)
                MessageBox(intrigue.path.text..'dragon_trap_info.txt')
                intrigue.DragonTrapInfo(hero, region)
            end
            if def_noe.got_bers_stick == 1 and HasArtefact(hero, ARTIFACT_WAND_OF_X) and
                def_noe.dragon_bers == 0 and
                MCCS_QuestionBox(intrigue.path.text..'use_bers_on_dragons.txt') then
                Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
                Object.Show(PLAYER_1, 'red_dragon_02')
                sleep(5)
                for i, dragon in {'red_dragon_01', 'red_dragon_02'} do
                    FX.Play('Berserk', dragon)
                    sleep()
                end
                intrigue.dragon_bers = 1
            end
        end
    end,

    -- регион, в котором драконы атакуют героев
    DragonTrapEnter =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.DragonTrapEnter")
        end)
        BlockGame()
        if hero == "Karlam" then
            if intrigue.dragon_bers == 2 and
                MCCS_StartCombat("Karlam", nil, 2, {CREATURE_RED_DRAGON, 2, CREATURE_RED_DRAGON, 2}) then
                Object.RemoveSelection('red_dragon_01', 'red_dragon_02')
                Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
                UnblockGame()
            else
                for i, dragon in {'red_dragon_01', 'red_dragon_02'} do
                    PlayObjectAnimation(dragon, 'attack00', ONESHOT)
                end
                sleep(10)
                RemoveObject("Karlam")
            end
        else
            if intrigue.dragon_bers == 1 then
                for i, dragon in {'red_dragon_01', 'red_dragon_02'} do
                    PlayObjectAnimation(dragon, 'attack00', ONESHOT)
                end
                sleep(10)
                RemoveObject(hero)
                local prob = random(2) + 1
                PlayObjectAnimation('red_dragon_0'..prob, 'death', ONESHOT_STILL)
                sleep(15)
                --RemoveObject('red_dragon_0'..prob)
                sleep(5)
                MessageBox(intrigue.path.text..'templar_3_dead.txt', 'UnblockGame')
                intrigue.dragon_bers = 2
            end
        end
        UnblockGame()
    end,

    -- портал уровня интриг
    MatronPortalEnter =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.MatronPortalEnter")
        end)
        SetWarfogBehaviour(0, 0)
        SetObjectEnabled(object, 1)
        Touch.RemoveFunctions(object)
        OpenRegionFog(PLAYER_1, 'noelli_fight')
        OpenRegionFog(PLAYER_1, 'noe_fight_portal')
        sleep()
        MakeHeroInteractWithObject(hero, object)
    end,

    -- бой с Ноэлли в палатах интриг
    NoelliFight =
    function(hero)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.NoelliFight")
        end)
        BlockGame()
        -- настройка параметров Ноэлли
        WarpHeroExp("Noellie", Levels[defaultDifficulty == DIFFICULTY_HEROIC and 16 or 15])
        if defaultDifficulty == DIFFICULTY_HEROIC then
            GiveHeroSkill("Noellie", SKILL_LUCK)
            GiveHeroSkill("Noellie", WARLOCK_FEAT_LUCKY_SPELLS)
            GiveArtefact("Noellie", ARTIFACT_EVERCOLD_ICICLE)
            GiveArtefact("Noellie", ARTIFACT_PHOENIX_FEATHER_CAPE)
            GiveArtefact("Noellie", ARTIFACT_TITANS_TRIDENT)
            GiveArtefact("Noellie", ARTIFACT_EARTHSLIDERS)
        end
        --
        ChangeHeroStat("Noellie", STAT_ATTACK, defaultDifficulty)
        ChangeHeroStat("Noellie", STAT_DEFENCE, defaultDifficulty)
        ChangeHeroStat("Noellie", STAT_SPELL_POWER, ceil(defaultDifficulty * 1.5))
        ChangeHeroStat("Noellie", STAT_KNOWLEDGE, ceil(defaultDifficulty * 2))
        -- эффекты при входе в зал
        MoveCamera(16, 81, UNDERGROUND, 55, math.pi/9, math.pi/3)
        sleep(20)
        for i = 1, 3 do
            OpenRegionFog(PLAYER_1, 'matron_fog_reg_'..i)
        end
        for i = 1, 6 do
            FX.Play('Fakel_dbl', 'm_ch_lamp_'..i)
            SetObjectFlashlight('m_ch_lamp_'..i, 'm_ch_fl')
            sleep(10)
        end
        --
        local t = TIER_TABLES[TOWN_DUNGEON]
        if MCCS_StartCombat(hero, 'Noellie', 6,
                    {Random.FromTable_IgnoreValue(t[1][1], t[1]), 58,
                    Random.FromTable_IgnoreValue(t[2][1], t[2]), 42,
                    Random.FromTable_IgnoreValue(t[2][1], t[2]), 40,
                    Random.FromTable_IgnoreValue(t[4][1], t[4]), 19,
                    Random.FromTable_IgnoreValue(t[5][1], t[5]), 9,
                    CREATURE_SHADOW_DRAGON, 1}, nil, nil,
                    ARENAS.MATRON_CHAMBERS, 1) then
            StartDialogScene(DIALOG_SCENES.FINAL, 'Win')
        end
    end,

    -- нападение стража в заклинательном покое
    Templar2Attack =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.Templar2Attack")
        end)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        BlockGame()
        unknown_path.UnblockDarkPortal('dark_portal_05')
        sleep(5)
        FX.Play('Dimension_door', 'dark_portal_05', '', 1, 1)
        sleep(5)
        DeployReserveHero("Dalom", 73, 29,  UNDERGROUND)
        sleep(10)
        MoveHeroRealTime("Dalom", GetObjectPosition(hero))
        UnblockGame()
    end,

    -- настроить заклинательный покой

    -- настроить коридор с ловушками, нападение стража там и возможность убить его законтроленными баллистами
    TrapCorridorStart =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.TrapCorridorStart")
        end)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        if hero == "Karlam" then
            local have_safe
            if GetHeroCreatures(hero, CREATURE_STALKER) > 0 then
                MiniDialog.Start(intrigue.path.dialog.."ScoutsTrapCorridorDialog/", PLAYER_1, intrigue.dialogs.ScoutsTrapCorridor)
                have_safe = 1
            end
            startThread(intrigue.TrapCorridorSetup, {"trap_corridor_11", "trap_corridor_12", "trap_corridor_13", "trap_corridor_14"}, have_safe)
            startThread(intrigue.TrapCorridorSetup, {"trap_corridor_21", "trap_corridor_22", "trap_corridor_23"}, have_safe)
            startThread(intrigue.TrapCorridorSetup, {"trap_corridor_31", "trap_corridor_32", "trap_corridor_33"}, have_safe)
        end
    end,

    TrapCorridorSetup = 
    function(possible_traps, have_safe)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.TrapCorridorSetup")
        end)
        local safe_place = ""
        if have_safe then
            safe_place = Random.FromTable(possible_traps)
            FX.Play(FX.Effects['Art_green'], first_trap_safe_place)
        end
        for i, trap in possible_traps do
            if trap ~= safe_place then
                Trigger(REGION_ENTER_AND_STOP_TRIGGER, trap, "intrigue.TrapCorridorActivate")
            end
        end
    end,

    TrapCorridorActivate = 
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_Intrigue.TrapCorridorActivate")
        end)
        local fx = Random.FromSelection("Ice_bolt", "Lightning_bolt", "Implosion", "Fireball")
        FX.Play(FX.Effects[fx], hero)
        for slot = 0, 6 do
            local creature, count = GetObjectArmySlotCreature(hero, slot)
            if not (creature == 0 or count == 0) then
                local remove_count = count * 0.2
                Hero.CreatureInfo.Add(creature, -remove_count)
            end
        end
    end
}