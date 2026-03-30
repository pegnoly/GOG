while GetGameVar("CURRENT_MISSION") == "" do
    sleep()
end

local current_mission = GetGameVar("CURRENT_MISSION")
if current_mission == "C1M1" or current_mission == "C1M2" then
    return
end

while not custom_ability_common do
    sleep()
end

--#region types

CUSTOM_ABILITY_BLOOD_RITUALS = 9

---@alias BloodRitualType
---|`LESSER_SABBATH_RITUAL`
---|`ELEMENTAL_CONFLUX_RITUAL`
---|`BEAST_TAMING_RITUAL`
---|`SECRET_COVEN_RITUAL`
---|`DRAGON_CALLING_RITUAL`
LESSER_SABBATH_RITUAL = 1
ELEMENTAL_CONFLUX_RITUAL = 2
BEAST_TAMING_RITUAL = 3
SECRET_COVEN_RITUAL = 4
DRAGON_CALLING_RITUAL = 5

---@alias BloodRitualUpgradeType
---|`LESSER_COVEN_GRADED_CREATURES`
LESSER_SABBATH_GRADED_CREATURES = 1
BEAST_TAMING_GRADED_CREATURES = 2
SECRET_COVEN_GRADED_CREATURES = 3
DRAGON_CALLING_GRADED_CREATURES = 4

---@class BloodRitualDefinition
---@field folder string
---@field blood_cost number
---@field level_needed number
---@field possible_upgrades? BloodRitualUpgradeType[] 
---@field active_upgrades? BloodRitualUpgradeType[]
---@field upgrade_level? number
---@field text_variant number
---@field desc_fn fun(path: string, context: IncarnationRitualsContext | any): string | table
---@field option_desc_fn fun(path: string, context: IncarnationRitualsContext | any): string | table
BloodRitualDefinition = {}

---@class IncarnationRitualsContext
---@field relative_path string
---@field creature_per_tier_amount number[]
---@field elementals_amount number
---@field active_upgrades? BloodRitualUpgradeType[]
---@field hero_level? number
---@field level_needed? number
---@field blood_amount? number

--#endregion

--#region data

