
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

using { Player }
using { Utility }


# -----------------------------------------------------------------------------------------------------------------

PressedInputMessage<localizes><public>(Input : string) : message = "Pressed Input: {Input}"
ReleasedInputMessage<localizes><public>(Input : string, HeldTime : float) : message = "Released Input: {Input} after {HeldTime}"


# -----------------------------------------------------------------------------------------------------------------

world_devices<public> := class<concrete>:

    Channel<private> : log = log{Channel := DeviceLog}
    

    @editable
    var ModeDetector<public> : ?accolades_device = false

    @editable
    var DebugMessages<public> : ?[]elimination_feed_device = false

    @editable
    var PlayerHUDS<public> : ?[]hud_message_device = false    

    @editable
    var Transporter<public> : ?teleporter_device = false

    @editable
    var TrackableInputs<public> : ?[]input_trigger_device = false

    @editable
    var AudioTracks<public> : ?audio_manager = false


    @editable
    var ThirdPersonController<public> : ?gameplay_controls_third_person_device = false

 
    @editable
    var PlayerCamera<public> : ?gameplay_camera_orbit_device = false


    # ---------------------------------------------------------------------

    @editable
    RoundDevice<public> : round_settings_device = round_settings_device:

    @editable
    ZombieSpawners<public> : []creature_spawner_device = array:

    @editable
    LobbySpawnpoint<public> : creative_prop = creative_prop:

    @editable
    FieldBarriers<public> : []barrier_device = array:

    @editable
    FieldBarriersAlt<public> : []barrier_device = array:

    @editable
    MusicTrack<public> : radio_device = radio_device:

    @editable
    TransportToFieldZone<public> : mutator_zone_device = mutator_zone_device:


    @editable
    BigZones<public> : []mutator_zone_device = array:

    @editable
    SmallZones<public> : []mutator_zone_device = array:

    @editable
    Spawnpads<public> : []player_spawner_device = array:

    @editable
    GameInProgressTimer<public> : timer_device = timer_device:

    @editable
    ScoreTimer<public> : timer_device = timer_device:

    @editable
    CoinGoldGranter<public> : item_granter_device = item_granter_device:
    @editable
    ScoreGoldGranter<public> : item_granter_device = item_granter_device:

    @editable
    SmallZonesDisplay1<public> : []mutator_zone_device = array:
    @editable
    SmallZonesDisplay2<public> : []mutator_zone_device = array:


    @editable
    ItemButtons<public> : []conditional_button_device = array:

    @editable
    Accolades<public> : []accolades_device = array:

    @editable
    ItemGranters<public> : []item_granter_device = array:

    @editable
    HelmetSwitches<public> : []switch_device = array:

    @editable
    EquipSwitches<public> : []switch_device = array:

    @editable
    HelmetVFXs<public> : []visual_effect_powerup_device = array:

    @editable
    HelmetClearer<public> : visual_effect_powerup_device = visual_effect_powerup_device:

    @editable
    FieldBeacons<public> : []beacon_device = array:

    @editable
    TouchdownSound<public> : audio_player_device = audio_player_device:

    @editable
    FieldTeleporter<public> : teleporter_device = teleporter_device:

    # Survived 1 round.
    # Survived 5 Rounds in a row.
    # Survived 10 Rounds in a row.
    # Survived 25 Rounds in a row.
    # Survived 50 Rounds in a row.
    # Survived 75 Rounds in a row.
    # Survived 100 Rounds in a row.

    # Failed to survive
    # Collected a Coin!

    # Purchase 1 Item
    # Purcahse 5 Items
    # Purchase 10 Items
    # Purchase 25 Items
    # Purchase 50 Items
    
    # Played for 5 mins
    # Played for 10 mins
    # Played for 30 mins
    # Played for 60 mins
    # Played for 60 mins






    # ---------------------------------------------------------------------


    Initialize<public>(Game : game_manager, TaggedDevices : world_devices)<suspends> : void =
        SetDevices(Game)

        sync:
            CheckMode(Game)
            InitializeInputs(Game)

            Sleep(Inf)



    SetDevices<private>(Game : game_manager)<suspends> : void =
        var AudioManager : ?audio_manager = false

        if (not AudioTracks?):
            set AudioManager = option {audio_manager{}}

        defer:
            if (AudioManager?):
                set AudioTracks = AudioManager

        # InitialPlatformPosition := Game.TagManager.InitialPlatformPosition.X

        # Print("InitialPlatformPosition {InitialPlatformPosition}")

        for (Key -> Object : Game.TagManager.TaggedWorldDevices, Object.GetValidLength() > 0):
        

            # -1344
            # if (Value := Int[InitialPlatformPosition + (-64.0 * 21.0)]):
            #     if (Index := Mod[Int[InitialPlatformPosition - (InitialPlatformPosition + (-64.0 * 21.0))], 64]): 
                    # Print("Index TestA {Index}")

                
            case (Key):
                -25408 => # Mode Detector Device:
                    if (not ModeDetector?, Device := accolades_device[Object[0]?]):
                        set ModeDetector = option {Device}
                        Channel.Print("[ Device Found: Overriding [Mode Detector] ]")


                
                -25472 => # Debug Messages Device:
                    if (not DebugMessages?):
                        Devices := for (Index -> CastableDevice : Object, Device := elimination_feed_device[CastableDevice?]) do Device
                        set DebugMessages = option {Devices}
                        Channel.Print("[ Device Found: Overriding [Debug Messages] ]")


                
                -25536 => # Player HUDS Device:
                    if (not PlayerHUDS?):
                        Devices := for (Index -> CastableDevice : Object, Device := hud_message_device[CastableDevice?]) do Device
                        set PlayerHUDS = option {Devices}
                        Channel.Print("[ Device Found: Overriding [Player HUDS] ]")


                
                -25600 => # Transporter Device:
                    if (not Transporter?, Device := teleporter_device[Object[0]?]):
                        set Transporter = option {Device}
                        Channel.Print("[ Device Found: Overriding [Transporter] ]")



                -25664 => # Trackable Inputs Device:
                    if (not TrackableInputs?):
                        Devices := for (Index -> CastableDevice : Object, Device := input_trigger_device[CastableDevice?]) do Device
                        set TrackableInputs = option {Devices}
                        Channel.Print("[ Device Found: Overriding [Trackable Inputs] ]")



                -25728 =>
                    if (not AudioTracks?):
                        RadioDevices := for (Index -> CastableDevice : Object, Device := radio_device[CastableDevice?]) do Device

                        if (Tracks := AudioManager?):
                            Tracks.SetRadioDevices(RadioDevices)
                            
                            Channel.Print("[ Device Found: Overriding [Audio Manager [Radios]] ]")



                -25792 =>
                    if (not AudioTracks?):
                        AudioDevices := for (Index -> CastableDevice : Object, Device := audio_player_device[CastableDevice?]) do Device

                        if (Tracks := AudioManager?):
                            Tracks.SetAudioDevices(AudioDevices)
                                
                            Channel.Print("[ Device Found: Overriding [Audio Manager [Audios]] ]")

                
                -25920 =>
                    if (not ThirdPersonController?, Device := gameplay_controls_third_person_device[Object[0]?]):
                        set ThirdPersonController = option {Device}
                        Channel.Print("[ Device Found: Overriding [Third Person Controller] ]")

                        

                -25984 =>
                    if (not PlayerCamera?, Device := gameplay_camera_orbit_device[Object[0]?]):
                        set PlayerCamera = option {Device}
                        Channel.Print("[ Device Found: Overriding [Player Camera] ]")


                _ =>



    # -----------------------------------------------------------------------------------------------------------------

    CheckMode<private>(Game : game_manager)<suspends> : void =
        if:
            PlayerContainer := Game.PlayerContainers[0]?
            Detector := ModeDetector?
            InEditResponse := DebugMessages?[0]
            InPublicResponse := DebugMessages?[1]

        then:
            race:
                block:
                    Detector.TestAwardEvent.Await()
                    InEditResponse.Activate()
                    return

                block:
                    Detector.Award(PlayerContainer.Agent)

                    Sleep(1.0) 
                    InPublicResponse.Activate()



    InitializeInputs<private>(Game : game_manager)<suspends> : void = 
        PressedEvents  : []listenable(agent)               = for (Index -> Input : TrackableInputs?) do Input.PressedEvent
        ReleasedEvents : []listenable(tuple(agent, float)) = for (Index -> Input : TrackableInputs?) do Input.ReleasedEvent

        loop:
            race:
                if (PressedEvents.Length > 0):
                    InputResult := PressedEvents.Race()
                    
                    if (PlayerContainer := GetPlayerContainer[Game.PlayerContainers, InputResult(0)?]):
                        SendInput(InputResult(1), input_type.Pressed, PlayerContainer)

                else Sleep(Inf)


                if (ReleasedEvents.Length > 0):
                    InputResult := ReleasedEvents.Race()
                    
                    if (PlayerContainer := GetPlayerContainer[Game.PlayerContainers, InputResult(0)?(0)], HeldTime := InputResult(0)?(1)):
                        SendInput(InputResult(1), input_type.Released, PlayerContainer, ?HeldTime := HeldTime)

                else Sleep(Inf)


            Sleep(-1.0)


            
    # -----------------------------------------------------------------------------------------------------------------

    SendInput<private>(Input : int, Type : input_type, PlayerContainer : player_container, ?HeldTime : float = 0.0) : void =
        if (InputEvent := PlayerContainer.PlayerInputs[Input]):

            case (Type):
                input_type.Pressed =>
                    # Print(PressedInputMessage(ToText(Input)))

                    InputEvent.Signal(PlayerContainer)


                input_type.Released =>
                    # Print(ReleasedInputMessage(ToText(Input), HeldTime))

                    InputEvent.Signal(PlayerContainer)

                    if (PlayerContainer.QueuedToField?):
                        if (HeldTime >= 0.4):
                            set PlayerContainer.QueuedToField = false

                            if (Game := GlobalGame[GetSession()], InputA := Game.WorldDevices.TrackableInputs?[9]):
                                InputA.Unregister(PlayerContainer.Agent)

