
c2m1_unfamiliar_country = {
    name = "UNFAMILIAR_COUNTRY",
    path = {
        main = "UserCampaigns/GameOfGods/M1/Quests/Primary/UnfamiliarCountry",
        text = "UserCampaigns/GameOfGods/M1/Quests/Primary/UnfamiliarCountry/Texts/",
        dialog = "UserCampaigns/GameOfGods/M1/Quests/Primary/UnfamiliarCountry/Dialogs/"
    },

    Load = 
    function()
        Quest.Names["UNFAMILIAR_COUNTRY"] = "UserCampaigns/GameOfGods/M1/Quests/Primary/UnfamiliarCountry/name.txt"
    end,

    Init = 
    function ()

    end
}