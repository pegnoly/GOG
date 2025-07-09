ainurel_advmap = {

    heroes = {'Ainurel', 'Ainurel_Heroic'},

    army_constant = {
        [1] = 24900,
        [2] = 25250,
        [3] = 25300,
        [4] = 25500,
        [5] = 25500,
        [6] = 26500,
        [7] = 28000
    },

    army_diff_step = {
        [1] = 2490,
        [2] = 2525,
        [3] = 2530,
        [4] = 2550,
        [5] = 2550,
        [6] = 2650,
        [7] = 2700
    },

    initial_level = 17,

    additional_levels = {
        [DIFFICULTY_EASY] = 1,
        [DIFFICULTY_NORMAL] = 2,
        [DIFFICULTY_HARD] = 3,
        [DIFFICULTY_HEROIC] = 5
    },

    army_getters = {
        [1] = function () local id = ainurel_advmap.GetShooter(TOWN_NECROMANCY, 1) return id end,
        [2] = function () local id = Creature.Selection.RandomUpgradedFromTier(TOWN_NECROMANCY, 2) return id end,
        [3] = function () local id = Creature.Selection.RandomUpgradedFromTier(TOWN_NECROMANCY, 3) return id end,
        [4] = function () local id = Creature.Selection.RandomUpgradedFromTier(TOWN_NECROMANCY, 4) return id end,
        [5] = function () local id = ainurel_advmap.GetShooter(TOWN_NECROMANCY, 5) return id end,
        [6] = function () local id = Creature.Selection.RandomUpgradedFromTier(TOWN_NECROMANCY, 6) return id end,
        [7] = function () local id = ainurel_advmap.GetTier7Creature() return id end,
    },

    Init = 
    function()
        print"Ainurel init"
        AddHeroEvent.AddListener("c1m1_ainurel_advmap_add_hero_listener", 
        function(hero)
            if list_iterator.Any(ainurel_advmap.heroes, function (_hero) return _hero == %hero end) then
                startThread(ainurel_advmap.GiveLevels, hero)
                startThread(ainurel_advmap.SetupArmy, hero)
            end
        end)
    end,

    GiveLevels = 
    function (hero)
        WarpHeroExp(hero, Levels[ainurel_advmap.initial_level])
        local exp_count = Levels[ainurel_advmap.initial_level + ainurel_advmap.additional_levels[initialDifficulty]] - Levels[ainurel_advmap.initial_level]
        GiveExp(hero, exp_count)
    end,

    SetupArmy = 
    function(hero)
        local removed
        for level = 1, 7 do 
            local creature = ainurel_advmap.army_getters[level]()
            print("Found creature: ", creature, " of level ", level)
            local total_power = ainurel_advmap.army_constant[level] + defaultDifficulty * ainurel_advmap.army_diff_step[level]
            local count = floor(total_power / Creature.Params.Power(creature))
            count = count > 0 and count or 1
            AddHeroCreatures(hero, creature, count)
            if not removed then
                while GetHeroCreatures(hero, creature) ~= count do
                    sleep()
                end
                RemoveHeroCreatures(hero, CREATURE_PIXIE, 9999)
                while GetHeroCreatures(hero, CREATURE_PIXIE) ~= 0 do
                    sleep()
                end
                removed = 1
            end
        end
    end,

    GetShooter = 
    function (town, tier)
        local tiers = TIER_TABLES[town]
        local shooters = list_iterator.Filter(
            tiers[tier], 
            function(creature) 
                local ans = Creature.Params.IsGeneratable(creature) and Creature.Type.IsShooter(creature)
                print("Total: ", ans)
                return ans
            end)
        print("Shooters ", shooters)
        local actual_creature = Random.FromTable(shooters)
        return actual_creature
    end,

    GetTier7Creature =
    function ()
        return CREATURE_BONE_DRAGON
    end
}

