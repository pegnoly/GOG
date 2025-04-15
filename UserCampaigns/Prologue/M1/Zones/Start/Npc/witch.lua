START_ZONE_WITCH_INTERACTION_STATE_NOT_INTERACTED = 0
START_ZONE_WITCH_INTERACTION_STATE_BASE_INTERACTION = 1
START_ZONE_WITCH_INTERACTION_STATE_ASHA_TEAR_INTERACTION = 2

START_ZONE_WITCH_FIRST_DIALOG = "C1M1_DIALOG_03"
START_ZONE_WITCH_SECOND_DIALOG = "C1M1_DIALOG_04"
START_ZONE_WITCH_THIRD_DIALOG = "C1M1_DIALOG_05"

while not Npc and START_ZONE_WITCH_INTERACTION_STATE_ASHA_TEAR_INTERACTION do
    sleep()
end

npc_start_zone_witch = {

    interaction_state = START_ZONE_WITCH_INTERACTION_STATE_NOT_INTERACTED,

    Init = 
    function ()
        Touch.DisableObject("start_zone_witch")
        Touch.SetFunction("start_zone_witch", "npc_interaction", npc_start_zone_witch.Interact)
        Npc.Init("start_zone_witch")
        Npc.AddInteraction(
            "start_zone_witch", 
            "base", 
            function (_hero, _object)
                local result = npc_start_zone_witch.interaction_state == START_ZONE_WITCH_INTERACTION_STATE_NOT_INTERACTED and not Quest.IsActive(asha_tear.name)
                return result
            end,
            function (hero, _object)
                print("This interaction?")
                MiniDialog.Start("C1M1_DIALOG_03")
                npc_start_zone_witch.interaction_state = START_ZONE_WITCH_INTERACTION_STATE_BASE_INTERACTION
                MakeHeroInteractWithObject(hero, "start_zone_witch_hut_of_magi")
            end
        )
        Npc.AddInteraction(
            "start_zone_witch",
            "base_repeat",
            function (_hero, _object)
                local result = npc_start_zone_witch.interaction_state ~= START_ZONE_WITCH_INTERACTION_STATE_NOT_INTERACTED and not Quest.IsActive(asha_tear.name)
                return result
            end,
            function (_hero, _object)
                MiniDialog.Start(START_ZONE_WITCH_SECOND_DIALOG)
            end
        )
        Npc.AddInteraction(
            "start_zone_witch",
            "asha_tear_int",
            function (_hero, _object)
                local result = kill_baal.eternal_night_state ~= ETERNAL_NIGHT_STATE_STARTED and 
                    Quest.IsActive(asha_tear.name) and 
                    npc_start_zone_witch.interaction_state == START_ZONE_WITCH_INTERACTION_STATE_BASE_INTERACTION
                return result
            end,
            function (_hero, _object)
                local eternal_night_state = kill_baal.eternal_night_state
                MiniDialog.Start(START_ZONE_WITCH_THIRD_DIALOG, eternal_night_state == ETERNAL_NIGHT_STATE_HALF_TIME_GONE and "half_eternal_night" or nil)
                npc_start_zone_witch.interaction_state = START_ZONE_WITCH_INTERACTION_STATE_ASHA_TEAR_INTERACTION
            end
        )
        Npc.AddInteraction(
            "start_zone_witch",
            "asha_tear_no_int",
            function (_hero, _object)
                local result = kill_baal.eternal_night_state ~= ETERNAL_NIGHT_STATE_STARTED and
                    Quest.IsActive(asha_tear.name) and 
                    npc_start_zone_witch.interaction_state == START_ZONE_WITCH_INTERACTION_STATE_NOT_INTERACTED
                return result
            end,
            function (_hero, _object)
                MessageBox(start_zone.path.text.."witch_no_interaction.txt")
            end
        )
        Npc.AddInteraction(
            "start_zone_witch",
            "eternal_night_interaction",
            function (_hero, _object)
                local result = kill_baal.eternal_night_state == ETERNAL_NIGHT_STATE_STARTED
                return result
            end,
            function (_hero, _object)
                MessageBox(start_zone.path.text.."witch_left_house.txt")
            end
        )
        Npc.AddInteraction(
            "start_zone_witch",
            "no_special_interaction",
            function (_hero, _object)
                local result = kill_baal.eternal_night_state ~= ETERNAL_NIGHT_STATE_STARTED 
                    and (npc_start_zone_witch.interaction_state == START_ZONE_WITCH_INTERACTION_STATE_ASHA_TEAR_INTERACTION or Quest.IsCompleted(asha_tear.name))
            end,
            function (_hero, _object)
                print("Or this one?")
                MessageBox(start_zone.path.text.."witch_cant_help.txt")
            end
        )
    end,

    Interact = function (hero, object)
        Npc.RunInteractions(hero, object)
    end
}