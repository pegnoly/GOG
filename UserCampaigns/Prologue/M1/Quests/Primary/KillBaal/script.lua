-- @quest 
-- Кампания. Личный демон.
-- Миссия. Сердце ночи.
-- Тип квеста. Основной.
-- Имя квеста. Пробуждённый.

ARTIFACT_C1_M1_LIFE_ESSENCE = 402

-- возможные типы поиска точки для перемещений Баала
BAAL_SPAWN_MODE_KARLAM_CLOSEST = 1
BAAL_SPAWN_MODE_BAAL_FURTHEST = 2
BAAL_SPAWN_MODE_TELEPORT = 3

-- возможные состояния вечной ночи
ETERNAL_NIGHT_STATE_NOT_STARTED = 1
ETERNAL_NIGHT_STATE_HALF_TIME_GONE = 2
ETERNAL_NIGHT_STATE_JUST_STARTED = 3
ETERNAL_NIGHT_STATE_STARTED = 4

-- возможные состояния прогресса квеста
KILL_BAAL_QUEST_PROGRESS_MUST_TALK_WITH_PROPHET = 0
KILL_BAAL_QUEST_PROGRESS_MUST_GO_TO_MORITON = 1
KILL_BAAL_QUEST_PROGRESS_MORITON_ENTERED = 11
KILL_BAAL_QUEST_PROGRESS_MUST_CREATE_SPRING = 2

ARTIFACT_SIGN_OF_SYLANNA = 300

