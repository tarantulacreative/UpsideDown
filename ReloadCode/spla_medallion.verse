<# --------------------------------------------------------------------------

                        |||||  ||||   |      |||
                        |      |  |   |     |   |
                        |||||  ||||   |     |||||
                            |  |      |     |   |
                        |||||  |      ||||| |   |  ©

Please note that by using this script you agree to the terms and conditions, and each of my policies available via my Discord Server.
SPLA Discord Server: https://discord.gg/TheSPLAGames

-------------------------------------------------------------------------- #>

# All of the fortnite imports
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }

# All of the verse imports
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

# All of the UnrealEngine imports
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


# Medallion Setup
medallion_manager<public> := class(creative_device):
    @editable
    Medallions:[]medallion = array{}

    @editable
    DefaultClass:class_and_team_selector_device = class_and_team_selector_device{}

    OnBegin<override>()<suspends>:void =
        for (Med : Medallions):
            set Med.DefaultClass = DefaultClass
            spawn{Med.Init()}

medallion<public> := class<concrete><unique>:
    @(/Verse.org/Simulation:)editable_text_box:
        MultiLine := false
        MaxLength := 16
    Name : string = "Medallion Name"

    @editable
    DropInput : input_trigger_device = input_trigger_device{}

    @editable
    Medallion : collectible_object_device = collectible_object_device{}

    @editable
    MedallionMarker : player_marker_device = player_marker_device{}

    @editable
    AbilitySettings:ability = exploding_bullet{}

    @editable
    BuffUpgrade : buff_upgrade = buff_upgrade{}

    @editable
    UISetup : ui_settings = ui_settings{}

    UsesUIManager : uses_ui_manager = uses_ui_manager{}

    MedalDropped : event() = event(){}

    var DefaultClass:class_and_team_selector_device = class_and_team_selector_device{}
    var StartingPoint : transform = transform{}
    var LastPlayer : ?player = false

    Init<public>()<suspends> : void =
        Print("Spawning medallion")
        set StartingPoint = Medallion.GetTransform()
        spawn{AwaitPickup()}
        AbilitySettings.Init()

    AwaitPickup<public>()<suspends> : void =
        Medallion.Show()
        Medallion.RespawnForAll()
        CollectingAgent := Medallion.CollectedEvent.Await()
        if:
            Player := player[CollectingAgent]
        then:
            Pickup(Player)

    Pickup<public>(Player : player) : void =
        AbilitySettings.Cooldown.TimerDevice.Enable(Player)
        AbilitySettings.Reset(Player, LastPlayer)
        set LastPlayer = option{Player}
        DropInput.Register(Player)
        MedallionMarker.Attach(Player)
        Medallion.Hide()
        UsesUIManager.Show(Player, UISetup, AbilitySettings.UsesLeft)
        spawn{PlayerEvents(Player)}
        spawn{ActivatePower(Player)}

    UpdateUsesUI(Player : player)<suspends> : void =
        race:
            MedalDropped.Await()
            loop:
                Sleep(0.1)
                UsesUIManager.UpdateUses(Player, AbilitySettings.UsesLeft)

    Drop<public>(Player : player, ?DropLocation : vector3 = vector3{X := -5000.0, Y := -5000.0, Z := -5000.0}) : void =
        if:
            DropLocation = vector3{X := -5000.0, Y := -5000.0, Z := -5000.0} 
            Player.IsActive[]
            Char := Player.GetFortCharacter[]
            Location := Char.GetTransform()
            Translation := vector3:
                X := Location.Translation.X,
                Y := Location.Translation.Y,
                Z := Location.Translation.Z + 150.0

            Medallion.TeleportTo[Translation, Location.Rotation]
        else if:
            DropLocation <> vector3{X := -5000.0, Y := -5000.0, Z := -5000.0}
            Medallion.TeleportTo[DropLocation, IdentityRotation()]
        else if:
            Medallion.TeleportTo[StartingPoint]

        Print("Medallion dropped")

        AbilitySettings.Cooldown.TimerDevice.Disable(Player)
        UsesUIManager.Hide(Player)
        MedalDropped.Signal()
        AbilitySettings.MedalDropped.Signal()
        MedallionMarker.Detach(Player)
        DefaultClass.ChangeClass(Player)
        BuffUpgrade.Stop(Player)

        DropInput.Unregister(Player)
        spawn{AwaitPickup()}

    PlayerEvents<public>(Player:player)<suspends> : void =
        var LastLocation : vector3 = vector3{}
        if:
            Char := Player.GetFortCharacter[]
        then:
            race:
                loop:
                    Sleep(0.1)
                    if (not Player.IsActive[]):
                        Print("Player left the game.")
                        Drop(Player)
                        break
                loop:
                    Sleep(0.1)
                    if (Char.IsActive[]):
                        set LastLocation = Char.GetTransform().Translation
                block:
                    Result := Char.EliminatedEvent().Await()
                    Print("Player died, dropping the medallion")
                    Drop(Player, ?DropLocation := LastLocation)
                loop:
                    Sleep(0.0)
                    PressedAgent := DropInput.PressedEvent.Await()
                    Print("Checking input")
                    if:
                        PressedPlayer := player[PressedAgent]
                        PressedPlayer = Player
                        Char.IsCrouching[]
                    then:
                        Print("Dropping medallion")
                        Drop(Player)
                        break

    ActivatePower<public>(Player : player)<suspends> : void =
        spawn{AbilitySettings.Start(Player)}
        BuffUpgrade.Activate(Player)

