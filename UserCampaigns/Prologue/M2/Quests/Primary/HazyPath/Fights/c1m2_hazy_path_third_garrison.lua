
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m2_hazy_path_third_garrison = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[2] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[3] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[4] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[5] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[6] = UNIT_COUNT_GENERATION_MODE_RAW,
		[7] = UNIT_COUNT_GENERATION_MODE_RAW,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_HARD] = 11500,
			[DIFFICULTY_NORMAL] = 9500,
			[DIFFICULTY_EASY] = 7500,
			[DIFFICULTY_HEROIC] = 13500,
		},
		[2] = {
			[DIFFICULTY_HEROIC] = 14000,
			[DIFFICULTY_NORMAL] = 10000,
			[DIFFICULTY_EASY] = 8000,
			[DIFFICULTY_HARD] = 12000,
		},
		[3] = {
			[DIFFICULTY_EASY] = 9000,
			[DIFFICULTY_HARD] = 14000,
			[DIFFICULTY_HEROIC] = 16500,
			[DIFFICULTY_NORMAL] = 11500,
		},
		[4] = {
			[DIFFICULTY_NORMAL] = 15500,
			[DIFFICULTY_HARD] = 19000,
			[DIFFICULTY_EASY] = 12000,
			[DIFFICULTY_HEROIC] = 22500,
		},
		[5] = {
			[DIFFICULTY_EASY] = 9000,
			[DIFFICULTY_HARD] = 13000,
			[DIFFICULTY_HEROIC] = 15000,
			[DIFFICULTY_NORMAL] = 11000,
		},
		[6] = {
			[DIFFICULTY_EASY] = 3,
			[DIFFICULTY_HARD] = 5,
			[DIFFICULTY_HEROIC] = 6,
			[DIFFICULTY_NORMAL] = 4,
		},
		[7] = {
			[DIFFICULTY_HARD] = 4,
			[DIFFICULTY_EASY] = 2,
			[DIFFICULTY_HEROIC] = 5,
			[DIFFICULTY_NORMAL] = 3,
		},
	},

	army_counts_grow = {
	},

	army_getters = {
		[1] = function ()
            local result = Random.FromTable({43, 44, 145})
            return result
        end,
		[2] = function ()
            local result = Random.FromTable({45, 46, 146})
            return result
        end,
		[3] = function ()
            local result = Random.FromTable({47, 48, 147})
            return result
        end,
		[4] = function ()
            local result = Random.FromTable({49, 50, 148})
            return result
        end,
		[5] = function ()
            local result = Random.FromTable({51, 52, 149})
            return result
        end,
		[6] = function ()
            local result = Random.FromTable({54})
            return result
        end,
		[7] = function ()
            local result = Random.FromTable({150})
            return result
        end,
	},

	required_artifacts = {	},
	optional_artifacts = {
		[MISCSLOT1] = {87},
		[CHEST] = {56},
		[SHOULDERS] = {84},
		[PRIMARY] = {1},
	},

	artifacts_base_costs = {
		[DIFFICULTY_EASY] = 5200,
		[DIFFICULTY_HARD] = 9000,
		[DIFFICULTY_HEROIC] = 12000,
		[DIFFICULTY_NORMAL] = 7000,
	},

}