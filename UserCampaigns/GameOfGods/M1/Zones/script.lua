c2m1_zones_main = {

    path = mainPath.."Zones/",

    Load = function ()
        doFile(c2m1_zones_main.path.."Listmur/script.lua")
    end,

    Init = 
    function ()
        while not c2m1_zone_listmur do
            sleep()
        end

        startThread(c2m1_zone_listmur.Init)
    end
}