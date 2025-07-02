
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m1_cursed_dwells_outpost = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[2] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[3] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[4] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[5] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[6] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[7] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_HEROIC] = 46000,
			[DIFFICULTY_HARD] = 44000,
			[DIFFICULTY_NORMAL] = 42000,
			[DIFFICULTY_EASY] = 40000,
		},
		[2] = {
			[DIFFICULTY_HARD] = 44000,
			[DIFFICULTY_EASY] = 42000,
			[DIFFICULTY_HEROIC] = 45000,
			[DIFFICULTY_NORMAL] = 43000,
		},
		[3] = {
			[DIFFICULTY_NORMAL] = 42500,
			[DIFFICULTY_HEROIC] = 45500,
			[DIFFICULTY_HARD] = 44000,
			[DIFFICULTY_EASY] = 41000,
		},
		[4] = {
			[DIFFICULTY_HEROIC] = 46500,
			[DIFFICULTY_EASY] = 42000,
			[DIFFICULTY_HARD] = 45000,
			[DIFFICULTY_NORMAL] = 43500,
		},
		[5] = {
			[DIFFICULTY_EASY] = 40000,
			[DIFFICULTY_HEROIC] = 47500,
			[DIFFICULTY_HARD] = 45000,
			[DIFFICULTY_NORMAL] = 42500,
		},
		[6] = {
			[DIFFICULTY_EASY] = 41000,
			[DIFFICULTY_NORMAL] = 43500,
			[DIFFICULTY_HEROIC] = 48500,
			[DIFFICULTY_HARD] = 46000,
		},
		[7] = {
			[DIFFICULTY_NORMAL] = 48000,
			[DIFFICULTY_HARD] = 51000,
			[DIFFICULTY_EASY] = 45000,
			[DIFFICULTY_HEROIC] = 54000,
		},
	},

	army_counts_grow = {
		[1] = {
			[DIFFICULTY_HARD] = 4400,
			[DIFFICULTY_EASY] = 4000,
			[DIFFICULTY_HEROIC] = 4600,
			[DIFFICULTY_NORMAL] = 4200,
		},
		[2] = {
			[DIFFICULTY_HEROIC] = 4500,
			[DIFFICULTY_NORMAL] = 4300,
			[DIFFICULTY_HARD] = 4400,
			[DIFFICULTY_EASY] = 4200,
		},
		[3] = {
			[DIFFICULTY_NORMAL] = 4250,
			[DIFFICULTY_EASY] = 4100,
			[DIFFICULTY_HEROIC] = 4550,
			[DIFFICULTY_HARD] = 4400,
		},
		[4] = {
			[DIFFICULTY_HEROIC] = 4650,
			[DIFFICULTY_NORMAL] = 4350,
			[DIFFICULTY_HARD] = 4500,
			[DIFFICULTY_EASY] = 4200,
		},
		[5] = {
			[DIFFICULTY_HARD] = 4500,
			[DIFFICULTY_EASY] = 4000,
			[DIFFICULTY_NORMAL] = 4250,
			[DIFFICULTY_HEROIC] = 4750,
		},
		[6] = {
			[DIFFICULTY_EASY] = 4100,
			[DIFFICULTY_HEROIC] = 4850,
			[DIFFICULTY_NORMAL] = 4350,
			[DIFFICULTY_HARD] = 4600,
		},
		[7] = {
			[DIFFICULTY_HARD] = 5100,
			[DIFFICULTY_NORMAL] = 4800,
			[DIFFICULTY_HEROIC] = 5400,
			[DIFFICULTY_EASY] = 4500,
		},
	},

	army_getters = {
		[1] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {1})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[2] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {2})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[3] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {3})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[4] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {4})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[5] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {5})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[6] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {6})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
		[7] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO, TOWN_NECROMANCY}, {7})
			local id = Random.FromTable(possible_creatures)
			return id
		end,
	},

}