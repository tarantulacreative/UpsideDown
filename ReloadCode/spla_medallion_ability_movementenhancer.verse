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

movement_enhancer := class(ability):
    @editable
    MovementDevice : player_movement_settings_device = player_movement_settings_device{}

    @editable
    NeedsActivation : ?movement_activation = false

    CustomStart<override>(Player : player)<suspends> : void =
        Print("Starting power.")
        if (not NeedsActivation?):
            MovementDevice.AddTo(Player)
            ForceEnd.Await()
        else if (Activation := NeedsActivation?):
            race:
                Activation.Begin(Player)
                MedalDropped.Await()
            MovementDevice.AddTo(Player)
            race:
                MedalDropped.Await()
                Activation.Run(Player)

    Stop<override>(Player : player)<suspends> : void =
        MovementDevice.RemoveFrom(Player)

movement_activation := class<unique><concrete>:
    @editable
    LastsFor : type{X : float where X >= 0.0} = 0.0

    Begin<public>(Player : player)<suspends> : void =
        {}

    Run<public>(Player : player)<suspends> : void =
        Print("Running.")
        var TimeLeft : float = LastsFor
        loop:
            if (not Player.IsActive[]) {break}
            Sleep(1.0)
            set TimeLeft -= 1.0
            if (TimeLeft <= 0.0) {break}

healthcheck_movement_activation := class(movement_activation):
    @editable
    BeAtHealth : type{X : float where X >= 1.0} = 10.0

    Begin<override>(Player : player)<suspends> : void =
        if (Character := Player.GetFortCharacter[]):
            loop:
                Sleep(0.25)
                if (not Player.IsActive[]) {break}
                if (Character.GetHealth() <= BeAtHealth):
                    Print("They are below the health.")
                    break