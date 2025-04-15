start_zone = {

    path = {
        npc = zones_path.."Start/Npc/",
        text = zones_path.."Start/Texts/",
    },

    Load = function ()
        doFile(start_zone.path.npc.."witch.lua")
    end,

    Init = function ()
        startThread(npc_start_zone_witch.Init)
    end,

    InitTreantBank = function ()
        Touch.DisableObject("start_zone_elf_treasure")
        Touch.SetDefault("start_zone_elf_treasure", 
        function (hero, object)
            MessageBox(start_zone.path.text.."treant_bank_default.txt")
        end)
    end,

    InitElementalStockpile = function ()
        Touch.DisableObject("start_zone_elemental_stockpile")
    end,

}

while not start_zone.Load do
    sleep()
end

startThread(start_zone.Load)