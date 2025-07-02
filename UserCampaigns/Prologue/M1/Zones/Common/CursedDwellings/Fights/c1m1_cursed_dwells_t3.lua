
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m1_cursed_dwells_t3 = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[2] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[3] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[4] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[5] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_HARD] = 34000,
			[DIFFICULTY_NORMAL] = 32500,
			[DIFFICULTY_HEROIC] = 35500,
			[DIFFICULTY_EASY] = 31000,
		},
		[2] = {
			[DIFFICULTY_EASY] = 32000,
			[DIFFICULTY_HARD] = 34000,
			[DIFFICULTY_HEROIC] = 35000,
			[DIFFICULTY_NORMAL] = 33000,
		},
		[3] = {
			[DIFFICULTY_HEROIC] = 36500,
			[DIFFICULTY_HARD] = 35000,
			[DIFFICULTY_NORMAL] = 33500,
			[DIFFICULTY_EASY] = 32000,
		},
		[4] = {
			[DIFFICULTY_EASY] = 32000,
			[DIFFICULTY_HARD] = 36000,
			[DIFFICULTY_NORMAL] = 34000,
			[DIFFICULTY_HEROIC] = 38000,
		},
		[5] = {
			[DIFFICULTY_NORMAL] = 35000,
			[DIFFICULTY_HARD] = 36000,
			[DIFFICULTY_HEROIC] = 37000,
			[DIFFICULTY_EASY] = 34000,
		},
	},

	army_counts_grow = {
		[1] = {
			[DIFFICULTY_HARD] = 3400,
			[DIFFICULTY_NORMAL] = 3250,
			[DIFFICULTY_HEROIC] = 3550,
			[DIFFICULTY_EASY] = 3100,
		},
		[2] = {
			[DIFFICULTY_EASY] = 3200,
			[DIFFICULTY_NORMAL] = 3300,
			[DIFFICULTY_HARD] = 3400,
			[DIFFICULTY_HEROIC] = 3500,
		},
		[3] = {
			[DIFFICULTY_NORMAL] = 3350,
			[DIFFICULTY_HARD] = 3500,
			[DIFFICULTY_HEROIC] = 3650,
			[DIFFICULTY_EASY] = 3200,
		},
		[4] = {
			[DIFFICULTY_HARD] = 3600,
			[DIFFICULTY_EASY] = 3200,
			[DIFFICULTY_HEROIC] = 3800,
			[DIFFICULTY_NORMAL] = 3400,
		},
		[5] = {
			[DIFFICULTY_EASY] = 3400,
			[DIFFICULTY_HEROIC] = 3700,
			[DIFFICULTY_NORMAL] = 3500,
			[DIFFICULTY_HARD] = 3600,
		},
	},

	army_getters = {
		[1] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {1, 2})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[2] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_NECROMANCY, TOWN_INFERNO}, {2, 3})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[3] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {3, 4})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[4] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({}, {4, 5})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[5] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {5, 6})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
	},

}