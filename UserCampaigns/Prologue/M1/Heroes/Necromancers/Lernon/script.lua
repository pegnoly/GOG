lernon_advmap = {
    path = heroes_path.."Necromancers/Lernon/",

    Load =
    function ()
        doFile(lernon_advmap.path.."c1m1_lernon_fight_data.lua")
        while not (c1m1_lernon_fight_data and c1m1_necromancers and c1m1_necromancers.fights_data) do
            sleep()
        end
        c1m1_necromancers.fights_data["Lernon"] = c1m1_lernon_fight_data
        c1m1_necromancers.fights_data["Lernon"] = c1m1_lernon_fight_data
    end
}