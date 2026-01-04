# All of Fortnite imports
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }

# All of Verse imports
using { /Verse.org/Random }
using { /Verse.org/Simulation }

# All of Unreal imports
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

spla_elimination_manager<public> := class(creative_device):
    @editable
    LobbySpawners : []player_spawner_device = array{}

    @editable
    RespawnSound : audio_player_device = audio_player_device{}

    @editable
    SquadWipedHUD : timer_device = timer_device{}

    @editable
    RespawningLoot : item_granter_device = item_granter_device{}

    @editable
    RandomRespawningLoot : []item_granter_device = array{}

    @editable
    Reboot : reboot_system = reboot_system{}

    @editable
    var RespawningTeleporters : []teleporter_device = array{}


    InitEvents<public>(Player : player) : void =
        spawn{AwaitDamage(Player)}
        spawn{AwaitElimination(Player)}

    AwaitDamage<public>(Player : player)<suspends> : void =
        if:
            Char := Player.GetFortCharacter[]
        then:
            loop:
                Result := Char.DamagedEvent().Await()
                HandleDamage(Result)

    HandleDamage<public>(Result : damage_result) : void =
        Amount := Result.Amount
            Target := Result.Target
            MaybeInstigator := Result.Instigator # Will be false if the damage was caused by: Environment, Code etc
            MaybeSource := Result.Source # Will be false if the damage source was: Environment, Code etc

            # Handle what to do with the player that caused the damage
            if:
                Instigator := MaybeInstigator?
                InstigatorAgent := Instigator.GetInstigatorAgent[]
                InstigatorPlayer := player[InstigatorAgent]
                InstigatorCharacter := InstigatorPlayer.GetFortCharacter[]
            then:
                #

            # Handle what to do with the player that took the damage
            if:
                TargetCharacter := fort_character[Target]
                TargetAgent := TargetCharacter.GetAgent[]
                TargetPlayer := player[TargetAgent]
            then:
                #

    AwaitElimination<public>(Player : player)<suspends> : void =
        if:
            Char := Player.GetFortCharacter[]
        then:
            loop:
                Result := Char.EliminatedEvent().Await()
                spawn{HandleElimination(Result)}

    HandleElimination<public>(Result : elimination_result)<suspends> : void =
        EliminatedCharacter := Result.EliminatedCharacter
        MaybeEliminatingCharacter := Result.EliminatingCharacter # Will be false if the playe was eliminated via non character actions

        # Handle what to do with the eliminating player
        if:
            EliminatingCharacter := MaybeEliminatingCharacter?
            EliminatingCharacter <> EliminatedCharacter # Checking if the player eliminated themself
            EliminatingAgent := EliminatingCharacter.GetAgent[]
            EliminatingPlayer := player[EliminatingAgent]
        then:
            if:
                EliminatedAgent := EliminatedCharacter.GetAgent[]
                EliminatedPlayer := player[EliminatedAgent]
            then:
                if:
                    Reboot.PlayerReboots[EliminatedAgent] = 0
                then:
                    Print("Showing squad wiped HUD")
                    SquadWipedHUD.Start(EliminatingAgent)
                else if:
                    not Reboot.IsRebootEnabled?
                then:
                    Print("Showing squad wiped HUD")
                    SquadWipedHUD.Start(EliminatingAgent)

        # Handle what to do with the player that got eliminated
        Print("About to handle eliminated player")
        if:
            EliminatedAgent := EliminatedCharacter.GetAgent[]
            EliminatedPlayer := player[EliminatedAgent]
        then:
            if:
                Print("Staring if checks")
                Reboot.IsRebootEnabled?
                Print("Reboot is enabled!")
            then:
                Print("Handling reboot for player")
                Sleep(0.5)
                spawn{Reboot.HandleReboot(EliminatedAgent)}
            else:
                Print("Reboots are no longer enabled")

    Respawn<public>(Agent : agent)<suspends> : void =
        Print("Player is being instantly respawned")
        if:
            StormDevice := GetRandomStorm[]
            RespawnTeleporter := RespawningTeleporters[StormDevice.CurrentPhase]
            StormPhase := StormDevice.StormPhases[StormDevice.CurrentPhase]
            LobbySpawner := LobbySpawners[GetRandomInt(0, LobbySpawners.Length - 1)]
            SpawnerLocation := LobbySpawner.GetTransform()
            Agent.Respawn(SpawnerLocation.Translation, SpawnerLocation.Rotation)
        then:
            Print("Respawning inside circle. Phase = {StormDevice.CurrentPhase}")
            MoveTeleporter(Agent, RespawnTeleporter, StormPhase)
            Print("Player should be respawned now")
            RespawningLoot.GrantItem(Agent)
            for (Granter : RandomRespawningLoot) { Granter.CycleToRandomItem(Agent) }
            RespawnSound.Play(Agent)
            RespawnTeleporter.Teleport(Agent)
            Location := StormPhase.Beacon.GetTransform().Translation
            if (RespawnTeleporter.TeleportTo[Location, IdentityRotation()]) {}
        else:
            Print("ERROR WHILST RESPAWNING PLAYER. Trying again in 0.5")
            Sleep(0.5)
            Respawn(Agent)

    MoveTeleporter(Agent:agent, Teleporter:teleporter_device, Phase:storm_phase_options):void =
        Print("Attempting to move teleporter for current Phase.")

        PhaseBeaconTransform := Phase.Beacon.GetTransform()
        PhaseCircleCenterX := PhaseBeaconTransform.Translation.X
        PhaseCircleCenterY := PhaseBeaconTransform.Translation.Y
        PhaseCircleCenterZ := 20000.0

        PhaseRadiusCM := (Phase.Radius / 2.0) * 100.0

        Print("Current Phase Beacon Center: X: {PhaseCircleCenterX}, Y: {PhaseCircleCenterY}, Z: {PhaseCircleCenterZ}")
        Print("Current Phase Radius (cm): {PhaseRadiusCM}")

        RandomAngle := GetRandomFloat(0.0, 2.0 * PiFloat)
        RandomDistanceForTeleporter := Sqrt(GetRandomFloat(0.0, 1.0)) * PhaseRadiusCM

        LocalTeleporterOffsetX := RandomDistanceForTeleporter * Cos(RandomAngle)
        LocalTeleporterOffsetY := RandomDistanceForTeleporter * Sin(RandomAngle)

        TeleporterTargetX := PhaseCircleCenterX + LocalTeleporterOffsetX
        TeleporterTargetY := PhaseCircleCenterY + LocalTeleporterOffsetY
        TeleporterTargetZ := PhaseCircleCenterZ

        TeleporterTargetPos := vector3{X := TeleporterTargetX, Y := TeleporterTargetY, Z := TeleporterTargetZ}

        Print("Teleporter RandomDistance: {RandomDistanceForTeleporter}, Angle: {RandomAngle}")
        Print("Calculated Local Offsets: X: {LocalTeleporterOffsetX}, Y: {LocalTeleporterOffsetY}")
        Print("Teleporter Target World Position: X: {TeleporterTargetX}, Y: {TeleporterTargetY}, Z: {TeleporterTargetZ}")

        if (Teleporter.TeleportTo[TeleporterTargetPos, IdentityRotation()]):
            Print("Teleporter successfully moved to: X: {TeleporterTargetX}, Y: {TeleporterTargetY}, Z: {TeleporterTargetZ}")
        else:
            Print("Failed to move teleporter.")