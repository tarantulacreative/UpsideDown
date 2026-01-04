# All of Fortnite imports
using { /Fortnite.com/Devices }

# All of Verse imports
using { /Verse.org/Simulation }

# All of Unreal imports
using { /UnrealEngine.com/Temporary/Diagnostics }

<# --- GLOBAL DATA --- #>
StringToMessage<public><localizes>(String : string) : message = "{String}"

var Globals<public> : weak_map(session, global_variables) := map{}

SetGlobals<public>(GameDevice : spla_game_device, RoundDevice : spla_round_device, EliminationManager : spla_elimination_manager, RandomStorm:random_storm)<decides><transacts> : void =
    set Globals[GetSession()] = global_variables:
        Devices := spla_devices:
            Game := GameDevice,
            Rounds := RoundDevice,
            Elimination := EliminationManager,
            Storm := RandomStorm

GetDevices<public>()<decides><transacts> : spla_devices =
    GlobalData := Globals[GetSession()]
    GlobalData.Devices

GetGameDevice<public>()<decides><transacts> : spla_game_device =
    Devices := GetDevices[]
    Devices.Game

GetRoundDevice<public>()<decides><transacts> : spla_round_device =
    Devices := GetDevices[]
    Devices.Rounds

GetEliminationManager<public>()<decides><transacts> : spla_elimination_manager =
    Devices := GetDevices[]
    Devices.Elimination

GetRandomStorm<public>()<decides><transacts> : random_storm =
    Devices := GetDevices[]
    Devices.Storm

global_variables<public> := class:
    Devices<public> : spla_devices

spla_devices<public> := class:
    var Game<public> : spla_game_device
    var Rounds<public> : spla_round_device
    var Elimination<public> : spla_elimination_manager
    var Storm<public> : random_storm

spla_game_device<public> := class(creative_device):
    @editable
    RoundDevice : spla_round_device = spla_round_device{}

    @editable
    EliminationManager : spla_elimination_manager = spla_elimination_manager{}

    @editable
    RandomStorm:random_storm = random_storm{}

    @editable
    Testing : logic = false

    @editable
    EndRound : end_game_device = end_game_device{}

    OnBegin<override>()<suspends> : void =
        set RoundDevice.Testing = Testing
        SystemSetup()
        spawn{AwaitPlayerEvents()}
        for (Player : GetPlayspace().GetPlayers()):
            Player.Init()

    SystemSetup<public>() : void =
        option{SetGlobals[Self, RoundDevice, EliminationManager, RandomStorm]}
        spawn{RoundDevice.Start()}

    AwaitPlayerEvents<public>()<suspends> : void =
        sync:
            loop:
                AddedPlayer := GetPlayspace().PlayerAddedEvent().Await()
                AddedPlayer.Init()
            loop:
                RemovedPlayer := GetPlayspace().PlayerRemovedEvent().Await()
                RemovedPlayer.Remove()

    (InPlayer : player).Init<public>() : void =
        EliminationManager.InitEvents(InPlayer)

    (InPlayer : player).Remove<public>() : void =
        {}