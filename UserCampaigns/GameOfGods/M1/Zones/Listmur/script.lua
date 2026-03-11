while not c2m1_great_search do
    sleep()
end

c2m1_zone_listmur = {

    path = {
        text = mainPath.."Zones/Listmur/Texts/"
    },

    Init = function ()
        Interactable("listmur_temple")
            .AsBuilding(DISABLED_DEFAULT, c2m1_zone_listmur.path.text.."temple_name.txt")

        Interactable("listmur_magistrat")
            .AsBuilding(DISABLED_INTERACT, c2m1_zone_listmur.path.text.."magistrat_name.txt")
    end
}