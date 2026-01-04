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

health_regenerator := class(ability):
    @editable:
        ToolTip := TT_ApplyFor
    ApplyFor : health_logic = health_logic.Health

    @editable:
        ToolTip := TT_Amount
    Amount : float = 50.0

    @editable:
        ToolTip := TT_ApplyFor
    ApplyOn : apply_type = apply_type{}

    @editable:
        ToolTip := TT_Overtime
    Overtime : ?float = false

    CustomStart<override>(Player : player)<suspends> : void =
        Print("Starting for health regen.")
        ApplyOn.Track(Player)
        if (Character := Player.GetFortCharacter[]):
            race:
                ForceEnd.Await()
                loop:
                    Sleep(0.1)
                    if (not Character.IsActive[]):
                        ForceEnd.Signal()
                    if (not Player.IsActive[]):
                        ForceEnd.Signal()
                loop:
                    ApplyOn.ActivatedEvent.Await()
                    Print("Activated event signalled.")
                    Activate(Player)
                    break
        ApplyOn.StoppedEvent.Signal()

    Stop<override>(Player : player)<suspends> : void =
        ApplyOn.Stop(Player)

    Activate(Player : player)<suspends> : void =
        if (Character := Player.GetFortCharacter[]):
            Print("Got character")
            if (AwaitAmount := Overtime?):
                Print("Overtime is set.")
                var RemainingAmount : float = Amount
                var PerSecond : float = Amount / AwaitAmount
                MaxHealth := Character.GetMaxHealth()
                MaxShield := Character.GetMaxShield()
                if (Character.GetHealth() >= MaxHealth, Character.GetShield() >= MaxShield):
                    return
                race:
                    ForceEnd.Await()
                    loop:
                        Sleep(0.1)
                        if (not Character.IsActive[]):
                            ForceEnd.Signal()
                        if (not Player.IsActive[]):
                            ForceEnd.Signal()
                    loop:
                        CheckApply(Player, PerSecond)
                        set RemainingAmount -= PerSecond
                        if (RemainingAmount <= 0.0):
                            break
                        Sleep(1.0)
            else:
                Print("Overtime was not set")
                MaxHealth := Character.GetMaxHealth()
                MaxShield := Character.GetMaxShield()
                if (Character.GetHealth() >= MaxHealth, Character.GetShield() >= MaxShield):
                    Print("Health is full.")
                    return
                CheckApply(Player, Amount)

    CheckApply(Player : player, GrantAmount : float) : void =
        if (Character := Player.GetFortCharacter[]):
            case (ApplyFor):
                health_logic.Health => GrantHealth(Character, GrantAmount)
                health_logic.Shield => GrantShield(Character, GrantAmount)
                health_logic.Both =>
                    if (Character.GetHealth() < Character.GetMaxHealth()):
                        GrantHealth(Character, GrantAmount)
                    else:
                        GrantShield(Character, GrantAmount)
                health_logic.ApplyToBoth =>
                    GrantHealth(Character, GrantAmount)
                    GrantShield(Character, GrantAmount)
                
    GrantHealth(Character : fort_character, GrantAmount : float) : void =
        Print("Granting health")
        if (Character.GetHealth() >= Character.GetMaxHealth()):
            return
        var AmountToGrant : float = GrantAmount
        RemainingHealth := Character.GetMaxHealth() - Character.GetHealth()
        if (RemainingHealth < GrantAmount):
            set AmountToGrant = RemainingHealth
        if (AmountToGrant <> GrantAmount, ApplyFor = health_logic.Both):
            RemainingAmount := GrantAmount - AmountToGrant
            GrantShield(Character, RemainingAmount)
        Print("Health granted {AmountToGrant}")
        Character.SetHealth(Character.GetHealth() + AmountToGrant)

    GrantShield(Character : fort_character, GrantAmount : float) : void =
        Print("Granting shield")
        if (Character.GetShield() >= Character.GetMaxShield()):
            return
        var AmountToGrant : float = GrantAmount
        RemainingShield := Character.GetMaxShield() - Character.GetShield()
        if (RemainingShield < GrantAmount):
            set AmountToGrant = RemainingShield
        Character.SetShield(Character.GetShield() + AmountToGrant)

apply_type := class<unique><concrete>:
    StoppedEvent : event() = event(){}
    ActivatedEvent : event() = event(){}

    Track(Player : player) : void = {}
    Stop(Player : player) : void = {}

