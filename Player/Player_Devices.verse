
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SceneGraph }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Random }
using { /Verse.org/Concurrency }

using { World }
using { Utility }

# Camera
# HUD Parameters
# Transitions


# -----------------------------------------------------------------------------------------------------------------

player_devices<public> := class:

    Channel<private> : log = log{Channel := DeviceLog}


    var CSDTree<public> : []cinematic_sequence_device = array:
        
    var QuestObjects<public> : []cinematic_sequence_device = array:
        
    var QuestTrackers<public> : []tracker_device = array:


        
    Initialize<public>(Game : game_manager, PlayerContainer : player_container)<suspends> : void =
        set CSDTree = for (Index := 0..10 - 1) do cinematic_sequence_device:
        set QuestTrackers = for (Index := 0..3 - 1) do tracker_device:

        SetDevices(Game, PlayerContainer)



    SetDevices<private>(Game : game_manager, PlayerContainer : player_container)<suspends> : void =
        for (Entry -> Object : Game.TagManager.TaggedPlayerDevices, Object.GetValidLength() > 0):
            case (Entry):
                # Camera CSD Device:
                -25408 => if (Device := cinematic_sequence_device[Object[PlayerContainer.PlayerIndex]?], set CSDTree[0] = Device):
                    Channel.Print("[ Device Found: Setting up [Camera CSD] ]")


                # HUD Parameters CSD Device:
                -25472 => if (Device := cinematic_sequence_device[Object[PlayerContainer.PlayerIndex]?], set CSDTree[1] = Device):
                    Channel.Print("[ Device Found: Setting up [HUD Parameters CSD] ]")


                # Transitions CSD Device:
                -25536 => if (Device := cinematic_sequence_device[Object[PlayerContainer.PlayerIndex]?], set CSDTree[2] = Device):
                    Channel.Print("[ Device Found: Setting up [Transitions CSD] ]")


                # Additive CSD Device:
                -25600 => if (Device := cinematic_sequence_device[Object[PlayerContainer.PlayerIndex]?], set CSDTree[3] = Device):
                    Channel.Print("[ Device Found: Setting up [Additive CSD] ]")

                
                # Quest Objects 1 CSD Device:
                -25920 => if (Device := cinematic_sequence_device[Object[PlayerContainer.PlayerIndex]?], set QuestObjects[0] = Device):
                    Channel.Print("[ Device Found: Setting up [Quest Objects 1 CSD] ]")
                

                # Quest Objects 2 CSD Device:
                -25984 => if (Device := cinematic_sequence_device[Object[PlayerContainer.PlayerIndex]?], set QuestObjects[1] = Device):
                    Channel.Print("[ Device Found: Setting up [Quest Objects 2 CSD] ]")


                # Quest Objects 3 CSD Device:
                -26048 => if (Device := cinematic_sequence_device[Object[PlayerContainer.PlayerIndex]?], set QuestObjects[2] = Device):
                    Channel.Print("[ Device Found: Setting up [Quest Objects 3 CSD] ]")


                # Quest 1 Tracker Device:
                -26112 => if (Device := tracker_device[Object[PlayerContainer.PlayerIndex]?], set QuestTrackers[0] = Device):
                    Channel.Print("[ Device Found: Setting up [Quest 1 Tracker] ]")
                

                # Quest 2 Tracker Device:
                -26176 => if (Device := tracker_device[Object[PlayerContainer.PlayerIndex]?], set QuestTrackers[1] = Device):
                    Channel.Print("[ Device Found: Setting up [Quest 2 Tracker] ]")


                # Quest 3 Tracker Device:
                -26240 => if (Device := tracker_device[Object[PlayerContainer.PlayerIndex]?], set QuestTrackers[2] = Device):
                    Channel.Print("[ Device Found: Setting up [Quest 3 Tracker] ]")

                _ =>