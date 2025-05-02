-- @quest
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Квест: Туманный путь.
-- Тип квеста: Основной.

unknown_path =
{
        -- *Переменные* --

    -- техническая информация --
    name = "UNKNOWN_PATH",
    path = 
    {
        dialog = q_path.."Primary/UnknownPath/Dialogs/",
        text = q_path.."Primary/UnknownPath/Texts/"
    },
    dialogs =
    {
        FirstObelisk = "GOG_M1_Q_UNKNOWN_PATH_FIRST_OBELISK_DIALOG",
        SecondObelisk = "GOG_M1_Q_UNKNOWN_PATH_SECOND_OBELISK_DIALOG"
    },
    -- эльфийские посты --
    -- пути к файлам арен
    posts = {ARENAS.POST_1, ARENAS.POST_2, ARENAS.POST_3},

    -- юниты, расположенные на постах
    posts_units =
    {
        [1] =
        {
            'post1_archer1', 'post1_archer2', 'post1_archer3',
            'post1_treant1', 'post1_treant2', 'post1_druid',
            'post1_dancer', 'post1_uni'
        },
        [2] =
        {
            'post2_archer1', 'post2_archer2', 'post2_archer3', 'post2_archer4',
            'post2_dancer1', 'post2_dancer2', 'post2_druid',
            'post2_treant1', 'post2_treant2', 'post2_uni1', 'post2_uni2',
            'post2_dragon1', 'post2_dragon2'
        },
    },

    -- инфа о респе энтов на 3 посте, ['имя юнита'] = {id существа, угол поворота модели}
    post3_treants =
    {
        ['treant_tree_1'] = {CREATURE_ANGER_TREANT, 46},
        ['treant_tree_2'] = {CREATURE_TREANT, 153},
        ['treant_tree_3'] = {CREATURE_TREANT_GUARDIAN, 211},
        ['treant_tree_4'] = {CREATURE_ANGER_TREANT, 288}
    },

    -- логика преследования Лойрена --
    -- флаг, что Лойрен достиг одной из ключевых точек и в данный момент не может достать героя = будет ждать в этой точке.

    loiren_waits = 0,

    -- ключевые точки перемещения Лойрена(1 = не посещена)
    loiren_dest =
    {
        ['loiren_dest1'] = 1,
        ['loiren_dest2'] = 1,
        ['loiren_dest3'] = 1
    },

    -- текущая ключевая точка для Лойрена
    loiren_current_dest = "loiren_dest1",

    loiren_initial_army = 
    {
        43 + 7 * initialDifficulty, 
        25 + 6 * initialDifficulty, 
        16 + 4 * initialDifficulty, 
        8 + 2.5 * initialDifficulty, 
        5 + initialDifficulty,
        1 + initialDifficulty, 
        defaultDifficulty - 2
    },

    loiren_post_army =
    {
        ['post1'] = {[2] = 3 * defaultDifficulty, [3] = 2 * defaultDifficulty, [4] = 2 + defaultDifficulty, 
                     [5] = defaultDifficulty, [6] = (defaultDifficulty > 2 and 1 or 0)},
        ['post2'] = {[1] = 6 * defaultDifficulty, [2] = 5 * defaultDifficulty, [3] = 3.5 * defaultDifficulty, 
                     [4] = 2 * defaultDifficulty, [5] = 1 + defaultDifficulty, [6] = (defaultDifficulty > 2 and 2 or 1)},
        ['post3'] = {[1] = 7 * defaultDifficulty, [2] = 6 * defaultDifficulty, [3] = 4.5 * defaultDifficulty, [4] = 3 * defaultDifficulty, 
                     [5] = 3 + defaultDifficulty, [6] = 1 + defaultDifficulty, [7] = (defaultDifficulty > 3 and 2 or 1)}
    },

    -- обелиски ТЭ --
    -- флаг, что диалог об обелисках был показан
    obelisk_msg = 0,

    -- число существ, которых необходимо принести в жертву обелиску
    obelisk_creatures_to_sacriface_count = initialDifficulty == DIFFICULTY_HEROIC and 8 or 5,

    -- процент опыта, который снимается обелиском
    obelisk_exp_remove_percent = initialDifficulty == DIFFICULTY_HEROIC and 0.25 or 0.15,

    -- таблица связей обелисков и порталов
    dark_obelisks =
    {
        ['dark_obelisk_01'] = 'dark_portal_01',
        ['dark_obelisk_02'] = 'dark_portal_02',
        ['dark_obelisk_03'] = 'dark_portal_03',
        ['dark_obelisk_04'] = 'dark_portal_04',
    },

        -- *ФУНКЦИИ* --
    
    -- главная функция загрузки квеста:
    -- 1. Инициализировать основной путь
    -- 2. Инициализировать обелиски
    Init =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.Init")
        end)
        startThread(unknown_path.MainPathInit)
        startThread(unknown_path.DarkObelisksInit)
        print("<color=green>M1_Q_UnknownPath.Init successfull")
    end,

    -- загрузка основного пути
    -- 1. Настроить юнитов в постах
    -- 2. Настроить регионы
    -- 3. Настроить героев
    MainPathInit =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.MainPathInit")
        end)
        Object.Show(PLAYER_1, 'dung_enter')
        -- 1.
        for i, post in unknown_path.posts_units do
            Animation.NewGroup('post'..i, post)
            for j, unit in post do
                Touch.DisableMonster(unit, nil, 0)
            end
        end
        --
        startThread(unknown_path.PostsActivityThread)
        -- 2.
        Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'loiren_dest1', 'unknown_path.LoirenDest')
        Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'loiren_dest2', 'unknown_path.LoirenDest')
        Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'loiren_dest3', 'unknown_path.LoirenDest')
        --
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'enable_loiren_region', 'unknown_path.EnableLoiren')
        --
        -- for i = 1, 4 do
        --     SetRegionBlocked('ai_block'..i, 1, PLAYER_3)
        -- end
        -- 3.
        DeployReserveHero("Linaas", RegionToPoint('ving_point'))
        while not IsObjectExists("Linaas") do
            sleep()
        end
        EnableHeroAI("Linaas", nil)
        SetObjectEnabled("Linaas", nil)
    end,

    -- загрузка темных обелисков
    DarkObelisksInit =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.DarkObelisksInit")
        end)
        for obelisk, portal in unknown_path.dark_obelisks do
            startThread(
            function()
                local portal = %portal
                Touch.DisableObject(portal)
                Touch.SetFunction(portal, '_portal_close',
                function(hero, object)
                    ShowFlyingSign(unknown_path.path.text.."portal_closed_msg.txt", object, -1, 5.0)
                end)
            end)
            Touch.DisableObject(obelisk)
            Touch.SetFunction(obelisk, '_msg', unknown_path.DarkObeliskMsg)
            Touch.SetFunction(obelisk, '_touch', unknown_path.DarkObeliskTouch)
        end
    end,

    -- сообщения при касании обелисков
    DarkObeliskMsg = 
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.DarkObeliskMsg")
        end)
        Touch.RemoveFunction(object, '_msg')
        --
        if object == 'dark_obelisk_01' then
            MiniDialog.Start(unknown_path.path.dialog..'FirstObeliskDialog/', PLAYER_1, "GOG_M1_Q_UNKNOWN_PATH_FIRST_OBELISK_DIALOG")
        end
        --
        if object == 'dark_obelisk_02' then
            MiniDialog.Start(unknown_path.path.dialog..'SecondObeliskDialog/', PLAYER_1, "GOG_M1_Q_UNKNOWN_PATH_SECOND_OBELISK_DIALOG")
        end
        --
        if object == 'dark_obelisk_04' then
            startThread(ghost_hope.Init, hero, GetObjectOwner(hero))
        end
        --
        MakeHeroInteractWithObject(hero, object)
    end,

    -- логика касания обелисков
    -- 1. Вариант с жертвой существ
    --  a) Посчитать число живых существ.
    --  b) Если оно меньше нужного, закончить.
    --  c) Иначе удалить существ у героя, начиная с самых низших тиров.
    -- 2. Вариант с жертвой опыта
    -- 3. Разблокировка связанного с обелиском портала.
    DarkObeliskTouch =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.DarkObeliskTouch")
        end)
        -- 
        if MCCS_QuestionBoxForPlayers(PLAYER_1, {unknown_path.path.text.."obelisk_sacriface_condition.txt"; 
                            cr_count = unknown_path.obelisk_creatures_to_sacriface_count, 
                            xp_percent = ceil(unknown_path.obelisk_exp_remove_percent * 100)}) then
            -- 1a.
            local possible_creatures = {}
            for slot = 0, 6 do
                local creature, count = GetObjectArmySlotCreature(hero, slot)
                if not (creature == 0 or count == 0) then
                    if (not possible_creatures[creature]) and Creature.Type.IsAlive(creature) then
                        possible_creatures[creature] = {tier = Creature.Params.Tier(creature), count = GetHeroCreatures(hero, creature)}
                    end
                end
            end
            local sum = 0
            for creature, info in possible_creatures do
                sum = sum + info.count
            end
            -- 1b.
            if sum < unknown_path.obelisk_creatures_to_sacriface_count then
                MessageBox(unknown_path.path.text.."obelisk_sacriface_not_enough_creatures.txt")
                return
            else
                -- 1c.
                local cr_to_remove = unknown_path.obelisk_creatures_to_sacriface_count
                local curr_tier = 1
                --
                while cr_to_remove > 0 do
                    for creature, info in possible_creatures do
                        if info.tier == curr_tier then
                            local curr_removed = 0
                            if info.count < 5 then
                                curr_removed = info.count
                            else
                                curr_removed = 5
                            end
                            Hero.CreatureInfo.Add(hero, creature, -curr_removed)
                            cr_to_remove = cr_to_remove - curr_removed
                            if cr_to_remove <= 0 then
                                break
                            end
                        end
                    end
                    if cr_to_remove > 0 then
                        curr_tier = curr_tier + 1
                    end
                end
            end
        else
            -- 2.
            local xp = GetHeroStat(hero, STAT_EXPERIENCE)
            TakeAwayHeroExp(hero, ceil(xp * unknown_path.obelisk_exp_remove_percent))
        end
        -- 3.
        FX.Play('Bloodlust', object)
        sleep(5)
        SetObjectFlashlight(object, 'blood_fl')
        --
        sleep(10)
        --
        MarkObjectAsVisited(object, hero)
        startThread(unknown_path.UnblockDarkPortal, unknown_path.dark_obelisks[object])
        Touch.RemoveFunction(object, '_touch')
    end,

    -- разблокировка темных порталов
    UnblockDarkPortal = 
    function(portal)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.UnblockDarkPortal")
        end)
        Object.Show(PLAYER_1, portal, 1)
        if portal == 'dark_portal_05' then
            sleep(5)
            FX.Play('Monolith_two_way', portal)
            SetObjectEnabled('magic_room_portal_out', 1)
            Touch.RemoveFunctions('magic_room_portal_out')
        else
            SetObjectEnabled(portal, 1)
            Touch.RemoveFunctions(portal)
            sleep(5)
            FX.Play('Monolith_one_way', portal)
        end
    end,

    -- включение Лойрена
    EnableLoiren =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.EnableLoiren")
        end)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "enable_loiren_region", nil)
        startThread(unknown_path.DeployLoiren)
    end,

    -- настройка Лойрена
    DeployLoiren =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.DeployLoiren")
        end)
        DeployReserveHero("Loiren", RegionToPoint('loiren_point'))
        while not IsObjectExists("Loiren") do
            sleep()
        end
        SetObjectRotation("Loiren", 180)
        local check
        local tiers = TIER_TABLES[TOWN_PRESERVE]
        for tier = 1, 6 + (1 * (initialDifficulty > 2)) do
            local creature, count = Random.FromTable_IgnoreValue(tiers[tier][1], tiers[tier]), unknown_path.loiren_initial_army[tier]
            AddHeroCreatures("Loiren", creature, count)
            if not check then
                while GetHeroCreatures("Loiren", creature) ~= count do
                    sleep()
                end
                RemoveHeroCreatures("Loiren", CREATURE_WOOD_ELF, 999)
                repeat
                    sleep()
                until GetHeroCreatures("Loiren", CREATURE_WOOD_ELF) == 0
                check = 1
            end
        end
        WarpHeroExp("Loiren", Levels[10 + initialDifficulty])
        for stat = STAT_ATTACK, STAT_KNOWLEDGE do
            ChangeHeroStat("Loiren", stat, 2 + defaultDifficulty)
        end
        Object.Show(PLAYER_1, "Loiren", 1, 1)
        sleep(15)
        UnblockGame()
        startThread(unknown_path.LoirenMove)
    end,

    -- логика перемещений Лойрена
    -- 1. Если Лойрен может достичь игрока, он бежит к нему, 
    -- однако, если между ним и игроком есть одна из ключевых точек и она ближе, чем игрок, то сначала он бежит в ключевую точку.
    -- 2. Если Лойрен не может достичь игрока, он движется к ближайшей достижимой ключевой точке и ожидает игрока в ней.
    LoirenMove =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.LoirenMove")
        end)
        while IsHeroAlive("Loiren") do
            while not IsPlayerCurrent(PLAYER_3) do
                sleep()
            end
            -- 1.
            if CanMoveHero("Loiren", GetObjectPosition("Karlam")) then
                if unknown_path.loiren_waits == 1 then
                    EnableHeroAI("Loiren", 1)
                    unknown_path.loiren_waits = 0
                end
                if unknown_path.loiren_current_dest and CanMoveHero("Loiren", RegionToPoint(unknown_path.loiren_current_dest)) then
                    local curr_dest_move_points = CalcHeroMoveCost("Loiren", RegionToPoint(unknown_path.loiren_current_dest))
                    local karlam_move_points = CalcHeroMoveCost("Loiren", GetObjectPosition("Karlam"))
                    if curr_dest_move_points <= karlam_move_points then
                        MoveHeroRealTime("Loiren", RegionToPoint(unknown_path.loiren_current_dest))
                    else
                        MoveHeroRealTime("Loiren", GetObjectPosition("Karlam"))
                    end
                else
                    MoveHeroRealTime("Loiren", GetObjectPosition("Karlam"))
                end
            else
                -- 2.
                if unknown_path.loiren_waits == 0 then
                    for reg, active in unknown_path.loiren_dest do
                        if active then
                            print('Loiren is moving to point ', reg)
                            MoveHeroRealTime("Loiren", RegionToPoint(reg))
                            break
                        end
                    end
                end
            end
            sleep()
        end
    end,

    -- Лойрен достигает очередной ключевой точки
    LoirenDest =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.LoirenDest")
        end)
        if hero == "Loiren" then
            Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, region, nil)
            unknown_path.loiren_dest[region] = nil
            if region == "loiren_dest1" then
                unknown_path.loiren_current_dest = "loiren_dest2"
                startThread(unknown_path.LoirenEntersPost, 1)
            end
            --
            sleep(3)
            if not CanMoveHero("Loiren", GetObjectPosition("Karlam")) then
                unknown_path.loiren_waits = 1
                EnableHeroAI("Loiren", nil)
            end
        end
    end,

    PostsActivityThread =
    function()
        local activity_flag
        while 1 do
            if GetCurrentPlayer() == PLAYER_1 then
                if not activity_flag then
                    activity_flag = 1
                    for i = 1, 3 do
                        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post'..i, 'unknown_path.PostEnter')
                    end
                end
            else
                if activity_flag then
                    activity_flag = nil
                    for i = 1, 3 do
                        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'e_post'..i, nil)
                    end
                end
            end
            sleep()
        end    
    end,

    -- герой заходит в область эльфийского поста
    -- 1. Определить номер поста
    -- 2. Если герой - Карлам:
    --  a)Запустить засаду энтов, если пост третий
    --  b)Запустить штурм города с соотв. ареной
    -- 3. Если герой - Лойрен, выдать ему армию в соответствии с постом
    PostEnter =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.PostEnter")
        end)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        -- 1.
        local num = string.spread(region)[7]
        -- 2.
        if hero == "Karlam" then
            SetGameVar('post', num)
            -- 2a.
            if num == '3' then
                unknown_path.TreantsAttack(hero)
                sleep(6)
            end
            -- 2b.
            local index = GetLastSavedCombatIndex()
            SiegeTown(hero, unknown_path.posts[num + 0])
            while GetLastSavedCombatIndex() == index do
                sleep()
            end
            if IsHeroAlive(hero) then
                UnblockGame()
                SetObjectOwner('e_post'..num, PLAYER_1)
                SetGameVar('post', 0)
                if num ~= '3' then
                    Animation.PlayGroup('post'..num, {'death'}, PLAY_CONDITION_SINGLEPLAY, ONESHOT_STILL)
                    sleep(15)
                    Object.RemoveTable(Animation.Groups['post'..num].actors)
                else
                    SetObjectEnabled("Karlam", 1)
                    RemoveObject("Linaas")
                    Animation.PlayGroup('post_3_treants', {'death'}, PLAY_CONDITION_SINGLEPLAY, ONESHOT_STILL)
                    sleep(15)
                    Object.RemoveTable(Animation.Groups['post_3_treants'].actors)
                end
            end
        else
            -- 3.
            startThread(unknown_path.LoirenEntersPost, num)
        end
    end,

    LoirenEntersPost =
    function(post_num)
        if post_num == "3" then
            RemoveObject("Linaas")
        end
        Object.RemoveTable(Animation.Groups['post'..post_num].actors)
        for tier, count in unknown_path.loiren_post_army['post'..post_num] do
            Hero.CreatureInfo.AddByTier("Loiren", TOWN_PRESERVE, tier, count)
        end
    end,

    -- засада энтов на 3 посте.
    TreantsAttack =
    function(hero)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_UnknownPath.TreantsAttack")
        end)
        BlockGame()
        SetObjectEnabled("Karlam", nil)
        MoveCamera(85, 61, GROUND, 30, math.pi / 4, 0)
        sleep(15)
        local actors = {}
        for tree, info in unknown_path.post3_treants do
            startThread(
            function()
                local x, y = GetObjectPosition(%tree)
                local info = %info
                for i = 1, 5 + random(4) do
                    FX.Play('Treant_hit', %tree, '', 0.1 * Random.FromSelection(1, -1) * random(4), 0.1 * Random.FromSelection(1, -1) * random(4), 1)
                end
                sleep(5)
                RemoveObject(%tree)
                sleep()
                CreateMonster('post_treant_'..%tree, info[1], 1, x, y, GROUND, 3, 1, info[2])
                while not IsObjectExists('post_treant_'..%tree) do
                    sleep()
                end
                Touch.DisableMonster('post_treant_'..%tree, DISABLED_ATTACK, 0)
                %actors[length(%actors) + 1] = 'post_treant_'..%tree
            end)
        end
        Animation.NewGroup('post_3_treants', actors)
        sleep(10)
        Animation.PlayGroup('post_3_treants', {'attack00'}, PLAY_CONDITION_SINGLEPLAY, ONESHOT)
        FX.Play('Roots_start', hero)
        sleep(10)
        MoveHeroRealTime("Vingael", 86, 69)
        sleep(5)
        SetObjectPosition("Vingael", 86, 68, GROUND, 0)
        sleep()
        MoveHeroRealTime("Vingael", GetObjectPosition("Karlam"))
        sleep(5)
        --UnblockGame()
    end,
}