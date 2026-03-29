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

---@class BloodRitualDefinition
---@field folder string
---@field blood_cost number
---@field level_needed number
---@field upgrade number
---@field desc_fn fun(path: string, context: IncarnationRitualsContext | any): string | table
---@field option_desc_fn fun(path: string, context: IncarnationRitualsContext | any): string | table
BloodRitualDefinition = {}

---@class IncarnationRitualsContext
---@field relative_path string
---@field creature_per_tier_amount number[]
---@field hero_level? number
---@field level_needed? number
---@field blood_amount? number

bloody_rituals_spec = {
    heroes = {"Noellie"},
    path = "/scripts/advmap/Specs/BloodyRituals/",
    
    current_blood_amount = 0,
    max_blood_amount = -1,

    base_blood_amount = 300,
    blood_per_level_amount = 20,

    ---@type table<BloodRitualType, BloodRitualDefinition>
    incarnation_rituals_data = {
        [LESSER_SABBATH_RITUAL] = {
            folder = "LesserSabbath",
            blood_cost = 140,
            level_needed = 1,
            upgrade = 0,
            ---@param context IncarnationRitualsContext
            desc_fn = function (path, context)
                local result = {path; t1_amount = context.creature_per_tier_amount[1], t2_amount = context.creature_per_tier_amount[2]}
                return result
            end,
            ---@param context IncarnationRitualsContext
            option_desc_fn = function (path, context)
                local blood = bloody_rituals_spec.current_blood_amount
                local color = (context.hero_level >= context.level_needed and blood >= context.blood_amount) and 
                    rtext("white", 1) or 
                    rtext("grey", 1)
                local result = {
                    path; 
                    -- option_color = color,
                    use_condition = (context.hero_level >= context.level_needed) and 
                        { context.relative_path.."blood_amount.txt"; amount = context.blood_amount} or
                        { context.relative_path.."level_needed.txt"; level = context.level_needed }
                }
                return result
            end
        },
        -- [ELEMENTAL_CONFLUX_RITUAL] = {
        --     blood_cost = 140,
        --     level_needed = 1,
        --     upgrade = 0
        -- },
        -- [BEAST_TAMING_RITUAL] = {
        --     blood_cost = 250,
        --     level_needed = 9,
        --     upgrade = 0
        -- },
        -- [SECRET_COVEN_RITUAL] = {
        --     blood_cost = 330,
        --     level_needed = 16,
        --     upgrade = 0
        -- },
        -- [DRAGON_CALLING_RITUAL] = {
        --     blood_cost = 500,
        --     level_needed = 25,
        --     upgrade = 0
        -- }
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

    OpenRitualsMenu = 
    function (hero)
        Dialog.NewDialog(bloody_rituals_menu_dialog, hero, PLAYER_1)
    end
}

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
            return -1
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

---@type DialogDefinition
incarnation_rituals_menu_dialog = {
    path = "/scripts/advmap/Specs/BloodyRituals/",
    icon = "",
    title = "summon_rituals",
    select_text = "",
    state = 1,
    effect = function (player, state, answer, next_state)
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
                [1] = 10,
                [2] = 5
            }
        }
        local rituals_data = { nil, nil, nil, nil, nil }
        local index = 1
        ---@param data BloodRitualDefinition
        for ritual, data in bloody_rituals_spec.incarnation_rituals_data do
            context.blood_amount = data.blood_cost
            context.level_needed = data.level_needed
            rituals_data[index] = data.desc_fn(bloody_rituals_spec.path..data.folder.."/text_upg"..data.upgrade..".txt", context)
            dialog.options[dialog.state][index] = {
                answer = data.option_desc_fn(bloody_rituals_spec.path..data.folder.."/name", context),
                is_enabled = 1,
                next_state = ritual,
                is_custom_path = 1
            }
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

startThread(bloody_rituals_spec.Init)