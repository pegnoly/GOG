
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m1_concealed_paths_secret_place_fight_data = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[2] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[3] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[4] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[5] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[6] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_HEROIC] = 120000,
			[DIFFICULTY_NORMAL] = 89000,
			[DIFFICULTY_EASY] = 75000,
			[DIFFICULTY_HARD] = 105000,
		},
		[2] = {
			[DIFFICULTY_HEROIC] = 103000,
			[DIFFICULTY_HARD] = 88000,
			[DIFFICULTY_EASY] = 62000,
			[DIFFICULTY_NORMAL] = 75000,
		},
		[3] = {
			[DIFFICULTY_EASY] = 80000,
			[DIFFICULTY_HEROIC] = 140000,
			[DIFFICULTY_NORMAL] = 100000,
			[DIFFICULTY_HARD] = 120000,
		},
		[4] = {
			[DIFFICULTY_EASY] = 75000,
			[DIFFICULTY_HEROIC] = 120000,
			[DIFFICULTY_NORMAL] = 90000,
			[DIFFICULTY_HARD] = 105000,
		},
		[5] = {
			[DIFFICULTY_HARD] = 100000,
			[DIFFICULTY_NORMAL] = 90000,
			[DIFFICULTY_HEROIC] = 110000,
			[DIFFICULTY_EASY] = 80000,
		},
		[6] = {
			[DIFFICULTY_HEROIC] = 86000,
			[DIFFICULTY_EASY] = 65000,
			[DIFFICULTY_HARD] = 79000,
			[DIFFICULTY_NORMAL] = 72000,
		},
	},

	army_counts_grow = {
		[1] = {
			[DIFFICULTY_HARD] = 4500,
			[DIFFICULTY_EASY] = 1500,
			[DIFFICULTY_HEROIC] = 6000,
			[DIFFICULTY_NORMAL] = 3000,
		},
		[2] = {
			[DIFFICULTY_EASY] = 2000,
			[DIFFICULTY_HARD] = 6000,
			[DIFFICULTY_HEROIC] = 8000,
			[DIFFICULTY_NORMAL] = 4000,
		},
		[3] = {
			[DIFFICULTY_NORMAL] = 4000,
			[DIFFICULTY_EASY] = 3000,
			[DIFFICULTY_HARD] = 5000,
			[DIFFICULTY_HEROIC] = 6000,
		},
		[4] = {
			[DIFFICULTY_NORMAL] = 5000,
			[DIFFICULTY_HARD] = 7500,
			[DIFFICULTY_EASY] = 2500,
			[DIFFICULTY_HEROIC] = 10000,
		},
		[5] = {
			[DIFFICULTY_EASY] = 1000,
			[DIFFICULTY_NORMAL] = 2000,
			[DIFFICULTY_HARD] = 3000,
			[DIFFICULTY_HEROIC] = 4000,
		},
		[6] = {
			[DIFFICULTY_NORMAL] = 3000,
			[DIFFICULTY_HARD] = 4500,
			[DIFFICULTY_HEROIC] = 6000,
			[DIFFICULTY_EASY] = 1500,
		},
	},

	army_getters = {
		[1] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO}, {6})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Type.IsCaster(creature) and Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[2] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO}, {6})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Params.IsGeneratable(creature) and Creature.Type.IsCaster(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[3] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO}, {4})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Type.IsShooter(creature) and Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[4] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO}, {4})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Type.IsShooter(creature) and Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[5] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO}, {3})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[6] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_INFERNO}, {1})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
	},

}