input_apply_type := class(apply_type):
    @editable:
        ToolTip := TT_Input
    Input : input_trigger_device = input_trigger_device{}

    @editable:
        ToolTip := TT_InputType
    InputType : input_trigger_type = input_trigger_type.Pressed

    @editable:
        ToolTip := TT_HoldTime
    HoldTime : ?float = false

    var Cancelables : []cancelable = array{}
    var IsRunning : logic = false

    Track<override>(Player : player) : void =
        set Cancelables = array{}
        Input.Register(Player)
        case (InputType):
            input_trigger_type.Pressed =>
                Cancelable := Input.PressedEvent.Subscribe(HandleActivation)
                set Cancelables += array{Cancelable}
            input_trigger_type.Released =>
                Cancelable := Input.ReleasedEvent.Subscribe(HandleHeldActivation)
                set Cancelables += array{Cancelable}

    Stop<override>(Player : player) : void =
        Input.Unregister(Player)
        for (Cancelable : Cancelables):
            Cancelable.Cancel()
        set Cancelables = array{}

    HandleActivation(Agent : agent) : void =
        if (IsRunning?):
            return
        Print("Activating")
        set IsRunning = true
        ActivatedEvent.Signal()
        if (Player := player[Agent]):
            Stop(Player)

    HandleHeldActivation(Result : tuple(agent, float)) : void =
        Agent := Result(0)
        TimeHeld := Result(1)

        if (Time := HoldTime?):
            if (TimeHeld >= Time):
                Print("Held for correct amount of time.")
                HandleActivation(Agent)
        else:
            Print("Hold time not set, activating on normal release.")
            HandleActivation(Agent)

health_check_apply_type := class(apply_type):
    @editable:
        ToolTip := TT_TrackAmount
    TrackAmount : float = 25.0

    @editable
    TrackType : tracking_type = tracking_type.Both

    Track<override>(Player : player) : void =
        spawn{TrackHealth(Player)}
    
    Stop<override>(Player : player) : void =
        StoppedEvent.Signal()

    TrackHealth(Player : player)<suspends> : void =
        Print("Tracking health")
        if (Character := Player.GetFortCharacter[]):
            race:
                block:
                    StoppedEvent.Await()
                    Print("Stop event happened.")
                loop:
                    Sleep(0.1)
                    if (not Character.IsActive[]):
                        break
                    if (not Player.IsActive[]):
                        break
                loop:
                    var Total : float = 0.0
                    case (TrackType):
                        tracking_type.Both => set Total = Character.GetHealth() + Character.GetShield()
                        tracking_type.Health => set Total = Character.GetHealth()
                        tracking_type.Shield => set Total = Character.GetShield()
                    if (Total <= TrackAmount):
                        ActivatedEvent.Signal()
                        break
                    Sleep(0.5)
            Print("No longer tracking health")

on_elimination_apply_type := class(apply_type):

    var TrackingPlayer : ?player = false
    var Cancelables : []cancelable = array{}
    
    Track<override>(Player : player) : void =
        set TrackingPlayer = option{Player}
        spawn{AwaitElim(Player)}

    Stop<override>(Player : player) : void =
        for (Cancelable : Cancelables):
            Cancelable.Cancel()
        set Cancelables = array{}
        set TrackingPlayer = false
        StoppedEvent.Signal()

    AwaitElim(Player : player)<suspends> : void =
        for (Enemy : creative_device{}.GetPlayspace().GetPlayers(), Enemy <> Player):
            if (Character := Enemy.GetFortCharacter[]):
                Cancelable := Character.EliminatedEvent().Subscribe(HandleElim)
                set Cancelables += array{Cancelable}

    HandleElim(Result : elimination_result) : void =
        if (EliminatingPlayer := player[Result.EliminatingCharacter?.GetAgent[]]):
            if (TrackedPlayer := TrackingPlayer?, EliminatingPlayer = TrackedPlayer):
                ActivatedEvent.Signal()

health_logic := enum:
    Health
    Shield
    Both
    ApplyToBoth

input_trigger_type := enum:
    Pressed
    Released

tracking_type := enum:
    Both
    Health
    Shield


# <> <> <> <> <>
#   TOOL TIPS
# <> <> <> <> <>
TT_ApplyFor<localizes> : message = "Note that Both makes it apply first to health until health is at max, and then the remaining amount to the shield. \nApply To Both, this applies the amount directly to both shield and health."
TT_Amount<localizes> : message = "Set this to the amount of Health/Shield you want to apply."
TT_ApplyOn<localizes> : message = "Select the drop down and choose how you would like for this ability to enable."
TT_Input<localizes> : message = "Set this to an input trigger device and set it to whichever input you would like to register to activate this ability. \nI recommend enabling the option: Consume Input."
TT_InputType<localizes> : message = "Set this to an input trigger device and set it to whichever input you would like to register to activate this ability. \nI recommend enabling the option: Consume Input."
TT_HoldTime<localizes> : message = "Leave this as false if you want any release input to register correctly. \nIf you would like to only enable if the input is pressed for a certain time set that time here."
TT_Overtime<localizes> : message = "Leave this as false if want the health/shield to be granted instantly all at once. \nSet this to a number if you'd like for the health/shield to apply overtime."
TT_TrackAmount<localizes> : message = "Set this to the amount of health the player should be at in total before this power is applied (total amount = Health + Shield), unless stated otherwise"