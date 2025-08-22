
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

loiren_fight_data = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[2] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[3] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[4] = UNIT_COUNT_GENERATION_MODE_RAW,
		[5] = UNIT_COUNT_GENERATION_MODE_RAW,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_HEROIC] = 18000,
			[DIFFICULTY_NORMAL] = 12000,
			[DIFFICULTY_EASY] = 9000,
			[DIFFICULTY_HARD] = 15000,
		},
		[2] = {
			[DIFFICULTY_NORMAL] = 14000,
			[DIFFICULTY_EASY] = 10000,
			[DIFFICULTY_HARD] = 18000,
			[DIFFICULTY_HEROIC] = 22000,
		},
		[3] = {
			[DIFFICULTY_NORMAL] = 14000,
			[DIFFICULTY_EASY] = 10000,
			[DIFFICULTY_HARD] = 18000,
			[DIFFICULTY_HEROIC] = 22000,
		},
		[4] = {
			[DIFFICULTY_NORMAL] = 10,
			[DIFFICULTY_HEROIC] = 16,
			[DIFFICULTY_HARD] = 13,
			[DIFFICULTY_EASY] = 7,
		},
		[5] = {
			[DIFFICULTY_HEROIC] = 5,
			[DIFFICULTY_HARD] = 4,
			[DIFFICULTY_NORMAL] = 3,
			[DIFFICULTY_EASY] = 2,
		},
	},

	army_counts_grow = {
	},

	army_getters = {
		[1] = function ()
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_PRESERVE}, {1})
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
			local possible_creatures = Creature.Selection.FromTownsAndTiers({TOWN_PRESERVE}, {2})
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
            local result = Random.FromTable({48, 147})
            return result
        end,
		[4] = function ()
            local result = Random.FromTable({148})
            return result
        end,
		[5] = function ()
            local result = Random.FromTable({54, 150})
            return result
        end,
	},

	required_artifacts = {	},
	optional_artifacts = {
		[NECK] = {19},
		[CHEST] = {56},
		[HEAD] = {66},
		[PRIMARY] = {90},
		[MISCSLOT1] = {87},
	},

	artifacts_base_costs = {
		[DIFFICULTY_HEROIC] = 22500,
		[DIFFICULTY_HARD] = 20000,
		[DIFFICULTY_NORMAL] = 17500,
		[DIFFICULTY_EASY] = 15000,
	},

}