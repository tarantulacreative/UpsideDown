using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Native }
using { /UnrealEngine.com/Temporary/Diagnostics }

BusConfig<public> := class<concrete>():
    @editable BP_Battlebus : creative_prop = creative_prop{}
    @editable Camera : gameplay_camera_orbit_device = gameplay_camera_orbit_device{}
    @editable MainTeleporter : teleporter_device = teleporter_device{}
    @editable BusMoveSpeed : float = 1024.0

BusRoute<public> := class<concrete>():
    @editable StartProp : ?creative_prop = false
    @editable EndProp : ?creative_prop = false
    @editable HideProp : ?creative_prop = false
    @editable Rotation : rotation = rotation{}
    @editable StartLocation : vector3 = vector3{}
    @editable EndLocation : vector3 = vector3{}
    @editable HideLocation : vector3 = vector3{}

BusTimerClass<public> := class<concrete>():
    @editable StartTimer : timer_device = timer_device{}
    @editable BattlebusReadyTimer : timer_device = timer_device{}
    @editable JumpEjectTimer : timer_device = timer_device{}
    @editable StartTimerDuration : float = 5.0
    @editable BattlebusReadyTimerDuration : float = 5.0
    @editable JumpEjectTimerDuration : float = 15.0

BusAudioClass<public> := class<concrete>():
    @editable StartSFX : audio_player_device = audio_player_device{}
    @editable JumpSFX : audio_player_device = audio_player_device{}
    @editable AmbienceSFX : audio_player_device = audio_player_device{}
    @editable ThanksSFX : audio_player_device = audio_player_device{}

BusAccoladeClass<public> := class<concrete>():
    @editable JumpAccolade : accolades_device = accolades_device{}
    @editable ThanksAccolade : accolades_device = accolades_device{}

BattleBusLogic<public> := class<concrete>():
    @editable BarrierDevice : barrier_device = barrier_device{}
    @editable SpawnIslandMutator : mutator_zone_device = mutator_zone_device{}
    @editable InvincibilityMutator : mutator_zone_device = mutator_zone_device{}
    @editable PlayerSpawners : []player_spawner_device = array{} 
    @editable JumpInputTrigger : input_trigger_device = input_trigger_device{}
 
