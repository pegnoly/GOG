M2_Q_Generators = 
{
        --*Переменные*--
    -- Техническая информация
    name = "GENERATORS",
    path = 
    {
        text = q_path.."Primary/Generators/Texts/",
        dialog = q_path.."Primary/Generators/Dialogs/",
        override = q_path.."Primary/Generators/Overrides/",
    },
    dialog =
    {
        StartDialog = "GOG_M2_Q_GENERATORS_START_DIALOG",
        FirstTouchDialog = "GOG_M2_Q_GENERATORS_FIRST_TOUCH_DIALOG",
        CheckingSystemDialog = "GOG_M2_Q_GENERATORS_CHECKING_SYSTEM_DIALOG",
        DemonicGeneratorDialog = "GOG_M2_Q_GENERATORS_DEMONIC_GENERATOR_DIALOG"
    },
    -- флаг первого взаимодействия с генераторами
    first_generator_touch = 0,
    -- флаг, что игрок узнал принцип работы генераторов
    generator_system_checked = 0, 
    -- число посещенных генераторов
    generators_count = 0,
    -- статус починки генераторов
    generators_repaired =
    {
      ['run_gen_01'] = nil,
      ['run_gen_02'] = nil,
      ['run_gen_03'] = nil,
      ['run_gen_04'] = nil
    },
    -- ресурсы для восстановления генераторов
    resources_to_repair =
    {
        ['run_gen_01'] = 
        {
            [WOOD] = 15 + 5 * Global.InitialDifficulty, 
            [ORE] = 0, 
            [MERCURY] = 8 + 4 * Global.InitialDifficulty, 
            [CRYSTAL] = 20 + 2 * Global.InitialDifficulty, 
            [SULFUR] = 0, 
            [GEM] = 5 + 8 * Global.InitialDifficulty, 
            [GOLD] = 0
        },
        ['run_gen_03'] = 
        {
            [WOOD] = 0, 
            [ORE] = 30 + 4 * Global.InitialDifficulty, 
            [MERCURY] = 0, 
            [CRYSTAL] = 0, 
            [SULFUR] = 6 + 7 * Global.InitialDifficulty, 
            [GEM] = 10 + 4 * Global.InitialDifficulty, 
            [GOLD] = 0
        },
        ['run_gen_04'] = 
        {
            [WOOD] = 10 + 7 * Global.InitialDifficulty, 
            [ORE] = 25 + 5 * Global.InitialDifficulty, 
            [MERCURY] = 2 + 5 * Global.InitialDifficulty, 
            [CRYSTAL] = 3 + 4 * Global.InitialDifficulty, 
            [SULFUR] = 11 + Global.InitialDifficulty, 
            [GEM] = 7 + 4 * Global.InitialDifficulty, 
            [GOLD] = 0
        }
    },

    -- модель неактивного портала(для сцены призыва демона)
    portal_static = "/MapObjects/WP/M2/Portal_2Side_Shell.(AdvMapStaticShared).xdb#xpointer(/AdvMapStaticShared)",
        
        --*Функции*--
    
    -- загрузка квеста
    Init =
    function()
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.Init")
        end)
        for i, generator in {'run_gen_gologurs', 'run_gen_01', 'run_gen_02', 'run_gen_03', 'run_gen_04', 'run_gen_homodor', 'run_gen_ulkeron'} do
            Touch.DisableObject(generator, nil, M2_Q_Generators.path.override.."unknown_device_name.txt", 
                                                M2_Q_Generators.path.override.."unknown_device_desc.txt") 
            Touch.SetFunction(generator, '_touch', M2_Q_Generators.RunicGeneratorTouch)
        end
        Touch.SetFunction('run_gen_homodor', '_touch', M2_Q_Generators.RunicGeneratorHomodorTouch)
        --
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'run_gen_ulkeron_region', 'M2_Q_Generators.RunicGeneratorUlkeronEnter')
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'runic_generator_demons_ambush_region', 'M2_Q_Generators.GeneratorDemonAmbush')
        --
        startThread(M2_Q_Generators.RunicGeneratorsFX, 'run_gen_gologurs')
    end,

    -- старт квеста - активируется в диалоге с Малгумолом(см. ObscureCountry/script.lua)
    Start =
    function(hero)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.Start")
        end)
        MiniDialog.Start(M2_Q_Generators.path.dialog.."StartDialog/", PLAYER_1, M2_Q_Generators.dialog.StartDialog)
        Quest.Start(M2_Q_Generators.name, hero)
        for i, generator in {'run_gen_gologurs', 'run_gen_01', 'run_gen_02', 'run_gen_03', 'run_gen_04', 'run_gen_homodor', 'run_gen_ulkeron'} do
            Quest.SetObjectQuestmark(generator, QUESTMARK_OBJ_IN_PROGRESS, 20)
            Touch.DisableObject(generator, nil, M2_Q_Generators.path.override.."runic_generator_name.txt", 
                                                M2_Q_Generators.path.override.."runic_generator_desc.txt")
            Object.Show(PLAYER_1, generator)
        end
    end,

    -- завершение квеста - активируется в диалоге с Малгумолом(см. ObscureCountry/script.lua)
    Finish = 
    function(hero)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.Finish")
        end)
        local progress = Quest.GetProgress(M2_Q_Generators.name)
        if progress < 6 then
            MessageBox(M2_Q_Generators.path.text.."generators_not_repaired.txt")
        else
            Quest.ResetObjectQuestmark("Malgumol")
            Quest.Finish(M2_Q_Generators.name, hero)
            Quest.Start(M2_Q_FindGates, hero)
        end
    end,

    -- поток воспроизведения эффектов на генераторе
    RunicGeneratorsFX = 
    function(generator)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.RunicGeneratorsFX")
        end)
        while 1 do
            --local curr_fx = GetRandFromT({'Battlerage_rune', 'Berserk_rune', 'Charge_rune', 'Dragonform_rune', 'Spellimmun_rune', 'Ethereal_rune', 'Exorcism_rune', 'Magcontrol_rune', 'Revive_rune', 'Stunning_rune'})
            AdvMap.FX.Play('Berserk_rune', generator, '', Random.FromSelection(1, -1) * (0.5 + 0.1 * random(5)), Random.FromSelection(1, -1) * (0.5 + 0.1 * random(5)), 11 +  random(4), 90)
            sleep(4)
        end
    end,

    -- логика касания генераторов
    -- 1. Квест неактивен
    -- 2. Квест активен
    --  a)Прогресс 0 - получить информацию об устройстве генераторов
    --  b)Касание захваченного демонами генератора
    --  c)Починка генератора
    RunicGeneratorTouch =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.RunicGeneratorTouch")
        end)
        -- 1.
        if Quest.IsUnknown(M2_Q_Generators.name) then
            M2_Q_Generators.RunicGeneratorNoQuestTouch(hero, object)
        else
            if Quest.IsActive(M2_Q_Generators.name) then
                local progress = Quest.GetProgress(M2_Q_Generators.name)
                -- 2a.
                if progress == 0 then
                    M2_Q_Generators.RunicGeneratorCheckSystem(hero, object)
                else
                    if not M2_Q_Generators.generators_repaired[object] then
                        -- 2b.
                        if object == "run_gen_02" then
                            M2_Q_Generators.DemonicGeneratorTouch(hero, object)
                        -- 2c.
                        else
                            M2_Q_Generators.RepairGenerator(hero, object)
                        end
                    else
                        MessageBox(M2_Q_Generators.path.text.."generator_already_checked.txt")
                    end
                end
            else
                if Quest.IsCompleted(M2_Q_Generators.name) then
                    MessageBox(M2_Q_Generators.path.text.."generator_already_checked.txt")
                end
            end
        end
    end,

    -- касание генератора без наличия квеста
    RunicGeneratorNoQuestTouch =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.RunicGeneratorNoQuestTouch")
        end)
        if M2_Q_Generators.first_generator_touch == 0 then
            M2_Q_Generators.first_generator_touch = 1
            MiniDialog.Start(M2_Q_Generators.path.dialog.."FirstTouch/", PLAYER_1, M2_Q_Generators.dialog.FirstTouchDialog)
        else
            ShowFlyingSign(M2_Q_Generators.path.text.."unknown_device.txt", object, PLAYER_1, 7.0)
        end
    end,

    -- получение информации об устройстве генераторов
    RunicGeneratorCheckSystem =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.RunicGeneratorCheckSystem")
        end)
        if object == 'run_gen_gologurs' then
            MiniDialog.Start(M2_Q_Generators.path.dialog.."CheckingSystem/", PLAYER_1, M2_Q_Generators.dialog.CheckingSystemDialog)
            Quest.Update(M2_Q_Generators.name, 1, hero)
            Quest.ResetObjectQuestmark(object)
        else
            MessageBox(M2_Q_Generators.path.text.."generator_system_unknown.txt")
        end
    end,

    -- касание захваченного демонами генератора
    DemonicGeneratorTouch =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.DemonicGeneratorTouch")
        end)
        MiniDialog.Start(M2_Q_Generators.path.dialog.."DemonicGenerator/", PLAYER_1, M2_Q_Generators.dialog.DemonicGeneratorDialog)
        M2_Q_Generators.generators_repaired[object] = 1
        Quest.Update(M2_Q_Generators.name, Quest.GetProgress(M2_Q_Generators.name) + 1, hero)
        Quest.ResetObjectQuestmark(object)
        if Quest.GetProgress(M2_Q_Generators.name) == 5 then
            Quest.SetObjectQuestmark("Malgumol", QUESTMARK_OBJ_IN_PROGRESS)
            Quest.Update(M2_Q_Generators.name, 6, hero)
        end
    end,

    -- починка генератора
    RepairGenerator =
    function(hero, object)
        errorHook(
        function()
            print("<color=red>Error: <color=green>M2_Q_Generators.RepairGenerator")
        end)
        if MCCS_QuestionBox({M2_Q_Generators.path.text..object.."_repair_msg.txt"; 
                            resource_list = Resource.GenerateList(M2_Q_Generators.resources_to_repair[object])}) then
            if Resource.IsEnoughT(PLAYER_1, M2_Q_Generators.resources_to_repair[object]) then
                if Resource.RemoveT(PLAYER_1, M2_Q_Generators.resources_to_repair[object]) then
                    ShowFlyingSign(M2_Q_Generators.path.text.."generator_repaired.txt", object, 1, 7.0)
                    M2_Q_Generators.generators_repaired[object] = 1
                    Quest.ResetObjectQuestmark(object)
                    startThread(M2_Q_Generators.RunicGeneratorsFX, object)
                    Quest.Update(M2_Q_Generators.name, Quest.GetProgress(M2_Q_Generators.name) + 1, hero)
                    if Quest.GetProgress(M2_Q_Generators.name) == 5 then
                        Quest.SetObjectQuestmark("Malgumol", QUESTMARK_OBJ_IN_PROGRESS)
                        Quest.Update(M2_Q_Generators.name, 6, hero)
                    end
                end
            else
                MessageBox(M2_Q_Generators.path.text.."no_res_to_repair.txt")
            end
        end
    end,

    GeneratorDemonAmbush =
    function(hero, object)
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
        BlockGame()
        local demons_types = {CREATURE_BALOR, CREATURE_INFERNAL_SUCCUBUS, CREATURE_ARCHDEVIL}
        for i = 1, 3 do
          startThread(
          function()
            local x, y, z = GetObjectPosition('runic_generator_spawn_0'..%i)
            AdvMap.FX.Play('Summon_balor', 'runic_generator_spawn_0'..%i)
            sleep(15)
            CreateMonster('demon_ambush_'..%i, %demons_types[%i], 1, x, y, z, 3, 1, 180)
            while not IsObjectExists('demon_ambush_'..%i) do
              sleep()
            end
            PlayObjectAnimation('demon_ambush_'..%i, 'happy', ONESHOT)
          end)
        end
        sleep(20)
        local tier_table = TIER_TABLES[TOWN_INFERNO]
        local stack_info =
        {
            Random.FromTable_IgnoreTable({nil, tier_table[1][1]}, tier_table[1]), 250,
            Random.FromTable_IgnoreTable({nil, tier_table[3][1]}, tier_table[3]), 110,
            Random.FromTable_IgnoreTable({nil, tier_table[4][1]}, tier_table[4]), 59,
            Random.FromTable_IgnoreTable({nil, tier_table[4][1]}, tier_table[4]), 43,
            Random.FromTable_IgnoreTable({nil, tier_table[6][1]}, tier_table[6]), 16,
            Random.FromTable_IgnoreTable({nil, tier_table[7][1]}, tier_table[7]), 9)
        }
        if MCCS_StartCombat(hero, nil, 6, stack_info) then
          for i = 1, 3 do
            PlayObjectAnimation('demon_ambush_'..i, 'death', ONESHOT_STILL)
          end
          sleep(15)
          Object.RemoveSelection('demon_ambush_1', 'demon_ambush_2', 'demon_ambush_3')
        end
        UnblockGame()
    end,
}