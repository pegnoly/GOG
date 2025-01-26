c1m1_heroes = {
    Load = 
    function ()
        doFile(mainPath.."Heroes/Ainurel/script.lua")
        print"c1m1_heroes Load"
    end,

    Init = 
    function ()
        while not ainurel_advmap do
            sleep()
        end
        startThread(ainurel_advmap.Init)
        print"c1m1_heroes Init"
    end
}