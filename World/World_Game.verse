
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Game }

using { Collections }
using { Menus }
using { Player }
using { Utility }

var GlobalGame<public> : weak_map(session, game_manager) = map:

coin_tag_1<public> := class(tag):
coin_tag_2<public> := class(tag):
coin_tag_3<public> := class(tag):
    
ball_tag_1<public> := class(tag):
ball_tag_2<public> := class(tag):

# -----------------------------------------------------------------------------------------------------------------

game_manager<public> := class<concrete>:

    var PlayerContainers<public> : []?player_container = array:

    var SimulationDevice<public> : creative_device = creative_device:

    TagManager<public> : tag_manager = tag_manager:
        
    @editable
    WorldData<public> : world_game_data = world_game_data:

    @editable
    WorldDevices<public> : world_devices = world_devices:
        
    @editable_slider(int) {MinValue := option {1}, MaxValue := option {24}}
    MaxPlayerCount : int = 1


    TimeForGameTimer<public> : int = 25

    var CoinGroups<public> : [][]collectible_object_device = array{array{}, array{}, array{}}
    var BallGroups<public> : [][]creative_prop = array{array{}, array{}}

    # ---------------------------------------------------------------------


    Initialize<public>(SetupDevice : setup_manager)<suspends> : void = 
        Print("Initializing Game Manager")

        option:
            set PlayerContainers = for (Index := 0..MaxPlayerCount - 1) do false
            set SetupDevice.PlayerDevices = for (Index := 0..MaxPlayerCount - 1) do player_devices:
            set SimulationDevice = SetupDevice
            set GlobalGame[GetSession()] = Self

        TagManager.Initialize(Self)
        

    CountdownLobbyTimer<public> : timer = timer{Time := 30}

    GameOverEvent<public> : event() = event():


    OnEnteringTeleporter<public>(Agent : agent) : void =
        if (PlayerContainer := GetPlayerContainer[PlayerContainers,Agent], WorldData.PlayersOnField.Find[PlayerContainer]):
            option:
                Array := WorldData.PlayersOnField.RemoveFirstElement[PlayerContainer]
                set WorldData.PlayersOnField = Array
        
            set PlayerContainer.HasBeenEliminated = false
            set PlayerContainer.IsSafe = true

            if (HUD := WorldDevices.PlayerHUDS?[7]):
                HUD.SetText(StreakMessage(PlayerContainer.PlayerGameData.HighestStreak, PlayerContainer.PlayerGameData.CurrentStreak))
                HUD.Show(Agent)

            Menu := PlayerContainer.PlayerUIManager
            Menu.Uncollapse()


    OnItemPurchased(Agent : agent) : void =
        if (PlayerContainer := GetPlayerContainer[PlayerContainers, Agent]):
            set PlayerContainer.PlayerGameData.ItemsPurchased += 1
            case (PlayerContainer.PlayerGameData.ItemsPurchased):
                1 =>
                    if (Achievement := WorldDevices.Accolades[9]):
                        Achievement.Award(PlayerContainer.Agent)
                5 =>
                    if (Achievement := WorldDevices.Accolades[10]):
                        Achievement.Award(PlayerContainer.Agent)
                10 =>
                    if (Achievement := WorldDevices.Accolades[11]):
                        Achievement.Award(PlayerContainer.Agent)
                25 =>
                    if (Achievement := WorldDevices.Accolades[12]):
                        Achievement.Award(PlayerContainer.Agent)
                50 =>
                    if (Achievement := WorldDevices.Accolades[13]):
                        Achievement.Award(PlayerContainer.Agent)
                _ =>

            Save(PlayerContainer)

    OnHelmetEquipped(Agent : agent, Item : tuple(int, switch_device)) : void =
        if (PlayerContainer := GetPlayerContainer[PlayerContainers, Agent], VFX := WorldDevices.HelmetVFXs[Item(0)]):
            case (Item(0)):
                0 =>
                    if (PlayerContainer.PlayerGameData.HighestStreak >= 10):
                        VFX.Pickup(PlayerContainer.Agent)

                        for (Index -> S : WorldDevices.EquipSwitches, Index <> Item(0)):
                            S.TurnOff(PlayerContainer.Agent)

                    else Item(1).TurnOff(PlayerContainer.Agent)

                1 =>
                    if (PlayerContainer.PlayerGameData.HighestStreak >= 25):
                        VFX.Pickup(PlayerContainer.Agent)

                        for (Index -> S : WorldDevices.EquipSwitches, Index <> Item(0)):
                            S.TurnOff(PlayerContainer.Agent)

                    else Item(1).TurnOff(PlayerContainer.Agent)

                2 =>
                    if (PlayerContainer.PlayerGameData.HighestStreak >= 50):
                        VFX.Pickup(PlayerContainer.Agent)

                        for (Index -> S : WorldDevices.EquipSwitches, Index <> Item(0)):
                            S.TurnOff(PlayerContainer.Agent)

                    else Item(1).TurnOff(PlayerContainer.Agent)

                3 =>
                    if (PlayerContainer.PlayerGameData.HighestStreak >= 75):
                        VFX.Pickup(PlayerContainer.Agent)

                        for (Index -> S : WorldDevices.EquipSwitches, Index <> Item(0)):
                            S.TurnOff(PlayerContainer.Agent)

                    else Item(1).TurnOff(PlayerContainer.Agent)

                4 =>
                    if (PlayerContainer.PlayerGameData.HighestStreak >= 100):
                        VFX.Pickup(PlayerContainer.Agent)

                        for (Index -> S : WorldDevices.EquipSwitches, Index <> Item(0)):
                            S.TurnOff(PlayerContainer.Agent)

                    else Item(1).TurnOff(PlayerContainer.Agent)

                _ => 



    OnStart<public>()<suspends> : void =
        WorldDevices.TransportToFieldZone.AgentEntersEvent.Subscribe(CheckIfFieldIsReady)
        WorldDevices.FieldTeleporter.EnterEvent.Subscribe(OnEnteringTeleporter)

        for (Spawnpad : WorldDevices.Spawnpads):
            Spawnpad.SpawnedEvent.SubscribeSuspends(OnPlayerSpawnedIn)

        for (Index -> Zone : WorldDevices.BigZones):
            Zone.AgentEntersEvent.SubscribeAgent(OnBigZoneEntered, Index)

        for (Index -> Zone : WorldDevices.SmallZones):
            Zone.AgentEntersEvent.SubscribeAgent(OnSmallZoneEntered, Index)

        for (Index -> Granter : WorldDevices.ItemGranters):
            Granter.ItemGrantedEvent.Subscribe(OnItemPurchased)

        for (Index -> Switch : WorldDevices.EquipSwitches):
            Switch.TurnedOnEvent.SubscribeAgent(OnHelmetEquipped, (Index, Switch))
            Switch.TurnedOffEvent.SubscribeAgent(OnHelmetEquipped, (Index, Switch))
            

        TaggedCoins1 := for (FindableObject : SimulationDevice.FindCreativeObjectsWithTag(coin_tag_1{})) do FindableObject
        TaggedCoins2 := for (FindableObject : SimulationDevice.FindCreativeObjectsWithTag(coin_tag_2{})) do FindableObject
        TaggedCoins3 := for (FindableObject : SimulationDevice.FindCreativeObjectsWithTag(coin_tag_3{})) do FindableObject

        TaggedBalls1 := for (FindableObject : SimulationDevice.FindCreativeObjectsWithTag(ball_tag_1{})) do FindableObject
        TaggedBalls2 := for (FindableObject : SimulationDevice.FindCreativeObjectsWithTag(ball_tag_2{})) do FindableObject

        set CoinGroups += for (CoinGroupIndex -> Objects : array{TaggedCoins1, TaggedCoins2, TaggedCoins3}):
            CoinArray := for (Coin : Objects, Device := collectible_object_device[Coin]) do Device

        set BallGroups += for (BallGroupIndex -> Objects : array{TaggedBalls1, TaggedBalls2}):
            BallArray := for (Ball : Objects, Device := creative_prop[Ball]) do Device

        for (Coins : CoinGroups):
            for (Coin : Coins):
                Coin.CollectedEvent.Subscribe(OnCoinCollected)
        for (Balls : BallGroups):
            for (Ball : Balls):
                Ball.Hide()
            
        var InitialZoneLocation : vector3 = WorldDevices.TransportToFieldZone.GetTransform().Translation
        var DroppedZoneLocation : vector3 = WorldDevices.TransportToFieldZone.GetTransform().Translation
        set DroppedZoneLocation.Z = WorldDevices.TransportToFieldZone.GetTransform().Translation.Z - 64.0

        loop:
            if (WorldData.CurrentHalf = current_half.First):
                WorldDevices.TransportToFieldZone.Enable()
                WorldDevices.TransportToFieldZone.MoveTo(InitialZoneLocation, rotation{}, 0.01)
                GameOverEvent.Signal()
                set WorldData.IsReadyToEnter = true
                WorldDevices.FieldTeleporter.Enable()

                for (Zone : WorldDevices.SmallZonesDisplay1):
                    Zone.Disable()
                for (Zone : WorldDevices.SmallZonesDisplay2):
                    Zone.Enable()

            else:
                for (Zone : WorldDevices.SmallZonesDisplay1):
                    Zone.Enable()
                for (Zone : WorldDevices.SmallZonesDisplay2):
                    Zone.Disable()

            for (Index -> OPPlayerContainer : PlayerContainers, PlayerContainer := OPPlayerContainer?):
                for (IndexA -> Barrier : WorldDevices.FieldBarriers, ProcBarrier := WorldDevices.FieldBarriersAlt[IndexA]):
                    Barrier.RemoveFromIgnoreList(PlayerContainer.Agent)
                    ProcBarrier.RemoveFromIgnoreList(PlayerContainer.Agent)

            if (not WorldData.InitialTimeAlreadyDisplayed?):
                spawn {CountdownLobbyTimer.Start()}

            else spawn {CountdownLobbyTimer.Start(?ForcedTime := option {10})}

            CountdownLobbyTimer.OnCompletedEvent.Await()
            set WorldData.InitialTimeAlreadyDisplayed = true
            set FieldIsReady = false
            WorldDevices.FieldTeleporter.Disable()

            WorldDevices.TransportToFieldZone.Disable()
            WorldDevices.TransportToFieldZone.MoveTo(DroppedZoneLocation, rotation{}, 0.01)
            set WorldData.IsReadyToEnter = false

            Sleep(2.0)

            StartGame()


    OnCoinCollected(Agent : agent) : void =
        WorldDevices.CoinGoldGranter.GrantItem(Agent)
  
        if (Achievement := WorldDevices.Accolades[7]):
            Achievement.Award(Agent)


    RoundTimer<public> :timer = timer{Time := 25}

    StartGame<private>()<suspends> : void =
        Print("Transitioning to field")

        set WorldData.WorldState = world_state.InGame
        set WorldData.IsRoundComplete = false

        for (Index -> InPlayerContainer : PlayerContainers, PlayerContainer := InPlayerContainer?):
            if (PlayerContainer.QueuedToField?):
                CheckIfFieldIsReady(PlayerContainer.Agent)


        for (Index -> PlayerContainer : WorldData.PlayersOnField):
            spawn {HandlePlayerToField(PlayerContainer, Index)}

        for (Coins : CoinGroups):
            for (Coin : Coins):
                Coin.Hide()

            for (Index -> Coin : Shuffle(Coins), Index < 5):
                Coin.RespawnForAll()
                Coin.Show()

        for (Balls : BallGroups):
            for (Ball : Balls):
                Ball.Hide()

            if (Ball := Shuffle(Balls)[0]):
                Ball.Show()

        Sleep(4.0)

        spawn {RoundTimer.Start()}

        for (Button : WorldDevices.ItemButtons):
            Button.Disable()

        var InitialTimerLocation : vector3 = WorldDevices.GameInProgressTimer.GetTransform().Translation
        var RaisedTimerLocation : vector3 = WorldDevices.GameInProgressTimer.GetTransform().Translation
        set RaisedTimerLocation.Z = WorldDevices.GameInProgressTimer.GetTransform().Translation.Z + 512.0

        WorldDevices.GameInProgressTimer.MoveTo(RaisedTimerLocation, WorldDevices.GameInProgressTimer.GetTransform().Rotation, 0.01)
        WorldDevices.GameInProgressTimer.Start()

        for (Index -> PlayerContainer : WorldData.PlayersOnField):
            for (IndexA -> Barrier : WorldDevices.FieldBarriers, ProcBarrier := WorldDevices.FieldBarriersAlt[IndexA]):
                Barrier.AddToIgnoreList(PlayerContainer.Agent)
                ProcBarrier.AddToIgnoreList(PlayerContainer.Agent)

        if:
            Big1 := WorldDevices.BigZones[0]
            Big2 := WorldDevices.BigZones[1]
            Small1 := WorldDevices.SmallZones[0]
            Small2 := WorldDevices.SmallZones[1]

        then:
            if (WorldData.CurrentHalf = current_half.First):
                Big1.Enable()
                Big2.Disable()
                Small1.Disable()
                Small2.Enable()

            else:
                Big1.Disable()
                Big2.Enable()
                Small1.Enable()
                Small2.Disable()

                for (Zone : WorldDevices.SmallZonesDisplay1):
                    Zone.Enable()
                for (Zone : WorldDevices.SmallZonesDisplay2):
                    Zone.Disable()
            

        for (Index -> OPPlayerContainer : PlayerContainers, PlayerContainer := OPPlayerContainer?):
            set PlayerContainer.IsSafe = false
        

        race:
            RoundTimer.OnCompletedEvent.Await()

            loop:
                SmallZoneEvent.Await()

                PlayersStillOnField := for (PlayerContainer : WorldData.PlayersOnField, not PlayerContainer.IsSafe? or PlayerContainer.HasBeenEliminated?):
                    PlayerContainer

                Print("Players Still On Field: {PlayersStillOnField.Length}")

                if (PlayersStillOnField.Length = 0):
                    RoundTimer.Complete()
                    break

                Sleep(0.0)

        if (WorldData.CurrentHalf = current_half.First):
            GameOverEvent.Signal()

        WorldDevices.GameInProgressTimer.MoveTo(InitialTimerLocation, WorldDevices.GameInProgressTimer.GetTransform().Rotation, 0.01)
        WorldDevices.GameInProgressTimer.Reset()

        OnRoundComplete()

        Sleep(2.0)




    OnRoundComplete<public>()<suspends> : void =
        Print("Round Ended")

        set WorldData.IsRoundComplete = true

        if (WorldData.CurrentHalf = current_half.First):
            set FieldIsReady = false
            set WorldData.CurrentHalf = current_half.Second

        else:
            set FieldIsReady = true
            set WorldData.CurrentHalf = current_half.First

        for (Button : WorldDevices.ItemButtons):
            Button.Enable()

        for (Zone : WorldDevices.BigZones):
            Zone.Disable()

        for (Zone : WorldDevices.SmallZones):
            Zone.Disable()

        for (Z : WorldDevices.ZombieSpawners):
            Z.EliminateCreatures()

        for (Balls : BallGroups):
            for (Ball : Balls):
                Ball.Hide()

        for (Index -> PlayerContainer : WorldData.PlayersOnField):
            set PlayerContainer.HasBeenEliminated = false

            for (Beacon : WorldDevices.FieldBeacons):
                Beacon.RemoveFromShowList(PlayerContainer.Agent)

            for (IndexA -> Barrier : WorldDevices.FieldBarriers, ProcBarrier := WorldDevices.FieldBarriersAlt[IndexA]):
                Barrier.RemoveFromIgnoreList(PlayerContainer.Agent)
                ProcBarrier.RemoveFromIgnoreList(PlayerContainer.Agent)

        for (Index -> PlayerContainer : WorldData.PlayersOnField):
            Menu := PlayerContainer.PlayerUIManager

            Save(PlayerContainer)
            
            if (not PlayerContainer.IsSafe?):
                PlayerContainer.FortCharacter.Damage(damage_args{Amount := 200.0, Instigator := false, Source := false})

                spawn {MenuTest(Menu)}
                
            else Menu.Uncollapse()


    MenuTest(Menu : player_ui_manager)<suspends> : void =
        Sleep(3.0)
        Menu.Uncollapse()


        
    OnPlayerSpawnedIn(Agent : agent)<suspends> : void =
        if (PlayerContainer := GetPlayerContainer[PlayerContainers, Agent]):

            for (Beacon : WorldDevices.FieldBeacons):
                Beacon.RemoveFromShowList(PlayerContainer.Agent)

            if (WorldData.PlayersOnField.Find[PlayerContainer]):
                option:
                    Array := WorldData.PlayersOnField.RemoveFirstElement[PlayerContainer]
                    set WorldData.PlayersOnField = Array
            
                set PlayerContainer.HasBeenEliminated = false
                set PlayerContainer.PlayerGameData.CurrentStreak = 0
                set PlayerContainer.IsSafe = true

                if (HUD := WorldDevices.PlayerHUDS?[7]):
                    HUD.SetText(StreakMessage(PlayerContainer.PlayerGameData.HighestStreak, PlayerContainer.PlayerGameData.CurrentStreak))
                    HUD.Show(Agent)

                Sleep(3.0)

                Menu := PlayerContainer.PlayerUIManager
                Menu.Uncollapse()


    OnBigZoneEntered(Agent : agent, Index : int) : void =
        if (PlayerContainer := GetPlayerContainer[PlayerContainers, Agent]):
            if (WorldData.CurrentHalf = current_half.First):
                if (Barrier := WorldDevices.FieldBarriers[0], ProcBarrier := WorldDevices.FieldBarriersAlt[0]):
                    Print("Ignoring Big 1")

                    Barrier.RemoveFromIgnoreList(PlayerContainer.Agent)
                    ProcBarrier.RemoveFromIgnoreList(PlayerContainer.Agent)
    
            else:
                if (Barrier := WorldDevices.FieldBarriers[1], ProcBarrier := WorldDevices.FieldBarriersAlt[1]):
                    Print("Ignoring Big 2")
                    
                    Barrier.RemoveFromIgnoreList(PlayerContainer.Agent)
                    ProcBarrier.RemoveFromIgnoreList(PlayerContainer.Agent)


    StreakMessage<public><localizes>(HighestStreak : int, CurrentStreak : int) : message = "{HighestStreak}\n{CurrentStreak}"

    SmallZoneEvent<public> : event() = event():

    OnSmallZoneEntered(Agent : agent, Index : int) : void =
        if (PlayerContainer := GetPlayerContainer[PlayerContainers, Agent]):
            if (not PlayerContainer.IsSafe?):
                set PlayerContainer.IsSafe = true

                WorldDevices.TouchdownSound.Play(PlayerContainer.Agent)

                PlayerContainer.CheckHelmetData(Self)

                WorldDevices.ScoreTimer.Start(PlayerContainer.Agent)
                WorldDevices.ScoreTimer.Complete(PlayerContainer.Agent)
                WorldDevices.ScoreGoldGranter.GrantItem(Agent)

                if (HUD := WorldDevices.PlayerHUDS?[6]):
                    HUD.Show(PlayerContainer.Agent)

                if (HUD := WorldDevices.PlayerHUDS?[7]):
                    set PlayerContainer.PlayerGameData.CurrentStreak += 1

                    if (PlayerContainer.PlayerGameData.CurrentStreak > PlayerContainer.PlayerGameData.HighestStreak):
                        set PlayerContainer.PlayerGameData.HighestStreak += 1

                    HUD.SetText(StreakMessage(PlayerContainer.PlayerGameData.HighestStreak, PlayerContainer.PlayerGameData.CurrentStreak))
                    HUD.Show(PlayerContainer.Agent)

                SmallZoneEvent.Signal()

                PlayerContainer.PlayerGameData.CheckCurrentStreakForAchievements(PlayerContainer)
                Save(PlayerContainer)

                

            for (IndexA -> Barrier : WorldDevices.FieldBarriers, ProcBarrier := WorldDevices.FieldBarriersAlt[IndexA]):
                Barrier.RemoveFromIgnoreList(PlayerContainer.Agent)
                ProcBarrier.RemoveFromIgnoreList(PlayerContainer.Agent)




    var FieldIsReady : logic = true
    
    CheckIfFieldIsReady(Agent : agent) : void = 
        if (PlayerContainer := GetPlayerContainer[PlayerContainers, Agent]):
            if (FieldIsReady?):
                FieldPosition := 100.0 * ((GetPlayerContainersSize(PlayerContainers) - 1) * 1.0)

                if (PlayerContainer.FortCharacter.TeleportTo[vector3{X := -6188.0, Y := (-358.0 - FieldPosition) + 100.0 * PlayerContainer.PlayerIndex, Z := 8313.2}, PlayerContainer.FortCharacter.GetTransform().Rotation]):

                set WorldData.PlayersOnField += array{PlayerContainer}

                if (Input := WorldDevices.TrackableInputs?[9]):
                    Input.Unregister(PlayerContainer.Agent)

            else:
                if (Input := WorldDevices.TrackableInputs?[9]):
                    Input.Register(PlayerContainer.Agent)

                    set PlayerContainer.QueuedToField = true
                
            


    
    RoundTimeMessage<public><localizes>(Number : int) : message = "{Number}"
    RunMessage<public><localizes> : message = "RUN"

    HandlePlayerToField(PlayerContainer : player_container, Index : int)<suspends> : void =
        Menu := PlayerContainer.PlayerUIManager
        Menu.Collapse()

        if (WorldData.CurrentHalf = current_half.First):
            if (Beacon := WorldDevices.FieldBeacons[1]):
                Beacon.AddToShowList(PlayerContainer.Agent)

        else:
            if (Beacon := WorldDevices.FieldBeacons[0]):
                Beacon.AddToShowList(PlayerContainer.Agent)

        if (TimerHUD := WorldDevices.PlayerHUDS?[3], StaticTimerHUD := WorldDevices.PlayerHUDS?[4]):

            if (CountdownHUD := WorldDevices.PlayerHUDS?[5]):
                for (CountdownIndex := 0..2, Time := 3 - CountdownIndex):
                    CountdownHUD.SetText(RoundTimeMessage(Time))
                    CountdownHUD.Show(PlayerContainer.Agent)

                    Sleep(1.0)

                CountdownHUD.SetText(RunMessage)
                CountdownHUD.Show(PlayerContainer.Agent)

                Sleep(1.0)

                CountdownHUD.Hide(PlayerContainer.Agent)

                TimerHUD.Show(PlayerContainer.Agent)
                Sleep(1.0)

                race:
                    loop:
                        Time := RoundTimer.OnTickEvent.Await()
                        StaticTimerHUD.SetText(RoundTimeMessage(Time))
                        StaticTimerHUD.Show(PlayerContainer.Agent)

                    block:
                        RoundTimer.OnCompletedEvent.Await()
                        WorldDevices.GameInProgressTimer.Reset()
                        StaticTimerHUD.SetText(RoundTimeMessage(TimeForGameTimer))
                        StaticTimerHUD.Hide(PlayerContainer.Agent)
                        TimerHUD.Hide(PlayerContainer.Agent)


            # for (IndexA -> HUD : WorldDevices.PlayerHUDS?):
            #     if (IndexA = 0 or IndexA = 1):
                    
            #     else:
            #         case (IndexA):
            #             2 => HUD.SetText(PlayerPointsMessage(500))
            #             3 => HUD.SetText(WorldZombiesLeftMessage(6))
            #             4 => HUD.SetText(WorldRoundMessage(1))
            #             _ =>

            #         Print("Showing HUD #{IndexA}")
            #         HUD.Show(PlayerContainer.Agent)







