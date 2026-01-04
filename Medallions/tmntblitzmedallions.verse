
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

MedallionToolTip<localizes> : message = "Here you can add as many medallions as you would like"
NameToolTip<localizes> : message = "Choose the name you would like to use"
MedalPropToolTip<localizes> : message = "Select the colletible device you want to use as the medallion"
PowersToolTip<localizes> : message = "Choose what power or powers youd like this medallion to have"
DashToolTip<localizes> : message = "Dahing ability allows the player to dash in a forward momentum"
LazerToolTip<localizes> : message = "Lazer beam ability gives the player a lazer beam that when activated deals damage to players inside of it"
BeamVFXToolTip<localizes> : message = "Select the VFX Powerup device that you will use for the lazer beam to show"
DashInputToolTip<localizes> : message = "Select the input trigger device here and select it to the space bar (jump button)"
DashMoverToolTip<localizes> : message = "Select a movement modulator and add the forward momentum setting"
DashHUDToolTip<localizes> : message = "Select the HUD device you will use to display the Dash HUD (this is optional)"
PowerSettingsToolTip<localizes> : message = "All the settings needed to set up each power"
DashPowerToolTip<localizes> : message = "Settings available for the dash power"
LazerPowerToolTip<localizes> : message = "Settings available for the lazer power"
DashCooldownToolTip<localizes> : message = "Set the cooldown for the dash power to become available again"
DropInputToolTip<localizes> : message = "Select the input device used for dropping the medallion"
LazerInputToolTip<localizes> : message = "Select the input device used for dropping the medallion"
LazerCooldownToolTip<localizes> : message = "Choose the amount of cooldown the lazer power should have"
ExplosiveToolTip<localizes> : message = "Select the explosive device, make sure that the explosions arent visible (unless you want them to be)"
LazerDurationToolTip<localizes> : message = "Set the cooldown for the lazer power to become available again"
VFXClearTriggerToolTip<localizes> : message = "Set this to a trigger, link that trigger to the vfx of the beam. Have it clear the vfx on triggered."

var GlobalData : weak_map(session, global_data) = map{}

global_data := class<unique>:
    MedalSystem : medal_system

GetGlobals()<decides><transacts> : global_data =
    GD := GlobalData[GetSession()]
    return GD

