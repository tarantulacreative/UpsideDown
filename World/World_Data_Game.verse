
using { /Fortnite.com/Devices }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

using { Player }
using { Utility }


current_half<public> := enum{First, Second}

# -----------------------------------------------------------------------------------------------------------------

world_game_data<public> := class<concrete>:

    var WorldState<public> : world_state = world_state.InLobby

    var CurrentRound<public> : int = 1

    var PlayersOnField<public> : []player_container = array:

    var CurrentHalf<public> : current_half = current_half.First

    var InitialTimeAlreadyDisplayed<public> : logic = false

    var IsRoundComplete<public> : logic = false

    var IsReadyToEnter<public> : logic = true