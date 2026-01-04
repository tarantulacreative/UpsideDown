
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /Verse.org/Colors }

using { Collections }
using { World }
using { Utility }


# -----------------------------------------------------------------------------------------------------------------

PlayerReadyMessage<localizes><public> : message = "Ready"
PlayerUnreadyMessage<localizes><public> : message = "Unready"
PlayerStartMessage<localizes><public> : message = "Start"
PlayerCancelMessage<localizes><public> : message = "Cancel"

LobbyCountdownMessage<localizes><public>(Time : int) : message = "New Round Starts in {Time}"

# -----------------------------------------------------------------------------------------------------------------

# Structural Hierarcialy Menu Collection:
lobby_menu_collection<public> := class(base_gui_collection):

    PlayerIndex<public> : int

    var IsPlayerReady<public> : logic = false 

    # Initialize canvas for player:
    Initialize<override>(RootCanvas : canvas, Layouts : []base_gui_collection)<suspends> : void =
        # if (Game := GlobalGame[GetSession()], Character := Game.WorldDevices.LobbyCharactersADD?[PlayerIndex]):
        #     Character.Trigger(PlayerContainer.Agent)

        (super:)Initialize(RootCanvas, Layouts)

            

    Uninitialize<override>(RootCanvas : canvas)<suspends> : void =
        # if (Game := GlobalGame[GetSession()], Checkbox := Game.WorldDevices.LobbyCheckboxes?[PlayerIndex], Character := Game.WorldDevices.LobbyCharactersCLEAR?[PlayerIndex]):
        #     Sleep(3.0)
        #     Checkbox.TurnOff(PlayerContainer.Agent)
        #     Character.Trigger(PlayerContainer.Agent)

        (super:)Uninitialize(RootCanvas)



    HandleInteractions<override>()<suspends> : void =
        loop:
            Update()
            OnConfirmButtonPressed()

            Sleep(0.0)



    InitializeCollectionComponents<override>() : void =
        defer {(super:)InitializeCollectionComponents()}

        set Canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                    Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 1.0}
                    Widget := canvas:
                        Slots := array:
                            canvas_slot:
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                                Offsets := margin{Left := 0.0, Top := -200.0, Right := 0.0, Bottom := 0.0}
                                Alignment := vector2{X := 0.5, Y := 1.0}
                                Widget := text_block{DefaultText := EmptyMessage, DefaultTextColor := NamedColors.White}


        set ConfirmButtons = option:
            array:
                confirm_button:
                    Slot := canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                        Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X := 0.5, Y := 1.0}
                        Widget := canvas:
                            Slots := array:
                                # 0 Lobby Interactable Button:
                                canvas_slot:
                                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                                    Offsets := margin{Left := 0.0, Top := -100.0, Right := 662.0, Bottom := 88.5}
                                    Alignment := vector2{X := 0.5, Y := 1.0}
                                    SizeToContent := false
                                    ZOrder := 1
                                    Widget := button_loud{DefaultText := PlayerReadyMessage}
        


    OnConfirmButtonPressed<override>()<suspends> : void =
        if (ConfirmButtonEvents.Length > 0, Game := GlobalGame[GetSession()]):
            Result := ConfirmButtonEvents.Race()  

            # if:
            #     Widget := Result(0)?
            #     Button := text_button_base[Widget.Source]
            #     Checkbox := Game.WorldDevices.LobbyCheckboxes?[PlayerIndex]

            # then:
            #     if (GetPlayerContainersSize(Game.PlayerContainers) > 1):
            #         case (IsPlayerReady):
            #             false =>
            #                 set IsPlayerReady = true

            #                 Button.SetText(PlayerUnreadyMessage)
            #                 Checkbox.TurnOn(PlayerContainer.Agent)
            #                 Game.ReadyUpEvent.Signal(true)

            #             true =>
            #                 set IsPlayerReady = false

            #                 Button.SetText(PlayerReadyMessage)
            #                 Checkbox.TurnOff(PlayerContainer.Agent)
            #                 Game.ReadyUpEvent.Signal(false)

            #             _ =>
                
            #     else:
            #         case (IsPlayerReady):
            #             false =>
            #                 set IsPlayerReady = true

            #                 Button.SetText(PlayerUnreadyMessage)
            #                 Checkbox.TurnOn(PlayerContainer.Agent)
            #                 Game.ReadyUpEvent.Signal(true)

            #             true =>
            #                 set IsPlayerReady = false

            #                 Button.SetText(PlayerReadyMessage)
            #                 Checkbox.TurnOff(PlayerContainer.Agent)
            #                 Game.ReadyUpEvent.Signal(false)

            #             _ =>


        else Sleep(Inf)


        
    Update<override>()<suspends> : void =
        if (Game := GlobalGame[GetSession()]):

            ContainerAmount := GetPlayerContainersSize(Game.PlayerContainers)

            if (Button := text_button_base[ConfirmButtonRef[0]]):
                if (ContainerAmount > 1):
                    case (IsPlayerReady):
                        false =>
                            Button.SetText(PlayerReadyMessage)

                        true =>
                            Button.SetText(PlayerUnreadyMessage)

                        _ =>

                else:
                    case (IsPlayerReady):
                        false =>
                            Button.SetText(PlayerStartMessage)

                        true =>
                            Button.SetText(PlayerCancelMessage)

                        _ =>
                
        
            

    
    # -----------------------------------------------------------------------------------------------------------------


    LockButton<public>() : void =
        if (Button := ConfirmButtonRef[0]):
            Button.SetEnabled(false)
    
    
    
    UnlockButton<public>() : void =
        if (Button := ConfirmButtonRef[0]):
            Button.SetEnabled(true)
            set IsPlayerReady = false
            spawn {Update()}



    UpdateCountdown<public>(Timer : timer)<suspends> : void =
        race:
            loop:
                Time := Timer.OnTickEvent.Await()

                if (Can := canvas[Canvas.Slots[0].Widget], TextBlock := text_block[Can.Slots[0].Widget]):
                    TextBlock.SetText(LobbyCountdownMessage(Time))

                Sleep(0.0)

            Timer.ResetEvent.Await()


    CancelCountdown<public>() : void =
        if (TextBlock := text_block[Canvas.Slots[0].Widget]):
            TextBlock.SetText(EmptyMessage)


    