
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Random }
using { /Verse.org/Concurrency }

using { World }
using { Utility }


# -----------------------------------------------------------------------------------------------------------------

player_progression<public> := class:

    var PlayerLevel<public> : int = 1

    var PlayerEXP<public> : int = 0


    BaseEXPMultiplier<public> : float = 1.1


    
    UpdateProgression<public>() : void =
        return