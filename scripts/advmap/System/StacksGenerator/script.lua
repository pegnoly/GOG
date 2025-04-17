print("Init generator")
doFile(GetMapDataPath().."monsters_generated_data.lua")

while not GENERATABLE_STACKS do
    sleep()
end

stacks_generator = {
    Init = function ()
        for stack, data in GENERATABLE_STACKS do
            print("Trying to generate stack: ", stack)
            startThread(stacks_generator.ProcessStack, stack)
        end
    end,

    ProcessStack = function (stack)
        errorHook(function ()
            print("Stack generator error with stack: ", %stack)
        end)
        local creature_type, creature_count = GetObjectArmySlotCreature(stack, 0)
        print("Base creature type of stack: ", creature_type)
        local town = Creature.Params.Town(creature_type)
        print("Creature town: ", town)
        if town ~= TOWN_NO_TYPE then
            local tier = Creature.Params.Tier(creature_type)
            print("Creature tier: ", tier)
            local add_tier
            if tier == 7 then
                add_tier = 6
            elseif tier == 1 then
                add_tier = 2
            else 
                add_tier = tier + Random.FromSelection(1, -1)
            end
            print("Tier to add: ", add_tier)
            local tier_creatures_sorted = list_iterator.Filter(TIER_TABLES[town][add_tier], 
            function (creature)
                local result = Creature.Params.IsGeneratable(creature)
                return result
            end)
            print("Possible creatures to add: ", tier_creatures_sorted)
            AddObjectCreatures(stack, Random.FromTable(tier_creatures_sorted), 10) 
        end
    end
}