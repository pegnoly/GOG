
c1m1_keepers_duty = {
    name = "KEEPERS_DUTY",
    path = {
        text = "UserCampaigns/Prologue/M1/Quests/Primary/KeepersDuty/Texts/",
        dialog = "UserCampaigns/Prologue/M1/Quests/Primary/KeepersDuty/Dialogs/"
    },

    dialogs = {
        UminoFirst = "C1M1_DIALOG_02"
    },

    Init = 
    function ()
        Quest.Names["KEEPERS_DUTY"] = "UserCampaigns/Prologue/M1/Quests/Primary/KeepersDuty/name.txt"
    end
}