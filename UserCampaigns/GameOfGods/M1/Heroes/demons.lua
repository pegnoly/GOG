c2m1_demons = {

    -- количество появлений конкретного героя в качестве мейна
    heroes_as_main_count = {},

    -- пул героев на уровнях ниже героя
    default_pool = {
        "C2M1_Isfet",
        "C2M1_Shezmur"
    },

    -- пул героев на уровне герой
    heroic_pool = {
        "C2M1_Isfet_Heroic",
        "C2M1_Shezmur_Heroic"
    },

    -- пул для данного конкретного расклада 
    current_pool = nil,

    -- герой, который всегда должен быть мейном
    always_main = nil,

    -- герои, в текущий момент имеющие статус мейна
    current_mains = {},

    -- максимальное число героев, которые могут одновременно иметь статус мейна
    max_mains_count = -1,

    -- увеличение числа мейнов со временем на герое
    heroic_mains_increase_count = 1,

    -- число дней, через которое увеличивается число мейнов
    heroic_mains_increase_period = 25,

    -- следующая дата, на которой должен произойти прирост числа мейнов
    heroic_mains_increase_next_day = -1,

    -- базовая настройка
    Init = 
    function ()
        c2m1_demons.current_pool = initialDifficulty == DIFFICULTY_HEROIC and c2m1_demons.heroic_pool or c2m1_demons.default_pool
        c2m1_demons.always_main = Random.FromTable(c2m1_demons.current_pool)

        if initialDifficulty == DIFFICULTY_EASY then
            c2m1_demons.max_mains_count = 2
        elseif initialDifficulty == DIFFICULTY_HEROIC then
            NewDayEvent.AddListener("C2M1_mains_count_increase_listener", c2m1_demons.MainsCountIncrease)
            c2m1_demons.max_mains_count = 4
        else
            c2m1_demons.max_mains_count = 3
        end

        AddHeroEvent.AddListener("C2M1_demons_add_hero_listener", c2m1_demons.Add)
    end,

    -- на герое управляет увеличением числа мейн героев демонов
    MainsCountIncrease = 
    function (day)
        if c2m1_demons.heroic_mains_increase_next_day == -1 then
            NewDayEvent.FinishInvoking("C2M1_mains_count_increase_listener")
            return 
        end
        if day == c2m1_demons.heroic_mains_increase_next_day then
            c2m1_demons.max_mains_count = c2m1_demons.max_mains_count + 1
            c2m1_demons.heroic_mains_increase_next_day = c2m1_demons.heroic_mains_increase_next_day + c2m1_demons.heroic_mains_increase_period
            if c2m1_demons.max_mains_count == 8 then
                NewDayEvent.RemoveListener("C2M1_mains_count_increase_listener")
            end         
            NewDayEvent.FinishInvoking("C2M1_mains_count_increase_listener")
            return
        end
    end,

    -- базовая функция добавления героев-демонов
    Add = 
    function (hero)
        -- это герой, всегда выступающий в роли мейна
        if hero == c2m1_demons.always_main then
            c2m1_demons.heroes_as_main_count[hero] = 1
            c2m1_demons.current_mains[hero] = 1
            AddHeroEvent.FinishInvoking("C2M1_demons_add_hero_listener")
            return
        end
        --
        if len(c2m1_demons.current_mains) < c2m1_demons.max_mains_count then
            c2m1_demons.heroes_as_main_count[hero] = 1
            c2m1_demons.current_mains[hero] = 1
            AddHeroEvent.FinishInvoking("C2M1_demons_add_hero_listener")
            return
        end 
    end,
}