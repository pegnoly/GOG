
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m1_cursed_dwells_t2 = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[2] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[3] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[4] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_EASY] = 22000,
			[DIFFICULTY_HEROIC] = 31000,
			[DIFFICULTY_HARD] = 28000,
			[DIFFICULTY_NORMAL] = 25000,
		},
		[2] = {
			[DIFFICULTY_NORMAL] = 25500,
			[DIFFICULTY_HARD] = 28000,
			[DIFFICULTY_EASY] = 23000,
			[DIFFICULTY_HEROIC] = 30500,
		},
		[3] = {
			[DIFFICULTY_NORMAL] = 27500,
			[DIFFICULTY_HARD] = 30000,
			[DIFFICULTY_HEROIC] = 32500,
			[DIFFICULTY_EASY] = 25000,
		},
		[4] = {
			[DIFFICULTY_EASY] = 28000,
			[DIFFICULTY_HARD] = 31000,
			[DIFFICULTY_NORMAL] = 29500,
			[DIFFICULTY_HEROIC] = 32500,
		},
	},

	army_counts_grow = {
		[1] = {
			[DIFFICULTY_EASY] = 2200,
			[DIFFICULTY_HARD] = 2800,
			[DIFFICULTY_HEROIC] = 3100,
			[DIFFICULTY_NORMAL] = 2500,
		},
		[2] = {
			[DIFFICULTY_HARD] = 28000,
			[DIFFICULTY_HEROIC] = 3050,
			[DIFFICULTY_NORMAL] = 2550,
			[DIFFICULTY_EASY] = 2300,
		},
		[3] = {
			[DIFFICULTY_EASY] = 2500,
			[DIFFICULTY_HARD] = 3000,
			[DIFFICULTY_HEROIC] = 3250,
			[DIFFICULTY_NORMAL] = 2750,
		},
		[4] = {
			[DIFFICULTY_EASY] = 2800,
			[DIFFICULTY_HARD] = 3100,
			[DIFFICULTY_HEROIC] = 3250,
			[DIFFICULTY_NORMAL] = 2950,
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
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_NECROMANCY, TOWN_INFERNO}, {3, 4})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[4] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {4, 5})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
	},

}