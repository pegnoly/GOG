while not BTD_BANK_CRYPT and BTD_BANKS_DATA do
	sleep()
end

BTD_BANKS_DATA[BTD_BANK_CRYPT] = {
	recharges_count = 1,
	recharge_timer = 28,
	morale_loss = 3,
	luck_loss = 1,
	generation_chances = {
		[BANK_DIFFICULTY_EASY] = 100,
		[BANK_DIFFICULTY_MEDIUM] = 30,
		[BANK_DIFFICULTY_HARD] = 20,
		[BANK_DIFFICULTY_CRITICAL] = 20,
		[BANK_DIFFICULTY_BOSS] = 20,
	},
	variants = {
		[0] = {
			difficulty = BANK_DIFFICULTY_EASY,
			creatures = {
				{
					type = BANK_SLOT_TYPE_CREATURE_TIER,
					town = TOWN_NECROMANCY,
					tier = 1,
					base_power = 5000,
					power_grow = 1000, 
				},
				{
					type = BANK_SLOT_TYPE_CREATURE_TIER,
					town = TOWN_NECROMANCY,
					tier = 2,
					base_power = 6000,
					power_grow = 1100, 
				},
				{
					type = BANK_SLOT_TYPE_CREATURE_TIER,
					town = TOWN_NECROMANCY,
					tier = 1,
					base_power = 5900,
					power_grow = 900, 
				},
			}
		},
		[1] = {
			difficulty = BANK_DIFFICULTY_EASY,
			creatures = {
				{
					type = BANK_SLOT_TYPE_CREATURE_TIER,
					town = TOWN_NECROMANCY,
					tier = 4,
					base_power = 50000,
					power_grow = 3000, 
				},
			}
		},
		[2] = {
			difficulty = BANK_DIFFICULTY_MEDIUM,
			creatures = {
			}
		},
		[3] = {
			difficulty = BANK_DIFFICULTY_HARD,
			creatures = {
			}
		},
	}
}