medal_system := class(creative_device):
    @editable:
        ToolTip := MedallionToolTip
    Medallion : medallion = medallion{}

    @editable
    DefaultClass : class_and_team_selector_device = class_and_team_selector_device{}

    @editable:
        ToolTip := PowerSettingsToolTip
    PowerSettings : medal_power_settings = medal_power_settings{}

    @editable
    CenterPosition : vector3 = vector3{}

    var AllowedAgent : ?agent = false

    OnBegin<override>()<suspends> : void =
        if. set GlobalData[GetSession()] = global_data{MedalSystem := Self}

        Players := GetPlayspace().GetPlayers()
        PowerSettings.DashPower.DashInput.PressedEvent.Subscribe(DashAbility)
        PowerSettings.LazerPower.LazerInput.PressedEvent.Subscribe(LazerBetween)

        Medallion.MedalCollectible.CollectedEvent.Subscribe(MedalHandler{Device := Self, Parameter1 := Medallion, Parameter2 := false}.HandlerFunction)
        Medallion.DropInput.PressedEvent.Subscribe(MedalHandler{Device := Self, Parameter1 := Medallion, Parameter2 := false}.HandlerFunction2)

        if (Medallion.Powers.Invis?):
            PowerSettings.Invis.Activate()

        for (Player : Players):
            OnJoin(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnJoin)

    OnJoin(Player : player) : void =
        if (Character := Player.GetFortCharacter[]):
            Character.EliminatedEvent().Subscribe(OnElim)
            Character.DamagedEvent().Subscribe(OnDamage)
            Character.DamagedShieldEvent().Subscribe(OnDamage)

    OnElim(Result : elimination_result) : void =
        if (EliminatingCharacter := Result.EliminatingCharacter?, EliminatingPlayer := player[EliminatingCharacter.GetAgent[]]):
            spawn{Medallion.SyphonSetup.Apply(EliminatingPlayer)}

    OnDamage(Result : damage_result) : void =
        if (Instigator := Result.Instigator?, Agent := Instigator.GetInstigatorAgent[], Player := player[Agent], AllowedAgent? = Agent):
            if (Target := Result.Target, Character := fort_character[Target], TargetPlayer := player[Character.GetAgent[]]):
                if (Medallion.Powers.Knockback?):
                    PowerSettings.Knockback.Activate(Player, TargetPlayer)

    HandlePickUp(Agent : agent, Medal : medallion) : void =
        Print("Picked up the {Medal.Name} medallion")
        Print("This medallion has these powers activated:")
        Medal.MedalCollectible.Hide()
        Medal.HUD.Show(Agent)
        set AllowedAgent = option{Agent}
        if:
            Medal.Powers.Dash = true
        then:
        if:
            Medal.Powers.Dash = true
        then:
        if:
            Medal.Powers.ExtraDamage = true
        then:
        if:
            Medal.Powers.NitroBoost = true
            Player := player[Agent]
        then:
            PowerSettings.NitroBoost.Activate(Player)
        if (Medal.Powers.ShieldRegen?, Player := player[Agent]):
            PowerSettings.ShieldRegen.Activate(Player)
        Medal.Class.ChangeClass(Agent)
        Medal.DamageAmp.SetMagnitude(Medal.DamageAmount)
        Medal.DamageAmp.Pickup(Agent)
        spawn{HandlePlayerActive(Agent, Medal)}

    HandlePlayerActive(Agent : agent, Medal : medallion)<suspends> : void =
        if:
            Player := player[Agent]
            Char := Player.GetFortCharacter[]
        then:
            loop:
                Sleep(0.1)
                if:
                    not Char.IsActive[]
                then:
                    Print("Player either left or died, dropping the medal")
                    HandleDrop(Agent, Medal, true)
                    break

    HandleDrop(Agent : agent, Medal : medallion, AbandonLogic : logic) : void =
        if:
            AbandonLogic = false
        then:
            if:
                RealAgent := agent[AllowedAgent?]
                RealAgent = Agent
            then:
                Print("Player has the medallion, so they can drop it")
                Collectible := Medal.MedalCollectible
                if:
                    Char := Agent.GetFortCharacter[]
                    Char.IsCrouching[]
                then:
                    if:
                        PlayerPos := Char.GetTransform()
                        Collectible.TeleportTo[vector3{X := PlayerPos.Translation.X, Y := PlayerPos.Translation.Y, Z := PlayerPos.Translation.Z + 400.0}, PlayerPos.Rotation]
                    then:
                        Medal.HUD.Hide(Agent)
                        Collectible.Show()
                        Collectible.RespawnForAll()
                        DefaultClass.ChangeClass(Agent)
                        Medal.DamageAmp.SetMagnitude(1.0)
                        Medal.DamageAmp.Pickup(Agent)
                        spawn{Collectible.MoveTo(PlayerPos.Translation, PlayerPos.Rotation, 2.0)}
                        set AllowedAgent = false
                        PowerSettings.LazerPower.VFXClearTrigger.Trigger(Agent)
            else:
                Print("Player does not have the medallion to drop")
        else:
            Print("Abandoning logic")
            Collectible := Medal.MedalCollectible
            if:
                All := GetPlayspace().GetPlayers()
                RanInt := GetRandomInt(0, All.Length - 1)
                RanPlayer := All[RanInt]
                RanChar := RanPlayer.GetFortCharacter[]
                Collectible.TeleportTo[vector3{X := CenterPosition.X, Y := CenterPosition.Y, Z := CenterPosition.Z + 400.0}, RanChar.GetTransform().Rotation]
            then:
                Collectible.Show()
                Collectible.RespawnForAll()
                spawn{Collectible.MoveTo(CenterPosition, RanChar.GetTransform().Rotation, 2.0)}
                set AllowedAgent = false
                PowerSettings.LazerPower.VFXClearTrigger.Trigger(Agent)

    Cooldown(PowerCooldown : float, String : string)<suspends> : void =
        var TimeLeft : float = PowerCooldown
        loop:
            Sleep(1.0)
            set TimeLeft -= 1.0
            if:
                TimeLeft <= 0.0
            then:
                Print("Cooldown has ended")
                if:
                    String = "Dash"
                then:
                    set PowerSettings.DashPower.CanDash = true
                else if:
                    String = "Lazer"
                then:
                    set PowerSettings.LazerPower.CanLazer = true
                else if:
                    String = "Invis"
                then:
                    set PowerSettings.Invis.CanInvis = true
                break

    CustomClass(Agent : agent, Medal : medallion) : void =
        if:
            ActualAllowedAgent := agent[AllowedAgent?]
            ActualAllowedAgent = Agent
        then:
            Medal

    DashAbility(Agent : agent) : void =
        if:
            ActualAllowedAgent := agent[AllowedAgent?]
            ActualAllowedAgent = Agent
        then:
            Print("Player has the medallion")
            Dash := PowerSettings.DashPower
            if:
                FortChar := Agent.GetFortCharacter[]
                FortChar.IsInAir[]
                Dash.CanDash = true
            then:
                Print("Player is in the air, so they can dash and they are not on cooldown")
                Dash.DashMover.Activate(Agent)
                Print("Starting cooldown")
                set Dash.CanDash = false
                spawn{Cooldown(Dash.DashCooldown, "Dash")}
            else if:
                FortChar := Agent.GetFortCharacter[]
                not FortChar.IsInAir[]
            then:
                Print("Player was not in the air to dash")
            else if:
                FortChar := Agent.GetFortCharacter[]
                Dash.CanDash = false
            then:
                Print("Players dash was not available, they are on cooldown")
        else:
            Print("Player does not have the medallion")

    LazerBetween(Agent : agent) : void =
        spawn{LazerAbility(Agent)}

    LazerAbility(Agent : agent)<suspends> : void =
        if:
            ActualAllowedAgent := agent[AllowedAgent?]
            ActualAllowedAgent = Agent
        then:
            Print("Player has the medallion")
            Lazer := PowerSettings.LazerPower
            if:
                FortChar := Agent.GetFortCharacter[]
                not FortChar.IsCrouching[]
                Lazer.CanLazer = true
            then:
                Print("Player is able to use the lazer ability and they are not on cooldown")
                Lazer.BeamVFX.Spawn()
                Lazer.BeamVFX.Pickup(Agent)
                set Lazer.CanLazer = false
                spawn{ActivateLazerExplosive(Agent, Lazer)}
                Sleep(Lazer.LazerDuration)
                Lazer.VFXClearTrigger.Trigger(Agent)
                spawn{Cooldown(Lazer.LazerCooldown, "Lazer")}
            else if:
                Lazer.CanLazer = false
            then:
                Print("Ability on cooldown")
        else:
            Print("Player does not have the medallion")

    ActivateLazerExplosive(Agent : agent, Power : lazer)<suspends> : void =
        Print("Explosions starting")
        if:
            Char := Agent.GetFortCharacter[]
        then:
            var TimeLeft : float = Power.LazerDuration
            var ChosenExplosive : ?explosive_device = false
            
            TeamCollection := GetPlayspace().GetTeamCollection()
            Teams := TeamCollection.GetTeams()

            if:
                TeamOne := Teams[0]
                TeamCollection.IsOnTeam[Agent, TeamOne]
                FirstExplosive := Power.Explosives[0]
            then:
                set ChosenExplosive = option{FirstExplosive}
            else if:
                TeamTwo := Teams[1]
                TeamCollection.IsOnTeam[Agent, TeamTwo]
                SecondExplosive := Power.Explosives[1]
            then:
                set ChosenExplosive = option{SecondExplosive}

            if:
                Explosive := ChosenExplosive?
            then:
                race:
                    loop:
                        Print("Explosions started")
                        option{Explosive.TeleportTo[Char.GetViewLocation(), Char.GetTransform().Rotation]}
                        Explosive.Explode(Agent)
                        Explosive.Reset()
                        Print("Explosion moved")
                        Sleep(0.25)

                    loop:
                        Sleep(1.0)
                        set TimeLeft -= 1.0
                        if:
                            TimeLeft <= 0.0
                        then:
                            break

