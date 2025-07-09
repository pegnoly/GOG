c1m1_necromancers = {
    path = heroes_path.."Necromancers/",

    queue = {"Lernon", "Ainurel", "Thaye", "Menippe", "Orris", "Mourniel", "Mordrakar"},
    current_number = 1,
    current_hero = "",
    spawn_day = -1,
    attack_day = -1,
    spawn_delay = 1,
    spawn_point = "moriton_necromancer_spawn_region",
    attack_points = {
        "moriton_necromancer_attack_point_1",
        "moriton_necromancer_attack_point_2",
        "moriton_necromancer_attack_point_3",
        "moriton_necromancer_attack_point_4"
    },
    fights_data = {},

    Load = 
    function ()
        doFile(c1m1_necromancers.path.."Lernon/script.lua")
    end,

    Init = 
    function ()
        while not lernon_advmap do
            sleep()
        end
        startThread(lernon_advmap.Load)
    end,

    StartQueue =
    function ()
        c1m1_necromancers.spawn_day = GetDate(DAY) + c1m1_necromancers.spawn_delay
        c1m1_necromancers.attack_day = c1m1_necromancers.spawn_day + 1
        NewDayEvent.AddListener("c1m1_moriton_zone_spawn_necromancer_listener", c1m1_necromancers.SpawnCurrent)
        NewDayEvent.AddListener("c1m1_moriton_zone_start_necromancer_attack_listener", c1m1_necromancers.StartAttack)
    end,

    SpawnCurrent =
    function (day)
        if day == c1m1_necromancers.spawn_day then
            local name = c1m1_necromancers.queue[c1m1_necromancers.current_number]
            c1m1_necromancers.current_hero = GetDifficulty() == DIFFICULTY_HEROIC and name.."_Heroic" or name
            DeployReserveHero(c1m1_necromancers.current_hero, RegionToPoint(c1m1_necromancers.spawn_point))
            while not IsObjectExists(c1m1_necromancers.current_hero) do
                sleep()
            end
            EnableHeroAI(c1m1_necromancers.current_hero, nil)
            local fight_data = FightGenerator.GenerateHeroSetupData(c1m1_necromancers.fights_data[c1m1_necromancers.current_hero])
            --print("Fight data: ", fight_data)
            startThread(FightGenerator.ProcessHeroSetup, c1m1_necromancers.current_hero, fight_data)
        end
    end,

    StartAttack = 
    function (day)
        if day == c1m1_necromancers.attack_day then
            local point = Random.FromTable(c1m1_necromancers.attack_points)
            local x, y, f = RegionToPoint(point)
            SetObjectPosition(c1m1_necromancers.current_hero, x, y, f, 0)
            startThread(c1m1_necromancers.AttackThread, c1m1_necromancers.current_hero)
        end
    end,

    AttackThread = 
    function (hero)
        while IsHeroAlive(hero) do
            while not IsPlayerCurrent(PLAYER_2) do
                sleep()
            end
            local x, y, f = GetObjectPosition("Moriton")
            MoveHeroRealTime(hero, x, y, f)
            sleep()
        end
    end
}