doFile("/scripts/advmap/Banks/consts.lua")
doFile("/scripts/advmap/Banks/Data/main.lua")

doFile(GetMapDataPath().."buildings_generated_data.lua")

while not NEW_BANKS_DATA and BTD_BANKS_DATA and BTD_BANKS_DATA[BTD_BANK_DRAGON_UTOPIA] do
    sleep()
end

print"BTD BANKS DATA READY"

btd_banks = {

    current_difficulties = {},
	current_cooldowns = {},

    InitBank = function (bank)
        btd_banks.current_cooldowns[bank] = 0
        btd_banks.current_difficulties[bank] = nil
		Touch.DisableObject(bank)
		Touch.SetFunction(bank, "_"..bank.."_touch", btd_banks.TouchBank)
    end,

    SetupVariant = function (bank, type)
        local info = BTD_BANKS_DATA[type]
		local prob = random(100) + 1
		local current_chance = 0
		for difficulty, chance in info.generation_chances do
			current_chance = current_chance + chance;
			if current_chance >= prob then
				btd_banks.current_difficulties[bank] = difficulty
				break
			end
		end
		OverrideObjectTooltipNameAndDescription(
            bank, 
            BTD_BANKS_NAMES[type], 
            BTD_BANKS_DIFF_NAMES[btd_banks.current_difficulties[bank]]
        )
    end,

    TouchBank = function (hero, object)
        local bank_type = NEW_BANKS_DATA[object]
        local difficulty = btd_banks.current_difficulties[object]
        local possible_variants = list_iterator.Filter(BTD_BANKS_DATA[bank_type].variants, function (variant)
            local result = variant.difficulty == %difficulty
            return result
        end)
        -- print("Possible variants: ", possible_variants)
        local concrete_variant = Random.FromTable(possible_variants)
        -- print("Selected variant:", concrete_variant)
        local slots_count = 0
        local stacks_data, n = {}, 1
        for i, slot_data in concrete_variant.creatures do
            slots_count = slots_count + 1
            if slot_data.type == BANK_SLOT_TYPE_CREATURE_TIER then
                local generatable_creatures = list_iterator.Filter(TIER_TABLES[slot_data.town][slot_data.tier], function (creature)
                    local result = Creature.Params.IsGeneratable(creature)
                    return result
                end)
                print("<color=red>Selecting creature from <color=green>", generatable_creatures)
                local creature = Random.FromTable(generatable_creatures)
                print("<color=red>Selected creature: <color=green>", creature)
                local week = GetDate(WEEK)
                local count = ceil((slot_data.base_power + week * slot_data.power_grow) / Creature.Params.Power(creature))
                stacks_data[n] = creature
                stacks_data[n + 1] = count
                n = n + 2
            end
        end
        print("<color=red>Stacks data: <color=green>", stacks_data)
        MCCS_StartCombat(hero, nil, slots_count, stacks_data, nil, nil, nil, nil)
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