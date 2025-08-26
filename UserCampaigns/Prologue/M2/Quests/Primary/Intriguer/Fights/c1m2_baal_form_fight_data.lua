
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m2_baal_form_fight_data = {
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
			[DIFFICULTY_EASY] = 120000,
			[DIFFICULTY_HEROIC] = 210000,
			[DIFFICULTY_NORMAL] = 150000,
			[DIFFICULTY_HARD] = 180000,
		},
		[2] = {
			[DIFFICULTY_NORMAL] = 145000,
			[DIFFICULTY_HEROIC] = 205000,
			[DIFFICULTY_EASY] = 115000,
			[DIFFICULTY_HARD] = 175000,
		},
		[3] = {
			[DIFFICULTY_NORMAL] = 130000,
			[DIFFICULTY_EASY] = 105000,
			[DIFFICULTY_HARD] = 155000,
			[DIFFICULTY_HEROIC] = 180000,
		},
		[4] = {
			[DIFFICULTY_HEROIC] = 175000,
			[DIFFICULTY_EASY] = 100000,
			[DIFFICULTY_NORMAL] = 125000,
			[DIFFICULTY_HARD] = 150000,
		},
		[5] = {
			[DIFFICULTY_HARD] = 146000,
			[DIFFICULTY_HEROIC] = 168000,
			[DIFFICULTY_EASY] = 102000,
			[DIFFICULTY_NORMAL] = 124000,
		},
		[6] = {
			[DIFFICULTY_EASY] = 100000,
			[DIFFICULTY_NORMAL] = 120000,
			[DIFFICULTY_HARD] = 140000,
			[DIFFICULTY_HEROIC] = 160000,
		},
		[7] = {
			[DIFFICULTY_NORMAL] = 115000,
			[DIFFICULTY_HARD] = 140000,
			[DIFFICULTY_EASY] = 90000,
			[DIFFICULTY_HEROIC] = 165000,
		},
	},

	army_counts_grow = {
	},

	army_getters = {
		[1] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_DUNGEON}, {1})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[2] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_DUNGEON}, {2})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[3] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_DUNGEON}, {3})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[4] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_DUNGEON}, {4})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[5] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_DUNGEON}, {5})
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
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_DUNGEON}, {6})
			local filtered_creatures = list_iterator.Filter(
				possible_creatures,
				function(creature)
					local result = Creature.Params.IsGeneratable(creature)
					return result
				end)
			local id = Random.FromTable(filtered_creatures)
			return id
		end,
		[7] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_DUNGEON}, {7})
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