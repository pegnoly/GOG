c1m1_heroes = {
    Load = 
    function ()
        doFile(heroes_path.."Necromancers/script.lua")

        while not c1m1_necromancers do
            sleep()
        end

        startThread(c1m1_necromancers.Load)
    end,

    Init = 
    function ()
        while not (c1m1_necromancers and c1m1_necromancers.Init) do
            sleep()
        end
        startThread(c1m1_necromancers.Init)
        print"c1m1_heroes Init"
    end
}