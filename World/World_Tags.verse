
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Random }
using { /Verse.org/Concurrency }

using { Lists }
using { Player }
using { Utility }


# -----------------------------------------------------------------------------------------------------------------

tag_manager<public> := class:

    var InitialPlatformPosition<public> : vector3 = vector3:

    var TaggedPlayerDevices<public> : [int][]?creative_object_interface = map:
    var TaggedWorldDevices<public> : [int][]?creative_object_interface = map:

        
    Initialize<public>(Game : game_manager)<suspends> : void = 
        Setup(Game)

        sync:
            AssignPlayerTagsToMap(Game)
            AssignWorldTagsToMap(Game)



    Setup<private>(Game : game_manager) : void =
        BasePlatformObjects := for (FindableObject : Game.SimulationDevice.FindCreativeObjectsWithTag(tagged_base_platform{})) do FindableObject

        if (Object := BasePlatformObjects[0]):
            set InitialPlatformPosition = Object.GetTransform().Translation

            for (Index := 0..99):
                option {set TaggedPlayerDevices[Int[InitialPlatformPosition.X] + -1344 + (-64 * Index)] = for (Unused := 0..20 - 1) do false}
                option {set TaggedWorldDevices[Int[InitialPlatformPosition.X] + -1344 + (-64 * Index)] = for (Unused := 0..20 - 1) do false}




    AssignPlayerTagsToMap<private>(Game : game_manager)<suspends> : void =
        DeviceList : []tag = array:
            tagged_csd_camera:
            tagged_csd_hud_parameters:
            tagged_csd_transitions:
            tagged_csd_additive:
            tagged_csd_quest_1:
            tagged_csd_quest_2:
            tagged_csd_quest_3:
            tagged_tracker_quest_1:
            tagged_tracker_quest_2:
            tagged_tracker_quest_3:
            tagged_chair_player_seat:
                

        Channel : log = log{Channel := PlayerTagLog}
                

        for (Tag : DeviceList):
            TagList := for (FindableObject : Game.SimulationDevice.FindCreativeObjectsWithTag(Tag)) do FindableObject
            
            for (Object : TagList):
                ObjectPosition := Object.GetTransform().Translation

                if:
                    X := Round[ObjectPosition.X]
                    Y := Round[ObjectPosition.Y]

                    SlotValue := CalculateSlotValue[Y, -1216]

                then:
                    if (not TaggedPlayerDevices[X][SlotValue]?):
                        if (set TaggedPlayerDevices[X][SlotValue] = option{Object}):
                            # Channel.Print("Set Object -> [{X}][{SlotValue}]")

                        else Channel.Print("Failed to Slot into [{X}][{SlotValue}] for Object located at [{ObjectPosition.X}] [{ObjectPosition.Y}] / [{X}][{SlotValue}]")

                    else Channel.Print("Object Slot already occupied at [{X}][{SlotValue}]")

            Sleep(0.0)



    AssignWorldTagsToMap<private>(Game : game_manager)<suspends> : void =
        DeviceList : []tag = array:
            tagged_mode_detector:
            tagged_debug_messages:
            tagged_hud:
            tagged_teleporter:
            tagged_trackable_inputs:
            tagged_radio_tracks:
            tagged_audio_tracks:
            tagged_third_person_controller:
            tagged_player_camera:
            tagged_interaction_camera:
            tagged_player_menu_camera:

        Print("Length {DeviceList.Length}")

        Channel : log = log{Channel := WorldTagLog}


        for (Index -> Tag : DeviceList):
            TagList := for (FindableObject : Game.SimulationDevice.FindCreativeObjectsWithTag(Tag)) do FindableObject
            
            for (Object : TagList):
                ObjectPosition := Object.GetTransform().Translation

                if:
                    X := Round[ObjectPosition.X]
                    Y := Round[ObjectPosition.Y]

                    SlotValue := CalculateSlotValue[Y, -3264]

                then:
                    if (not TaggedWorldDevices[X][SlotValue]?):
                        if (set TaggedWorldDevices[X][SlotValue] = option{Object}):
                            Channel.Print("Set Object -> [{X}][{SlotValue}]")

                        else Channel.Print("Failed to Slot into [{X}][{SlotValue}] for Object located at [{ObjectPosition.X}] [{ObjectPosition.Y}] / [{X}][{SlotValue}]")

                    else Channel.Print("Object Slot already occupied at [{X}][{SlotValue}]")

            Sleep(0.0)



# -----------------------------------------------------------------------------------------------------------------
