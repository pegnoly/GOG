while not custom_ability_common and upgadeable_arts_common and UPG_ARTIFACT_SOULBINDER do
    sleep()
end

print"Are we here?"

CUSTOM_ABILITY_SOULBINDER_MENU = 5
CUSTOM_ABILITY_SOULBINDER_CONNECTOR = 6
CUSTOM_ABILITY_SOULBINDER_DISTRIBUTOR = 7
CUSTOM_ABILITY_SOULBINDER_INTERACTOR = 8

ARTIFACT_SOULBINDER_L1 = 136
ARTIFACT_SOULBINDER_L2 = 137
ARTIFACT_SOULBINDER_L3 = 138
ARTIFACT_SOULBINDER_L4 = 139
ARTIFACT_SOULBINDER_L5 = 140

while not ARTIFACT_SOULBINDER_L5 do
    sleep()
end

soulbinder = {
    path = "/scripts/advmap/Artifacts/Soulbinder/",

    connected_heroes = {},

    exp_combined_for_levels = {
        [2] = 201007,
        [3] = 596047,
        [4] = 1769450,
        [5] = 3301383
    },

    current_exp_for_hero = {},

    Init = 
    function ()
        upgadeable_arts_common.presets[UPG_ARTIFACT_SOULBINDER] = {
            [ARTIFACT_SOULBINDER_L1] = 1,
            [ARTIFACT_SOULBINDER_L2] = 2,
            [ARTIFACT_SOULBINDER_L3] = 3,
            [ARTIFACT_SOULBINDER_L4] = 4,
            [ARTIFACT_SOULBINDER_L5] = 5
        }

        custom_ability_common.RegisterAbility(CUSTOM_ABILITY_SOULBINDER_MENU, 
        function (hero)
            if HasUpgradeableArtifact(hero, UPG_ARTIFACT_SOULBINDER) or soulbinder.connected_heroes[hero] then
                return CUSTOM_ABILITY_ENABLED
            end
            return CUSTOM_ABILITY_NOT_PRESENT
        end,
        function (hero)
            startThread(soulbinder.OpenMenu, hero)
        end)

        custom_ability_common.RegisterAbility(CUSTOM_ABILITY_SOULBINDER_CONNECTOR,
        function (hero)
            if HasUpgradeableArtifact(hero, UPG_ARTIFACT_SOULBINDER) and (not soulbinder.connected_heroes[hero]) then
                return CUSTOM_ABILITY_ENABLED
            end
            return CUSTOM_ABILITY_NOT_PRESENT
        end,
        function (hero)
            startThread(soulbinder.OpenConnectionSelectDialog, hero)
        end)
    end,

    OpenMenu = 
    function (hero)
        local player = GetObjectOwner(hero)
        if not soulbinder.connected_heroes[hero] then
            startThread(MCCS_MessageBoxForPlayers, player, soulbinder.path.."menu_no_bind.txt")
        else
            local connected_hero = soulbinder.connected_heroes[hero]
            local level = GetUpgradeableArtifactLevel(hero, UPG_ARTIFACT_SOULBINDER)
            if level == 0 then
                level = GetUpgradeableArtifactLevel(connected_hero, UPG_ARTIFACT_SOULBINDER)
            end
            local level_info = level == 5 and soulbinder.path.."max_level_reached.txt" or {
                soulbinder.path.."upgrade_info.txt";
                level = level,
                exp_to_next_level = soulbinder.exp_combined_for_levels[level + 1],
                current_exp = soulbinder.current_exp_for_hero[hero],
                exp_needed = soulbinder.exp_combined_for_levels[level + 1]
            }
            startThread(MCCS_MessageBoxForPlayers, player, {
                soulbinder.path.."menu.txt";
                hero = Hero.Params.Name(hero),
                connected_hero = Hero.Params.Name(connected_hero),
                level_info = level_info
            })
        end
    end,

    OpenConnectionSelectDialog = 
    function (hero)
        Dialog.NewDialog(soulbinder_connection_select_dialog, hero, GetObjectOwner(hero))
    end,

    ConnectHeroToHero = 
    ---@param hero string
    ---@param connected_hero string
    function (hero, connected_hero)
        soulbinder.connected_heroes[hero] = connected_hero
        soulbinder.connected_heroes[connected_hero] = hero
        soulbinder.current_exp_for_hero[hero] = 0
        soulbinder.current_exp_for_hero[connected_hero] = 0
    end
}

soulbinder_connection_select_dialog = {
    state = 1,
    path = soulbinder.path,
    icon = '/Textures/SpecialAbilities/Magic_Bond.(Texture).xdb#xpointer(/Texture)',
    title = 'bind_my_soul_title',
    select_text = '',

    perform_func =
    function(player, curr_state, answer, next_state)
        local return_state = 0
        if IsNum(next_state) then
            if next_state ~= -1 then
                return_state = next_state
            end
        else
            local hero = Dialog.GetActiveHeroForPlayer(player)
            startThread(soulbinder.ConnectHeroToHero, hero, next_state)
        end
        return return_state
    end,

    options = {},

    Reset =
    function(player)
        local dialog = Dialog.GetActiveDialogForPlayer(player)
        dialog.options[1] = {[0] = 'bind_my_soul_main.txt';}
        dialog.options[2] = {[0] = 'bind_my_soul_main.txt';}
    end,

    Open =
    function(player)
        Dialog.Reset(player)
        local active_hero = Dialog.GetActiveHeroForPlayer(player)
        local dialog = Dialog.GetActiveDialogForPlayer(player)
        local n, heroes, curr_state = 0, GetPlayerHeroes(GetObjectOwner(active_hero)), 1
        for _, hero in heroes do
            if hero and hero ~= active_hero and not soulbinder.connected_heroes[hero] then
                n = n + 1
                if n == 5 and heroes[n + 1] then
                    Dialog.SetAnswer(dialog, curr_state, n, "/Text/Default/next.txt", 2)
                    curr_state = curr_state + 1
                    n = 1
                else
                    Dialog.SetAnswer(dialog, curr_state, n, {dialog.path..'hero_to_bind.txt'; hero_name = Hero.Params.Name(hero)}, hero, 1, 1)
                end
            end
        end
        if n == 0 then
            Dialog.SetText(dialog, 1, dialog.path..'no_heroes_to_bind.txt')
            Dialog.SetAnswer(dialog, 1, 1, "/Text/Default/back.txt", -1)
        end
        Dialog.Action(player)
    end
}

startThread(soulbinder.Init)