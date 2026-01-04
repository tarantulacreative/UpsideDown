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



# Dash ability setup
dash := class(ability):
    @editable
    DashModulator : movement_modulator_device = movement_modulator_device{}

    @editable
    JumpInput : input_trigger_device = input_trigger_device{}

    @editable
    DashDelay : type{_X : float where _X >= 0.0} = 0.0

    CustomStart<override>(Player : player)<suspends> : void =
        Print("Starting power.")
        JumpInput.Register(Player)
        AwaitInput(Player)

    Stop<override>(Player : player)<suspends> : void =
        Print("Stopping power.")
        JumpInput.Unregister(Player)
        ForceEnd.Signal()

    AwaitInput(Player : player)<suspends> : void =
        Print("Awaiting jump input")
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
                    Agent := JumpInput.PressedEvent.Await()
                    Print("Jump pressed")
                    if (PressedPlayer := player[Agent], PressedPlayer = Player, Character.IsInAir[]):
                        Sleep(0.05)
                        if (Character.IsFalling[]):
                            ApplyDash(Player)
                            break

    ApplyDash(Player : player)<suspends> : void =
        Print("Applying dash")
        if (Character := Player.GetFortCharacter[]):
            Rotation := Character.GetViewRotation()
            if (DashModulator.TeleportTo[DashModulator.GetTransform().Translation, Rotation]):
                Sleep(0.025)
                DashModulator.Activate(Player)
        Sleep(DashDelay)