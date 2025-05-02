---@alias BTDBankType
BTD_BANK_BLOOD_TEMPLE = 0
BTD_BANK_CRYPT = 1
BTD_BANK_DRAGON_UTOPIA = 2
BTD_BANK_DWARVEN_TREASURE = 3
BTD_BANK_GARGOYLE_STONEVAULT = 4
BTD_BANK_MAGI_VAULT = 5
BTD_BANK_PYRAMID = 6
BTD_BANK_ELEMENTAL_STOCKPILE = 7
BTD_BANK_SUNKEN_TEMPLE = 8
BTD_BANK_TREANT_THICKET = 9

---@alias BTDBankDIFFICULTY
BANK_DIFFICULTY_EASY = 1
BANK_DIFFICULTY_MEDIUM = 2
BANK_DIFFICULTY_HARD = 3
BANK_DIFFICULTY_CRITICAL = 4
BANK_DIFFICULTY_BOSS = 5

---@alias CreatureSlotType
BANK_SLOT_TYPE_CREATURE_TIER = 0
BANK_SLOT_TYPE_CONCRETE_CREATURE = 1 

while not BTD_BANK_TREANT_THICKET and BANK_DIFFICULTY_BOSS do
    sleep()
end

BTD_BANKS_NAMES = {
	[BTD_BANK_CRYPT] = "/scripts/advmap/Banks/Texts/crypt.txt",
	[BTD_BANK_PYRAMID] = "/scripts/advmap/Banks/Texts/pyramid.txt",
	[BTD_BANK_MAGI_VAULT] = "/scripts/advmap/Banks/Texts/magi_vault.txt",
	[BTD_BANK_DRAGON_UTOPIA] = "/scripts/advmap/Banks/Texts/dragon_utopia.txt",
	[BTD_BANK_ELEMENTAL_STOCKPILE] = "/scripts/advmap/Banks/Texts/stockpile.txt",
	[BTD_BANK_DWARVEN_TREASURE] = "/scripts/advmap/Banks/Texts/dwarven.txt",
	[BTD_BANK_BLOOD_TEMPLE] = "/scripts/advmap/Banks/Texts/blood_temple.txt",
	[BTD_BANK_TREANT_THICKET] = "/scripts/advmap/Banks/Texts/treant.txt",
	[BTD_BANK_GARGOYLE_STONEVAULT] = "/scripts/advmap/Banks/Texts/gargoyle.txt",
	[BTD_BANK_SUNKEN_TEMPLE] = "/scripts/advmap/Banks/Texts/sunken_temple.txt"
}

BTD_BANKS_DIFF_NAMES = {
	[BANK_DIFFICULTY_EASY] = "/scripts/advmap/Banks/Texts/guard_easy.txt",
	[BANK_DIFFICULTY_MEDIUM] = "/scripts/advmap/Banks/Texts/guard_medium.txt",
	[BANK_DIFFICULTY_HARD] = "/scripts/advmap/Banks/Texts/guard_hard.txt",
    [BANK_DIFFICULTY_CRITICAL] = "/scripts/advmap/Banks/Texts/guard_critical.txt",
    [BANK_DIFFICULTY_BOSS] = "/scripts/advmap/Banks/Texts/guard_boss.txt"
}