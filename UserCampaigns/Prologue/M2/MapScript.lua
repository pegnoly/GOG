--------------------------------------------------------------------------------
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Автор: Gerter
-- mail : owafe001@gmail.com 
-- discord : pegnoly#9113
-- telegram : https://t.me/pegn0ly
--------------------------------------------------------------------------------
q_path = mainPath..'Quests/'

DECORATIVE_PLAYERS = {}

DIALOG_SCENES =
{
  START          = '/DialogScenes/M1/Begin/DialogScene.xdb#xpointer(/DialogScene)',
  DUNGEON_GATES  = '/DialogScenes/M1/DungeonGates/DialogScene.xdb#xpointer(/DialogScene)',
  WITCHES_RITUAL = '/DialogScenes/M1/WitchesRitual_RM/DialogScene.xdb#xpointer(/DialogScene)',
  FINAL          = '/DialogScenes/M1/Final/DialogScene.xdb#xpointer(/DialogScene)'
}

ARENAS =
{
  MATRON_CHAMBERS = '/Arenas/CombatArena/M1/MatronChambers.(AdvMapTownCombat).xdb#xpointer(/AdvMapTownCombat)',
  POST_1          = '/Maps/CombatArenas/M1/elf_post1.(AdvMapTown).xdb#xpointer(/AdvMapTown)',
  POST_2          = '/Maps/CombatArenas/M1/elf_post2.(AdvMapTown).xdb#xpointer(/AdvMapTown)',
  POST_3          = '/Maps/CombatArenas/M1/elf_post3.(AdvMapTown).xdb#xpointer(/AdvMapTown)',
}

COMBAT_LIGHTS =
{
  MORNING     = '/Lights/_(AmbientLight)/M1/WP_M1_Ground_dark_day.(AmbientLight).xdb#xpointer(/AmbientLight)',
  DAY = '/Lights/_(AmbientLight)/M1/WP_M1_Mountain_day_fog.(AmbientLight).xdb#xpointer(/AmbientLight)',
  NIGHT   = '/Lights/_(AmbientLight)/M1/WP_M1_Foggy_night.(AmbientLight).xdb#xpointer(/AmbientLight)',
  --UGROUND = '/Lights/_(AmbientLight)/Scenes/Taiga_Forest_Fog.xdb#xpointer(/AmbientLight)',
  UGROUND = '/Lights/_(AmbientLight)/M1/WP_M1_Uground_darkness.(AmbientLight).xdb#xpointer(/AmbientLight)',
  --UGROUND = '/Lights/_(AmbientLight)/M1/WP_M1_Uground_fog.(AmbientLight).xdb#xpointer(/AmbientLight)',
  CURRENT = ''
}

while not Quest do
    sleep()
end

Quest.Names['UNKNOWN_PATH'] = q_path.."Primary/UnknownPath/name.txt"
Quest.Names['INTRIGUE'] = q_path.."Primary/Intrigue/name.txt"
Quest.Names['GHOST_HOPE'] = q_path.."Secondary/GhostHope/name.txt"
Quest.Names['SEVEN_SEALS'] = q_path.."Secondary/SevenSeals/name.txt"

function LoadScripts()
    --
    doFile(q_path.."Primary/HeroesNeverDie/script.lua")
    doFile(q_path.."Primary/UnknownPath/script.lua")
    doFile(q_path.."Primary/Intrigue/script.lua")
    --
    doFile(q_path.."Secondary/GhostHope/script.lua")
    doFile(q_path.."Secondary/SevenSeals/script.lua")
    --
    dofile(mainPath.."test.lua")
    while not CombatConnection do
        sleep()
    end
    CombatConnection.combat_scripts_paths['cursed_rock_fight'] = mainPath.."Combat/CursedRock/script.lua"
    CombatConnection.combat_scripts_paths['cursed_rock_blood_effect'] = mainPath.."Combat/CursedRockBlood/script.lua"
    CombatConnection.combat_scripts_paths['noellie_fight'] = mainPath.."Combat/NoellieFight/script.lua"
end

while not Animation do
    sleep()
end

function SetupThisMapAnimGroups()
    local deads = {}
    for i = 1, 5 do
        deads[i] = 'dead'..i
    end
    Animation.NewGroup("dead", deads)
    Animation.NewGroup("dp_st", {'dp_st_1', 'dp_st_2'})
    Animation.NewGroup("dp_u", {'dp_u_1', 'dp_u_2', 'dp_u_3', 'dp_u_4', 'dp_u_5', 'dp_u_6'})
end

function PlayThisMapAnimGroups()
    Animation.PlayGroup("dead", {"death"}, PLAY_CONDITION_SINGLEPLAY, ONESHOT_STILL)
end

NewDayEvent.AddListener("GOG_M1_change_light_listener",
function(day)
    local dow = GetDate(DAY_OF_WEEK)
    if dow == 1 then
        SetAmbientLight(GROUND, "GOG_M1_Ground_dark_morning", 1, 7.0)
    elseif dow == 2 then
        SetAmbientLight(GROUND, "GOG_M1_Mountain_day_fog", 1, 7.0)
    elseif dow == 5 then
        SetAmbientLight(GROUND, "GOG_M1_Foggy_night", 1, 7.0)
    end
end)

function Test()
    consoleCmd('enable_cheats')
    consoleCmd('setvar console_size = 10000')
    -- GiveArtefact(Karlam, 41)
    -- GiveArtefact(Karlam, 43)
    -- consoleCmd('add_army 3 2 1000')
    AddHeroCreatures('Karlam', CREATURE_PHOENIX, 1000)
    OpenCircleFog(0, 0, 0, 999, 1)
    OpenCircleFog(0, 0, 1, 999, 1)
end

function StartMap()
    LoadScripts()
    sleep(10)
    -- CreateCombatFunctionsList(COMBAT_FUNCTIONS_PATHS)
    -- !TODO reimpl this.
    --SetHeroesExpCoef(0.3 + 0.2 - 0.05 * initialDifficulty) 

    --DeployReserveHero('Noellie', RegionToPoint('noe_return'))
    --UGCombatLightInit()
    SetAmbientLight(GROUND, 'GOG_M1_Ground_dark_morning')
    SetAmbientLight(UNDERGROUND, 'WP_M1_Uground_darkness')
    -- основные глобальные переменные
    SetGameVar('mission', 1)
    SetGameVar('karlam_lvl', 0)
    SetGameVar('karlam_soldier_luck', 0)
    SetGameVar('post', 0)
    SetGameVar('dung_fight', 'none')
    -- загрузка базовых квестов
    startThread(unknown_path.Init)
    startThread(intrigue.Init)
    startThread(heroes_never_die.Init)
    startThread(seven_seals.Init)
    sleep(10)
    --
    SetupThisMapAnimGroups()
    PlayThisMapAnimGroups()
    SetCombatLight(COMBAT_LIGHTS.MORNING)
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.MORNING
    for i, dolmen in GetObjectNamesByType('BUILDING_LEARNING_STONE') do
      Touch.DisableObject(dolmen)
      Touch.SetFunction(dolmen, '_dolmen_touch',
      function(hero, object)
          GiveExp(hero, 750 - 100 * initialDifficulty)
          MarkObjectAsVisited(object, hero)
      end)
    end
end

startThread(Test)
startThread(StartMap)
StartDialogSceneInt(DIALOG_SCENES.START)
UnblockGame()