bloody_rituals_spec = {
    heroes = {"Noellie"},
    path = "/scripts/advmap/Specs/BloodyRituals/",
    
    current_blood_amount = 200,
    max_blood_amount = -1,

    base_blood_amount = 300,
    blood_per_level_amount = 20,

    ---@type table<BloodRitualType, BloodRitualDefinition>
    incarnation_rituals_data = {
        [LESSER_SABBATH_RITUAL] = {
            folder = "LesserSabbath",
            blood_cost = 140,
            level_needed = 1,
            possible_upgrades = { LESSER_SABBATH_GRADED_CREATURES },
            active_upgrades = {},
            text_variant = 0,
            ---@param context IncarnationRitualsContext
            desc_fn = function (path, context)
                local result = {path; t1_amount = context.creature_per_tier_amount[1], t2_amount = context.creature_per_tier_amount[2]}
                return result
            end,
            option_desc_fn = function (path, context)
                local result = bloody_rituals_spec.CommonRitualOptionDescConstructor(path, context)
                return result
            end
        },
        [ELEMENTAL_CONFLUX_RITUAL] = {
            folder = "ElementalUnity",
            blood_cost = 140,
            level_needed = 1,
            possible_upgrades = {},
            active_upgrades = {},
            text_variant = 0,
            ---@param context IncarnationRitualsContext
            desc_fn = function (path, context)
                local result = {path; amount = context.elementals_amount}
                return result
            end,
            option_desc_fn = function (path, context)
                local result = bloody_rituals_spec.CommonRitualOptionDescConstructor(path, context)
                return result
            end
        },
        [BEAST_TAMING_RITUAL] = {
            folder = "BeastTaming",
            blood_cost = 250,
            level_needed = 9,
            possible_upgrades = {},
            active_upgrades = {},
            text_variant = 0,      
            ---@param context IncarnationRitualsContext
            desc_fn = function (path, context)
                local result = {path; t3_amount = context.creature_per_tier_amount[3], t5_amount = context.creature_per_tier_amount[5]}
                return result
            end,
            option_desc_fn = function (path, context)
                local result = bloody_rituals_spec.CommonRitualOptionDescConstructor(path, context)
                return result
            end
        },
        [SECRET_COVEN_RITUAL] = {
            folder = "SecretCoven",
            blood_cost = 330,
            level_needed = 16,
            possible_upgrades = {},
            active_upgrades = {},
            text_variant = 0,
            ---@param context IncarnationRitualsContext
            desc_fn = function (path, context)
                local result = {path; t4_amount = context.creature_per_tier_amount[4], t6_amount = context.creature_per_tier_amount[6]}
                return result
            end,
            option_desc_fn = function (path, context)
                local result = bloody_rituals_spec.CommonRitualOptionDescConstructor(path, context)
                return result
            end
        },
        [DRAGON_CALLING_RITUAL] = {
            folder = "DragonCalling",
            blood_cost = 500,
            level_needed = 25,
            possible_upgrades = {},
            active_upgrades = {},
            text_variant = 0,
            ---@param context IncarnationRitualsContext
            desc_fn = function (path, context)
                local result = {path; t7_amount = context.creature_per_tier_amount[7]}
                return result
            end,
            option_desc_fn = function (path, context)
                local result = bloody_rituals_spec.CommonRitualOptionDescConstructor(path, context)
                return result
            end
        }
    },

    ---@type table<BloodRitualType, fun(hero: string, context: IncarnationRitualsContext)>
    incarnation_rituals_activator = {
        [LESSER_SABBATH_RITUAL] = function (hero, context)
            FX.Play('Summon_balor', hero)
            bloody_rituals_spec.current_blood_amount = bloody_rituals_spec.current_blood_amount - context.blood_amount
            sleep(30)
            if not contains(context.active_upgrades, LESSER_SABBATH_GRADED_CREATURES) then
                Hero.CreatureInfo.Add(hero, CREATURE_SCOUT, context.creature_per_tier_amount[1], CREATURE_WITCH, context.creature_per_tier_amount[2])
            else
                for tier = 1, 2 do
                    local base_creature = Hero.CreatureInfo.MaxUpgradedWithReturning(hero, TOWN_DUNGEON, tier) 
                    Hero.CreatureInfo.Add(hero, base_creature, context.creature_per_tier_amount[tier])
                end
            end
        end,

        [ELEMENTAL_CONFLUX_RITUAL] = function (hero, context)
            FX.Play('Summon_balor', hero)
            bloody_rituals_spec.current_blood_amount = bloody_rituals_spec.current_blood_amount - context.blood_amount
            sleep(30)
            local elem_type = Random.FromSelection(CREATURE_WATER_ELEMENTAL, CREATURE_EARTH_ELEMENTAL, CREATURE_AIR_ELEMENTAL, CREATURE_FIRE_ELEMENTAL)
            Hero.CreatureInfo.Add(hero, elem_type, context.elementals_amount)
        end,

        [BEAST_TAMING_RITUAL] = function (hero, context)
            FX.Play('Summon_balor', hero)
            bloody_rituals_spec.current_blood_amount = bloody_rituals_spec.current_blood_amount - context.blood_amount
            sleep(30)
            if not contains(context.active_upgrades, BEAST_TAMING_GRADED_CREATURES) then
                Hero.CreatureInfo.Add(hero, CREATURE_MINOTAUR, context.creature_per_tier_amount[3], CREATURE_HYDRA, context.creature_per_tier_amount[5])
            else
                for _, tier in { 3, 5 } do
                    local base_creature = Hero.CreatureInfo.MaxUpgradedWithReturning(hero, TOWN_DUNGEON, tier) 
                    Hero.CreatureInfo.Add(hero, base_creature, context.creature_per_tier_amount[tier])
                end
            end
        end,

        [SECRET_COVEN_RITUAL] = function (hero, context)
            FX.Play('Summon_balor', hero)
            bloody_rituals_spec.current_blood_amount = bloody_rituals_spec.current_blood_amount - context.blood_amount
            sleep(30)
            if not contains(context.active_upgrades, SECRET_COVEN_GRADED_CREATURES)then
                Hero.CreatureInfo.Add(hero, CREATURE_RIDER, context.creature_per_tier_amount[4], CREATURE_MATRON, context.creature_per_tier_amount[6])
            else
                for _, tier in { 4, 6 } do
                    local base_creature = Hero.CreatureInfo.MaxUpgradedWithReturning(hero, TOWN_DUNGEON, tier) 
                    Hero.CreatureInfo.Add(hero, base_creature, context.creature_per_tier_amount[tier])
                end
            end
        end,

        [DRAGON_CALLING_RITUAL] = function (hero, context)
            FX.Play('Summon_balor', hero)
            bloody_rituals_spec.current_blood_amount = bloody_rituals_spec.current_blood_amount - context.blood_amount
            sleep(30)
            if not contains(context.active_upgrades, DRAGON_CALLING_GRADED_CREATURES) then
                Hero.CreatureInfo.Add(hero, CREATURE_SHADOW_DRAGON, context.creature_per_tier_amount[7])
            else
                local base_creature = Hero.CreatureInfo.MaxUpgradedWithReturning(hero, TOWN_DUNGEON, 7) 
                Hero.CreatureInfo.Add(hero, base_creature, context.creature_per_tier_amount[7])
            end
        end
    },

    Init = 
    function ()
        for _, hero in bloody_rituals_spec.heroes do
            custom_ability_common.RegisterUniqueAbilityForHero(
                CUSTOM_ABILITY_BLOOD_RITUALS, 
                function (_)
                    return 1
                end,
                bloody_rituals_spec.OpenRitualsMenu,
                hero
            )
            startThread(custom_ability_common.UniqueAbilityUpdateThread, CUSTOM_ABILITY_BLOOD_RITUALS, hero)
        end
    end,

    CommonRitualOptionDescConstructor = 
    ---@param path string
    ---@param context IncarnationRitualsContext | any
    ---@return table
    function (path, context)
        local blood = bloody_rituals_spec.current_blood_amount
        local is_enabled = (context.hero_level >= context.level_needed and blood >= context.blood_amount) and 1 or nil
        local color = is_enabled and 
            '"/Text/Default/Colors/white.txt"' or 
            '"/Text/Default/Colors/grey.txt"'
        local result = {
            path; 
            option_color = color,
            use_condition = (context.hero_level >= context.level_needed) and 
                { context.relative_path.."blood_amount.txt"; amount = context.blood_amount, option_color = color} or
                { context.relative_path.."level_needed.txt"; level = context.level_needed },
            disable_reason = is_enabled and '"blank.txt"' or 
                (context.hero_level < context.level_needed and 
                    "'"..context.relative_path.."level_too_low.txt".."'" or "'"..context.relative_path.."not_enough_blood.txt".."'")
        }
        return result
    end,

    OpenRitualsMenu = 
    function (hero)
        Dialog.NewDialog(bloody_rituals_menu_dialog, hero, PLAYER_1)
    end
}
--#endregion

