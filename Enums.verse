
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


# -----------------------------------------------------------------------------------------------------------------

input<public> := enum{Fire, Target, Crouch, Jump, Sprint, Interact, PreviousItem, NextItem, SwapQuickbar, HarvestingTool, Forward, Backward, Left, Right}
input_type<public> := enum{Pressed, Released}

player_state<public> := enum{Inactive, InTitleSequence, InLoading, InWorld}
world_state<public> := enum{InLobby, InGame}

character<public> := enum{CharacterSp, CharacterPa, CharacterSq, CharacterKr, CharacterBu}