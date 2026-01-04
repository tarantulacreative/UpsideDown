# All of Fortnite imports
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }

# All of Verse imports
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

# All of Unreal imports
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

reboot_system<public> := class<concrete>:
    RebootUI<public> : reboot_manager = reboot_manager{}

    @editable_number(int):
        MinValue := option{1}
    AvailableReboots : int = 3

    @editable
    RebootCountdownTimer : timer_device = timer_device{}

    @editable
    RebootDisablingWarningAudio : audio_player_device = audio_player_device{}

    @editable
    RebootDisabledTimer : timer_device = timer_device{}

    @editable
    RebootCounter : tracker_device = tracker_device{}

    @editable
    RespawningTimer : timer_device = timer_device{}
 
    @editable:
        ToolTip := TT_Timers
    Timers<public> : timer_settings = timer_settings{}

    var IsRebootEnabled<public> : logic = false
    var PlayerReboots<public> : [agent]int = map{}

    ReduceTimerEvent<public> : event(agent) = event(agent){}

    Init<public>() : void =
        spawn{StartReboot()}
        for (Player : creative_device{}.GetPlayspace().GetPlayers(), Char := Player.GetFortCharacter[], Char.IsActive[]) { option{set PlayerReboots[Player] = AvailableReboots} }

    StartReboot<public>()<suspends> : void =
        Print("Initializing reboots")
        set IsRebootEnabled = true
        TimeToSleep := Timers.RebootTimer - Timers.TimeLeftWarning
        RebootCounter.SetValue(AvailableReboots)
        for (Player : creative_device{}.GetPlayspace().GetPlayers()) { RebootCounter.SetValue(Player, AvailableReboots), RebootCounter.Assign(Player) }
        Sleep(TimeToSleep)
        Print("Warning time")
        RebootCountdownTimer.StartForAll()
        RebootCountdownTimer.SetActiveDuration(Timers.TimeLeftWarning)
        Sleep(5.0)
        RebootCountdownTimer.CompleteForAll()
        RebootUI.Show(Timers.TimeLeftWarning - 5.0)
        Sleep(Timers.TimeLeftWarning - 10.0)
        RebootDisablingWarningAudio.Play()
        Sleep(5.0)
        spawn{DisableReboot()}

    DisableReboot<public>()<suspends> : void =
        Print("Reboot is now disabled")
        set IsRebootEnabled = false
        set PlayerReboots = map{}
        RebootDisabledTimer.Start()
        RebootCounter.RemoveFromAll()

    HandleReboot<public>(Agent : agent)<suspends> : void =
        race:
            loop:
                Sleep(0.15)
                if:
                    not IsRebootEnabled?
                then:
                    Print("Reboot is disabled")
                    RespawningTimer.Disable()
                    break
            block:
                Print("Handling reboot")
                if:
                    EliminationManager := GetEliminationManager[]
                    IsRebootEnabled?
                then:
                    Print("Reboot is enabled, rebooting player if they have reboots left")
                    if:
                        RebootsLeft := PlayerReboots[Agent]
                        RebootsLeft <> 0
                    then:
                        Print("Player has reboots left")
                        RespawningTimer.Enable(Agent)
                        RespawningTimer.Reset(Agent)
                        RespawningTimer.Start(Agent)
                        RespawningTimer.SetActiveDuration(Timers.RespawnTimer, Agent)
                        Sleep(Timers.RespawnTimer)
                        option{set PlayerReboots[Agent] = RebootsLeft - 1}
                        RebootCounter.SetValue(Agent, RebootsLeft - 1)
                        EliminationManager.Respawn(Agent)
                    else:
                        Print("Player has no reboots left")
                        RebootCounter.Remove(Agent)

timer_settings<public> := class<concrete>:
    @editable:
        ToolTip := TT_RebootTimer
    RebootTimer<public> : float = 30.0

    @editable:
        ToolTip := TT_TimeLeftWarning
    TimeLeftWarning<public> : float = 15.0

    @editable
    RespawnTimer<public> : float = 5.0

<# TOOLTIPS #>
TT_Timers<public><localizes> : message = "Here is a list of timer options for the reboot system"
TT_RebootTimer<public><localizes> : message = "How long should reboots stay enabled for?"
TT_TimeLeftWarning<public><localizes> : message = "How long left should the warning pop up that reboots are about to be disabled?"
TT_RespawnTimer<public><localizes> : message = "How long should a player need to wait before they reboot?"
TT_EliminationReward<public><localizes> : message = "Upon getting an elimination, how many seconds should be removed from the respawning timer that is left for that teammate?"