battle_bus_device := class(creative_device):
    @editable BusRoutes : []BusRoute = array{}
    @editable BusConfigs : []BusConfig = array{}
    @editable BusAudio : BusAudioClass = BusAudioClass{}
    @editable BusTimers : BusTimerClass = BusTimerClass{}
    @editable BusAccolades : BusAccoladeClass = BusAccoladeClass{}
    @editable BusHelper : BattleBusLogic = BattleBusLogic{}

    var CurrentRouteIndex : int = -1
    var CurrentConfigIndex : int = -1
    var IsBusMoving : logic = false
    var EmoteRewardsActive : logic = false
    var AwardedPlayers : [agent]logic = map{}
 
    OnBegin<override>()<suspends>: void =
        BusHelper.JumpInputTrigger.PressedEvent.Subscribe(OnJumpInput)
        BusHelper.SpawnIslandMutator.AgentBeginsEmotingEvent.Subscribe(OnPlayerEmote)
        for (Index := 0..BusConfigs.Length - 1):
            if (Config := BusConfigs[Index]):
                Config.MainTeleporter.TeleportedEvent.Subscribe(OnPlayerTeleported)
        set CurrentRouteIndex = -1
        set CurrentConfigIndex = -1
        set IsBusMoving = false
        set EmoteRewardsActive = false
        set AwardedPlayers = map{}
        for (Index := 0..BusConfigs.Length - 1):
            if (Config := BusConfigs[Index]):
                Config.BP_Battlebus.Hide()
                Config.MainTeleporter.Disable()
        Sleep(0.1) 
        BusHelper.BarrierDevice.Enable()
        BusHelper.InvincibilityMutator.Enable()
        for (Player : GetPlayspace().GetPlayers()):
            BusHelper.JumpInputTrigger.Unregister(Player)
            for (Index := 0..BusConfigs.Length - 1):
                if (Config := BusConfigs[Index]):
        BusAudio.StartSFX.Stop()
        BusAudio.JumpSFX.Stop()
        BusAudio.AmbienceSFX.Stop()  
        BusAudio.ThanksSFX.Stop()
        BusHelper.SpawnIslandMutator.Disable()
        PickRandomRoute()  
        spawn { StartBattlebusSequence() }

    StartBattlebusSequence()<suspends> : void =
        BusTimers.StartTimer.SetMaxDuration(BusTimers.StartTimerDuration)
        BusTimers.StartTimer.Start()
        spawn { WaitAndCallStartComplete(BusTimers.StartTimerDuration) }

    GetLocation(Location : vector3) : vector3 =
        if (Location.X = 0.0 and Location.Y = 0.0 and Location.Z = 0.0):
            return vector3{X := 0.0, Y := 0.0, Z := 0.0}
        return Location

    GetLocation(Prop : ?creative_prop, FallbackLocation : vector3) : vector3 =
        if (ValidProp := Prop?):
            return ValidProp.GetTransform().Translation
        return GetLocation(FallbackLocation)

    PickRandomRoute()<suspends>:void =  
        if (BusRoutes.Length > 0 and BusConfigs.Length > 0):
            RandomRouteIndex := GetRandomInt(0, BusRoutes.Length - 1)
            RandomConfigIndex := GetRandomInt(0, BusConfigs.Length - 1)
            set CurrentRouteIndex = RandomRouteIndex
            set CurrentConfigIndex = RandomConfigIndex    
            if (Route := BusRoutes[CurrentRouteIndex], Config := BusConfigs[CurrentConfigIndex]):
                StartPos := GetLocation(Route.StartProp, Route.StartLocation)
                CurrentBusPos := Config.BP_Battlebus.GetTransform().Translation
                var RetryCount: int = 0
                var TeleportSuccess: logic = false
                loop:
                    if (Config.BP_Battlebus.TeleportTo[StartPos, Route.Rotation]):
                        set TeleportSuccess = true
                        break
                    else:
                        set RetryCount += 1
                        if (RetryCount >= 3):
                            break
                        Sleep(0.1)
                if (TeleportSuccess = true):
                    NewBusPos := Config.BP_Battlebus.GetTransform().Translation
                    Config.BP_Battlebus.Show()
                    TeleporterStartPos := vector3{ X := StartPos.X, Y := StartPos.Y, Z := StartPos.Z - 256.0 }
                    set RetryCount = 0
                    var TeleporterSuccess: logic = false
                    loop:
                        if (Config.MainTeleporter.TeleportTo[TeleporterStartPos, Route.Rotation]):
                            set TeleporterSuccess = true
                            break
                        else:
                            set RetryCount += 1
                            if (RetryCount >= 3):
                                break
                            Sleep(0.1)
                else:

    OnStartTimerComplete(Agent : ?agent) : void =
        BusHelper.SpawnIslandMutator.Enable()
        BusAudio.StartSFX.Play()
        BusAudio.AmbienceSFX.Play()  
        if (CurrentConfigIndex >= 0 and CurrentConfigIndex < BusConfigs.Length):
            if (Config := BusConfigs[CurrentConfigIndex]):
                for (Player : GetPlayspace().GetPlayers()):
                    Config.Camera.AddTo(Player)
                spawn { StartBusFlight(CurrentRouteIndex, CurrentConfigIndex) }
                spawn { MoveTeleporterWithBus(CurrentRouteIndex, CurrentConfigIndex) }  
        BusTimers.BattlebusReadyTimer.SetMaxDuration(BusTimers.BattlebusReadyTimerDuration)
        BusTimers.BattlebusReadyTimer.Start()
        spawn { WaitAndCallReadyComplete(BusTimers.BattlebusReadyTimerDuration) }

    OnBattlebusReadyTimerComplete(Agent : ?agent) : void =
        set EmoteRewardsActive = true
        set AwardedPlayers = map{}
        if (CurrentConfigIndex >= 0 and CurrentConfigIndex < BusConfigs.Length):
            if (Config := BusConfigs[CurrentConfigIndex]):
                Config.MainTeleporter.Enable()
        for (Player : GetPlayspace().GetPlayers()):
            BusHelper.JumpInputTrigger.Register(Player)
        for (Spawner : BusHelper.PlayerSpawners):
            Spawner.Disable()
        BusTimers.JumpEjectTimer.SetMaxDuration(BusTimers.JumpEjectTimerDuration)
        BusTimers.JumpEjectTimer.Start()
        spawn { WaitAndCallJumpEjectComplete(BusTimers.JumpEjectTimerDuration) }

    WaitAndCallStartComplete(Duration : float)<suspends> : void =
        if (Duration > 0.0):
            Sleep(Duration)
        OnStartTimerComplete(false)

    WaitAndCallReadyComplete(Duration : float)<suspends> : void =
        if (Duration > 0.0):
            Sleep(Duration)
        OnBattlebusReadyTimerComplete(false)

    WaitAndCallJumpEjectComplete(Duration : float)<suspends> : void =
        if (Duration > 0.0):
            Sleep(Duration)
        OnJumpEjectTimerComplete(false)

    OnJumpEjectTimerComplete(Agent : ?agent) : void =
        BusAudio.AmbienceSFX.Stop()
        if (CurrentConfigIndex >= 0 and CurrentConfigIndex < BusConfigs.Length):
            if (Config := BusConfigs[CurrentConfigIndex]):
                Config.Camera.RemoveFromAll()
        spawn{OnJumpEject()}

    StartBusFlight(RouteIndex : int, ConfigIndex : int)<suspends> : void =
        if (RouteIndex >= 0 and RouteIndex < BusRoutes.Length and ConfigIndex >= 0 and ConfigIndex < BusConfigs.Length):
            if (Route := BusRoutes[RouteIndex]):
                if (Config := BusConfigs[ConfigIndex]):
                    StartPos := GetLocation(Route.StartProp, Route.StartLocation)
                    EndPos := GetLocation(Route.EndProp, Route.EndLocation)
                    CurrentBusPos := Config.BP_Battlebus.GetTransform().Translation  
                    DesiredCruise := BusTimers.BattlebusReadyTimerDuration + BusTimers.JumpEjectTimerDuration
                    MoveDistance := Distance(StartPos, EndPos)
                    var MoveDuration : float = DesiredCruise
                    if (MoveDuration <= 0.0 and Config.BusMoveSpeed > 0.0):
                        set MoveDuration = MoveDistance / Config.BusMoveSpeed
                    set IsBusMoving = true
                    spawn { LogBusPosDuringMove(ConfigIndex, MoveDuration) }
                    Config.BP_Battlebus.MoveTo(EndPos, Route.Rotation, MoveDuration)
                    Sleep(MoveDuration)
                    set IsBusMoving = false
                    FinalBusPos := Config.BP_Battlebus.GetTransform().Translation

    LogBusPosDuringMove(ConfigIndex : int, Duration : float)<suspends> : void =
        if (ConfigIndex >= 0 and ConfigIndex < BusConfigs.Length, Config := BusConfigs[ConfigIndex]):
            var Elapsed : float = 0.0
            loop:
                if (Elapsed >= Duration or IsBusMoving = false):
                    break
                Sleep(1.0)
                set Elapsed = Elapsed + 1.0
                Pos := Config.BP_Battlebus.GetTransform().Translation
                Print("[BattleBus] Bus pos X={Pos.X} Y={Pos.Y} Z={Pos.Z}")

    MoveTeleporterWithBus(RouteIndex : int, ConfigIndex : int)<suspends> : void =
        if (RouteIndex >= 0 and RouteIndex < BusRoutes.Length and ConfigIndex >= 0 and ConfigIndex < BusConfigs.Length):
            if (Route := BusRoutes[RouteIndex]):
                if (Config := BusConfigs[ConfigIndex]):
                    StartPos := GetLocation(Route.StartProp, Route.StartLocation)
                    EndPos := GetLocation(Route.EndProp, Route.EndLocation)               
                    TeleporterEndPos := vector3{X := EndPos.X, Y := EndPos.Y, Z := EndPos.Z - 256.0}
                    DesiredCruise := BusTimers.BattlebusReadyTimerDuration + BusTimers.JumpEjectTimerDuration
                    MoveDistance := Distance(StartPos, EndPos)
                    var MoveDuration : float = DesiredCruise
                    if (MoveDuration <= 0.0 and Config.BusMoveSpeed > 0.0):
                        set MoveDuration = MoveDistance / Config.BusMoveSpeed
                    Config.MainTeleporter.MoveTo(TeleporterEndPos, Route.Rotation, MoveDuration)
                    Sleep(MoveDuration)

    OnJumpInput(Agent : agent) : void =
        if (CurrentConfigIndex >= 0 and CurrentConfigIndex < BusConfigs.Length):
            if (Config := BusConfigs[CurrentConfigIndex]):
                Config.MainTeleporter.Teleport(Agent)
                BusHelper.JumpInputTrigger.Unregister(Agent)
                BusAccolades.JumpAccolade.Award(Agent)

    OnPlayerEmote(Agent : agent) : void =
        if (BusHelper.SpawnIslandMutator.IsInVolume[Agent]):
            if (EmoteRewardsActive = true):
                if (not AwardedPlayers[Agent]?):
                    if (set AwardedPlayers[Agent] = true):
                        BusAccolades.ThanksAccolade.Award(Agent)
                        BusAudio.ThanksSFX.Play()

    OnPlayerTeleported(Agent : agent) : void =
        if (CurrentConfigIndex >= 0 and CurrentConfigIndex < BusConfigs.Length):
            if (Config := BusConfigs[CurrentConfigIndex]):
                Config.Camera.RemoveFrom(Agent)
        BusAudio.JumpSFX.Play()

    OnJumpEject()<suspends> : void =
        set EmoteRewardsActive = false
        set AwardedPlayers = map{}
        if (CurrentConfigIndex >= 0 and CurrentConfigIndex < BusConfigs.Length):
            if (Config := BusConfigs[CurrentConfigIndex]):
                for (Player : GetPlayspace().GetPlayers()):
                    if (BusHelper.SpawnIslandMutator.IsInVolume[Player]):
                        Config.MainTeleporter.Teleport(Player)
                Sleep(0.2)
                for (Player : GetPlayspace().GetPlayers()):
                    if (BusHelper.SpawnIslandMutator.IsInVolume[Player]):
                        Config.MainTeleporter.Teleport(Player)
                Sleep(0.5)
                Config.MainTeleporter.Disable()
                BusHelper.SpawnIslandMutator.Disable()
                BusHelper.BarrierDevice.Disable()
                Config.Camera.RemoveFromAll()
                for (Player : GetPlayspace().GetPlayers()):
                    BusHelper.JumpInputTrigger.Unregister(Player)
                spawn{MoveBus(CurrentRouteIndex, CurrentConfigIndex)}

    MoveBus(RouteIndex : int, ConfigIndex : int)<suspends> : void =
        if (RouteIndex >= 0 and RouteIndex < BusRoutes.Length and ConfigIndex >= 0 and ConfigIndex < BusConfigs.Length):
            if (Route := BusRoutes[RouteIndex]):
                if (Config := BusConfigs[ConfigIndex]):
                    HidePos := GetLocation(Route.HideProp, Route.HideLocation)
                    CurrentPos := Config.BP_Battlebus.GetTransform().Translation
                    MoveDistance := Distance(CurrentPos, HidePos)
                    var MoveDuration: float = 0.0
                    if (Config.BusMoveSpeed > 0.0):
                        set MoveDuration = MoveDistance / Config.BusMoveSpeed
                    else:
                        set MoveDuration = 0.0
                    Config.BP_Battlebus.MoveTo(HidePos, Route.Rotation, MoveDuration)
                    #if (MoveDuration > 0.0):
                    #    Sleep(MoveDuration)
                    Config.BP_Battlebus.Hide()
                    BusHelper.InvincibilityMutator.Disable()