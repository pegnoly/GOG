Npc = {
    interactions = {},

    Init = 
    function (object)
        Npc.interactions[object] = {}
    end,

    AddInteraction = 
    function (object, name, condition, interaction)
        Npc.interactions[object][name] = {condition = condition, interaction = interaction}
    end,

    RemoveInteraction =
    function (object, name)
        Npc.interactions[object][name] = nil
    end,

    RunInteractions = 
    function (hero, object)
        local interactions = Npc.interactions[object]
        local actual_interactions, n = {}, 0
        for interaction in interactions do
            if interaction.condition(hero, object) then
                n = n + 1
                actual_interactions[n] = interaction.interaction
            end
        end
        for interaction in actual_interactions do
            interaction(hero, object)
        end
    end
}