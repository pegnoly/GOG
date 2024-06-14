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
        sleep(5)
        DeployReserveHero("C2M1_Isfet_Heroic", 17, 7)
    end,

    AddDefault = 
    function (hero)
        if hero == "C2M1_Isfet" then
            c2m1_demons.heroes_as_main_count[hero] = 1
        end
        WarpHeroExp(hero, Levels[20])
        startThread(c2m1_isfet.SetupDefault)
    end,

    AddHeroic = 
    function (hero)
        if hero == "C2M1_Isfet_Heroic" then
            c2m1_demons.heroes_as_main_count[hero] = 1
        end
        ChangeHeroStat(hero, STAT_ATTACK, 16 + random(4))
        ChangeHeroStat(hero, STAT_DEFENCE, 6 + random(3))
        ChangeHeroStat(hero, STAT_SPELL_POWER, 4 + random(4))
        ChangeHeroStat(hero, STAT_KNOWLEDGE, 14 + random(6))
        for i, machine in {WAR_MACHINE_BALLISTA, WAR_MACHINE_AMMO_CART, WAR_MACHINE_FIRST_AID_TENT} do
            pcall(GiveHeroWarMachine, hero, machine)
        end
        WarpHeroExp(hero, Levels[23])
        startThread(c2m1_isfet.SetupHeroic, hero)
    end,

    SetupHeroic = 
    function (hero)
        local object = GetHeroTown(hero) or hero
        local week = ceil(GetDate(DAY) / 7)
        local times_as_main = c2m1_demons.heroes_as_main_count[hero]
        for tier = 1, 7 do
            local tier_creature = c2m1_isfet.GetAdjustedTierCreature(tier)
            local count = ceil((week + times_as_main)  * c2m1_isfet.army_multipliers[tier])
            AddObjectCreatures(object, tier_creature, count)
        end
        --
        c2m1_isfet.artifacts_pool_weight = c2m1_isfet.artifacts_pool_weight + c2m1_isfet.artifacts_pool_weight_grow
        startThread(
            ai_art_distribution.BuildArtifactsSet, 
            hero, 
            c2m1_isfet.artifacts_pool_weight, 
            c2m1_isfet.required_arts_pool,
            c2m1_isfet.random_artifacts_pool
        )
    end,

    -- выбираются грейды с максимальной суммарной скоростью и инициативой.
    GetAdjustedTierCreature =
    function (tier)
        local result = table.max(TIER_TABLES[TOWN_INFERNO][tier], 
        function (creature)
            local res = Creature.Params.Initiative(creature) + Creature.Params.Speed(creature)
            return res
        end)
        return result
    end
}