medallion := class<concrete>:
    @editable:
        ToolTip := NameToolTip
    Name : string = ""

    @editable
    SyphonSetup : syphon_settings = syphon_settings{}

    @editable
    Class : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    DamageAmp : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}

    @editable
    DamageAmount : float = 2.0

    @editable
    HUD : hud_message_device = hud_message_device{}

    @editable:
        ToolTip := MedalPropToolTip
    MedalCollectible : collectible_object_device = collectible_object_device{}

    @editable:
        ToolTip := DropInputToolTip
    DropInput : input_trigger_device = input_trigger_device{}

    @editable:
        ToolTip := PowersToolTip
    Powers : medal_powers = medal_powers{}

medal_powers := class<concrete>:
    @editable:
        ToolTip := DashToolTip
    Dash : logic = false

    @editable:
        ToolTip := LazerToolTip
    Lazer : logic = false

    @editable
    ExtraDamage : logic = false

    @editable
    Invis : logic = false

    @editable
    ShieldRegen : logic = false

    @editable
    Knockback : logic = false

    @editable
    NitroBoost : logic = false

nitro_boost := class<concrete>:
    @editable
    NitroGranter : item_granter_device = item_granter_device{}

    @editable
    NitroConditional : conditional_button_device = conditional_button_device{}

    Activate(Player : player) : void =
        spawn{Track(Player)}

    Track(Player : player)<suspends> : void =
        loop:
            Sleep(0.5)
            if (not Player.IsActive[]):
                break
            if (not Player.GetFortCharacter[].IsActive[]):
                break
            if (player[GetGlobals[].MedalSystem.AllowedAgent?] <> Player):
                break
            if (not GetGlobals[].MedalSystem.AllowedAgent?):
                break
            Count := NitroConditional.GetItemCount(Player, 0)
            if (Count < 3):
                NitroGranter.GrantItem(Player)

