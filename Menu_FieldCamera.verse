
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

FieldCountdownMessage<localizes><public>(Time : int) : message = "Next Round Starts in {Time}"
WaitingForPlayersMessage<localizes><public>(Dots : string) : message = "Waiting for Players{Dots}"
RoundStartingMessage<localizes><public>(Dots : string) : message = "Round in Progress{Dots}"
GameInProgressMessage<localizes><public>(PlayersAlive : int, TotalPlayers : int) : message = "Game In Progress: [ Players Remaining / Total Players ]"

# -----------------------------------------------------------------------------------------------------------------

# Structural Hierarcialy Menu Collection:
field_camera_menu_collection<public> := class(base_gui_collection):

    UsesVerseCanvas<override> : logic = false

    # Initialize canvas for player:
    Initialize<override>(RootCanvas : canvas, Layouts : []base_gui_collection)<suspends> : void =
        (super:)Initialize(RootCanvas, Layouts)

            

    Uninitialize<override>(RootCanvas : canvas)<suspends> : void =
        (super:)Uninitialize(RootCanvas)



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
                                Offsets := margin{Left := 0.0, Top := -110.0, Right := 0.0, Bottom := 0.0}
                                Alignment := vector2{X := 0.5, Y := 1.0}
                                Widget := text_block:
                                    DefaultText := EmptyMessage
                                    DefaultTextColor := NamedColors.Orange
                                    DefaultShadowOffset := option {vector2{X := 0.0, Y := 5.0}}
                                    DefaultShadowColor := NamedColors.Black
                                    DefaultShadowOpacity := 0.4

                            canvas_slot:
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                                Offsets := margin{Left := 0.0, Top := -150.0, Right := 0.0, Bottom := 0.0}
                                Alignment := vector2{X := 0.5, Y := 1.0}
                                Widget := text_block:
                                    DefaultText := EmptyMessage
                                    DefaultTextColor := NamedColors.White
                                    DefaultShadowOffset := option {vector2{X := 0.0, Y := 5.0}}
                                    DefaultShadowColor := NamedColors.Black
                                    DefaultShadowOpacity := 0.6
     

    
    # -----------------------------------------------------------------------------------------------------------------


    UpdateCountdown<public>(Timer : timer)<suspends> : void =
        if:
            Game := GlobalGame[GetSession()]
            isCanvas := canvas[Canvas.Slots[0].Widget]
            BottomTextBlock := text_block[isCanvas.Slots[0].Widget]
            TopTextBlock := text_block[isCanvas.Slots[1].Widget]

        then:
            loop:
                # if (Game.WorldData.IsReadyToEnter?):
                    
                race:
                    loop:
                        Time := Timer.OnTickEvent.Await()
                        BottomTextBlock.SetText(LobbyCountdownMessage(Time))

                    loop:
                        for (DotsToShow := 1..3):
                            DotsMessage := for (Index := 0..DotsToShow - 1) do '.'
                            TopTextBlock.SetText(WaitingForPlayersMessage(DotsMessage))

                            Sleep(2.0)

                        Sleep(1.0)


                    Timer.OnCompletedEvent.Await()

                    block:
                        UninitializeEvent.Await()
                        return

                UpdateStartingGameTimer(Timer)

                # else UpdateStartingGameTimer(Timer)


    UpdateStartingGameTimer<public>(Timer : timer)<suspends> : void =
        if:
            Game := GlobalGame[GetSession()]
            isCanvas := canvas[Canvas.Slots[0].Widget]
            BottomTextBlock := text_block[isCanvas.Slots[0].Widget]
            TopTextBlock := text_block[isCanvas.Slots[1].Widget]

        then:
            BottomTextBlock.SetText(EmptyMessage)

            race:
                loop:
                    for (DotsToShow := 1..3):
                        DotsMessage := for (Index := 0..DotsToShow - 1) do '.'
                        TopTextBlock.SetText(RoundStartingMessage(DotsMessage))

                        Sleep(1.0)

                    Sleep(1.0)

                Game.GameOverEvent.Await()

                block:
                    Timer.OnStartedEvent.Await()
                    return

            TopTextBlock.SetText(EmptyMessage)
                



    # UpdateProgressHUD<public>() : void =
    #     if:
    #         Game := GlobalGame[GetSession()]
    #         isCanvas := canvas[Canvas.Slots[0].Widget]
    #         BottomTextBlock := text_block[isCanvas.Slots[0].Widget]
    #         TopTextBlock := text_block[isCanvas.Slots[1].Widget]

    #     then:
    #         TopTextBlock.SetText(GameInProgressMessage(0, 0))
    #         BottomTextBlock.SetText(EmptyMessage)

    