# Abilities Setup        
ability := class<abstract><unique>:
    @editable:
        ToolTip := TT_MedalUses
    Uses<public> : type{_X:int where 0 <= _X} = 0
    
    @editable
    Cooldown<public> : cooldown = cooldown{}

    ForceEnd : event() = event(){}
    RestartEvent : event() = event(){}
    MedalDropped : event() = event(){}

    var UsesLeft<public> : int = 1
    
    Init() : void =
        set UsesLeft = Uses

    Reset(Player : player, LastPlayer : ?player) : void =
        if (Last := LastPlayer?, Player <> LastPlayer):
            set UsesLeft = Uses
            set Cooldown.IsOnCooldown = false
    
    Start(Player : player)<suspends> : void =
        Print("Starting ability.")
        if (not Cooldown.IsOnCooldown?):
            case (Uses):
                0 =>
                    CustomStart(Player)
                    Stop(Player)
                _ =>
                    case (UsesLeft):
                        0 =>
                            race:
                                BeginCooldown(Player)
                                MedalDropped.Await()
                        _ =>
                            set UsesLeft -= 1
                            CustomStart(Player)
                            Stop(Player)
                            if (UsesLeft = 0):
                                race:
                                    BeginCooldown(Player)
                                    MedalDropped.Await()
                            else {spawn{Start(Player)}}

    BeginCooldown(Player : player)<suspends> : void =
        Cooldown.Start(Player)
        set UsesLeft = Uses
        set Cooldown.IsOnCooldown = false
        spawn{Start(Player)}
    
    CustomStart(Player : player)<suspends> : void = {}
    Stop(Player : player)<suspends> : void = {}

cooldown := class<concrete>:
    @editable
    CooldownTime : type{_X : float where 0.0 <= _X} = 0.0
    
    @editable
    TimerDevice : timer_device = timer_device{}

    StopCooldown : event() = event(){}
    
    var IsOnCooldown : logic = false
    
    Start(Player : player)<suspends> : void =
        set IsOnCooldown = true
        TimerDevice.Enable(Player)
        TimerDevice.Reset(Player)
        TimerDevice.SetMaxDuration(CooldownTime)
        TimerDevice.Start(Player)
        race:
            loop:
                Sleep(0.1)
                if (not Player.IsActive[]):
                    StopCooldown.Signal()
                    break
            Sleep(CooldownTime)
        Stop(Player)

    Stop(Player : player)<suspends> : void =
        set IsOnCooldown = false
        TimerDevice.Disable(Player)

# Buff Upgrade
buff_upgrade := class:
    @editable:
        ToolTip := TT_BuffedClass
    BuffedClass : ?class_and_team_selector_device = false

    @editable
    CustomHealth : type{_X : float where _X >= 1.0} = 100.0

    @editable
    CustomShield : type{_X : float where _X >= 1.0} = 100.0

    Activate(Player : player) : void =
        if (Character := Player.GetFortCharacter[]):
            if (Class := BuffedClass?) {Class.ChangeClass(Player)}
            Character.SetMaxHealth(CustomHealth)
            Character.SetMaxShield(CustomShield)
            Character.SetHealth(CustomHealth)
            Character.SetShield(CustomShield)

    Stop(Player : player) : void =
        if (Character := Player.GetFortCharacter[]):
            Character.SetMaxHealth(100.0)
            Character.SetMaxShield(100.0)
            if (Character.GetHealth() > 100.0) {Character.SetHealth(100.0)}
            if (Character.GetShield() > 100.0) {Character.SetShield(100.0)}

# UI Setup
ui_settings := class<concrete>:
    @editable
    ShouldShow : logic = false

    @editable
    Position : ui_placement = ui_placement{}

    @editable
    TextSettings : text_settings = text_settings{}

    @editable
    BackgroundSettings : background_settings = background_settings{}

text_settings := class<concrete>:
    @(/Verse.org/Simulation:)editable_text_box:
        MultiLine := false
        MaxLength := 32
    UsesMessage : string = ""

    @editable
    TextColor : color = NamedColors.Gold

background_settings := class<concrete>:
    @editable
    HasBackground : logic = false

    @editable
    Size : vector2 = vector2{X := 256.0, Y := 64.0}

    @editable
    BackgroundColor : color = NamedColors.Black

    @editable_number(float):
        MinValue := option{0.0}
        MaxValue := option{1.0}
    BackgroundOpacity : type{_X:float where 0.000000 <= _X, _X <= 1.000000} = 1.0

    @editable
    Background : ?texture = false