knockback := class<concrete>:
    @editable
    KnockbackPad : movement_modulator_device = movement_modulator_device{}

    Activate(Player : player, Target : player) : void =
        KnockbackPad.Activate(Target)

shield_regen := class<concrete>:
    @editable
    MaxToHeal : float = 50.0

    @editable
    OutOfCombatFor : float = 15.0

    var InCombat : float = 0.0

    Activate(Player : player) : void =
        if (Device := GetGlobals[].MedalSystem, Player = player[Device.AllowedAgent?]):
            set InCombat = 0.0
        spawn{Track(Player)}

    Track(Player : player)<suspends> : void =
        if (Character := Player.GetFortCharacter[]):
            var IsCounting : logic = false
            race:
                loop:
                    Sleep(0.5)
                    if (not Character.IsActive[]):
                        break
                    if (not Player.IsActive[]):
                        break
                    if (Device := GetGlobals[].MedalSystem, not Device.AllowedAgent?):
                        break
                loop:
                    Sleep(0.25)
                    Character.DamagedEvent().Await()
                    set InCombat = OutOfCombatFor
                    set IsCounting = true
                loop:
                    Sleep(1.0)
                    if (IsCounting?):
                        set InCombat -= 1.0
                        if (InCombat <= 0.0):
                            set InCombat = 0.0
                            set IsCounting = false
                            StartRegen(Character)

    StartRegen(Character : fort_character)<suspends> : void =
        race:
            loop:
                Sleep(0.5)
                if (InCombat > 0.0):
                    break
            Character.DamagedEvent().Await()
            loop:
                Sleep(1.0)
                if (Character.GetShield() < MaxToHeal):
                    AmountToHeal := MaxToHeal / 10.0
                    Difference := 50.0 - Character.GetShield()
                    if (AmountToHeal < Difference):
                        Character.SetShield(AmountToHeal)
                    else:
                        Character.SetShield(Difference)
                        break

invis_settings := class<concrete>:
    @editable
    NeedsToHold : ?conditional_button_device = false

    @editable
    PressInput : ?input_trigger_device = false

    @editable
    InvisTimed : logic = false

    @editable
    InvisLength : float = 10.0

    @editable
    Cooldown : float = 30.0

    var CanInvis : logic = true

    Activate() : void =
        if (Input := PressInput?):
            Input.PressedEvent.Subscribe(OnPress)
        if (Hold := NeedsToHold?):
            spawn{Track()}

    Track()<suspends> : void =
        loop:
            Sleep(0.1)
            if (CanInvis?):
                if (Device := GetGlobals[].MedalSystem, Player := player[Device.AllowedAgent?], Character := Player.GetFortCharacter[]):
                    if (not Player.IsActive[]):
                        break
                    if (Hold := NeedsToHold?, Hold.IsHoldingItem[Player]):
                        Apply(Player)
                        if (not InvisTimed?):
                            loop:
                                Sleep(0.1)
                                if (not Hold.IsHoldingItem[Player]):
                                    Character.Show()
                                    if (Cooldown > 0.0):
                                        set CanInvis = false
                                        spawn{Device.Cooldown(Cooldown, "Invis")}
                                        break

    OnPress(Agent : agent) : void =
        if (Device := GetGlobals[].MedalSystem, Player := player[Agent], DevicePlayer := player[Device.AllowedAgent?], Player = DevicePlayer):
            Apply(Player)

    Apply(Player : player) : void =
        if (not CanInvis?):
            return
        if (Character := Player.GetFortCharacter[]):
            if (HoldItem := NeedsToHold?, HoldItem.IsHoldingItem[Player]):
                Character.Hide()
                spawn{Timed(Character)}
            else if (Press := PressInput?):
                Character.Hide()
                spawn{Timed(Character)}

    Timed(Character : fort_character)<suspends> : void =
        if (not InvisTimed?):
            return
        if (not InvisLength > 0.0):
            return
        var TimeLeft : float = InvisLength
        loop:
            if (not Character.IsActive[]):
                break
            Sleep(1.0)
            if (Device := GetGlobals[].MedalSystem, TimeLeft <= 0.0):
                Character.Show()
                set CanInvis = false
                spawn{Device.Cooldown(Cooldown, "Invis")}
                break