--#region menu_dialog
---@type DialogDefinition
bloody_rituals_menu_dialog = {
    path = "/scripts/advmap/Specs/BloodyRituals/",
    icon = "/UI/TownScreen/DundeonSpecialNormal.(Texture).xdb#xpointer(/Texture)",
    title = "menu_title",
    select_text = "",
    state = 1,
    effect = function (player, _, _, next_state)
        if next_state == 0 then
            return 0
        end
        local hero = Dialog.GetActiveHeroForPlayer(player)
        if next_state == 1 then
            Dialog.NewDialog(incarnation_rituals_menu_dialog, hero, player)
            return 0
        end
        return next_state
    end,

    options = {
        {
            [0] = "";
            {
                answer = "summon_rituals",
                is_enabled = 1,
                next_state = 1
            },
            {
                answer = "upgrade_rituals",
                is_enabled = 1,
                next_state = 2
            },
            {
                answer = "empower_rituals",
                is_enabled = 1,
                next_state = 3
            }
        }
    },

    Open = function (player)
        Dialog.Reset(player)
    end,

    Reset = function (player)
        local dialog = Dialog.GetActiveDialogForPlayer(player)
        dialog.options[1][0] = {
            bloody_rituals_menu_dialog.path.."menu_text.txt"; 
            current_blood = bloody_rituals_spec.current_blood_amount,
            max_blood = bloody_rituals_spec.max_blood_amount
        }
        Dialog.Action(player)
    end
}
--#endregion

