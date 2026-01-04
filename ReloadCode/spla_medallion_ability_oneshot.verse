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



# One Shot pickaxe
one_shot := class(ability):
    @editable
    OnlyPickaxe : logic = false

    @editable:
        ToolTip := TT_OneShotGuns
    OneShotGuns : ?[]conditional_button_device = false

    var Guns : []conditional_button_device = array{}

    CustomStart<override>(Player : player)<suspends> : void =
        if (not OnlyPickaxe?):
            for (ActualGun : OneShotGuns?) {set Guns += array{ActualGun}}
        AwaitEnemy(Player)
        ForceEnd.Await()

    Stop<override>(Player : player)<suspends> : void =
        ForceEnd.Signal()

    AwaitEnemy(Player : player)<suspends> : void =
        for (Enemy : creative_device{}.GetPlayspace().GetPlayers(), Enemy <> Player):
            spawn{AwaitEnemyDamage(Player, Enemy)}

    AwaitEnemyDamage(Player : player, Enemy : player)<suspends> : void =
        if (Character := Enemy.GetFortCharacter[]):
            race:
                ForceEnd.Await()
                loop:
                    Sleep(0.1)
                    if (not Enemy.IsActive[]) {break}
                loop:
                    Sleep(0.02)
                    Result := Character.DamagedEvent().Await()
                    if (OnlyPickaxe?, Result.Amount = 20.0):
                        Print("Pickaxe damage.")
                        Activate(Player, Enemy, Result)
                    else if (not OnlyPickaxe?, Guns.Length > 0, GunCheck[Player]):
                        Print("Damaged with specific gun.")
                        Activate(Player, Enemy, Result)
                    else if (not OnlyPickaxe?, Guns.Length = 0):
                        Print("Damage with any weapon or item.")
                        Activate(Player, Enemy, Result)
                loop:
                    Sleep(0.02)
                    Result := Character.DamagedShieldEvent().Await()
                    if (OnlyPickaxe?, Result.Amount = 20.0):
                        Print("Pickaxe damage.")
                        Activate(Player, Enemy, Result)
                    else if (not OnlyPickaxe?, Guns.Length > 0, GunCheck[Player]):
                        Print("Damaged with specific gun.")
                        Activate(Player, Enemy, Result)
                    else if (not OnlyPickaxe?, Guns.Length = 0):
                        Print("Damage with any weapon or item.")
                        Activate(Player, Enemy, Result)

    Activate(Player : player, Enemy : player, Result : damage_result) : void =
        if (Character := Enemy.GetFortCharacter[]):
            Health := Character.GetHealth()
            Shield := Character.GetShield()
            Total := Health + Shield
            Character.Damage(damage_args{Amount := Total, Instigator := Result.Instigator, Source := Result.Source})

    GunCheck(Player : player)<transacts><decides> : void =
        var IsHolding : logic = false
        for (Gun : Guns, Gun.IsHoldingItem[Player]) {set IsHolding = true}
        IsHolding?