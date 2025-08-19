
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c1m2_hazy_path_first_garrison = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_RAW,
		[2] = UNIT_COUNT_GENERATION_MODE_RAW,
		[3] = UNIT_COUNT_GENERATION_MODE_RAW,
		[4] = UNIT_COUNT_GENERATION_MODE_RAW,
		[5] = UNIT_COUNT_GENERATION_MODE_POWER_BASED,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_HARD] = 60,
			[DIFFICULTY_NORMAL] = 52,
			[DIFFICULTY_HEROIC] = 68,
			[DIFFICULTY_EASY] = 44,
		},
		[2] = {
			[DIFFICULTY_HEROIC] = 43,
			[DIFFICULTY_EASY] = 25,
			[DIFFICULTY_HARD] = 37,
			[DIFFICULTY_NORMAL] = 31,
		},
		[3] = {
			[DIFFICULTY_HARD] = 23,
			[DIFFICULTY_NORMAL] = 19,
			[DIFFICULTY_EASY] = 15,
			[DIFFICULTY_HEROIC] = 27,
		},
		[4] = {
			[DIFFICULTY_HEROIC] = 5,
			[DIFFICULTY_HARD] = 4,
			[DIFFICULTY_EASY] = 2,
			[DIFFICULTY_NORMAL] = 3,
		},
		[5] = {
			[DIFFICULTY_NORMAL] = 13000,
			[DIFFICULTY_HEROIC] = 19000,
			[DIFFICULTY_EASY] = 10000,
			[DIFFICULTY_HARD] = 16000,
		},
	},

	army_counts_grow = {
	},

	army_getters = {
		[1] = function ()
            local result = Random.FromTable({44, 145})
            return result
        end,
		[2] = function ()
            local result = Random.FromTable({46, 146})
            return result
        end,
		[3] = function ()
            local result = Random.FromTable({48, 147})
            return result
        end,
		[4] = function ()
            local result = Random.FromTable({53})
            return result
        end,
		[5] = function ()
            local result = Random.FromTable({43, 45, 47})
            return result
        end,
	},

}