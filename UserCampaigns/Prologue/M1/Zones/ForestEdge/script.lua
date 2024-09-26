forest_edge_zone = {

    path = GetMapDataPath().."Zones/ForestEdge/",

    Init = 
    function ()
        startThread(forest_edge_zone.InitArtifactMerchant)
        startThread(forest_edge_zone.InitTavern)
    end,

    InitArtifactMerchant = 
    function ()
        local path = forest_edge_zone.path.."Objects/ArtifactMerchant/"
        Touch.DisableObject("forest_edge_artifact_merchant", DISABLED_INTERACT, path.."name.txt", path.."desc.txt")
        Touch.SetDefault("forest_edge_artifact_merchant", function (hero, object)
            MessageBox(%path.."closed.txt")        
        end)
    end,

    InitTavern = 
    function ()
        local path = forest_edge_zone.path.."Objects/Tavern/"
        Touch.DisableObject("forest_edge_tavern", DISABLED_INTERACT, path.."name.txt", path.."desc.txt")
    end
}