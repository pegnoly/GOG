
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m2_hazy_path_second_garrison = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_RAW,
		[2] = UNIT_COUNT_GENERATION_MODE_RAW,
		[3] = UNIT_COUNT_GENERATION_MODE_RAW,
		[4] = UNIT_COUNT_GENERATION_MODE_RAW,
		[5] = UNIT_COUNT_GENERATION_MODE_RAW,
		[6] = UNIT_COUNT_GENERATION_MODE_RAW,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_HEROIC] = 38,
			[DIFFICULTY_HARD] = 31,
			[DIFFICULTY_EASY] = 17,
			[DIFFICULTY_NORMAL] = 24,
		},
		[2] = {
			[DIFFICULTY_EASY] = 13,
			[DIFFICULTY_HEROIC] = 28,
			[DIFFICULTY_HARD] = 23,
			[DIFFICULTY_NORMAL] = 18,
		},
		[3] = {
			[DIFFICULTY_HARD] = 22,
			[DIFFICULTY_EASY] = 12,
			[DIFFICULTY_HEROIC] = 27,
			[DIFFICULTY_NORMAL] = 17,
		},
		[4] = {
			[DIFFICULTY_HEROIC] = 8,
			[DIFFICULTY_HARD] = 7,
			[DIFFICULTY_EASY] = 5,
			[DIFFICULTY_NORMAL] = 6,
		},
		[5] = {
			[DIFFICULTY_NORMAL] = 3,
			[DIFFICULTY_EASY] = 2,
			[DIFFICULTY_HARD] = 4,
			[DIFFICULTY_HEROIC] = 5,
		},
		[6] = {
			[DIFFICULTY_HEROIC] = 15,
			[DIFFICULTY_EASY] = 9,
			[DIFFICULTY_NORMAL] = 11,
			[DIFFICULTY_HARD] = 13,
		},
	},

	army_counts_grow = {
	},

	army_getters = {
		[1] = function ()
            local result = Random.FromTable({47})
            return result
        end,
		[2] = function ()
            local result = Random.FromTable({48})
            return result
        end,
		[3] = function ()
            local result = Random.FromTable({147})
            return result
        end,
		[4] = function ()
            local result = Random.FromTable({51})
            return result
        end,
		[5] = function ()
            local result = Random.FromTable({52, 149})
            return result
        end,
		[6] = function ()
            local result = Random.FromTable({50, 148})
            return result
        end,
	},

}