ui_placement := class<concrete>:
    @editable_slider(float):
        MinValue := option{0.0}
        MaxValue := option{1.0}
        SliderDelta := option{0.1}
        SliderExponent := option{1.0}
        MouseLinearDeltaSensitivity := 0.25
        MouseShiftMovePixelPerDelta := 0.25
    Horizontal : float = 0.0

    @editable_slider(float):
        MinValue := option{0.0}
        MaxValue := option{1.0}
        SliderDelta := option{0.1}
        SliderExponent := option{1.0}
        MouseLinearDeltaSensitivity := 0.25
        MouseShiftMovePixelPerDelta := 0.25
    Vertical : float = 0.0


uses_ui_manager := class:
    var SlotsMap : [player]tuple(?canvas, medal_uses_ui) = map{}

    Show(Player : player, Settings : ui_settings, Uses : int) : void =
        if (Settings.ShouldShow?):
            Screen := medal_uses_ui{}
            Canvas := canvas{}
            Screen.Create(Uses, Settings.TextSettings, Settings.BackgroundSettings)
            Slot := canvas_slot:
                Widget := Screen.GetRootWidget()
                Anchors := anchors{Minimum := vector2{X := Settings.Position.Horizontal, Y := Settings.Position.Vertical}, Maximum := vector2{X := Settings.Position.Horizontal, Y := Settings.Position.Vertical}}
                Offsets := margin{} # We do not need offsets if our anchors are done properly
                Alignment := vector2{X := Settings.Position.Horizontal, Y := Settings.Position.Vertical}
                SizeToContent := true
                ZOrder := 99
            Canvas.AddWidget(Slot)
            if:
                PlayerUI := GetPlayerUI[Player]
                set SlotsMap[Player] = (option{Canvas}, Screen)
            then:
                PlayerUI.AddWidget(Canvas)

    Hide(Player : player) : void =
        if:
            PlayerUI := GetPlayerUI[Player]
            Slots := SlotsMap[Player]
            Canvas := Slots(0)?
        then:
            PlayerUI.RemoveWidget(Canvas)
            option. set SlotsMap[Player] = (false, Slots(1))

    UpdateUses(Player : player, Uses : int)<suspends> : void =
        if (Widget := SlotsMap[Player](1)):
            Widget.UpdateText(Player, Uses)

medal_uses_ui := class:
    UsesText : text_block = text_block{}
    
    var Background : widget = color_block{}
    var RootWidget : widget = overlay{}
    var UsesMessage : string = ""
    var MaxUsage : int = 0

    Create(MaxUses : int, TextSettings : text_settings, BackgroundSettings : background_settings) : void =
        set MaxUsage = MaxUses
        SetupBackground(BackgroundSettings)
        SetupText(TextSettings)
        set RootWidget = overlay:
            Slots := array:
                overlay_slot:
                    Widget := Background
                overlay_slot:
                    Widget := UsesText

    SetupBackground(Settings : background_settings) : void =
        if (Settings.HasBackground?):
            if (Texture := Settings.Background?):
                set Background = texture_block{DefaultImage := Texture, DefaultDesiredSize := Settings.Size}
            else:
                set Background = color_block{DefaultColor := Settings.BackgroundColor, DefaultDesiredSize := Settings.Size, DefaultOpacity := Settings.BackgroundOpacity}

    SetupText(Settings : text_settings) : void =
        UsesText.SetTextColor(Settings.TextColor)
        UsesText.SetText(CreateMessage("{Settings.UsesMessage}   {MaxUsage} / {MaxUsage}"))
        set UsesMessage = Settings.UsesMessage

    GetRootWidget() : widget = RootWidget

    UpdateText(Player : player, Uses : int) : void =
        case (Uses):
            0 => UsesText.SetText(CreateMessage("ACTIVE"))
            _ => UsesText.SetText(CreateMessage("{UsesMessage}   {Uses} / {MaxUsage}"))

    CreateMessage<localizes>(String : string) : message = "{String}"





# --- TOOL TIPS ---
TT_MedalUses<localizes>:message = "0 Uses = This ability will initially run once, setting up the power. Note this should only be set to 0 for powers that should be activated instantly when the medallion is picked up and doesn't require input response. \n> 0 Uses = This will then await for the correct response from the player towards activating this ability, once activated it will remove a use, once no uses are left it will trigger the cooldown."
TT_WaitForNoUses<localizes>:message = "Should we wait until the player has 0 uses remaining of this ability before starting cooldown? \nIf turned off, each use will have it's own cooldown before regenerating."
TT_UsesMessage<localizes>:message = "Leave this blank if you don't want to display anything before the usage count."
TT_OneShotGuns<localizes>:message = "Leave this as false/nothing if you want the one shot effect applied to every weapon. \nThese guns are only registered if OnlyPickaxe is unchecked!"
TT_BuffedClass<localizes>:message = "Leave this as false/nothing if you don't want the player to swap to a specific class."
TT_LastFor<localizes>:message = "Leave this as 0.0 for it to run infinitely with the medallion."