<# --- REBOOT WARNING UI --- #>
reboot_manager<public> := class:
    var WidgetsMap<public> : [player]reboot_widgets = map{}
    var CanvasMap<public> : [player]?canvas = map{}
    var Countdown<public> : float = 0.0

    Show<public>(RebootTime : float) : void =
        set Countdown = RebootTime
        for (Player : creative_device{}.GetPlayspace().GetPlayers()):
            Show(Player)
        spawn{UpdateCountdown()}

    Show<public>(Player : player) : void =
        Canvas : canvas = canvas{}
        Widget : reboot_ui = reboot_ui{}
        Widget.Create()
        CanvasSlot := canvas_slot:
            Widget := Widget.GetRootWidget()
            Anchors := anchors{Minimum := vector2{X := 1.0, Y := 0.5}, Maximum := vector2{X := 1.0, Y := 0.5}}
            Offsets := margin{}
            Alignment := vector2{X := 1.0, Y := 1.0}
            SizeToContent := true
            ZOrder := 0
        Canvas.AddWidget(CanvasSlot)
        RebootWidgets := reboot_widgets:
            Canvas := Canvas
            Widget := Widget
        RebootWidgets.Widget.CountdownText.SetText(StringToMessage(GetCountdownString()))
        if:
            set WidgetsMap[Player] = RebootWidgets
            set CanvasMap[Player] = option{Canvas}
            PlayerWidgets := WidgetsMap[Player]
            PlayerUI := GetPlayerUI[Player]
        then:
            PlayerUI.AddWidget(Canvas, player_ui_slot{ZOrder := 0})

    Hide<public>() : void =
        for (Player : creative_device{}.GetPlayspace().GetPlayers()):
            Hide(Player)

    Hide<public>(Player : player) : void =
        if:
            PlayerUI := GetPlayerUI[Player]
            Canvas := CanvasMap[Player]?
        then:
            PlayerUI.RemoveWidget(Canvas)
            option{set CanvasMap[Player] = false}

    UpdateCountdown<public>()<suspends> : void =
        loop:
            if:
                Countdown <= 0.0
            then:
                for (Player -> RebootWidgets : WidgetsMap):
                    RebootWidgets.Widget.CountdownText.SetText(StringToMessage(""))
                    RebootWidgets.Widget.RebootCountdownImage.SetImage(ReloadUI.TemplateTimer)
                break
            else:
                set Countdown -= 1.0
            Sleep(1.0)
            for (Player -> RebootWidgets : WidgetsMap):
                if:
                    Countdown <= 5.0
                then:
                    spawn{WarningColor(RebootWidgets.Widget)}
                CountdownString := GetCountdownString()
                RebootWidgets.Widget.CountdownText.SetText(StringToMessage(CountdownString))

    WarningColor<public>(Widget : reboot_ui)<suspends> : void =
        for (Index := 1..10):
            Widget.CountdownText.SetTextColor(NamedColors.Red)
            Sleep(0.25)
            Widget.CountdownText.SetTextColor(NamedColors.White)
            Sleep(0.25)

    GetCountdownString<public>() : string =
        var CountdownString : string = ""
        if:
            Minutes := Floor[Countdown / 60.0]
            Seconds := Floor[Countdown - (60.0 * Minutes)]
        then:
            if:
                Minutes < 10
                Seconds < 10
            then:
                set CountdownString = "{Minutes}:0{Seconds}"
            else if:
                Minutes < 10
                Seconds >= 10
            then:
                set CountdownString = "{Minutes}:{Seconds}"
            else if:
                Minutes > 10
                Seconds < 10
            then:
                set CountdownString = "{Minutes}:0{Seconds}"
            else if:
                Minutes > 10
                Seconds >= 10
            then:
                set CountdownString = "{Minutes}:{Seconds}"
        CountdownString

reboot_ui<public> := class:
    RebootCountdownImage<public> : texture_block = texture_block:
        DefaultImage := ReloadUI.TemplateTimer
        DefaultDesiredSize := vector2{X := 341.0, Y := 341.0}
    CountdownText<public> : text_block = text_block{DefaultTextColor := NamedColors.White}
    
    var RootWidget<public> : widget = overlay{}

    Create<public>() : void =
        set RootWidget = overlay:
            Slots := array:
                overlay_slot:
                    Padding := margin{Top := 100.0}
                    Widget := RebootCountdownImage
                overlay_slot:
                    Padding := margin{Top := 110.0, Right := 20.0}
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Center
                    Widget := CountdownText

    GetRootWidget<public>() : widget = RootWidget

reboot_widgets<public> := struct:
    Canvas : canvas
    Widget : reboot_ui