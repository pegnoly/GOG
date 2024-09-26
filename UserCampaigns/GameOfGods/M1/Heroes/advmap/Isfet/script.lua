c2m1_isfet = {

    army_multipliers = {
        36 + 6 * initialDifficulty,
        25 + 5 * initialDifficulty,
        16 + 4 * initialDifficulty,
        8 + 3 * initialDifficulty,
        5 + 2 * initialDifficulty,
        3 + floor(initialDifficulty * 1.5),
        1 + initialDifficulty
    },

    required_arts_pool = {
        ARTIFACT_CRASHER
    },

    random_artifacts_pool = {
        -- [PRIMARY] = {
        --     ARTIFACT_STAFF_OF_VEXINGS, 
        --     ARTIFACT_CRASHER, 
        --     ARTIFACT_SWORD_OF_RUINS, 
        --     ARTIFACT_RUNIC_WAR_AXE, 
        --     ARTIFACT_GREAT_AXE_OF_GIANT_SLAYING,
        --     ARTIFACT_DWARVEN_SMITHY_HUMMER
        -- },
        [SECONDARY] = {
            ARTIFACT_ICEBERG_SHIELD,
            ARTIFACT_DRAGON_SCALE_SHIELD,
            ARTIFACT_MOONBLADE
        },
        [HEAD] = {
            ARTIFACT_DRAGON_TALON_CROWN,
            ARTIFACT_HELM_OF_CHAOS,
            ARTIFACT_CROWN_OF_COURAGE,
            ARTIFACT_CROWN_OF_LEADER,
            ARTIFACT_CROWN_OF_PRIMAL_ENERGY
        },
        [CHEST] = {
            ARTIFACT_DRAGON_SCALE_ARMOR,
            ARTIFACT_VALORIOUS_ARMOR,
            ARTIFACT_PLATE_MAIL_OF_STABILITY,
            ARTIFACT_BREASTPLATE_OF_PETRIFIED_WOOD,
            ARTIFACT_TENEGORN_SCALES_L6
        },
        [NECK] = {
            ARTIFACT_NECKLACE_OF_BRAVERY,
            ARTIFACT_NECKLACE_OF_POWER,
            ARTIFACT_WEREWOLF_CLAW_NECKLACE,
            ARTIFACT_CHRONOMETER
        },
        [FINGER] = {
            ARTIFACT_DRAGON_EYE_RING,
            ARTIFACT_RING_OF_CELERITY,
            ARTIFACT_RING_OF_HASTE,
            ARTIFACT_NIGHTMARISH_RING,
            ARTIFACT_SIGNET_OF_UNITY
        },
        [FEET] = {
            ARTIFACT_DRAGON_BONE_GRAVES,
            ARTIFACT_DWARVEN_MITHRAL_GREAVES,
            ARTIFACT_BOOTS_OF_SWIFTNESS,
            ARTIFACT_BOOTS_OF_SPEED,
            ARTIFACT_BOOTS_OF_INTERFERENCE,
            ARTIFACT_SANDALS_OF_THE_SAINT
        },
        [SHOULDERS] = {
            ARTIFACT_DRAGON_WING_MANTLE,
            ARTIFACT_LION_HIDE_CAPE,
            ARTIFACT_RIGID_MANTLE,
            ARTIFACT_CLOAK_OF_MOURNING
        },
        [MISCSLOT1] = {
            ARTIFACT_GOLDEN_HORSESHOE,
            ARTIFACT_FOUR_LEAF_CLOVER,
            ARTIFACT_TAROT_DECK
        },
        --[INVENTORY] = {}
    },

    artifacts_pool_weight = 80000 + 6000 * initialDifficulty,
    artifacts_pool_weight_grow = 2000 * defaultDifficulty,

    Init = 
    function ()
        AddHeroEvent.AddListener("C2M1_isfet_add_hero_listener",
            GetDifficulty() == DIFFICULTY_HEROIC and c2m1_isfet.AddHeroic or c2m1_isfet.AddDefault
        )
        RemoveHeroEvent.AddListener("C2M1_isfet_remove_hero_listener", c2m1_isfet.Remove)
        RespawnHeroEvent.AddListener("C2M1_isfet_respawn_hero_listener",
            GetDifficulty() == DIFFICULTY_HEROIC and c2m1_isfet.RespawnHeroic or c2m1_isfet.RespawnDefault
        )
        sleep(5)
        DeployReserveHero("C2M1_Isfet_Heroic", 17, 7)
    end,

    -- первое появление на сложностях, кроме героя
    AddDefault = 
    function (hero)
        if hero ~= "C2M1_Isfet" then
            return 
        end
        c2m1_demons.heroes_as_main_count[hero] = 1
        ChangeHeroStat(hero, STAT_ATTACK, 10 + initialDifficulty + random(3))
        ChangeHeroStat(hero, STAT_DEFENCE, 3 + initialDifficulty + random(2))
        ChangeHeroStat(hero, STAT_SPELL_POWER, 2 + initialDifficulty + random(2))
        ChangeHeroStat(hero, STAT_KNOWLEDGE, 9 + initialDifficulty + random(3))
        for i, machine in {WAR_MACHINE_BALLISTA, WAR_MACHINE_AMMO_CART, WAR_MACHINE_FIRST_AID_TENT} do
            pcall(GiveHeroWarMachine, hero, machine)
        end
        WarpHeroExp(hero, Levels[16 + initialDifficulty])
        startThread(c2m1_isfet.Setup, hero)
    end,

    -- первое появление на сложности герой
    AddHeroic = 
    function (hero)
        if hero ~= "C2M1_Isfet_Heroic" then
            return 
        end
        consoleCmd("game_writelog 1")
        sleep(20)
        c2m1_demons.heroes_as_main_count[hero] = 1
        ChangeHeroStat(hero, STAT_ATTACK, 16 + random(4))
        ChangeHeroStat(hero, STAT_DEFENCE, 7 + random(3))
        ChangeHeroStat(hero, STAT_SPELL_POWER, 6 + random(4))
        ChangeHeroStat(hero, STAT_KNOWLEDGE, 13 + random(6))
        for i, machine in {WAR_MACHINE_BALLISTA, WAR_MACHINE_AMMO_CART, WAR_MACHINE_FIRST_AID_TENT} do
            pcall(GiveHeroWarMachine, hero, machine)
        end
        WarpHeroExp(hero, Levels[23])
        startThread(c2m1_isfet.Setup, hero)
    end,

    Remove = 
    function (hero)
        -- здесь должен обновляться стейт 
    end,

    RespawnDefault = 
    function (hero)
        c2m1_demons.heroes_as_main_count[hero] = c2m1_demons.heroes_as_main_count[hero] + 1
        for i, machine in {WAR_MACHINE_BALLISTA, WAR_MACHINE_AMMO_CART, WAR_MACHINE_FIRST_AID_TENT} do
            pcall(GiveHeroWarMachine, hero, machine)
        end
    end,

    RespawnHeroic = 
    function (hero)
        c2m1_demons.heroes_as_main_count[hero] = c2m1_demons.heroes_as_main_count[hero] + 1
    end,

    Setup = 
    function (hero)
        c2m1_isfet.artifacts_pool_weight = c2m1_isfet.artifacts_pool_weight + c2m1_isfet.artifacts_pool_weight_grow
        startThread(
            ai_art_distribution.BuildArtifactsSet, 
            hero, 
            c2m1_isfet.artifacts_pool_weight, 
            c2m1_isfet.required_arts_pool,
            c2m1_isfet.random_artifacts_pool
        )
        startThread(c2m1_isfet.ArmySetup, hero)
    end,

    ArmySetup = 
    function (hero)
        local object = GetHeroTown(hero) or hero
        local week = ceil(GetDate(DAY) / 7)
        local times_as_main = c2m1_demons.heroes_as_main_count[hero]
        local default_creature_removed
        for tier = 1, 7 do
            local tier_creature = c2m1_isfet.GetAdjustedTierCreature(tier)
            local count = ceil((week + times_as_main)  * c2m1_isfet.army_multipliers[tier])
            AddObjectCreatures(object, tier_creature, count)
            if not default_creature_removed then
                while GetObjectCreatures(object, tier_creature) ~= count do
                    sleep()
                end
                RemoveObjectCreatures(object, CREATURE_PIXIE, 99999)
                while GetObjectCreatures(object, CREATURE_PIXIE) ~= 0 do
                    sleep()
                end
                default_creature_removed = 1
            end
        end
    end,

    -- выбираются грейды с максимальной суммарной скоростью и инициативой.
    GetAdjustedTierCreature =
    function (tier)
        local tier_creatures = TIER_TABLES[TOWN_INFERNO][tier]
        local non_grade_creature = table.min(tier_creatures, 
        function (creature)
            if creature >= 2000 then
                return math.huge
            end
            local res = Creature.Params.Power(creature)
            return res
        end)
        --print("non_grade_creature: ", non_grade_creature)
        tier_creatures[non_grade_creature.key] = nil
        local result = table.max(tier_creatures, 
        function (creature)
            if creature >= 2000 then
                return -1
            end
            --print("creature: ", creature)
            local res = Creature.Params.Initiative(creature) + Creature.Params.Speed(creature)
            --print("sum: ", res)
            return res
        end)
        --print("result: ", result)
        return result.value
    end
}