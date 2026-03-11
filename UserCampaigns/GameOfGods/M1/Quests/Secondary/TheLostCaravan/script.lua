DIALOG_LOST_CARAVAN_START = "C2M1_DIALOG_05"

c2m1_lost_caravan = {
    name = "LOST_CARAVAN",
    path = {
        main = "UserCampaigns/GameOfGods/M1/Quests/Secondary/TheLostCaravan",
        text = "UserCampaigns/GameOfGods/M1/Quests/Secondary/TheLostCaravan/Texts/",
        dialog = "UserCampaigns/GameOfGods/M1/Quests/Secondary/TheLostCaravan/Dialogs/"
    },

    Load = 
    function()
        while not Quest and Quest.Names do 
            sleep()
        end
        Quest.Names["LOST_CARAVAN"] = "UserCampaigns/GameOfGods/M1/Quests/Secondary/TheLostCaravan/name.txt"
    end,

    Init = 
    function ()
    end,

    Start = 
    function (hero, object)
        MiniDialog.Start(DIALOG_LOST_CARAVAN_START)
        Quest.Start(c2m1_lost_caravan.name, hero)
    end
}