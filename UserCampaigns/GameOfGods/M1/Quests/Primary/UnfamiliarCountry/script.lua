DIALOG_ROAD_PACT_START = "C2M1_DIALOG_03"
DIALOG_BUY_ROAD_PACT = "C2M1_DIALOG_04"

c2m1_unfamiliar_country = {
    name = "UNFAMILIAR_COUNTRY",
    path = {
        main = "UserCampaigns/GameOfGods/M1/Quests/Primary/UnfamiliarCountry",
        text = "UserCampaigns/GameOfGods/M1/Quests/Primary/UnfamiliarCountry/Texts/",
        dialog = "UserCampaigns/GameOfGods/M1/Quests/Primary/UnfamiliarCountry/Dialogs/"
    },

    road_pact_cost = 4000,

    Load = 
    function()
        while not (Quest and Quest.Names) do
            sleep()
        end
        Quest.Names["UNFAMILIAR_COUNTRY"] = "UserCampaigns/GameOfGods/M1/Quests/Primary/UnfamiliarCountry/name.txt"
    end,

    Init = 
    function ()
        while not Interactables["listmur_magistrat"] do
            sleep()
        end

        local magistrat = Interactables["listmur_magistrat"]
        magistrat.AddInteraction("road_pact_talk", Interaction(c2m1_unfamiliar_country.RoadPactTalk, nil, INTERACTION_PRIORITY_DEFAULT))
        Quest.SetObjectQuestmark("listmur_magistrat", QUESTMARK_OBJ_IN_PROGRESS, 5)
    end,

    RoadPactTalk = 
    function (hero, object)
        MiniDialog.Start(DIALOG_ROAD_PACT_START)
        startThread(c2m1_unfamiliar_country.TryToBuyRoadPact, hero, object)
    end,

    TryToBuyRoadPact = 
    function (hero, object)
        local magistrat = Interactables["listmur_magistrat"]
        if MCCS_QuestionBox({c2m1_unfamiliar_country.path.text.."buy_road_pact.txt"; amount = c2m1_unfamiliar_country.road_pact_cost}) then
            local gold = GetPlayerResource(PLAYER_1, GOLD)
            if gold >= c2m1_unfamiliar_country.road_pact_cost then
                SetPlayerResource(PLAYER_1, GOLD, gold - c2m1_unfamiliar_country.road_pact_cost)
                Quest.Update(c2m1_unfamiliar_country.name, 1, hero)
                Quest.ResetObjectQuestmark("listmur_magistrat")
                MiniDialog.Start(DIALOG_BUY_ROAD_PACT)
                startThread(c2m1_lost_caravan.Start, hero, object)
                --
                magistrat.RemoveInteraction("road_pact_talk").RemoveInteraction("buy_road_pact")
            else
                MessageBox(c2m1_unfamiliar_country.path.text.."not_enough_gold.txt")
                if not magistrat.HasInteraction("buy_road_pact") then
                    magistrat.RemoveInteraction("road_pact_talk")
                    magistrat.AddInteraction("buy_road_pact", Interaction(c2m1_unfamiliar_country.TryToBuyRoadPact, nil, INTERACTION_PRIORITY_DEFAULT))
                end
            end
        else
            if not magistrat.HasInteraction("buy_road_pact") then
                magistrat.RemoveInteraction("road_pact_talk")
                magistrat.AddInteraction("buy_road_pact", Interaction(c2m1_unfamiliar_country.TryToBuyRoadPact, nil, INTERACTION_PRIORITY_DEFAULT))
            end
        end
    end
}