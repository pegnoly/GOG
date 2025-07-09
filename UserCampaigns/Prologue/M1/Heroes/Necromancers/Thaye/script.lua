CREATURE_INCORPOREAL_SKELETON = 2409
CREATURE_INCORPOREAL_SKELETON_ARCHER = 2410
CREATURE_INCORPOREAL_SKELETON_WARRIOR = 2411
CREATURE_INCORPOREAL_WALKING_DEAD = 2412
CREATURE_INCORPOREAL_ZOMBIE = 2413
CREATURE_INCORPOREAL_DISEASE_ZOMBIE = 2414
CREATURE_INCORPOREAL_VAMPIRE = 2415
CREATURE_INCORPOREAL_VAMPIRE_LORD = 2416
CREATURE_INCORPOREAL_NOSFERATU = 2417
CREATURE_INCORPOREAL_LICH = 2418
CREATURE_INCORPOREAL_ARCHLICH = 2419
CREATURE_INCORPOREAL_LICH_MASTER = 2420
CREATURE_INCORPOREAL_WIGHT = 2421
CREATURE_INCORPOREAL_WRAITH = 2422
CREATURE_INCORPOREAL_BANSHEE = 2423
CREATURE_INCORPOREAL_BONE_DRAGON = 2424
CREATURE_INCORPOREAL_SHADOW_DRAGON = 2425
CREATURE_INCORPOREAL_ASTRAL_DRAGON = 2426

thaye_spec = {

    army = {
        [1] = {
            first_variant = CREATURE_INCORPOREAL_SKELETON_WARRIOR,
            second_variant = CREATURE_INCORPOREAL_SKELETON_ARCHER,
            base = 154,
            diff_mult = 7
        },
        [2] = {
            first_variant = CREATURE_INCORPOREAL_ZOMBIE,
            second_variant = CREATURE_INCORPOREAL_DISEASE_ZOMBIE,
            base = 78,
            diff_mult = 8
        },
        [3] = {
            first_variant = CREATURE_GHOST,
            second_variant = CREATURE_POLTERGEIST,
            base = 42,
            diff_mult = 5
        },
        [4] = {
            first_variant = CREATURE_INCORPOREAL_VAMPIRE_LORD,
            second_variant = CREATURE_INCORPOREAL_NOSFERATU,
            base = 27,
            diff_mult = 4
        },
        [5] = {
            first_variant = CREATURE_INCORPOREAL_LICH,
            base = 12,
            diff_mult = 2
        },
        [6] = {
            first_variant = CREATURE_INCORPOREAL_WIGHT,
            base = 6,
            diff_mult = 1
        }
    },

    artifacts = {
        ARTIFACT_OGRE_SHIELD, ARTIFACT_RING_OF_LIFE, ARTIFACT_DRAGON_FLAME_TONGUE, ARTIFACT_STABILIZATION_AMULET, ARTIFACT_SUPRESSION_BAND
    },

    Setup = 
    function (hero)
        for i, creature_info in thaye_spec.army do
            local creature = creature_info.second_variant and 
                Random.FromSelection(creature_info.first_variant, creature_info.second_variant) or
                creature_info.first_variant
            local count = creature_info.base + (random(creature_info.diff_mult) + 1) * defaultDifficulty
            AddHeroCreatures(hero, creature, count)
        end
    end
}