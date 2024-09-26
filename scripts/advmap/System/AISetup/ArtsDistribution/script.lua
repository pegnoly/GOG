ai_art_distribution = {
    BuildArtifactsSet = 
    function (hero, set_weight, required_arts, random_arts_pool)
        --
        for i, art in required_arts do
            GiveArtefact(hero, art, 1)
        end
        --
        local already_used_slots = {}
        local slots = keys(random_arts_pool)
        --print("slots: ", slots)
        while len(already_used_slots) ~= len(slots) do
            local current_slot = Random.FromTable_IgnoreTable(already_used_slots, slots)
            if not current_slot then
                --print("ai_art_distribution: current slot wasn't found. But already_used_slots are ", already_used_slots, " and slots are ", slots)
                return
            end
            local possible_arts = table.select(random_arts_pool[current_slot], 
            function (art)
                local res = Art.Params.Cost(art) <= %set_weight
                return res
            end)
            if len(possible_arts) > 0 then
                local art_to_add = Random.FromTable(possible_arts)
                GiveArtefact(hero, art_to_add, 1)
                current_weight = set_weight - Art.Params.Cost(art_to_add)
            end
            already_used_slots[len(already_used_slots) + 1] = current_slot
            print("already_used_slots len: ", len(already_used_slots), ", slots len: ", len(slots))
            sleep()
        end
        --print("ai_art_distribution: finished. But already_used_slots are ", already_used_slots, " and slots are ", slots)
    end
}