--#region incarnation_rituals_dialog
---@type DialogDefinition
incarnation_rituals_menu_dialog = {
    path = "/scripts/advmap/Specs/BloodyRituals/",
    icon = "",
    title = "summon_rituals",
    select_text = "",
    state = 1,
    effect = function (player, _state, _answer, next_state)
        if IsNum(next_state) then
            return next_state
        end
        ---@type { ritual_type: BloodRitualType, context: IncarnationRitualsContext }
        local data = next_state
        data.context.blood_amount = bloody_rituals_spec.incarnation_rituals_data[data.ritual_type].blood_cost
        data.context.active_upgrades = bloody_rituals_spec.incarnation_rituals_data[data.ritual_type].active_upgrades
        startThread(bloody_rituals_spec.incarnation_rituals_activator[data.ritual_type], Dialog.GetActiveHeroForPlayer(player), data.context)
        return 0
    end,

    options = {},

    Open = function (player)
        Dialog.Reset(player)
    end,

    Reset = function (player)
        local dialog = Dialog.GetActiveDialogForPlayer(player)
        dialog.options = {}
        dialog.options[dialog.state] = {}
        ---@type IncarnationRitualsContext
        local context = {
            relative_path = bloody_rituals_spec.path,
            hero_level = GetHeroLevel(Dialog.GetActiveHeroForPlayer(player)),
            creature_per_tier_amount = {
                [1] = 8,
                [2] = 6,
                [3] = 5,
                [4] = 4,
                [5] = 3,
                [6] = 2,
                [7] = 1
            },
            elementals_amount = 5
        }
        local rituals_data = { nil, nil, nil, nil, nil }
        local index = 1
        ---@param data BloodRitualDefinition
        for ritual, data in bloody_rituals_spec.incarnation_rituals_data do
            context.blood_amount = data.blood_cost
            context.level_needed = data.level_needed
            context.active_upgrades = data.active_upgrades
            rituals_data[index] = data.desc_fn(bloody_rituals_spec.path..data.folder.."/text_upg"..data.text_variant..".txt", context)
            dialog.options[dialog.state][index] = {
                answer = data.option_desc_fn(bloody_rituals_spec.path..data.folder.."/name", context),
                is_enabled = 1,
                next_state = { ritual_type = ritual, context = context },
                is_custom_path = 1
            }
            index = index + 1
        end
        dialog.options[dialog.state][0] = {
            bloody_rituals_spec.path.."rituals_list_text.txt";
            ritual_data1 = rituals_data[1],
            ritual_data2 = rituals_data[2],
            ritual_data3 = rituals_data[3],
            ritual_data4 = rituals_data[4],
            ritual_data5 = rituals_data[5]
        }
        Dialog.Action(player)
    end
}
--#endregion

startThread(bloody_rituals_spec.Init)