medal_power_settings := class<concrete>:
    @editable:
        ToolTip := DashPowerToolTip
    DashPower : dash = dash{}

    @editable:
        ToolTip := LazerPowerToolTip
    LazerPower : lazer = lazer{}

    @editable
    Invis : invis_settings = invis_settings{}

    @editable
    ShieldRegen : shield_regen = shield_regen{}

    @editable
    Knockback : knockback = knockback{}

    @editable
    NitroBoost : nitro_boost = nitro_boost{}

syphon_settings := class<concrete>:
    @editable
    Enabled : logic = false

    @editable
    SyphonType : syphon_type = syphon_type.Health

    @editable
    SyphonApply : syphon_application = syphon_application.Instant

    @editable
    Amount : float = 50.0

    @editable
    OvertimeLength : float = 5.0

    Apply(Player : player)<suspends> : void =
        if (not Enabled?):
            return
        if (Character := Player.GetFortCharacter[]):
            case (SyphonType):
                syphon_type.Health =>
                    case (SyphonApply):
                        syphon_application.Instant => Character.SetHealth(Character.GetHealth() + Amount)
                        syphon_application.Overtime =>
                            AmountPerSecond := (Amount / OvertimeLength) / 2.0
                            loop:
                                if (not Character.IsActive[]):
                                    break
                                if (Player.IsActive[]):
                                    break
                                if (Character.GetHealth() >= Character.GetMaxHealth()):
                                    break
                                Character.SetHealth(Character.GetHealth() + AmountPerSecond)
                                Sleep(0.5)
                syphon_type.Shield =>
                    case (SyphonApply):
                        syphon_application.Instant => Character.SetShield(Character.GetShield() + Amount)
                        syphon_application.Overtime =>
                            AmountPerSecond := (Amount / OvertimeLength) / 2.0
                            loop:
                                if (not Character.IsActive[]):
                                    break
                                if (Player.IsActive[]):
                                    break
                                if (Character.GetShield() >= Character.GetMaxShield()):
                                    break
                                Character.SetShield(Character.GetShield() + AmountPerSecond)
                                Sleep(0.5)
                syphon_type.Both =>
                    case (SyphonApply):
                        syphon_application.Instant =>
                            Character.SetShield(Character.GetShield() + (Amount / 2.0))
                            Character.SetHealth(Character.GetHealth() + (Amount / 2.0))
                        syphon_application.Overtime =>
                            AmountPerSecond := ((Amount / OvertimeLength) / 2.0) / 2.0
                            loop:
                                if (not Character.IsActive[]):
                                    break
                                if (Player.IsActive[]):
                                    break
                                Character.SetHealth(Character.GetHealth() + AmountPerSecond)
                                Character.SetShield(Character.GetShield() + AmountPerSecond)
                                Sleep(0.5)

syphon_type := enum:
    Health
    Shield
    Both

syphon_application := enum:
    Instant
    Overtime

lazer := class<concrete>:
    @editable:
        ToolTip := BeamVFXToolTip
    BeamVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable:
        ToolTip := LazerInputToolTip
    LazerInput : input_trigger_device = input_trigger_device{}

    @editable:
        ToolTip := VFXClearTriggerToolTip
    VFXClearTrigger : trigger_device = trigger_device{}

    @editable:
        ToolTip := ExplosiveToolTip
    Explosives : []explosive_device = array{}

    @editable:
        ToolTip := LazerCooldownToolTip
    LazerCooldown : float = 3.0

    @editable:
        ToolTip := LazerDurationToolTip
    LazerDuration : float = 5.0

    var CanLazer : logic = true

dash := class<concrete>:
    @editable:
        ToolTip := DashInputToolTip
    DashInput : input_trigger_device = input_trigger_device{}

    @editable:
        ToolTip := DashMoverToolTip
    DashMover : movement_modulator_device = movement_modulator_device{}

    @editable:
        ToolTip := DashHUDToolTip
    DashHUD : hud_message_device = hud_message_device{}

    @editable:
        ToolTip := DashCooldownToolTip
    DashCooldown : float = 3.0

    var CanDash : logic = true

custom_class := class<concrete>:
    @editable
    Class : class_and_team_selector_device = class_and_team_selector_device{}

MedalHandler := class() {
    Device : medal_system
    Parameter1 : medallion
    Parameter2 : logic

    HandlerFunction(Agent : agent) : void = {
        Device.HandlePickUp(Agent, Parameter1)
    }
    HandlerFunction2(Agent : agent) : void = {
        Device.HandleDrop(Agent, Parameter1, Parameter2)
    }
}