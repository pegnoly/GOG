
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m1_cursed_dwells_t1 = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[2] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[3] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_NORMAL] = 25000,
			[DIFFICULTY_HEROIC] = 35000,
			[DIFFICULTY_HARD] = 30000,
			[DIFFICULTY_EASY] = 20000,
		},
		[2] = {
			[DIFFICULTY_NORMAL] = 4500,
			[DIFFICULTY_HARD] = 5000,
			[DIFFICULTY_HEROIC] = 5500,
			[DIFFICULTY_EASY] = 4000,
		},
		[3] = {
			[DIFFICULTY_HEROIC] = 5500,
			[DIFFICULTY_HARD] = 5000,
			[DIFFICULTY_EASY] = 4000,
			[DIFFICULTY_NORMAL] = 4500,
		},
	},

	army_counts_grow = {
		[1] = {
			[DIFFICULTY_EASY] = 2000,
			[DIFFICULTY_HEROIC] = 3500,
			[DIFFICULTY_HARD] = 3000,
			[DIFFICULTY_NORMAL] = 2500,
		},
		[2] = {
			[DIFFICULTY_HARD] = 700,
			[DIFFICULTY_NORMAL] = 600,
			[DIFFICULTY_EASY] = 500,
			[DIFFICULTY_HEROIC] = 900,
		},
		[3] = {
			[DIFFICULTY_HARD] = 700,
			[DIFFICULTY_EASY] = 500,
			[DIFFICULTY_HEROIC] = 900,
			[DIFFICULTY_NORMAL] = 600,
		},
	},

	army_getters = {
		[1] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {1, 2})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[2] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {2, 3})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[3] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {3, 4})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
	},

}