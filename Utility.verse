
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SceneGraph }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Random }
using { /Verse.org/Concurrency }

using { World }
using { Player }


# -----------------------------------------------------------------------------------------------------------------

EmptyMessage<localizes><public> : message = ""
SetName<localizes><public>(Agent : agent) : message = "{Agent}"





# -----------------------------------------------------------------------------------------------------------------

ToText<public>(Input : int) : []char =
    case (Input):
        0 => "Fire"
        1 => "Target"
        2 => "Crouch"
        3 => "Jump"
        4 => "Sprint"
        5 => "Interact"
        6 => "Previous Item"
        7 => "Next Item"
        8 => "Swap Quickbar"
        9 => "Harvesting Tool"
        10 => "Forward"
        11 => "Backward"
        12 => "Left"
        13 => "Right"
        _ => ""



(Array : []?t where t : type).GetValidLength<public>()<transacts> : int =
    return (for (Value : Array, Value?) do Value).Length
        




# -----------------------------------------------------------------------------------------------------------------

(Widget : widget).ForceUpdate<public>() : void =
    Widget.SetVisibility(widget_visibility.Hidden)
    Widget.SetVisibility(widget_visibility.Visible)





# -----------------------------------------------------------------------------------------------------------------

# Used when iterating through tagged content:
CalculateSlotValue<public>(Y : int, InitialValue : int)<decides><transacts> : int =
    return Abs(Floor((Y - InitialValue) / 64))






# -----------------------------------------------------------------------------------------------------------------

# (Entity:entity).GetComponent<public>(component_type:subtype(component))<decides><transacts>:component_type=
#     Entity.GetComponents(component_type)[0]





# -----------------------------------------------------------------------------------------------------------------

# Gets the current Agent's Container:
GetPlayerContainer<public>(Containers : []?player_container, Agent : agent)<decides><transacts> : player_container =
    Container := for (PlayerContainer : Containers, PlayerContainer?.Agent = Agent) do PlayerContainer?

    return Container[0]



GetPlayerContainersSize<public>(Containers : []?player_container)<transacts> : int =
    var Size : int = 0

    for (Container : Containers, Container?):
        set Size += 1

    return Size



# Teleport Transporter + Player to destination:
(Teleporter : teleporter_device).Teleport<public>(PlayerContainer : player_container, Destination : vector3) : void =
    OriginalPlacement := Teleporter.GetTransform()

    if (Teleporter.TeleportTo[Destination, OriginalPlacement.Rotation]):
        defer {option {Teleporter.TeleportTo[OriginalPlacement]}}

        Teleporter.Teleport(PlayerContainer.Agent)


# Teleport Transporter + Player to destination:
(Teleporter : teleporter_device).TeleportRandomlyInArea(Agent : agent, Destination : vector3, Spacing : float) : void =
    if (Teleporter.TeleportTo[Destination, rotation{}]):
        defer {option {Teleporter.TeleportTo[vector3{}, rotation{}]}}

        Teleporter.Teleport(Agent)
        



# -----------------------------------------------------------------------------------------------------------------



# Initialize a Timer:
timer<public> := class<transacts><unique>:

    var Time<public> : int

    ResetEvent<public> : event() = event():
    OnStartedEvent<public> : event() = event():
    OnCompletedEvent<public> : event() = event():
    OnTickEvent<public> : event(int) = event(int):

    # Start the Timer:
    Start<public>(?ForcedTime : ?int = false)<suspends> : void =
        if (NewTime := ForcedTime?):
            set Time = NewTime

        InitialTime := Time

        OnStartedEvent.Signal()

        race:
            loop:
                OnTickEvent.Signal(Time)

                Print("Time Until Start: {Time}", ?Duration := 1.0)
                
                if (Time = 0):
                    Complete()

                    set Time = InitialTime
                    
                    Sleep(1.0)
                    return

                else:
                    set Time -= 1
                    Sleep(1.0)

            block:
                ResetEvent.Await()
                set Time = InitialTime


    Reset<public>() : void =
        ResetEvent.Signal()
        
        
    Complete<public>() : void =
        OnCompletedEvent.Signal()
        Reset()









# -----------------------------------------------------------------------------------------------------------------

suspends_wrapper<internal>(t : type) := class:
    Callback<internal> : type{_(:t)<suspends> : void}

    Spawn<internal>(Payload : t) : void =
        spawn {Callback(Payload)}
        

(Subscribable : subscribable(t) where t : type).SubscribeSuspends<public>(Callback : type{_(:t)<suspends> : void})<transacts> : cancelable =
    Wrapper := suspends_wrapper(t):
        Callback := Callback

    Subscribable.Subscribe(Wrapper.Spawn)




# Subscribe Agent + Extra Data:
wrapper_agent<internal>(t : type) := class():
    Callback : tuple(agent, t) -> void
    ExtraData : t

    InputFunction<internal>(Agent : agent):void =
        Callback(Agent, ExtraData)


(Listenable : listenable(agent)).SubscribeAgent<public>(Callback : tuple(agent, t) -> void, ExtraData : t where t : type) : cancelable =
    Wrapper := wrapper_agent(t):
        Callback := Callback
        ExtraData := ExtraData

    Listenable.Subscribe(Wrapper.InputFunction)


    

# Subscribe ?Agent + Extra Data:
wrapper_optional_agent<internal>(t : type) := class():
    Callback : tuple(?agent, t) -> void
    ExtraData : t

    InputFunction<internal>(MaybeAgent : ?agent):void =
        Callback(MaybeAgent, ExtraData)


(Listenable : listenable(?agent)).SubscribeOptionalAgent<public>(Callback : tuple(?agent, t) -> void, ExtraData : t where t : type) : cancelable =
    Wrapper := wrapper_optional_agent(t):
        Callback := Callback
        ExtraData := ExtraData

    Listenable.Subscribe(Wrapper.InputFunction)




# Subscribe Agent / Float + Extra Data:
wrapper_agent_float<internal>(t : type) := class():
    Callback : tuple(tuple(agent, float), t) -> void
    ExtraData : t

    InputFunction<internal>(MaybeAgent : tuple(agent, float)):void =
        Callback(MaybeAgent, ExtraData)


(Listenable : listenable(tuple(agent, float))).SubscribeAgentFloat<public>(Callback : tuple(tuple(agent, float), t) -> void, ExtraData : t where t : type) : cancelable =
    Wrapper := wrapper_agent_float(t):
        Callback := Callback
        ExtraData := ExtraData

    Listenable.Subscribe(Wrapper.InputFunction)


    

(Awaitables : []awaitable(t) where t : type).Race<public>()<suspends>: tuple(?t, int) =
    (RaceAwaitables(Awaitables, 0))

RaceAwaitables<internal>(Awaitables : []awaitable(t), Index : int where t : type)<suspends> : tuple(?t, int) =
    if (Awaitable := Awaitables[Index]):
        race:
            block {RaceAwaitables(Awaitables, Index + 1)}

            block:
                Result := Awaitable.Await()
                (option{Result}, Index)
            
        
    else:
        if (Awaitables.Length > 0):
            Sleep(Inf)

        (false, Index)



        
(Awaitables : []awaitable(t) where t : type).Sync<public>()<suspends> : []t =
    SyncAwaitables(Awaitables, 0)

SyncAwaitables<internal>(Awaitables : []awaitable(t), Index : int where t : type)<suspends> : []t =
    if (Awaitable := Awaitables[Index]):
        Result : tuple(t, []t) = sync:
            Awaitable.Await()
            SyncAwaitables(Awaitables, Index + 1)

        array{Result(0)} + Result(1)

    else array:
