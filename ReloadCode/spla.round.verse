# All of Fortnite imports
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }

# All of Verse imports
using { /Verse.org/Random }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

# All of Unreal imports
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

spla_round_device<public> := class(creative_device):
    @editable_number(float):
        MinValue := option{0.0}
    BetweenRoundWait : float = 3.0

    @editable
    MaybeStartingTrigger:?trigger_device = false

    @editable
    MaybeStartingTimer:?timer_device = false

    @editable
    MatGranter : item_granter_device = item_granter_device{}

    @editable
    ItemGranters : []item_granter_device = array{}

    @editable
    UIDevice : team_counter = team_counter{}

    @editable
    VictoryTrigger:trigger_device = trigger_device{}

    @editable
    VictoryScreenDuration:float = 5.0

    var Testing : logic = false

    RoundBegunEvent : event(logic) = event(logic){}

    Start<public>()<suspends> : void =
        Sleep(BetweenRoundWait)
        if (StartingTrigger := MaybeStartingTrigger?):
            StartingTrigger.TriggeredEvent.Await()
        else if (StartingTimer := MaybeStartingTimer?):
            StartingTimer.Enable()
            StartingTimer.Start()
            StartingTimer.SuccessEvent.Await()
            StartingTimer.Disable()
        RoundBegunEvent.Signal(true)
        if:
            EliminationManager := GetEliminationManager[]
        then:
            EliminationManager.Reboot.Init()
        Print("Reboots are enabled.")
        var AmountOfPlayers : int = 0
        for (Player : GetPlayspace().GetPlayers()) { Print("Showing player counter"), UIDevice.Show(Player), set AmountOfPlayers += 1 }
        UIDevice.UpdateTeamCount(AmountOfPlayers)
        PlayerCheck()

    PlayerCheck<public>()<suspends> : void =
        if:
            not Testing?
            GameDevice := GetGameDevice[]
        then:
            loop:
                Sleep(0.15)
                var AlivePlayers : []player = array{}
                for (Player : GetPlayspace().GetPlayers(), Char := Player.GetFortCharacter[]):
                    if:
                        Char.IsActive[]
                    then:
                        set AlivePlayers += array{Player}
                    else:
                        if:
                            EliminationManager := GetEliminationManager[]
                            EliminationManager.Reboot.PlayerReboots[Player] <> 0
                        then:
                            set AlivePlayers += array{Player}
                Print("Alive players is: {AlivePlayers.Length}")
                UIDevice.UpdateTeamCount(AlivePlayers.Length)
                if:
                    AlivePlayers.Length = 1
                then:
                    Print("Round should end")
                    if:
                        GameManager := GetGameDevice[]
                        Winner := AlivePlayers[0]
                    then:
                        VictoryTrigger.Trigger()
                        Sleep(VictoryScreenDuration)
                        GameManager.EndRound.Activate(Winner)
                    else:
                        Print("There was no winner?")
                        if:
                            GameManager := GetGameDevice[]
                            RandomPlayer := GetPlayspace().GetPlayers()[0]
                        then:
                            VictoryTrigger.Trigger()
                            Sleep(VictoryScreenDuration)
                            GameManager.EndRound.Activate(RandomPlayer)
        else:
            Print("Debug: We are either testing the round or could not get the game device. Running checks.")
            if:
                not Testing?
            then:
                Print("We could not get the game device")
            else:
                Print("Testing is turned on!")


<# --- PLAYER COUNTER --- #>
team_counter<public> := class(creative_device):
    var WidgetsMap<public> : [player]team_counter_widgets = map{}
    var CanvasMap<public> : [player]?canvas = map{}

    Show<public>(Player : player) : void =
        Canvas : canvas = canvas{}
        Widget : team_counter_ui = team_counter_ui{}
        Widget.Create()
        CanvasSlot := canvas_slot:
            Widget := Widget.GetRootWidget()
            Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
            Offsets := margin{}
            Alignment := vector2{X := 0.0, Y := 0.5}
            SizeToContent := true
            ZOrder := 0
        Canvas.AddWidget(CanvasSlot)
        RebootWidgets := team_counter_widgets:
            Canvas := Canvas
            Widget := Widget
        if:
            set WidgetsMap[Player] = RebootWidgets
            set CanvasMap[Player] = option{Canvas}
            PlayerWidgets := WidgetsMap[Player]
            PlayerUI := GetPlayerUI[Player]
        then:
            Print("Adding player counter widget")
            PlayerUI.AddWidget(Canvas, player_ui_slot{ZOrder := 0})

    Hide<public>(Player : player) : void =
        if:
            PlayerUI := GetPlayerUI[Player]
            Canvas := CanvasMap[Player]?
        then:
            PlayerUI.RemoveWidget(Canvas)
            option{set CanvasMap[Player] = false}

    UpdateTeamCount<public>(PlayerCount : int) : void =
        for (Key -> Value : WidgetsMap):
            Value.Widget.PlayerCounter.SetText(StringToMessage("Players Alive: {PlayerCount}"))

team_counter_ui<public> := class:
    PlayerCounter<public> : text_block = text_block{DefaultTextColor := NamedColors.White}

    var RootWidget<public> : widget = overlay{}

    Create<public>() : void =
        set RootWidget = stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Widget := PlayerCounter

    GetRootWidget<public>() : widget = RootWidget

team_counter_widgets<public> := struct:
    Canvas : canvas
    Widget : team_counter_ui