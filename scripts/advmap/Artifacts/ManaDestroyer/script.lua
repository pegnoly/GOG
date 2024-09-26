mana_destroyer = {
    active_on_hero = {},

    MainThread = 
    function ()
        while 1 do
            for player = PLAYER_1, PLAYER_8 do
                if Player.IsActive(player) then
                    for i, hero in GetPlayerHeroes(player) do
                        if not mana_destroyer.active_on_hero[hero] then
                            if HasArtefact(hero, ARTIFACT_MANA_DESTROYER, 1) then
                                mana_destroyer.active_on_hero[hero] = 1
                                SetGameVar(hero.."_mana_destroyer", "active")
                            end
                        else
                            if not HasArtefact(hero, ARTIFACT_MANA_DESTROYER, 1) then
                                mana_destroyer.active_on_hero[hero] = nil     
                                SetGameVar(hero.."_mana_destroyer", '')
                            end
                        end
                    end
                end
            end
            sleep()
        end
    end,

    Init = 
    function ()
        startThread(mana_destroyer.MainThread)
    end
}