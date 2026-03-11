while not MiniDialog do
    sleep()
end

DIALOG_YLATH_TEMPLE_GREAT_SEARCH_START = "C2M1_DIALOG_02"

c2m1_great_search = {
    name = "GREAT_SEARCH",
    path = {
        main = "UserCampaigns/GameOfGods/M1/Quests/Secondary/TheGreatSearch",
        text = "UserCampaigns/GameOfGods/M1/Quests/Secondary/TheGreatSearch/Texts/",
        dialog = "UserCampaigns/GameOfGods/M1/Quests/Secondary/TheGreatSearch/Dialogs/"
    },

    Load = 
    function()
        while not (Quest and Quest.Names) do
            sleep()
        end
        Quest.Names["GREAT_SEARCH"] = "UserCampaigns/GameOfGods/M1/Quests/Secondary/TheGreatSearch/name.txt"
    end,

    Init = 
    function ()
        Quest.SetObjectQuestmark("listmur_temple", QUESTMARK_OBJ_NEW, 5)
    end,

    Start = 
    function (hero)
        MiniDialog.Start(DIALOG_YLATH_TEMPLE_GREAT_SEARCH_START)
        Quest.Start(c2m1_great_search.name, hero)
    end
}