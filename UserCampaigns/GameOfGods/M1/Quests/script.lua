c2m1_quests_main = {

    path = {
        primary = mainPath.."Quests/Primary/",
        secondary = mainPath.."Quests/Secondary/"
    },

    Load = function ()
        -- primary quests loaders
        doFile(c2m1_quests_main.path.primary.."UnfamiliarCountry/script.lua")

        -- secondary quests loaders
        doFile(c2m1_quests_main.path.secondary.."TheGreatSearch/script.lua")
        doFile(c2m1_quests_main.path.secondary.."TheLostCaravan/script.lua")

        while not (c2m1_unfamiliar_country and c2m1_great_search and c2m1_lost_caravan) do
            sleep()
        end
        startThread(c2m1_unfamiliar_country.Load)
            
        startThread(c2m1_great_search.Load)
        startThread(c2m1_lost_caravan.Load)
    end,

    Init = function ()
        startThread(c2m1_unfamiliar_country.Init)

        startThread(c2m1_great_search.Init)
        startThread(c2m1_lost_caravan.Init)
    end
}