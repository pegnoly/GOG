lernon_advmap = {
    heroes = {'Lernon', 'Lernon_Heroic'},

    army_constant = {
        [1] = 24900,
        [2] = 25250,
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

}