kill_baal = {
        --*ПЕРЕМЕННЫЕ*--

    -- техническая информация --
    name = "C1_M1_KILL_BAAL",

    state = nil,

    path = {
        text = primary_quest_path.."KillBaal/Texts/",
        dialog = primary_quest_path.."KillBaal/Dialogs/"
    },

    dialogs = {
        Prophet = "C1_M1_Q_KILL_BAAL_PROPHET_DIALOG"
    },

    -- Параметры, по которым определяется состояние Вечной Ночи
    eternal_night_start_day = -1,
    eternal_night_half_day = -1,
    eternal_night_base_delay = 81,
    eternal_night_delay_per_difficulty = 3,
    eternal_night_state = ETERNAL_NIGHT_STATE_NOT_STARTED,
    night_start_day_of_week = 5,
    --
    baal_first_spawn_day = -1,
    baal_spawn_points = {},
    max_spawn_distance = 800,
    max_heroes_distance = 10000,
    baal_active = nil,
    baal_spawn_dow = -1,
    baal_have_destination = nil,
    baal_teleported_this_turn = nil,
    baal_destination = {x = -1, y = -1, z = -1},

    -- Init = 
    -- function ()
    --     Touch.DisableObject("baal_point", DISABLED_INTERACT)
    --     Touch.SetFunction("baal_point", "C1_M1_q_kill_baal_baal_point_touch", kill_baal.BaalPointTouch)
    --     Quest.SetObjectQuestmark("baal_point", QUESTMARK_OBJ_NEW)
    --     --
    --     Touch.DisableObject("prorok1")
    --     Touch.SetFunction("prorok1", "C1_M1_q_kill_baal_prophet_hut_touch", kill_baal.ProphetHutTouch)
    -- end,

    -- Start = 
    -- function ()
    -- end,

    -- логика касания крипты Баала
    BaalPointTouch = 
    function (hero, object)
        if Quest.IsActive(kill_baal.name) then
            MessageBox(kill_baal.path.text.."baal_point_touch_active.txt")
            return
        end 
        --
        StartDialogScene(DIALOG_SCENES.BAAL_SPAWN)
        BlockGame()
        MessageBox(kill_baal.path.text.."baal_spawn_message.txt")
        Quest.Start(kill_baal.name, hero)
        --
        local eternal_night_delay = kill_baal.eternal_night_base_delay - defaultDifficulty * kill_baal.eternal_night_delay_per_difficulty
        kill_baal.eternal_night_start_day = GetDate(DAY) + eternal_night_delay
        kill_baal.eternal_night_half_day = GetDate(DAY) + floor(eternal_night_delay / 2)
        --
        NewDayEvent.AddListener("C1_M1_new_day_eternal_night_timing_listener", kill_baal.UpdateEternalNightTiming)
        NewDayEvent.AddListener("C1_M1_new_day_eternal_night_start_listener", kill_baal.EternalNightStart)
        NewDayEvent.AddListener("C1_M1_new_day_baal_appearance_listener", kill_baal.ManageBaalAppearance)
        NewDayEvent.InvokeAfter("C1_M1_new_day_eternal_night_timing_listener", "C1_M1_new_day_eternal_night_start_listener")
        NewDayEvent.InvokeAfter("C1_M1_new_day_eternal_night_timing_listener", "C1_M1_new_day_baal_appearance_listener")
        NewDayEvent.InvokeAfter("C1_M1_new_day_eternal_night_timing_listener", "C1_M1_new_day_update_light_listener")
        --
        local dow = GetDate(DAY_OF_WEEK)
        if dow == 4 then
            kill_baal.baal_first_spawn_day = GetDate(DAY) + 2
        else
            kill_baal.baal_first_spawn_day = dow < 5 and (GetDate(DAY) + 5 - dow) or (GetDate(DAY) + 12 - dow)
        end
        -- 
        Quest.SetObjectQuestmark("prorok1", QUESTMARK_OBJ_NEW_PROGRESS)
        Object.Show(PLAYER_1, "prorok1", 1, 1)
        sleep(15)
        MessageBox(kill_baal.path.text.."prorok1.txt")
        UnblockGame()
    end,

    -- InitBaalSpawnPoints = 
    -- function ()
    --     for i = 1, 36 do
    --         kill_baal.baal_spawn_points[i] = "sp"..i            
    --     end
    -- end,

    -- -- логика поиска оптимальной точки для респауна Баала.
    -- FindOptimalSpawnPoint =
    -- function (mode)
    --     if mode == BAAL_SPAWN_MODE_KARLAM_CLOSEST then
    --         local x, y, z = RegionToPoint(kill_baal.baal_spawn_points[1])
    --         local current_min_path = math.huge
    --         for i, point in kill_baal.baal_spawn_points do
    --             local path = CalcHeroMoveCost("Karlam", RegionToPoint(point))
    --             if path ~= -1 and path < current_min_path and path > kill_baal.max_spawn_distance then
    --                 current_min_path = path
    --                 x, y, z = RegionToPoint(point)
    --             end
    --         end
    --         return x, y, z
    --     elseif mode == BAAL_SPAWN_MODE_BAAL_FURTHEST then
    --         local x, y, z = RegionToPoint(kill_baal.baal_spawn_points[1])
    --         local current_max_path = 0
    --         for i, point in kill_baal.baal_spawn_points do
    --             local path = CalcHeroMoveCost("Baal", RegionToPoint(point))
    --             if path ~= -1 and path > current_max_path then
    --                 current_max_path = path
    --                 x, y, z = RegionToPoint(point)
    --             end
    --         end
    --         return x, y, z
    --     elseif mode == BAAL_SPAWN_MODE_TELEPORT then
    --         local x, y, z = GetObjectPosition("Baal")
    --         local current_min_path = math.huge
    --         for i, point in kill_baal.baal_spawn_points do
    --             local baal_path = CalcHeroMoveCost("Baal", RegionToPoint(point))
    --             if baal_path ~= -1 then
    --                 local karlam_path = CalcHeroMoveCost("Karlam", RegionToPoint(point))
    --                 if karlam_path ~= -1 and karlam_path >= kill_baal.max_spawn_distance then
    --                     local distance = CalcHeroMoveCost("Baal", GetObjectPosition("Karlam"))
    --                     if karlam_path < current_min_path and (karlam_path + baal_path) >= distance then
    --                         current_min_path = karlam_path
    --                         x, y, z = RegionToPoint(point)
    --                     end
    --                 end
    --             end
    --         end
    --         return x, y, z
    --     end
    -- end,

    -- -- логика перемещений Баала
    -- BaalMovementThread =
    -- function ()
    --     while 1 do
    --         if not kill_baal.baal_active then
    --             return
    --         end
    --         --
    --         if GetCurrentPlayer() == PLAYER_2 then
    --             local x, y, f = GetObjectPosition("Karlam")
    --             if CanMoveHero("Baal", x, y, f) then
    --                 local move_cost = CalcHeroMoveCost("Baal", x, y, f)
    --                 if move_cost >= kill_baal.max_heroes_distance and (not kill_baal.baal_teleported_this_turn) then
    --                     local bx, by, bf = kill_baal.FindOptimalSpawnPoint(BAAL_SPAWN_MODE_TELEPORT)
    --                     kill_baal.baal_teleported_this_turn = 1
    --                     SetObjectPosition("Baal", bx, by, bf, 3)
    --                     ChangeHeroStat("Baal", STAT_MOVE_POINTS, -(GetHeroStat("Baal", STAT_MOVE_POINTS) - 300))
    --                     sleep()
    --                 end
    --                 MoveHero("Baal", x, y, f)
    --             elseif (not kill_baal.baal_have_destination) then
    --                 kill_baal.baal_destination = kill_baal.FindOptimalSpawnPoint(BAAL_SPAWN_MODE_BAAL_FURTHEST)
    --                 MoveHero("Baal", kill_baal.baal_destination.x, kill_baal.baal_destination.y, kill_baal.baal_destination.z)
    --                 kill_baal.baal_have_destination = 1
    --             else
    --                 MoveHero("Baal", kill_baal.baal_destination.x, kill_baal.baal_destination.y, kill_baal.baal_destination.z)
    --             end
    --         end
    --     end
    -- end,

    -- AccelerateBaal = 
    -- function ()
    --     if kill_baal.baal_active then
    --         MakeHeroInteractWithObject("Baal", "stables")
    --     end
    -- end,

    -- GiveNightBonus = 
    -- function ()
    --     GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_ATTACK, 30)
    --     GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_DEFENCE, 30)
    --     GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_INITIATIVE, 50)
    --     GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_SPEED, 7)
    --     GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_HITPOINTS, 1000)
    -- end,

    -- BaalFirstRespawn = 
    -- function (day)
    --     if day == kill_baal.baal_first_spawn_day then
    --         BlockGame()
    --         MoveCamera(32, 26, 0, 0, 0, 0, 1, 1)
    --         sleep(20)
    --         SetObjectPosition("Baal", 32, 26, 0, 3)
    --         kill_baal.GiveNightBonus()
    --         sleep(10)
    --         MessageBox(kill_baal.path.text.."baal_first_appearance.txt")
    --         kill_baal.baal_active = 1
    --         kill_baal.baal_spawn_dow = 5
    --         startThread(kill_baal.BaalMovementThread)
    --     end
    -- end,

    -- -- логика для ивента нового дня.
    -- NewDayLogic =
    -- function (day)
    --     CheckEternalNightHalfTime(day)
    --     CheckEternalNightFullTime(day)
    --     ManageBaalAppearance(day)
    -- end,

    -- UpdateEternalNightTiming = 
    -- function (day)
    --     if day == kill_baal.eternal_night_half_day then
    --         kill_baal.baal_spawn_dow = 4
    --         MessageBox(kill_baal.path.text.."half_eternal_night.txt")
    --     elseif day == kill_baal.eternal_night_start_day then
    --         kill_baal.eternal_night_state = ETERNAL_NIGHT_STATE_JUST_STARTED
    --     end
    --     -- от расчетов в этой функции зависит исполнение других слушателей ивента нового дня, поэтому нужно ждать, пока она отработает
    --     NewDayEvent.FinishInvoking("C1_M1_new_day_eternal_night_timing_listener")
    -- end,

    -- -- проверка на наступление вечной ночи
    -- EternalNightStart = 
    -- function (day)
    --     if kill_baal.eternal_night_state == ETERNAL_NIGHT_STATE_JUST_STARTED then
    --         kill_baal.eternal_night_state = ETERNAL_NIGHT_STATE_STARTED
    --         MessageBox(kill_baal.path.text.."full_eternal_night.txt")
    --         SetAmbientLight(GROUND, 'deepnight', 1, 1)
    --         SetCombatLight(COMBAT_LIGHTS.NIGHT)
    --         COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.NIGHT
    --         --
    --         if kill_baal.baal_active then
    --             ShowFlyingSign(kill_baal.path.text.."baal_eternal_night_msg.txt", "Baal", PLAYER_1, 7.0)
    --         end
    --     end
    -- end,

    -- -- управляет появлением/исчезновением Баала
    -- -- 1. Если вечная ночь активна и Баал неактивен, то он должен появиться независимо от дня недели
    -- -- 2. Если вечная ночь неактивна, то
    -- -- a) Если первый день недели, то убрать Баала
    -- -- b) Если в этот день недели наступает ночь и Баал не активен, то Баал появляется
    -- ManageBaalAppearance = 
    -- function (day)
    --     if kill_baal.eternal_night_state ~= ETERNAL_NIGHT_STATE_NOT_STARTED then
    --         -- 1
    --         if not kill_baal.baal_active then
    --             startThread(kill_baal.SpawnBaal, "baal_eternal_night_msg")
    --             return
    --         end
    --     else
    --         -- 2a
    --         if day == 1 and kill_baal.baal_active then
    --             startThread(kill_baal.RemoveBaal)
    --             return
    --         end
    --         -- 2b
    --         if day == kill_baal.baal_spawn_dow and (not kill_baal.baal_active) then
    --             startThread(kill_baal.SpawnBaal, "baal_default_spawn_msg")
    --             return
    --         end
    --     end
    -- end,

    -- -- логика респауна Баала.
    -- SpawnBaal = 
    -- function (msg)
    --     local x, y, f = kill_baal.FindOptimalSpawnPoint(BAAL_SPAWN_MODE_KARLAM_CLOSEST)
    --     SetObjectPosition("Baal", x, y, f, 3)
    --     ShowFlyingSign(kill_baal.path.text..msg..".txt", "Baal", PLAYER_1, 7.0)
    --     kill_baal.baal_active = 1
    --     if kill_baal.eternal_night_state ~= ETERNAL_NIGHT_STATE_NOT_STARTED then
    --         kill_baal.AccelerateBaal()
    --     end
    -- end,

    -- -- Баал уходит при наступлении утра
    -- RemoveBaal = 
    -- function ()
    --     ShowFlyingSign(kill_baal.path.text.."baal_retreat.txt", "Baal", PLAYER_1, 7.0)
    --     sleep(5)
    --     SetObjectPosition('Baal', 3, 8, 1, 3)
    --     kill_baal.baal_active = nil
    -- end,

    -- логика касания хижины пророка
    SeerHutFirstInteraction =
    function (hero, _object)
        MiniDialog.Start("C1M1_DIALOG_06")
        Quest.Update(kill_baal.name, 1, hero)
        Art.Distribution.Give(hero, ARTIFACT_SIGN_OF_SYLANNA, 1)
    end,

    SeerHutSecondInteraction = 
    function (_hero, _object)
        MiniDialog.Start("C1M1_DIALOG_07")
    end

    -- -- логика боя в чаще энтов
    -- TreantBankFight = 
    -- function (hero, object)
    --     if MCCS_QuestionBox("") then

    --         CombatResultsEvent.AddListener("c1m1_start_zone_treant_bank_fight_remove_tag_listener",
    --         function (fight_id)
    --             local player = GetSavedCombatArmyPlayer(fight_id, 1)
    --             if not(CombatResultsEvent.fight_tag_for_player[player] and 
    --                 CombatResultsEvent.fight_tag_for_player[player] == "c1m1_start_zone_treant_bank_fight") then
    --                 return
    --             end
    --             CombatResultsEvent.fight_tag_for_player[player] = nil
    --             CombatResultsEvent.RemoveListener("c1m1_start_zone_treant_bank_fight_remove_tag_listener")
    --         end)

    --         local tiers = TIER_TABLES[TOWN_PRESERVE]
    --         local stacks = {
    --             {Random.FromTable_IgnoreValue(tiers[1], tiers[1][1], 113 + random(Creature.Params.Grow(tiers[1][1])))},
    --             {Random.FromTable_IgnoreValue(tiers[2], tiers[2][1], 48 + random(Creature.Params.Grow(tiers[2][1])))},
    --             {Random.FromTable_IgnoreValue(tiers[4], tiers[4][1], 16 + random(Creature.Params.Grow(tiers[4][1])))},
    --             {Random.FromTable_IgnoreValue(tiers[5], tiers[5][1], 12 + random(Creature.Params.Grow(tiers[5][1])))}
    --         }
    --         MCCS_StartCombat(hero, nil, 4, stacks, nil, "c1m1_start_zone_treant_bank_fight", nil, 1)
    --     end
    -- end,

    -- -- Пытается вызваться при касании внутренних гарнизонов Моритона.
    -- TryEnterMoriton =
    -- function (hero, object)
    --     if Quest.GetProgress(kill_baal.name) ~= KILL_BAAL_QUEST_PROGRESS_MUST_GO_TO_MORITON and 
    --         not HasArtefact(hero, ARTIFACT_RIGID_MANTLE, 1) then
    --         MessageBox()
    --         return
    --     end
    --     if HasArtefact(hero, ARTIFACT_RIGID_MANTLE, 1) then
    --         Touch.RemoveFunction(object, "kill_baal_try_enter_moriton")
    --     else

    --     end
    -- end
}

