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



exploding_bullet := class(ability):
    @editable
    Explosives:[]explosive_device = array{}

    @editable
    ExplosionsPerShot : type{_X:int where 1 <= _X} = 1

    @editable
    ExplosionDelay : type{_X:float where 0.0 <= _X, 60.0 >= _X} = 0.0

    @editable
    RemoveExplosiveOnActivatorDeath : logic = false

    @editable
    ExplodeExplosiveOnTargetDeath : logic = false

    DamageEvent : event(tuple(player, transform)) = event(tuple(player, transform)){}

    var AvailableExplosives : []explosive_device = array{}

    CustomStart<override>(Player : player)<suspends> : void =
        set AvailableExplosives = Explosives
        AwaitForDamage(Player)

    Stop<override>(Player : player)<suspends> : void =
        Print("Stopping medallion power.")
        for (Explosive : Explosives) {Explosive.Reset()}
        set AvailableExplosives = array{}
        ForceEnd.Signal()

    AwaitForDamage(Player : player)<suspends> : void =
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
                    spawn{SetupDamage(Player)}
                    EnemyData := DamageEvent.Await()
                    RestartEvent.Signal()
                    Sleep(0.25)
                    spawn{HandleExplosive(Player, EnemyData)}

    HandleExplosive(Player : player, EnemyData : tuple(player, transform))<suspends> : void =
        if (Character := Player.GetFortCharacter[], EnemyCharacter := EnemyData(0).GetFortCharacter[], Explosive := GetExplosive[]):
            Explosive.Reset()
            race:
                ForceEnd.Await()
                block:
                    if (EnemyCharacter.IsActive[]):
                        race:
                            loop:
                                Sleep(0.01)
                                if (EnemyCharacter.IsActive[]):
                                    option. Explosive.TeleportTo[EnemyCharacter.GetTransform()]
                                else:
                                    if (ExplodeExplosiveOnTargetDeath?):
                                        ActivateExplosions(Player, Explosive)
                                        break
                                    else {Sleep(ExplosionDelay * 2.0)}
                            ActivateExplosions(Player, Explosive)
                    else:
                        option. Explosive.TeleportTo[EnemyData(1)]
                        if (RemoveExplosiveOnActivatorDeath?):
                            race:
                                loop:
                                    Sleep(0.01)
                                    if (not Character.IsActive[]) {break}
                                ActivateExplosions(Player, Explosive)

    ActivateExplosions(Player : player, Explosive : explosive_device)<suspends> : void =
        Sleep(ExplosionDelay)
        for (Index := 1..ExplosionsPerShot):
            Explosive.Reset()
            Sleep(0.05)
            Explosive.Explode(Player)
            Sleep(0.25)

    SetupDamage(Player : player)<suspends> : void =
        for (Enemy : creative_device{}.GetPlayspace().GetPlayers(), Enemy <> Player) {spawn{AwaitDamage(Player, Enemy)}}
    
    AwaitDamage(Player : player, Enemy : player)<suspends> : void =
        Print("Listening for enemy damage.")
        var LastLocation : transform = transform{}
        if (Character := Enemy.GetFortCharacter[]):
            race:
                ForceEnd.Await()
                RestartEvent.Await()
                loop:
                    Sleep(0.1)
                    if (not Enemy.IsActive[]) {break}
                    if (Character.IsActive[]) {set LastLocation = Character.GetTransform()}
                loop:
                    Result := Character.DamagedEvent().Await()
                    if (Instigator := Result.Instigator?, InstigatorPlayer := player[Instigator.GetInstigatorAgent[]], InstigatorPlayer = Player):
                        DamageEvent.Signal(Enemy, LastLocation)
                        break
                loop:
                    Result := Character.DamagedShieldEvent().Await()
                    if (Instigator := Result.Instigator?, InstigatorPlayer := player[Instigator.GetInstigatorAgent[]], InstigatorPlayer = Player):
                        DamageEvent.Signal(Enemy, LastLocation)
                        break
            Print("End of listening for enemy damage")

    GetExplosive()<decides><transacts> : explosive_device =
        Explosive := AvailableExplosives[0]
        NewArray := AvailableExplosives.RemoveElement[0]
        set AvailableExplosives = NewArray
        Explosive