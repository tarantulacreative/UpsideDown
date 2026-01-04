
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

using { Collections }
using { Lists }
using { World }
using { Utility }

# -----------------------------------------------------------------------------------------------------------------

PlayerPointsMessage<public><localizes>(Points : int) : message = "Points: ${Points}"

# -----------------------------------------------------------------------------------------------------------------

player_game_data<public> := class:

    var PlayerState<public> : player_state = player_state.Inactive

    var CurrentStreak<public> : int = 0
    var HighestStreak<public> : int = 0
    var ItemsPurchased<public> : int = 0
        

    CheckCurrentStreakForAchievements<public>(PlayerContainer : player_container) : void =
        if (Game := GlobalGame[GetSession()]):
            case (CurrentStreak):
                1 =>
                    if (Achievement := Game.WorldDevices.Accolades[0]):
                        Achievement.Award(PlayerContainer.Agent)
                5 =>
                    if (Achievement := Game.WorldDevices.Accolades[1]):
                        Achievement.Award(PlayerContainer.Agent)
                10 =>
                    if (Achievement := Game.WorldDevices.Accolades[2]):
                        Achievement.Award(PlayerContainer.Agent)
                25 =>
                    if (Achievement := Game.WorldDevices.Accolades[3]):
                        Achievement.Award(PlayerContainer.Agent)
                50 =>
                    if (Achievement := Game.WorldDevices.Accolades[4]):
                        Achievement.Award(PlayerContainer.Agent)
                75 =>
                    if (Achievement := Game.WorldDevices.Accolades[5]):
                        Achievement.Award(PlayerContainer.Agent)
                100 =>
                    if (Achievement := Game.WorldDevices.Accolades[6]):
                        Achievement.Award(PlayerContainer.Agent)
                _ =>
            


    StartPlaytimeCheck<public>(PlayerContainer : player_container)<suspends> : void =
        var TimeSpentExisting : int = 0

        if (Game := GlobalGame[GetSession()]):
            loop:
                Sleep(60.0)

                set TimeSpentExisting += 1

                case (TimeSpentExisting):
                    5 =>
                        if (Achievement := Game.WorldDevices.Accolades[14]):
                            Achievement.Award(PlayerContainer.Agent)
                    10 =>
                        if (Achievement := Game.WorldDevices.Accolades[15]):
                            Achievement.Award(PlayerContainer.Agent)
                    30 =>
                        if (Achievement := Game.WorldDevices.Accolades[16]):
                            Achievement.Award(PlayerContainer.Agent)
                    60 =>
                        if (Achievement := Game.WorldDevices.Accolades[17]):
                            Achievement.Award(PlayerContainer.Agent)
                    _ =>




MakePlayerGameData<public><constructor>(SourceData : player_save_data)<transacts> := player_game_data:
    CurrentStreak := SourceData.CurrentStreak
    HighestStreak := SourceData.HighestStreak


