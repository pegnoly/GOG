
while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW do
    sleep()
end

c2m1_listmur_gates_fight = {
	stack_count_generation_logic = {
		[1] = UNIT_COUNT_GENERATION_MODE_RAW,
		[2] = UNIT_COUNT_GENERATION_MODE_RAW,
		[3] = UNIT_COUNT_GENERATION_MODE_RAW,
		[4] = UNIT_COUNT_GENERATION_MODE_RAW,
	},

	army_base_count_data = {
		[1] = {
			[DIFFICULTY_HEROIC] = 37,
			[DIFFICULTY_EASY] = 19,
			[DIFFICULTY_NORMAL] = 25,
			[DIFFICULTY_HARD] = 30,
		},
		[2] = {
			[DIFFICULTY_HARD] = 23,
			[DIFFICULTY_EASY] = 13,
			[DIFFICULTY_HEROIC] = 28,
			[DIFFICULTY_NORMAL] = 18,
		},
		[3] = {
			[DIFFICULTY_EASY] = 10,
			[DIFFICULTY_HEROIC] = 20,
			[DIFFICULTY_NORMAL] = 13,
			[DIFFICULTY_HARD] = 16,
		},
		[4] = {
			[DIFFICULTY_HEROIC] = 4,
			[DIFFICULTY_EASY] = 2,
			[DIFFICULTY_HARD] = 3,
			[DIFFICULTY_NORMAL] = 2,
		},
	},

	army_counts_grow = {
	},

	army_getters = {
		[1] = function ()
            local result = Random.FromTable({2305})
            return result
        end,
		[2] = function ()
            local result = Random.FromTable({2306})
            return result
        end,
		[3] = function ()
            local result = Random.FromTable({2307})
            return result
        end,
		[4] = function ()
            local result = Random.FromTable({2309})
            return result
        end,
	},

}