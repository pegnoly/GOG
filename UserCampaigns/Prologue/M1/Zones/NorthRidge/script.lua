north_ridge_zone = {
    path = GetMapDataPath().."Zones/NorthRidge/",

    Init = 
    function ()
        
    end,

    InitTreasure = 
    function ()
        local path = north_ridge_zone.path.."Objects/HiddenTreasure/"
        Touch.DisableObject("north_ridge_hidden_treasure", DISABLED_INTERACT, path.."name.txt", path.."desc.txt")
    end
}