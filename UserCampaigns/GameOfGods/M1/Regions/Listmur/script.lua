c2m1_listmur_region = {

    path = {
        dialog = regions_path.."Listmur/Dialogs/",
        text = regions_path.."Listmur/Texts/"
    },

    dialogs = {
        OnEnter = "C2M1_DIALOG_01"
    },

    Init = 
    function ()
        print("Init Listmur")
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "listmur_region_first_dialog", "c2m1_listmur_region.PlayOnEnterDialog")
    end,

    PlayOnEnterDialog = 
    function (_, region)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        MiniDialog.Start(c2m1_listmur_region.path.dialog.."KarlamNoellieFirst/", PLAYER_1, c2m1_listmur_region.dialogs.OnEnter, nil)
    end
}