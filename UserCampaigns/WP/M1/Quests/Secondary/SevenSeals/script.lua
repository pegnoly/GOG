-- @quest
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Квест: За семью печатями.
-- Тип квеста: Второстепенный.

    --*КОНСТАНТЫ*--
    
-- возможные типы ловушек в коридоре Элементов
SEVEN_SEALS_ELEM_TRAP_TYPE_WIND = 1
SEVEN_SEALS_ELEM_TRAP_TYPE_EARTH = 2
SEVEN_SEALS_ELEM_TRAP_TYPE_WATER = 3
SEVEN_SEALS_ELEM_TRAP_TYPE_FIRE = 4

-- id Колбы с кровью рохи
ARTIFACT_CURSED_ROCK_BLOOD_FIAL = 401
-- константа кастомабилки использования крови рохи
MCCS_CUSTOM_ABILITY__USE_CURSED_ROCK_BLOOD = "GOG_M1_CA_USE_ROCK_BLOOD"

seven_seals =
{
        --*ПЕРЕМЕННЫЕ*--
    
    -- техническая информация --
    name = "SEVEN_SEALS",
    path = 
    {
        text = q_path.."Secondary/SevenSeals/Texts/",
        dialog = q_path.."Secondary/SevenSeals/Dialogs/"
    },
    dialogs = 
    {
        StartDialog = "GOG_M1_Q_SEVEN_SEALS_START_DIALOG",
        TavernTempDialog = "GOG_M1_Q_SEVEN_SEALS_TAVERN_TEMP_DIALOG",
        TerhizSealDialog = "GOG_M1_Q_SEVEN_SEALS_TERHIZ_SEAL_DIALOG",
        SealBrokenDialog = "GOG_M1_Q_SEVEN_SEALS_SEAL_BROKEN_DIALOG",
        TavernFinishDialog = "GOG_M1_Q_SEVEN_SEALS_TAVERN_FINISH_DIALOG"
    },

    -- флаг активности ловушек в коридоре Элементов
    elem_trap_active = 0,

    -- информация об артефактах, которые дают полный резист к соотв. ловушкам
    elem_trap_resist_artifacts =
    {
        [SEVEN_SEALS_ELEM_TRAP_TYPE_WIND] = 
        {
            art = ARTIFACT_RING_OF_LIGHTING_PROTECTION,
            msg = "wind_protection_worked.txt"
        },
        [SEVEN_SEALS_ELEM_TRAP_TYPE_EARTH] = 
        {
            art = ARTIFACT_RIGID_MANTLE,
            msg = "earth_protection_worked.txt"
        },
        [SEVEN_SEALS_ELEM_TRAP_TYPE_WATER] =
        {
            art = ARTIFACT_DRAGON_FLAME_TONGUE,
            msg = "water_protection_worked.txt"
        },
        [SEVEN_SEALS_ELEM_TRAP_TYPE_FIRE] =
        {
            art = ARTIFACT_ICEBERG_SHIELD,
            msg = "fire_protection_worked.txt"
        }
    },

    -- информация о способностях существ и резистах, которые они дают к соотв. ловушкам
    elem_trap_resist_abilities_multipliers = 
    {
        [SEVEN_SEALS_ELEM_TRAP_TYPE_WIND] = 
        {
            [ABILITY_IMMUNITY_TO_MAGIC] = 1,
            [ABILITY_IMMUNITY_TO_AIR] = 1,
            [ABILITY_ENCHANTED_OBSIDIAN] = 1,
            [ABILITY_MAGIC_PROOF_75] = 0.75,
            [ABILITY_MAGIC_PROOF_50] = 0.5
        },
        [SEVEN_SEALS_ELEM_TRAP_TYPE_EARTH] =
        {
            [ABILITY_IMMUNITY_TO_MAGIC] = 1,
            [ABILITY_IMMUNITY_TO_EARTH] = 1,
            [ABILITY_ENCHANTED_OBSIDIAN] = 1,
            [ABILITY_MAGIC_PROOF_75] = 0.75,
            [ABILITY_MAGIC_PROOF_50] = 0.5
        },
        [SEVEN_SEALS_ELEM_TRAP_TYPE_WATER] =
        {
            [ABILITY_IMMUNITY_TO_MAGIC] = 1,
            [ABILITY_IMMUNITY_TO_WATER] = 1,
            [ABILITY_ENCHANTED_OBSIDIAN] = 1,
            [ABILITY_MAGIC_PROOF_75] = 0.75,
            [ABILITY_MAGIC_PROOF_50] = 0.5
        },
        [SEVEN_SEALS_ELEM_TRAP_TYPE_FIRE] =
        {
            [ABILITY_IMMUNITY_TO_MAGIC] = 1,
            [ABILITY_IMMUNITY_TO_FIRE] = 1,
            [ABILITY_ENCHANTED_OBSIDIAN] = 1,
            [ABILITY_MAGIC_PROOF_75] = 0.75,
            [ABILITY_MAGIC_PROOF_50] = 0.5,
            [ABILITY_FIRE_PROOF_50] = 0.5
        }
    },

    -- число боев, после которых пропадет эффект крови рохи
    rock_blood_effect_linger_fight_count = initialDifficulty == DIFFICULTY_HEROIC and 3 or 5,

    -- таблица активности эффекта крови рохи для героев
    rock_blood_effected_on_hero = {},

        --*ФУНКЦИИ*--
    
    -- загрузка квеста
    Init =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.Init")
        end)
        -- таверна
        Touch.DisableObject("temple_tavern")
        Touch.SetFunction("temple_tavern", "_talk", seven_seals.TavernTalk)
        Quest.SetObjectQuestmark("temple_tavern", QUESTMARK_OBJ_NEW, 7)
        -- кровавый храм
        Touch.DisableObject("blood_temple_01")
        Touch.SetFunction("blood_temple_01", "_fight", seven_seals.BloodTempleFight)
        -- коридор Элементов
        for i, region in {"wind_trap", "earth_trap", "water_trap", "fire_trap"} do
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, "seven_seals.EmitterEnter")
        end
        startThread(seven_seals.ElemTrapThread)
        FX.Play('Elem_seal', 'sealed_tomb', 'tomb_seal_01', 5.5, -7.5, 0, 0)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "elem_trap_05", "seven_seals.SealReached")
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, "rock_fight_region", "seven_seals.RockFight")
        -- использование крови рохи
        startThread(seven_seals.RockBloodVialUseInit)
        CombatResultsEvent.AddListener("GOG_M1_Q_SevenSeals.CursedRockEffectCheck", seven_seals.RockBloodEffectLingerCheckEvent)
        print("<color=green>M1_Q_SevenSeals.Init successfull")
    end,

    -- старт квеста
    Start =
    function(hero)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.Start")
        end)
        MiniDialog.Start(seven_seals.path.dialog.."StartDialog/", PLAYER_1, seven_seals.dialogs.StartDialog, (IsActive(ghost_hope.name) and 1 or nil))
        Quest.Start(seven_seals.name, hero)
        if not HasArtefact(hero, ARTIFACT_RING_OF_LIGHTING_PROTECTION) then
            Art.Distribution.Give(hero, ARTIFACT_RING_OF_LIGHTING_PROTECTION, 1)
        end
        OpenRegionFog(PLAYER_1, "elem_trap_01") 
        Quest.SetObjectQuestmark("temple_tavern", QUESTMARK_OBJ_IN_PROGRESS, 7)
        Quest.SetObjectQuestmark("blood_temple_01", QUESTMARK_OBJ_NEW_PROGRESS, 9)
    end,

    -- завершение квеста
    Finish =
    function(hero)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.Finish")
        end)
        Quest.ResetObjectQuestmark("temple_tavern")
        MiniDialog.Start(seven_seals.path.dialog.."TavernFinishDialog/", PLAYER_1, seven_seals.dialogs.TavernFinishDialog)
        Quest.Finish(seven_seals.name, hero)
        GiveBorderguardKey(PLAYER_1, KEY_PURPLE)
        RemoveArtefact(hero, ARTIFACT_CURSED_ROCK_BLOOD_FIAL)
        Touch.OverrideFunction("temple_tavern", "_talk",
        function(hero, object)
            MessageBox(seven_seals.path.text.."tavern_empty.txt")
        end)
    end,

    -- логика разговоров в таверне.
    -- 1)Квест не начат - начать
    -- 2)Квест завершен - сообщение, что таверна пуста
    -- 3)Квест в процессе:
    --  a)прогресс 0 - вывести промежуточный диалог
    --  b)прогресс 1 - завершить квест
    TavernTalk =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.TavernTalk")
        end)
        -- 1.
        if Quest.IsUnknown(seven_seals.name) then
            seven_seals.Start(hero)
        -- 2.
        elseif IsCompleted(seven_seals.name) then
            MessageBox(seven_seals.path.text.."tavern_empty.txt")
        else
            local progress = Quest.GetProgress(seven_seals.name)
            -- 3a.
            if progress == 0 then
                MiniDialog.Start(seven_seals.path.dialog.."TavernTempDialog/", PLAYER_1, seven_seals.dialogs.TavernTempDialog)
            -- 3b.
            elseif progress == 1 then
                seven_seals.Finish(hero)
            end
        end
    end,

    -- бой в кровавом храме
    BloodTempleFight =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.BloodTempleFight")
        end)
        local stacks_info = 
        {
            Random.FromTable_IgnoreValue(TIER_TABLES[TOWN_DUNGEON][2][1], TIER_TABLES[TOWN_DUNGEON][2]), 26 + random(5),
            Random.FromTable_IgnoreValue(TIER_TABLES[TOWN_DUNGEON][2][1], TIER_TABLES[TOWN_DUNGEON][2]), 30 + random(5),
            Random.FromTable_IgnoreValue(TIER_TABLES[TOWN_DUNGEON][3][1], TIER_TABLES[TOWN_DUNGEON][3]), 21 + random(5),
            Random.FromTable_IgnoreValue(TIER_TABLES[TOWN_DUNGEON][6]), 6 + random(3),
            Random.FromTable_IgnoreValue(TIER_TABLES[TOWN_DUNGEON][6][1], TIER_TABLES[TOWN_DUNGEON][6]), 5 + random(2)    
        }
        if MCCS_QuestionBox(seven_seals.path.text.."blood_temple_guarded.txt") and
           MCCS_StartCombat(hero, nil, 5, stacks_info) then
            Art.Distribution.Give(hero, ARTIFACT_ICEBERG_SHIELD)
            Art.Distribution.Give(hero, ARTIFACT_RING_OF_LIFE)
            MarkObjectAsVisited(object, hero)
            Quest.ResetObjectQuestmark(object)
            Touch.OverrideFunction(object, "_fight",
            function(hero, object)
                ShowFlyingSign(seven_seals.path.text.."blood_temple_empty.txt", object, PLAYER_1, 7.0)
            end)
        end
    end,

    -- проверяет необходимость активации эффектов в коридоре Элементов
    CheckElemTrapActive =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.CheckElemTrapActive")
        end)
        local answer
        for i, region in {'elem_trap_01', 'elem_trap_02', 'elem_trap_03', 'elem_trap_04',
                          'elem_trap_05', 'wind_trap', 'earth_trap', 'water_trap', 'fire_trap'}  do
            if length(GetObjectsInRegion(region, 'HERO')) > 0 then
                answer = 1
                return answer
            end
        end
        return answer
    end,

    -- эффекты воздушной ловушки
    WindTrapThread =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.WindTrapThread")
        end)
        while seven_seals.elem_trap_active == 1 do
            for i, emitter in {'wind_01', 'wind_02', 'wind_03'} do
                AdvMap.FX.Play('Lightning_bolt', emitter)
                sleep(4)
            end
            sleep()
        end
    end,
    
    -- эффекты ловушки земли
    EarthTrapThread =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.EarthTrapThread")
        end)
        while seven_seals.elem_trap_active == 1 do
            for i, emitter in {'earth_01', 'earth_02', 'earth_03'} do
                AdvMap.FX.Play('StoneSpikes', emitter)
                sleep(5)
            end
            sleep()
        end
    end,
    
    -- эффекты водной ловушки
    WaterTrapThread =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.WaterTrapThread")
        end)
        while seven_seals.elem_trap_active == 1 do
            for i, emitter in {'water_01', 'water_02', 'water_03'} do
                AdvMap.FX.Play('Ice_bolt', emitter)
                sleep(5)
            end
            sleep()
        end
    end,
    
    -- эффекты огненной ловушки
    FireTrapThread =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.FireTrapThread")
        end)
        while seven_seals.elem_trap_active == 1 do
            AdvMap.FX.Play('Firewall', 'fire_02', 'fire_02_fx')
            sleep(10)
            AdvMap.FX.Play('Firewall_end', 'fire_02')
            StopVisualEffects('fire_02_fx')
            sleep()
        end
    end,

    -- основной поток анимаций коридора Элементов
    ElemTrapThread =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.ElemTrapThread")
        end)
        while 1 do
            if (seven_seals.elem_trap_active == 0) and seven_seals.CheckElemTrapActive() then
                seven_seals.elem_trap_active = 1
                startThread(seven_seals.WindTrapThread)
                startThread(seven_seals.EarthTrapThread)
                startThread(seven_seals.WaterTrapThread)
                startThread(seven_seals.FireTrapThread)
            elseif (not seven_seals.CheckElemTrapActive()) then
                seven_seals.elem_trap_active = 0
            end
            sleep()
        end
    end,

    -- срабатывание ловушек в коридоре Элементов(смерть существ, не имеющих иммунитета к соотв. стихии)
    EmitterEnter = 
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.EmitterEnter")
        end)
        if region == 'wind_trap' then
            seven_seals.TrapActivated(hero, SEVEN_SEALS_ELEM_TRAP_TYPE_WIND)
            return
        end
        if region == 'earth_trap' then
            seven_seals.TrapActivated(hero, SEVEN_SEALS_ELEM_TRAP_TYPE_EARTH)
            return
        end
        if region == 'water_trap' then
            seven_seals.TrapActivated(hero, SEVEN_SEALS_ELEM_TRAP_TYPE_WATER)
            return
        end
        if region == 'fire_trap' then
            seven_seals.TrapActivated(hero, SEVEN_SEALS_ELEM_TRAP_TYPE_FIRE)
            return
        end
    end,

    TrapActivated = 
    function(hero, _type)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.TrapActivated. Hero: ", %hero, " trap type: ", %_type)
        end)
        -- 
        local art_info = seven_seals.elem_trap_resist_artifacts[_type]
        print("Art info : ", art_info)
        if HasArtefact(hero, art_info.art, 1) then
            MessageBox(seven_seals.path.text..art_info.msg)
            return
        end
        --
        local resist_info = seven_seals.elem_trap_resist_abilities_multipliers[_type]
        print("Resist info: ", resist_info)
        for slot = 0, 6 do
            local creature, count = GetObjectArmySlotCreature(hero, slot)
            if not (creature == 0 or count == 0) then
                local max_resist_mult = 0
                for ability, resist_mult in resist_info do
                    print("Checking ability ", ability, " for creature ", creature)
                    if Creature.Component.HasAbility(creature, ability) and (resist_mult > max_resist_mult) then
                        max_resist_mult = resist_mult
                    end
                end
                --
                print("Max resist miltiplier: ", max_resist_mult)
                if max_resist_mult < 1 then
                    local remove_count = ceil(count - (count * max_resist_mult))
                    Hero.Creature.Add(hero, creature, -remove_count)
                end
            end
        end 
    end,
    
    -- регион возле печати
    SealReached =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.SealReached")
        end)
        if hero == "Karlam" then
            consoleCmd("game_writelog 1")
            Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
            consoleCmd('setvar adventure_speed_human = 2')
            MoveCamera(90, 11, UNDERGROUND, 30, math.pi/4, math.pi/8)
            startThread(
            function()
                CreateMonster('terhiz', CREATURE_ARCH_MAGI, 1, 1, 1, GROUND, 3, 1, 180)
                sleep()
                Touch.DisableMonster('terhiz', DISABLED_BLOCKED, 0)
                sleep()
            end)
            ChangeHeroStat('Karlam', STAT_MOVE_POINTS, 9999)
            MoveHeroRealTime("Karlam", 89, 12, UNDERGROUND)
            while 1 do
                local kx, ky = GetObjectPosition("Karlam")
                if kx == 89 and ky == 12 then
                    SetObjectRotation("Karlam", 180)
                    break
                end
                sleep()
            end
            sleep(7)
            AdvMap.FX.Play('Unsummon', "Karlam", '', 2)
            sleep(8)
            SetObjectPosition('terhiz', 91, 12, UNDERGROUND)
            sleep(7)
            SetRegionBlocked('fire_trap', 1, PLAYER_1)
            --
            -- варианты диалога:
            -- дефолт(оба квеста не взяты)
            -- 1) взят в таверне, не взят у эльфийки
            -- 2) взят у эльфийки, не взят в таверне
            -- 3) взяты оба
            local dialog_alt_set = nil
            if IsUnknown(seven_seals.name) then
                if IsUnknown(ghost_hope.name) then
                    dialog_alt_set = nil
                else
                    dialog_alt_set = 2
                end
            else
                if IsUnknown(ghost_hope.name) then
                    dialog_alt_set = 1
                else
                    dialog_alt_set = 3
                end
            end
            print("M1_Q_SevenSeals.SealReached: dialog_set is ", dialog_alt_set)
            MiniDialog.Start(seven_seals.path.dialog..'TerhizSealDialog/', PLAYER_1, seven_seals.dialogs.TerhizSealDialog, dialog_alt_set)
            --
            sleep(5)
            PlayObjectAnimation('terhiz', 'cast', ONESHOT)
            sleep(30)
            AdvMap.FX.Play('Phantom_out', "Karlam")
            sleep(10)
            AdvMap.FX.Play('Phantom_in', "Karlam", '', 2, 2)
            sleep(8)
            DeployReserveHero('KarlamPh', 91, 14, GROUND)
            sleep()
            SetObjectOwner("Karlam", PLAYER_3)
            SetObjectRotation('KarlamPh', 180)
            --
            local check = 1
            for slot = 0, 6 do
                local creature, count = GetObjectArmySlotCreature("Karlam", slot)
                if not (creature == 0 or count == 0) then
                    AddHeroCreatures('KarlamPh', creature, count)
                    if check then
                        repeat
                            sleep()
                        until GetHeroCreatures('KarlamPh', creature) == count
                        check = nil
                        RemoveHeroCreatures('KarlamPh', CREATURE_PEASANT, 999)
                    end
                end
            end
            --
            --local skills = {}
            for skill = 1, 171 do
                while GetHeroSkillMastery('KarlamPh', skill) ~= GetHeroSkillMastery("Karlam", skill) do
                    GiveHeroSkill('KarlamPh', skill)
                end
                --skills[skill] = GetHeroSkillMastery(Karlam, skill)
            end
        --    for skill, mast in skills do
        --      if mast > 0 then
        --        for i = 1, mast do
        --          GiveHeroSkill('KarlamPh', skill)
        --        end
        --      end
        --    end
            --
            for school = MAGIC_SCHOOL_DESTRUCTIVE, MAGIC_SCHOOL_SUMMONING_WITH_EMP do
                for i, spell in Spell.by_schools[school] do
                    if KnowHeroSpell("Karlam", spell) then
                        TeachHeroSpell('KarlamPh', spell)
                    end
                end
            end
            print("Spells ok")
            --
            for art, info in art_info do
                if art ~= 0 and HasArtefact("Karlam", art) then
                    for i = 1, GetHeroArtifactsCount("Karlam", art) do
                        GiveArtefact('KarlamPh', art, 1)
                    end
                end
            end
            print("Arts ok")
            --
            local exp = GetHeroStat("Karlam", STAT_EXPERIENCE)
            if exp > 0 then
                WarpHeroExp('KarlamPh', exp)
            end
            print("exp ok")
            --
            sleep()
            SetObjectPosition('KarlamPh', 91, 14, UNDERGROUND, 0)
            sleep(10)
            Touch.DisableHero("Karlam")
            EnableHeroAI("Karlam", nil)
            consoleCmd('setvar adventure_speed_human = 5')
            print("done")
        end  
    end,

    RockFight =
    function(hero, region)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.RockFight")
        end)
        SetGameVar('cursed_rock_fight', '1')
        if MCCS_StartCombat(hero, nil, 1, {CREATURE_CURSED_ROCK, 1}, nil, nil, nil, 1) then
            SetGameVar('cursed_rock_fight', '0')
            BlockGame()
            PlAdvMap.FX.PlayayFX('Phantom_out', hero)
            sleep(15)
            ShowObject(PLAYER_1, "Karlam")
            sleep()
            AdvMap.FX.Play('Phantom_in', "Karlam")
            sleep(10)
            SetObjectOwner("Karlam", PLAYER_1)
            sleep()
            RemoveObject('KarlamPh')
            SetObjectEnabled("Karlam", 1)
            SetRegionBlocked('fire_trap', nil, PLAYER_1)
            sleep(5)
            MoveCamera(91, 16, UNDERGROUND, 45, math.pi/4)
            sleep(5)
            for i = 1, 30 do
                AdvMap.FX.Play('Arcane_crys_death', 'sealed_tomb', '', 5.5 + (random(3) * GetRandFrom(1, -1)), -7.5, random(15) + 1)
                sleep()
            end
            StopVisualEffects('tomb_seal_01')
            sleep(5)
            if Quest.IsActive(ghost_hope.name) then
                MessageBox(ghost_hope.path.text..'seal_broken.txt')
                Quest.Finish(ghost_hope.name, "Karlam")
            else
                MessageBox(seven_seals.path.text..'seal_broken.txt')
            end
            if Quest.IsActive(seven_seals.name) then
                Quest.Update(seven_seals.name, 1, "Karlam")
            end
            -- диалог
            MiniDialog.Start(seven_seals.path.dialog..'SealBrokenDialog/', PLAYER_1, seven_seals.dialogs.SealBrokenDialog, (IsActive(seven_seals.name) and 1 or nil))
            sleep()
            -- добавить MCCS, когда сгенерю файлы для новых артов
            GiveArtefact("Karlam", ARTIFACT_CURSED_ROCK_BLOOD_FIAL)
            RemoveObject('terhiz')
            UnblockGame()
        end
    end,

    -- инициализация кастомабилки для использования крови рохи
    RockBloodVialUseInit =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.RockBloodVialUseInit")
        end)
        CustomAbility.Artifact.DialogPredefAnswers[MCCS_CUSTOM_ABILITY__USE_CURSED_ROCK_BLOOD] = 
        {
            seven_seals.path.text.."ability_use_cursed_rock_blood.txt",
            MCCS_CUSTOM_ABILITY__USE_CURSED_ROCK_BLOOD,
            1
        }
        CustomAbility.Artifact.Callbacks[MCCS_CUSTOM_ABILITY__USE_CURSED_ROCK_BLOOD] = seven_seals.UseRockBloodVial

        startThread(seven_seals.RockBloodVialCheckThread)
    end,

    -- поток проверки наличия колбы с кровью у героев
    RockBloodVialCheckThread =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.RockBloodVialCheckThread")
        end)
        while 1 do
            for player = PLAYER_1, PLAYER_8 do
                if Player.IsActive(player) then
                    for i, hero in GetPlayerHeroes(player) do
                        if not CustomAbility.Artifact.AbilitiesByHero[hero][MCCS_CUSTOM_ABILITY__USE_CURSED_ROCK_BLOOD] then
                            if HasArtefact(hero, ARTIFACT_CURSED_ROCK_BLOOD_FIAL) then
                                CustomAbility.Artifact.AbilitiesByHero[hero][MCCS_CUSTOM_ABILITY__USE_CURSED_ROCK_BLOOD] = 1
                            end
                        else
                            if not HasArtefact(hero, ARTIFACT_CURSED_ROCK_BLOOD_FIAL) then
                                CustomAbility.Artifact.AbilitiesByHero[hero][MCCS_CUSTOM_ABILITY__USE_CURSED_ROCK_BLOOD] = nil
                            end    
                        end
                    end
                end
            end
            sleep()
        end 
    end,

    -- функция использования крови
    UseRockBloodVial =
    function(hero, player)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.UseRockBloodVial")
        end)
        BlockGame()
        FX.Play("Bloodlust", hero)
        sleep(10)
        SetGameVar(hero.."_rock_blood_used", "1")
        seven_seals.rock_blood_effected_on_hero[hero] = seven_seals.rock_blood_effect_linger_fight_count
        RemoveArtefact(hero, ARTIFACT_CURSED_ROCK_BLOOD_FIAL)
        MessageBox(seven_seals.path.text.."cursed_rock_blood_used.txt", "UnblockGame")
    end,

    -- ивент результатов боя, проверяющий спадание эффекта крови после определенного числа боев
    RockBloodEffectLingerCheckEvent =
    function(fight_id)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M1_Q_SevenSeals.RockBloodEffectLingerCheckEvent")
        end)
        local winner = GetSavedCombatArmyHero(fight_id, 1)
        if winner and seven_seals.rock_blood_effected_on_hero[winner] then
            seven_seals.rock_blood_effected_on_hero[winner] = seven_seals.rock_blood_effected_on_hero[winner] - 1
            if seven_seals.rock_blood_effected_on_hero[winner] == 0 then
                SetGameVar(winner.."_rock_blood_used", "0")
                MessageBox(seven_seals.path.text.."cursed_rock_blood_effect_vanished.txt")
            end
        end
    end
}