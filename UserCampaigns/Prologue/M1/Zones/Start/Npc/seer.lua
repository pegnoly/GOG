NPC_START_ZONE_INTERACTION_ASHA_TIER = 1

npc_start_zone_seer = {

    interaction_types = {
        [NPC_START_ZONE_INTERACTION_ASHA_TIER] = nil
    },

    Init = function ()
        Touch.DisableObject("start_zone_seer")
        Touch.SetFunction("start_zone_seer", "interaction", npc_start_zone_seer.Interact)
        Npc.Init("start_zone_seer")
        Npc.AddInteraction(
            "start_zone_seer",
            "baal_info",
            function (_hero, _object)
                local result = Quest.IsActive(kill_baal.name) and Quest.GetProgress(kill_baal.name) == 0
                return result
            end,
            function (hero, object)
                kill_baal.SeerHutFirstInteraction(hero, object)
            end
        )
        Npc.AddInteraction(
            "start_zone_seer",
            "moriton_not_visited",
            function (_hero, _object)
                local result = Quest.IsActive(kill_baal.name) and Quest.GetProgress(kill_baal.name) == 1
                return result
            end
        )
        Npc.AddInteraction(
            "start_zone_seer",
            "asha_tear_info",
            function (_hero, _object)
                local result = Quest.IsActive(asha_tear.name) and 
                    Quest.GetProgress(asha_tear.name) == 0 and
                    not npc_start_zone_seer.interaction_types[NPC_START_ZONE_INTERACTION_ASHA_TIER] and
                    kill_baal.eternal_night_state == ETERNAL_NIGHT_STATE_NOT_STARTED
                return result
            end,
            function (hero, object)
                asha_tear.StartZoneSeerTalk(hero, object)
            end
        )
        Npc.AddInteraction(
            "start_zone_seer",
            "no_interaction",
            function (_hero, _object)
                local result = npc_start_zone_seer.interaction_types[NPC_START_ZONE_INTERACTION_ASHA_TIER] and
                    kill_baal.eternal_night_state == ETERNAL_NIGHT_STATE_NOT_STARTED
                return result
            end,
            function (_hero, _object)
                MessageBox(start_zone.path.text.."no_seer.txt")
            end
        )
        Npc.AddInteraction(
            "start_zone_seer",
            "seer_killed",
            function (_hero, _object)
                local result = kill_baal.eternal_night_state == ETERNAL_NIGHT_STATE_STARTED
                return result
            end,
            function (_hero, _object)
                MessageBox(start_zone.path.text.."seer_killed.txt")
            end
        )
    end,

    Interact = function (hero, object)
        Npc.RunInteractions(hero, object)
    end
}