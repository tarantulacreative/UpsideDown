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



# Aimbot
aimbot := class(ability):
    @editable
    ThirdPersonControls : gameplay_controls_third_person_device = gameplay_controls_third_person_device{}

    @editable
    LastFor : type{_X : float where _X >= 0.0} = 0.0

    @editable
    SignalRemoteSetup : ?signal_remote_setup = false

    @editable
    InputSetup : ?input_trigger_device = false

    CustomStart<override>(Player : player)<suspends> : void =
        if (SignalRemote := SignalRemoteSetup?):
            AwaitSignal(Player)
        if (Input := InputSetup?):
            AwaitInput(Player)
        if (not InputSetup?, not SignalRemoteSetup?):
            race:
                ForceEnd.Await()
                loop:
                    Activate(Player)
                    if (LastFor = 0.0) {ForceEnd.Await()}

    Stop<override>(Player : player)<suspends> : void =
        Print("Stopping aimbot medal ability")
        ThirdPersonControls.RemoveFrom(Player)
        if (Setup := InputSetup?) {Setup.Unregister(Player)}
        ForceEnd.Signal()

    AwaitSignal(Player : player)<suspends> : void =
        if (Setup := SignalRemoteSetup?):
            Setup.SignalRemoteGranter.GrantItem(Player)
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
                        Sleep(0.02)
                        Agent := Setup.SignalRemoteManager.PrimarySignalEvent.Await()
                        if (PressedPlayer := player[Agent], PressedPlayer = Player):
                            Activate(Player)
                    loop:
                        Sleep(0.02)
                        Agent := Setup.SignalRemoteManager.SecondarySignalEvent.Await()
                        if (PressedPlayer := player[Agent], PressedPlayer = Player):
                            Activate(Player)
                Print("No longer awaiting signal")

    AwaitInput(Player : player)<suspends> : void =
        if (Setup := InputSetup?):
            Setup.Register(Player)
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
                        Sleep(0.02)
                        Agent := Setup.PressedEvent.Await()
                        if (PressedPlayer := player[Agent], PressedPlayer = Player):
                            Activate(Player)

    Activate(Player : player)<suspends> : void =
        if (LastFor = 0.0):
            ThirdPersonControls.AddTo(Player)
        else:
            ThirdPersonControls.AddTo(Player)
            race:
                block:
                    ForceEnd.Await()
                    ThirdPersonControls.RemoveFrom(Player)
                block:
                    Sleep(LastFor)
                    ThirdPersonControls.RemoveFrom(Player)
                    Cooldown.Start(Player)

signal_remote_setup := class<concrete>:
    @editable
    SignalRemoteGranter : item_granter_device = item_granter_device{}

    @editable
    SignalRemoteManager : signal_remote_manager_device = signal_remote_manager_device{}