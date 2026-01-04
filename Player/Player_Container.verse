
using { /Fortnite.com/Game }
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
using { Menus }
using { Lists }
using { Utility }
using { World }


# -----------------------------------------------------------------------------------------------------------------

player_container<public> := class<unique>:

    PlayerIndex<public> : int

    PlayerName<public> : message
    

    # -------------------------------------------------------------------------------------------------------------


    Agent<public> : player

    FortCharacter<public> : fort_character
    
    PlayerUI<public> : player_ui

    Canvas<public> : canvas


    # -------------------------------------------------------------------------------------------------------------


    var PlayerGameData<public> : player_game_data = player_game_data:

    PlayerDevices<public> : player_devices

    PlayerUIManager<public> : player_ui_manager

    var CurrentMenu<public> : ?base_gui_collection = false


    # -------------------------------------------------------------------------------------------------------------


    var PlayerInputs<public> : []event(player_container) = array:

    RemovedPlayerEvent<public> : event() = event():

    var QueuedToField<public> : logic = false
    var IsSafe<public> : logic = false
    var HasBeenEliminated<public> : logic = false

    # -------------------------------------------------------------------------------------------------------------


    Initialize<public>(Game : game_manager)<suspends> : void =
        Print("Initializing Player Container {PlayerIndex}")

        set PlayerInputs = for (Index := 0..13) do event(player_container):

        Load(Self)

        PlayerDevices.Initialize(Game, Self)
        spawn {PlayerUIManager.Initialize(Self)}
        spawn {PlayerGameData.StartPlaytimeCheck(Self)}

        CheckHelmetData(Game)

        for (Beacon : Game.WorldDevices.FieldBeacons):
            Beacon.RemoveFromShowList(Agent)

        Sleep(1.0)
        
        FieldCamera := field_camera_menu_collection{PlayerContainer := Self}
        spawn {FieldCamera.Show()}

        Sleep(1.0)
        spawn {FieldCamera.UpdateCountdown(Game.CountdownLobbyTimer)}

        if (HUD := Game.WorldDevices.PlayerHUDS?[7]):
            HUD.SetText(Game.StreakMessage(PlayerGameData.HighestStreak, PlayerGameData.CurrentStreak))
            HUD.Show(Agent)


        FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

                

    Uninitialize<public>(Game : game_manager) : void =
        Print("Uninitializing Player Container")
        
        if (Array := Game.WorldData.PlayersOnField.RemoveFirstElement[Self]):
            set Game.WorldData.PlayersOnField = Array

        Save(Self)
        
        # Remove player from the container:
        option {set Game.PlayerContainers[PlayerIndex] = false}
            



    OnPlayerEliminated(Result :elimination_result) : void =
        if (Game := GlobalGame[GetSession()]):

            if (Achievement := Game.WorldDevices.Accolades[8]):
                Achievement.Award(Agent)

            if (not Game.WorldData.IsRoundComplete?):
                set HasBeenEliminated = true
                Game.SmallZoneEvent.Signal()
                


                Print("Sending Signal")


    CheckHelmetData<public>(Game : game_manager) : void =
        if (PlayerGameData.HighestStreak >= 10, Switch := Game.WorldDevices.HelmetSwitches[0]):
            Switch.TurnOn(Agent)

        if (PlayerGameData.HighestStreak >= 25, Switch := Game.WorldDevices.HelmetSwitches[1]):
            Switch.TurnOn(Agent)

        if (PlayerGameData.HighestStreak >= 50, Switch := Game.WorldDevices.HelmetSwitches[2]):
            Switch.TurnOn(Agent)

        if (PlayerGameData.HighestStreak >= 75, Switch := Game.WorldDevices.HelmetSwitches[3]):
            Switch.TurnOn(Agent)

        if (PlayerGameData.HighestStreak >= 100, Switch := Game.WorldDevices.HelmetSwitches[4]):
            Switch.TurnOn(Agent)



# Down but not out
# Move items down
# Make only 1 purchase
# set amounts + change cost

# Show timer in lobby
# Goal post
# 30 hud timer change
# Grant coins

# -------------

# End round if all players elimned or made it

# Events

# Make zombies based on level
# Put barrier to stop zombies


# More Zombies
# Faster Zombies
# Smoke Screen
# Tighter push
# 

# 1 Item slot
# Add conditional to eahc vending machine



# Make players in lobby only see round in progress verse text


# INCREASE PLAYER COUNT