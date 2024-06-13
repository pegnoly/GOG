moriton_zone = {

    exp_sharing_blocked_for_hero = {},

    Init = 
    function()
        AddHeroEvent.AddListener("C1_M1_zone_moriton_add_preserve_hero_listener", moriton_zone.PreserveHeroAddListener)
    end,

    PreserveHeroAddListener = 
    function (hero)
        while not GetObjectOwner(hero) == PLAYER_1 do
            sleep()
        end
        moriton_zone.exp_sharing_blocked_for_hero[hero] = nil
        XpTrackingEvent.AddListener("C1_M1_zone_moriton_exp_sharing_listener", moriton_zone.ExpSharingListener)
    end,

    -- логика общего получения экспы героями-эльфами в Моритоне.
    ExpSharingListener = 
    function (hero, curr_exp, new_exp)
        local exp_diff = new_exp - curr_exp
        if exp_diff > 0 and (not moriton_zone.exp_sharing_blocked_for_hero[hero]) then
            for i, _hero in GetPlayerHeroes(PLAYER_1) do
                if _hero ~= hero then
                    if Hero.Params.Town(_hero) == TOWN_PRESERVE then
                        moriton_zone.exp_sharing_blocked_for_hero[_hero] = 1
                        local final_exp = GetHeroStat(_hero, STAT_EXPERIENCE) + exp_diff
                        GiveExp(_hero, exp_diff)
                        startThread(
                        function ()
                            while GetHeroStat(%_hero, STAT_EXPERIENCE) ~= %final_exp do
                                sleep()
                            end
                            sleep()
                            moriton_zone.exp_sharing_blocked_for_hero[%_hero] = nil
                        end)
                    end
                end
            end
        end
    end
}