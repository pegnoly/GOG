while not BTD_BANK_MAGI_VAULT and BTD_BANKS_DATA do
	sleep()
end

BTD_BANKS_DATA[BTD_BANK_MAGI_VAULT] = {
	recharges_count = -1,
	recharge_timer = 14,
	morale_loss = 0,
	luck_loss = 0,
	generation_chances = {
		[BANK_DIFFICULTY_EASY] = 20,
		[BANK_DIFFICULTY_MEDIUM] = 20,
		[BANK_DIFFICULTY_HARD] = 20,
		[BANK_DIFFICULTY_CRITICAL] = 20,
		[BANK_DIFFICULTY_BOSS] = 20,
	},
	variants = {
	}
}