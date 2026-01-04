
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Colors }

using { Player }


# -----------------------------------------------------------------------------------------------------------------

spawnable_zombie<public> := class<concrete>:

    @editable
    Button<public> : button_device = button_device:

    var Debris<public> : []creative_prop = array:


    OnInteract<public>() : void =
        return

# -----------------------------------------------------------------------------------------------------------------

