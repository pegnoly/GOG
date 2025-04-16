start_zone = {

    path = {
        npc = zones_path.."Start/Npc/",
        text = zones_path.."Start/Texts/",
    },

    Load = function ()
        doFile(start_zone.path.npc.."witch.lua")
        doFile(start_zone.path.npc.."seer.lua")
    end,

    Init = function ()
        startThread(npc_start_zone_witch.Init)
    end,
}

while not start_zone.Load do
    sleep()
end

startThread(start_zone.Load)