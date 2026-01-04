
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

using { Collections }
using { Utility }
using { Player }
using { World }


# -----------------------------------------------------------------------------------------------------------------

player_ui_manager<public> := class:

    var PlayerContainer<public> : ?player_container = false

    var Layouts<private> : []base_gui_collection = array:

    var AddedLayout<private> : ?base_gui_collection = false
    
    var CurrentlyCollapsed<private> : logic = false


    ShowEvent<private> : event(?base_gui_collection) = event(?base_gui_collection):
    CollapseEvent<private> : event(?base_gui_collection) = event(?base_gui_collection):
    CloseEvent<private> : event(?base_gui_collection) = event(?base_gui_collection):
    UncollapseEvent<private> : event() = event():

    InputMode<private> : player_ui_slot = player_ui_slot{InputMode := ui_input_mode.All}

        
    # Initialize canvas for player:
    Initialize<public>(InPlayerContainer : player_container)<suspends> : void =
        set PlayerContainer = option {InPlayerContainer}

        if:
            RootCanvas := PlayerContainer?.Canvas
            PlayerUI := PlayerContainer?.PlayerUI
            
        then:
            loop:
                set AddedLayout = ShowEvent.Await() 
                Print("Start Initializing")

                loop:
                    if (Layout := AddedLayout?):
                        if (Layouts.Length = 0):
                            
                            if (Layout.UsesVerseCanvas?):
                                # Add canvas w/ input mode to player's screen:
                                PlayerUI.AddWidget(RootCanvas, InputMode)

                            else PlayerUI.AddWidget(RootCanvas)

                            RootCanvas.ForceUpdate()

                            set Layouts += array{Layout}
                            spawn {Layout.Initialize(RootCanvas, Layouts)}


                        else if (MostRecentLayout := Layouts[Layouts.Length - 1], MostRecentLayout <> Layout):

                            set Layouts += array{Layout}
                            spawn {Layout.Initialize(RootCanvas, Layouts)}

                            

                    else if (Layouts.Length = 0):
                        option {set PlayerContainer?.CurrentMenu = false}
                        break


                    if (CurrentLayout := Layouts[Layouts.Length - 1]):
                        CurrentLayout.Canvas.SetEnabled(true)
                        CurrentLayout.Canvas.ForceUpdate()

                    race:
                        OnShow()
                        OnClose()
                        OnCollapse(RootCanvas, PlayerUI)


                Uninitialize(RootCanvas, PlayerUI)


        else Print("Womp Wo")



    # Uninitialize canvas for player:
    Uninitialize<public>(RootCanvas : canvas, PlayerUI : player_ui) : void =
        PlayerUI.RemoveWidget(RootCanvas)
        RootCanvas.ForceUpdate()

        for (Slot : RootCanvas.Slots):
            RootCanvas.RemoveWidget(Slot.Widget)

        for (Layout : Layouts):
            spawn {Layout.Uninitialize(RootCanvas)}

        set Layouts = array:


    # Show the layout on the players screen:
    Show<public>(Layout : base_gui_collection) : void =
        ShowEvent.Signal(option {Layout})
        Print("Showing ")


    # Close and remove the current menu from layouts then use the next layout:
    Close<public>() : void =
        CloseEvent.Signal(false)
        Print("Closing ")


    # Close and remove the current menu from layouts then use the next layout:
    CloseAll<public>()<suspends> : void =
        for (Layout : Layouts):
            CloseEvent.Signal(false)
            Sleep(0.01)
            Print("Closing ")


    # Collapse the menu for the player:
    Collapse<public>() : void =
        CollapseEvent.Signal(false)
        Print("Collapsing ")


    # Uncollapse and show the menu back on the players screen:
    Uncollapse<public>() : void =
        UncollapseEvent.Signal()
        Print("Uncollapsing ")
        

    # -------------------------------------------------------------------------------
    

    OnShow<private>()<suspends> : void =
        loop:
            isLayout := ShowEvent.Await()

            if (not CurrentlyCollapsed?):
                if:
                    Layout := isLayout?
                    OldLayout := Layouts[Layouts.Length - 1]

                then:
                    if (not OldLayout.KeepVisible?):
                        OldLayout.Canvas.SetVisibility(widget_visibility.Hidden)            

                    else OldLayout.Canvas.SetEnabled(false)

                    set AddedLayout = option {Layout}
                    break

            Sleep(0.0)


    OnCollapse<private>(RootCanvas : canvas, PlayerUI : player_ui)<suspends> : void =
        CollapseEvent.Await()


        PlayerUI.RemoveWidget(RootCanvas)
        RootCanvas.ForceUpdate()

        set CurrentlyCollapsed = true

        OnUncollapse(RootCanvas, PlayerUI)


    OnUncollapse<private>(RootCanvas : canvas, PlayerUI : player_ui)<suspends> : void =
        UncollapseEvent.Await()
        
        if (AddedLayout?.UsesVerseCanvas?):
            PlayerUI.AddWidget(RootCanvas, InputMode)

        else PlayerUI.AddWidget(RootCanvas)
        
        RootCanvas.ForceUpdate()

        set CurrentlyCollapsed = false
        set AddedLayout = false


    OnClose<private>()<suspends> : void =
        CloseEvent.Await()

        if:
            RootCanvas := PlayerContainer?.Canvas
            Layout := Layouts[Layouts.Length - 1]
            NewLayouts := Layouts.RemoveFirstElement[Layout]

        then:
            Layout.Uninitialize(RootCanvas)

            set Layouts = NewLayouts
            set AddedLayout = false