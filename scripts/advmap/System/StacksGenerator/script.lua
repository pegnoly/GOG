---@class GeneratableStack
---@field min_stacks number
---@field max_stacks number
---@field power number
---@field use_allied_fracs 1|nil
---@field max_tier number
---@field init_priority number
GeneratableStack = {}

---@class PreparedStackData
---@field creature number
---@field count number
PreparedStackData = {}

doFile(GetMapDataPath().."monsters_generated_data.lua")

while not GENERATABLE_STACKS do
    sleep()
end

stacks_generator = {
    ---@type table<string, PreparedStackData[]>
    prepared_stacks_data = {},
    ---@type table<number, string[]>
    stacks_by_priority = {},

    allied_towns = {
        [TOWN_HEAVEN] = { TOWN_HEAVEN, TOWN_ACADEMY, TOWN_PRESERVE, TOWN_FORTRESS, TOWN_RENEGADES },
        [TOWN_ACADEMY] = { TOWN_ACADEMY, TOWN_HEAVEN, TOWN_PRESERVE, TOWN_FORTRESS },
        [TOWN_PRESERVE] = { TOWN_PRESERVE, TOWN_HEAVEN, TOWN_FORTRESS, TOWN_ACADEMY },
        [TOWN_FORTRESS] = { TOWN_FORTRESS, TOWN_HEAVEN, TOWN_ACADEMY, TOWN_PRESERVE },
        [TOWN_DUNGEON] = { TOWN_DUNGEON, TOWN_NECROMANCY, TOWN_STRONGHOLD, TOWN_BASTION },
        [TOWN_NECROMANCY] = { TOWN_NECROMANCY, TOWN_BASTION, TOWN_STRONGHOLD, TOWN_DUNGEON}, 
        [TOWN_STRONGHOLD] = { TOWN_STRONGHOLD, TOWN_BASTION, TOWN_DUNGEON, TOWN_NECROMANCY, TOWN_SANCTUARY },
        [TOWN_BASTION] = { TOWN_BASTION, TOWN_DUNGEON, TOWN_NECROMANCY, TOWN_STRONGHOLD },
        [TOWN_SANCTUARY] = { TOWN_SANCTUARY, TOWN_STRONGHOLD },
        [TOWN_RENEGADES] = { TOWN_RENEGADES, TOWN_HEAVEN }
    },

    this_map_banned_towns = {},

    Init = function ()
        ---@param stack string
        ---@param data GeneratableStack
        for stack, data in GENERATABLE_STACKS do
            if not stacks_generator.stacks_by_priority[data.init_priority] then
                stacks_generator.stacks_by_priority[data.init_priority] = {}
            end
            table.push(stacks_generator.stacks_by_priority[data.init_priority], stack)
            startThread(stacks_generator.PrepareStack, stack, data)
        end
    end,

    PrepareStack = 
    ---@param stack string
    ---@param data GeneratableStack
    function (stack, data)
        local initial_creature, initial_count = GetObjectArmySlotCreature(stack, 0)
        local town = Creature.Params.TownExtended(initial_creature)
        if town == TOWN_NO_TYPE then
            return
        end
        stacks_generator.prepared_stacks_data[stack] = {}
        local additional_stacks_count = Random.FromSelection(data.min_stacks, data.max_stacks)
        local towns = data.use_allied_fracs and stacks_generator.allied_towns[town] or { town }
        local tiers = range_generator.FromTop(1, 7, function (item)
            local max_tier = %data.max_tier
            if item < max_tier then
                return 1
            end
            return nil
        end)
        local possible_ids = Iterator(Creature.Selection.FromTownsAndTiers(towns, tiers))
            .Filter(function (item)
                local initial_creature = %initial_creature
                if item ~= initial_creature and Creature.Params.IsGeneratable(item) then
                    return 1
                end
                return nil
            end)
            .TakeRandom(additional_stacks_count)
            .Collect()
        
        local power_per_stack = ceil(data.power / (additional_stacks_count + 1))
        for _, id in possible_ids do
            table.push(stacks_generator.prepared_stacks_data[stack], { creature = id, count = ceil(power_per_stack / Creature.Params.Power(id)) })
        end
        table.push(stacks_generator.prepared_stacks_data[stack], { 
            creature = initial_creature, 
            count = ceil(power_per_stack / Creature.Params.Power(initial_creature)) - initial_count
        })
    end,

    ProcessStacksOfPriority =
    ---@param priority number
    function (priority)
        for _, stack in stacks_generator.stacks_by_priority[priority] do
            if stacks_generator.prepared_stacks_data[stack] then
                local prepared_data = stacks_generator.prepared_stacks_data[stack]
                for _, stack_data in prepared_data do
                    AddObjectCreatures(stack, stack_data.creature, stack_data.count)
                end 
            end
        end
    end
}