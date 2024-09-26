C2M2_NPC_TARSHAD = "c2m2_npc_tarshad"

c2m2_r_mystery_keepers = {

    path = {
        names = GetMapDataPath().."Regions/MysteryKeepersRegion/Npc/Names",
    }

    Init = function ()
        Touch.DisableMonster(C2M2_NPC_TARSHAD, DISABLED_INTERACT, 0, c2m2_r_mystery_keepers.path.names.."tarshad.txt")
        Touch.SetFunction(C2M2_NPC_TARSHAD, "_touch", c2m2_r_mystery_keepers.TouchNpcTarshad)
    end,

    TouchNpcTarshad = 
    function (hero, object)
        
    end,
}