great_elementals = {
    elem_type = -1,
    elems_stack = "",
    current_elems_count = -1,
    base_elems_count = -1,
    last_unit = "",
    elem_killed_on_hero_turn = nil,
    elem_possibly_killed_by_spell = nil,
    path = GetMapDataPath().."Combat/GreatElementals/",
}

if not GetDefenderHero() then
    AddCombatFunction(CombatFunctions.START, "try_init_greater_elementals_fight",
    function ()
        if list_iterator.Any(GetDefenderCreatures(), function (creature) return GetCreatureType(creature) == CREATURE_OBSIDIAN_ELEMENTAL end) then
            for _, creature in GetDefenderCreatures() do
                if GetCreatureType(creature) == CREATURE_OBSIDIAN_ELEMENTAL then
                    great_elementals.elem_type = CREATURE_OBSIDIAN_ELEMENTAL
                    great_elementals.elems_stack = creature
                    great_elementals.base_elems_count = GetCreatureNumber(creature)
                    great_elementals.current_elems_count = great_elementals.base_elems_count
                    break
                end
            end
        elseif list_iterator.Any(GetDefenderCreatures(), function (creature) return GetCreatureType(creature) == CREATURE_BLAZE_ELEMENTAL end) then
            for _, creature in GetDefenderCreatures() do
                if GetCreatureType(creature) == CREATURE_BLAZE_ELEMENTAL then
                    great_elementals.elem_type = CREATURE_BLAZE_ELEMENTAL
                    great_elementals.elems_stack = creature
                    great_elementals.base_elems_count = GetCreatureNumber(creature)
                    great_elementals.current_elems_count = great_elementals.base_elems_count
                    break
                end
            end
        elseif list_iterator.Any(GetDefenderCreatures(), function (creature) return GetCreatureType(creature) == CREATURE_STORM_ELEMENTAL end) then
            for _, creature in GetDefenderCreatures() do
                if GetCreatureType(creature) == CREATURE_STORM_ELEMENTAL then
                    great_elementals.elem_type = CREATURE_STORM_ELEMENTAL
                    great_elementals.elems_stack = creature
                    great_elementals.base_elems_count = GetCreatureNumber(creature)
                    great_elementals.current_elems_count = great_elementals.base_elems_count
                    break
                end
            end
        elseif list_iterator.Any(GetDefenderCreatures(), function (creature) return GetCreatureType(creature) == CREATURE_ICE_ELEMENTAL end) then
            for _, creature in GetDefenderCreatures() do
                if GetCreatureType(creature) == CREATURE_ICE_ELEMENTAL then
                    great_elementals.elem_type = CREATURE_ICE_ELEMENTAL
                    great_elementals.elems_stack = creature
                    great_elementals.base_elems_count = GetCreatureNumber(creature)
                    great_elementals.current_elems_count = great_elementals.base_elems_count
                    break
                end
            end
        end
        --
        AddCombatFunction(CombatFunctions.ON_SPELL_CAST, "great_elementals_on_spell_cast",
        function (caster, spell, target)
            if caster == GetAttackerHero() then
                if great_elementals.elem_killed_on_hero_turn then
                    great_elementals.elem_possibly_killed_by_spell = 1
                    -- weird shit
                    while combatReadyPerson() do
                        sleep()
                    end
                    while not combatReadyPerson() do
                        sleep()
                    end
                    --
                    --great_elementals.ignore_default_death_event = nil
                    --
                    if GetCreatureNumber(great_elementals.elems_stack) == 0 and great_elementals.current_elems_count > 0 then
                        -- obsidian elem death
                        if great_elementals.elem_type == CREATURE_OBSIDIAN_ELEMENTAL then
                            if spell == SPELL_LIGHTNING_BOLT or spell == SPELL_CHAIN_LIGHTNING then
                                startThread(CombatFlyingSign, great_elementals.path.."stone_heart_collected.txt", great_elementals.elems_stack, 10)
                                SetGameVar("stone_heart", "collected")
                            else 
                                startThread(ResurrectElems, CREATURE_OBSIDIAN_ELEMENTAL)
                            end
                        -- blaze elem death
                        elseif great_elementals.elem_type == CREATURE_BLAZE_ELEMENTAL then
                            if spell == SPELL_ICE_BOLT or spell == SPELL_FROST_RING or spell == SPELL_DEEP_FREEZE then
                                startThread(CombatFlyingSign, great_elementals.path.."blazing_heart_collected.txt", great_elementals.elems_stack, 10)
                                SetGameVar("blazing_heart", "collected")
                            else 
                                startThread(ResurrectElems, CREATURE_BLAZE_ELEMENTAL)
                            end
                        -- storm elem death
                        elseif great_elementals.elem_type == CREATURE_STORM_ELEMENTAL then
                            if spell == SPELL_FIREBALL or spell == SPELL_MAGIC_ARROW or spell == SPELL_FIREWALL or spell == SPELL_ARMAGEDDON then
                                startThread(CombatFlyingSign, great_elementals.path.."dazzling_heart_collected.txt", great_elementals.elems_stack, 10)
                                SetGameVar("dazzling_heart", "collected")
                            else 
                                startThread(ResurrectElems, CREATURE_STORM_ELEMENTAL)
                            end
                        -- ice elem death
                        elseif great_elementals.elem_type == CREATURE_ICE_ELEMENTAL then
                            if spell == SPELL_EARTH_SPIKE or spell == SPELL_METEOR_SHOWER or spell == SPELL_IMPLOSION then
                                startThread(CombatFlyingSign, great_elementals.path.."frozen_heart_collected.txt", great_elementals.elems_stack, 10)
                                SetGameVar("frozen_heart", "collected")
                            else 
                                startThread(ResurrectElems, CREATURE_ICE_ELEMENTAL)
                            end
                        end
                    end
                end
            end
        end)
        --
        AddCombatFunction(CombatFunctions.UNIT_MOVE, "greater_elementals_fight_counter",
        function (unit)
            great_elementals.current_elems_count = GetCreatureNumber(great_elementals.elems_stack)
            great_elementals.last_unit = unit
            if unit == GetAttackerHero() then
                startThread(
                function ()
                    while combatReadyPerson() do
                        sleep()
                    end
                    while not combatReadyPerson() do
                        sleep()
                    end
                    if great_elementals.elem_killed_on_hero_turn and (not great_elementals.elem_possibly_killed_by_spell) then
                        startThread(ResurrectElems, great_elementals.elem_type)
                    end
                    great_elementals.elem_killed_on_hero_turn = nil
                    great_elementals.elem_possibly_killed_by_spell = nil
                end)
            end
        end)
        --
        AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_DEATH, "greater_elementals_default_death_event",
        function (creature)
            local type = GetCreatureType(creature)
            if list_iterator.Any({CREATURE_OBSIDIAN_ELEMENTAL, CREATURE_BLAZE_ELEMENTAL, CREATURE_STORM_ELEMENTAL, CREATURE_ICE_ELEMENTAL}, function (e) return %type == e end) then
                if great_elementals.last_unit == GetAttackerHero() then
                    great_elementals.elem_killed_on_hero_turn = 1
                    return
                else
                    if type == CREATURE_OBSIDIAN_ELEMENTAL then
                        startThread(ResurrectElems, CREATURE_OBSIDIAN_ELEMENTAL)
                    elseif type == CREATURE_BLAZE_ELEMENTAL then
                        startThread(ResurrectElems, CREATURE_BLAZE_ELEMENTAL)
                    elseif type == CREATURE_STORM_ELEMENTAL then
                        startThread(ResurrectElems, CREATURE_STORM_ELEMENTAL)
                    elseif type == CREATURE_ICE_ELEMENTAL then
                        startThread(ResurrectElems, CREATURE_ICE_ELEMENTAL)
                    end
                end 
            end
        end)
    end)
end

function ResurrectElems(elem_type)
    local x, y = pos(great_elementals.elems_stack)
    if pcall(AddCreature, DEFENDER, elem_type, great_elementals.base_elems_count, x, y, nil, great_elementals.elems_stack) then
        while not exist(great_elementals.elems_stack) do
            sleep()
        end
        startThread(CombatFlyingSign, great_elementals.path..GetResurrectMessage(elem_type), great_elementals.elems_stack, 15)
    end
end

function GetResurrectMessage(elem_type)
    local msg = ""
    if elem_type == CREATURE_OBSIDIAN_ELEMENTAL then
        msg = "obsidian_resurrect.txt"
    elseif elem_type == CREATURE_BLAZE_ELEMENTAL then
        msg = "blaze_resurrect.txt"
    elseif elem_type == CREATURE_STORM_ELEMENTAL then
        msg = "storm_resurrect.txt"
    elseif elem_type == CREATURE_ICE_ELEMENTAL then
        msg = "ice_resurrect.txt"
    end
    return msg
end