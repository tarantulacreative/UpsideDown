# All of Fortnite imports
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }

# All of Verse imports
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }

# All of Unreal imports
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

random_storm<public> := class(creative_device):
    @editable
    RoundDevice : spla_round_device = spla_round_device{}

    @editable
    StormController:advanced_storm_controller_device = advanced_storm_controller_device{}

    @editable
    StormPhases:[]storm_phase_options = array{}

    @editable
    ArenaBorders:border_limits = border_limits{}

    var CurrentPhase:int = 0

    OnBegin<override>()<suspends>:void =
        RoundDevice.RoundBegunEvent.Await()
        Start()

    Start()<suspends>:void =
        CenterX := (ArenaBorders.Minimum.X + ArenaBorders.Maximum.X) / 2.0
        CenterY := (ArenaBorders.Minimum.Y + ArenaBorders.Maximum.Y) / 2.0

        RandomX := GetRandomFloat(CenterX - 5000.0, CenterX + 5000.0)
        RandomY := GetRandomFloat(CenterY - 5000.0, CenterY + 5000.0)

        var BeaconPhaseLocation:vector3 = vector3{X := RandomX, Y := RandomY, Z := 0.0}
        
        if (PhaseOne := StormPhases[0], PhaseOne.Beacon.TeleportTo[BeaconPhaseLocation, IdentityRotation()]) {Print("DEBUG: Phase 1 storm beacon placed at X: {BeaconPhaseLocation.X}, Y: {BeaconPhaseLocation.Z}.")}
        for (Index -> StormPhase : StormPhases, Index <> 0, PreviousPhase := StormPhases[Index - 1]):
            case (StormPhase.PhaseType):
                phase_options.Normal => NormalLocation(PreviousPhase, StormPhase)
                phase_options.Rotating => RotatingLocation(PreviousPhase, StormPhase)
                phase_options.Moving => MovingLocation(PreviousPhase, StormPhase)

        StormController.GenerateStorm()
        loop:
            StormController.PhaseEndedEvent.Await()
            set CurrentPhase += 1

    NormalLocation(PreviousPhase:storm_phase_options, StormPhase:storm_phase_options):void =
        Beacon := StormPhase.Beacon
        Radius := StormPhase.Radius * 100.0
        PreviousBeacon := PreviousPhase.Beacon
        PreviousRadius := PreviousPhase.Radius * 100.0

        MaxCenterDisplacement:float = PreviousRadius - Radius
        RandomAngleRad := GetRandomFloat(0.0, 2.0 * PiFloat)
        ActualDisplacementForNewCenter := Sqrt(GetRandomFloat(0.0, 1.0)) * MaxCenterDisplacement
        OffsetX := ActualDisplacementForNewCenter * Cos(RandomAngleRad)
        OffsetY := ActualDisplacementForNewCenter * Sin(RandomAngleRad)

        NewBeaconCenterX := PreviousBeacon.GetTransform().Translation.X + OffsetX
        NewBeaconCenterY := PreviousBeacon.GetTransform().Translation.Y + OffsetY
        NewBeaconLocation := vector3{X := NewBeaconCenterX, Y := NewBeaconCenterY, Z := 0.0}

        if (Beacon.TeleportTo[NewBeaconLocation, IdentityRotation()]) {}
        Print("DEBUG: Beacon has been placed at X: {NewBeaconCenterX}, Y: {NewBeaconCenterY}.")

    RotatingLocation(PreviousPhase:storm_phase_options, StormPhase:storm_phase_options):void =
        Beacon := StormPhase.Beacon
        Radius := StormPhase.Radius * 100.0
        PreviousBeacon := PreviousPhase.Beacon
        PreviousRadius := PreviousPhase.Radius * 100.0
        
        RandomAngleRadians := GetRandomFloat(0.0, 2.0 * PiFloat)
        DirectionX := Cos(RandomAngleRadians)
        DirectionY := Sin(RandomAngleRadians)
        UnitDirectionVector := vector3{X:=DirectionX, Y:=DirectionY, Z:=0.0}.MakeUnitVector[] or vector3{X:=1.0, Y:=0.0, Z:=0.0}
        NewCenterStormX := PreviousBeacon.GetTransform().Translation.X + UnitDirectionVector.X * PreviousRadius
        NewCenterStormY := PreviousBeacon.GetTransform().Translation.Y + UnitDirectionVector.Y * PreviousRadius

        NewBeaconLocation := vector3{X := NewCenterStormX, Y := NewCenterStormY, Z := 0.0}

        if (Beacon.TeleportTo[NewBeaconLocation, IdentityRotation()]) {}
        Print("DEBUG: Beacon has been placed at X: {NewCenterStormX}, Y: {NewCenterStormY}.")

    MovingLocation(PreviousPhase:storm_phase_options, StormPhase:storm_phase_options):void =
        Beacon := StormPhase.Beacon
        Radius := StormPhase.Radius * 100.0
        PreviousBeacon := PreviousPhase.Beacon
        PreviousRadius := PreviousPhase.Radius * 100.0

        ActualPullFromEdge := GetRandomFloat(500.0, 5000.0)
        TotalOffsetForNewCenter := PreviousRadius + Radius + ActualPullFromEdge
        RandomAngleRadians := GetRandomFloat(0.0, 2.0 * PiFloat)
        DirectionX := Cos(RandomAngleRadians)
        DirectionY := Sin(RandomAngleRadians)
        UnitDirectionVector := vector3{X:=DirectionX, Y:=DirectionY, Z:=0.0}.MakeUnitVector[] or vector3{X:=1.0, Y:=0.0, Z:=0.0}
        NewCenterStormX := PreviousBeacon.GetTransform().Translation.X + UnitDirectionVector.X * TotalOffsetForNewCenter
        NewCenterStormY := PreviousBeacon.GetTransform().Translation.Y + UnitDirectionVector.Y * TotalOffsetForNewCenter

        NewBeaconLocation := vector3{X := NewCenterStormX, Y := NewCenterStormY, Z := 0.0}

        if (Beacon.TeleportTo[NewBeaconLocation, IdentityRotation()]) {}
        Print("DEBUG: Beacon has been placed at X: {NewCenterStormX}, Y: {NewCenterStormY}.")

storm_phase_options := class<concrete>:
    @editable
    Beacon:advanced_storm_beacon_device = advanced_storm_beacon_device{}

    @editable
    Radius:float = 0.0

    @editable
    PhaseType:phase_options = phase_options.Normal

phase_options := enum:
    Normal
    Rotating
    Moving

border_limits := class<concrete>:
    @editable
    Minimum:vector2 = vector2{X := -5000.0, Y := -5000.0}

    @editable
    Maximum:vector2 = vector2{X := 5000.0, Y := 5000.0}