# Start with Fixed Point Cam showing timer until next game #

    # Set Timer to 30 seconds - [ New Round starting in 30 ] ✅
        # Show all players who are in game

    # Get all players, transport to field

    # Remove Field Camera from Players


    # ------------------------------------------------------


    # Game Loop:

        # Show round 1 transition

        # Players have 10 seconds to think before being forced out

        # Once left zone, timer starts for elimination

        # Players are safe if they reach the other side
            # Earn more if reached earlier

        # Once all players have reached the zone (or eliminated)

    
    # When all players have been eliminated (or Round 20 has been reached), Match is over! Put all remaining players back into Field Camera.




# Additional Notes:

    # Players should have up to 3 attempts to get past. Players are respawned with Gold glow as invulnerable for 5 seconds.
        # After 3 attempts. Sent back to Field Camera
                












# Bigger Zones: for exiting zones       (Only Uses Exit Event)
# Smaller Zones: for reaching zones     (Only Uses Enter Event)

# 1st Side:
    # Bigger Zone 1 Enabled
    # Bigger Zone 2 Disabled
    
    # Smaller Zone 1 Disabled
    # Smaller Zone 2 Enabled


# 2nd Side:
    # Bigger Zone 1 Disabled
    # Bigger Zone 2 Enabled
    
    # Smaller Zone 1 Enabled
    # Smaller Zone 2 Disabled








# Interrupt if all players make it / are eliminated

# Fix Zombie issue

# Events + vending machines

# HUD Stuff + Sounds





# Save Data
# Zone show
# Disable Conditional Buttons on round start