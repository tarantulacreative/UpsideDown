
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Verse.org/Colors }

using { Player }
using { Utility }

# -----------------------------------------------------------------------------------------------------------------

# Player Messages:
PlayerAddedMessage<localizes><public>(Agent : message, PlayerIndex : int) : message = "{Agent} added to Slot: {PlayerIndex}"
PlayerRemovedMessage<localizes><public>(Agent : message) : message = "{Agent} has been removed from session."
PlayerDisconnectMessage<localizes><public>(Agent : message) : message = "{Agent} has taken too long to join the session."


# -----------------------------------------------------------------------------------------------------------------

setup_manager<public> := class(creative_device):

    var PlayerDevices<public> : []player_devices = array:

    var WorldDevices<public> : world_devices = world_devices:

    var JoinInProgressDelay<private> : float = 0.0

    
    @editable
    Game<private> : game_manager = game_manager:


    # ---------------------------------------------------------------------


    # On World Initialized:
    OnBegin<override>()<suspends> : void =
        Initialize()
        spawn {Game.OnStart()}
        
        Sleep(5.0)
        set JoinInProgressDelay = 5.0



    # Handle the initialization of world subscriptions: 
    HandleWorldSubscriptions<private>(Playspace : fort_playspace) : void =
        Playspace.PlayerAddedEvent().SubscribeSuspends(HandlePlayerAdded)
        Playspace.PlayerRemovedEvent().Subscribe(HandlePlayerRemoved)



    # Handle Setup of World and Players:
    Initialize<private>()<suspends> : void =
        Playspace := GetPlayspace()
        Players := Playspace.GetPlayers()

        HandleWorldSubscriptions(Playspace)
        Game.Initialize(Self)

        for (InPlayer : Players, Agent := agent[InPlayer]):
            spawn {HandlePlayerAdded(InPlayer)}

        spawn {Game.WorldDevices.Initialize(Game, WorldDevices)}

            

    # ---------------------------------------------------------------------


    # When Player joins the session:
    HandlePlayerAdded<private>(Agent : agent)<suspends> : void =
        PlayerJoiningEvent : event() = event():

        var CancelJoinEvent : logic = false

        race:
            block:
                loop:
                    if (FortCharacter := Agent.GetFortCharacter[], FortCharacter.IsActive[]):
                        PlayerJoiningEvent.Signal()
                        break
            
                    Sleep(0.1)
            
            block:
                PlayerJoiningEvent.Await()
                Sleep(0.0)

            block:
                Sleep(300.0)    # If Agent takes too long to join:

                if (InPlayer := player[Agent]):
                    Print("Player took to long to join")
                    InPlayer.SendToLobby()

                return

        InitializePlayer(Agent)



    # When Player leaves the session:
    HandlePlayerRemoved<private>(Agent : agent) : void =
        for (PlayerIndex -> StoredContainer : Game.PlayerContainers):
            if (PlayerContainer := StoredContainer?, PlayerContainer.Agent = Agent):
                PlayerContainer.RemovedPlayerEvent.Signal()
                OnPlayerRemoved(PlayerContainer)
                return



    InitializePlayer<private>(Agent : agent)<suspends> : void =   
        for (PlayerIndex -> StoredContainer : Game.PlayerContainers):
            if (not StoredContainer?):
                if:
                    InPlayer := player[Agent]
                    FortCharacter := InPlayer.GetFortCharacter[]
                    PlayerUI := GetPlayerUI[InPlayer]
                    PlayerPackage := PlayerDevices[PlayerIndex]

                then:   
                    PlayerContainer := player_container:
                        PlayerIndex     :=  PlayerIndex
                        PlayerName      :=  SetName(Agent)
                        Agent           :=  InPlayer
                        FortCharacter   :=  FortCharacter
                        Canvas          :=  canvas:
                        PlayerUI        :=  PlayerUI
                        PlayerDevices   :=  PlayerPackage
                        PlayerUIManager :=  player_ui_manager:

                    option {not PlayerSaveData[InPlayer], set PlayerSaveData[InPlayer] = player_save_data{}}

                    if (set Game.PlayerContainers[PlayerIndex] = option {PlayerContainer}):
                        Sleep(JoinInProgressDelay)
                        OnPlayerAdded(PlayerContainer)
                        return

                    else Err("Failed to store player properly!")

                        
            else if (StoredContainer?.Agent = Agent) then return
    


    # Once Player is added to the session:
    OnPlayerAdded<private>(PlayerContainer : player_container)<suspends> : void =
        Print(PlayerAddedMessage(PlayerContainer.PlayerName, PlayerContainer.PlayerIndex))

        spawn {PlayerContainer.Initialize(Game)}



    # When Player is being removed from the session:
    OnPlayerRemoved<private>(PlayerContainer : player_container) : void =
        Print(PlayerRemovedMessage(PlayerContainer.PlayerName))

        PlayerContainer.Uninitialize(Game)


# -----------------------------------------------------------------------------------------------------------------

