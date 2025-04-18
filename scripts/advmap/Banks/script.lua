doFile("/scripts/advmap/Banks/consts.lua")
doFile("/scripts/advmap/Banks/data.lua")

doFile(GetMapDataPath().."buildings_generated_data.lua")

while not NEW_BANKS_DATA and BTD_BANKS_DATA do
    sleep()
end

print"BTD BANKS DATA READY"

btd_banks = {

    current_variants = {},
	current_cooldowns = {},

    InitBank = function (bank)
        btd_banks.current_cooldowns[bank] = 0
		Touch.DisableObject(bank)
		Touch.SetFunction(bank, "_"..bank.."_touch", btd_banks.TouchBank)
    end,

    SetupVariant = function (bank, type)
        local info = BTD_BANKS_DATA[type]
		local prob = random(100) + 1
		local current_chance = 0
		for i, variant in info.variants do
			current_chance = current_chance + variant.chance;
			if current_chance >= prob then
				btd_banks.current_variants[bank] = i
				break
			end
		end
		OverrideObjectTooltipNameAndDescription(bank, BTD_BANKS_NAMES[type], BTD_BANKS_DIFF_NAMES[info.variants[btd_banks.current_variants[bank]].difficulty])
    end,

    TouchBank = function (hero, object)
        print"Touch bank"
    end,

    Init = function ()
        print"Bank init started"
        for bank, type in NEW_BANKS_DATA do
            print("Bank: ", bank)
            startThread(btd_banks.InitBank, bank)
			startThread(btd_banks.SetupVariant, bank, type)
        end
    end
}

while not MapLoadingEvent and btd_banks do
	sleep()
end

MapLoadingEvent.AddListener("test_list",
function()
	startThread(btd_banks.Init)
end)