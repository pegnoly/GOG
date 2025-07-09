
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m1_lernon_fight_data = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[2] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[3] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[4] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
		[5] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_EASY] = 20000,
			[DIFFICULTY_NORMAL] = 21500,
			[DIFFICULTY_HEROIC] = 25000,
			[DIFFICULTY_HARD] = 23000,
		},
		[2] = {
			[DIFFICULTY_EASY] = 19000,
			[DIFFICULTY_NORMAL] = 21000,
			[DIFFICULTY_HEROIC] = 25000,
			[DIFFICULTY_HARD] = 23000,
		},
		[3] = {
			[DIFFICULTY_HEROIC] = 32000,
			[DIFFICULTY_EASY] = 20000,
			[DIFFICULTY_HARD] = 27000,
			[DIFFICULTY_NORMAL] = 23500,
		},
		[4] = {
			[DIFFICULTY_HEROIC] = 30000,
			[DIFFICULTY_EASY] = 15000,
			[DIFFICULTY_NORMAL] = 20000,
			[DIFFICULTY_HARD] = 25000,
		},
		[5] = {
			[DIFFICULTY_HARD] = 31000,
			[DIFFICULTY_EASY] = 25000,
			[DIFFICULTY_NORMAL] = 28000,
			[DIFFICULTY_HEROIC] = 34000,
		},
	},

	army_counts_grow = {
	},

	army_getters = {
		[1] = function ()
            local result = Random.FromTable({2409, 2410, 2411})
            return result
        end,
		[2] = function ()
            local result = Random.FromTable({2412, 2413, 2414})
            return result
        end,
		[3] = function ()
            local result = Random.FromTable({2415, 2416, 2417})
            return result
        end,
		[4] = function ()
            local result = Random.FromTable({2418, 2419, 2420})
            return result
        end,
		[5] = function ()
            local result = Random.FromTable({2409, 2410, 2412, 2413, 2414, 2415, 2416, 2417, 2418, 2419, 2420, 2411})
            return result
        end,
	},

	required_artifacts = {	},
	optional_artifacts = {
		[SHOULDERS] = {84},
		[CHEST] = {64},
		[PRIMARY] = {80},
		[HEAD] = {55},
		[FINGER] = {23},
	},

	artifacts_base_costs = {
		[DIFFICULTY_HARD] = 9000,
		[DIFFICULTY_NORMAL] = 8000,
		[DIFFICULTY_EASY] = 7000,
		[DIFFICULTY_HEROIC] = 10000,
	},

}