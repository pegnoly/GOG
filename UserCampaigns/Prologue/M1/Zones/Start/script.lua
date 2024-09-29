start_zone = {

    path = 
    {
        text = zones_path.."Start/Texts/",
        -- dialog = primary_quest_path.."AshaTear/Dialogs/"
    },

    Init = 
    function ()
        startThread(start_zone.InitTreantBank)
        startThread(start_zone.InitElementalStockpile)
    end,

    InitTreantBank = 
    function ()
        Touch.DisableObject("start_zone_elf_treasure")
        Touch.SetDefault("start_zone_elf_treasure", 
        function (hero, object)
            MessageBox(start_zone.path.text.."treant_bank_default.txt")
        end)
    end,

    InitElementalStockpile = 
    function ()
        Touch.DisableObject("start_zone_elemental_stockpile")
    end
}