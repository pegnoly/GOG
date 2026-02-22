
c1m2_hide_and_seek = {
    name = "HIDE_AND_SEEK",
    path = {
        main = "UserCampaigns/Prologue/M2/Quests/Secondary/HideAndSeek",
        text = "UserCampaigns/Prologue/M2/Quests/Secondary/HideAndSeek/Texts/",
        dialog = "UserCampaigns/Prologue/M2/Quests/Secondary/HideAndSeek/Dialogs/"
    },

    Load = 
    function()
        Quest.Names["HIDE_AND_SEEK"] = "UserCampaigns/Prologue/M2/Quests/Secondary/HideAndSeek/name.txt"
    end,

    Init = 
    function ()

    end
}