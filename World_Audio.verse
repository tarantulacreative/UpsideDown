
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

using { Utility }


# -----------------------------------------------------------------------------------------------------------------

audio_manager<public> := class<concrete>:

    var CurrentWorldMusic<public> : radio_device = radio_device:
    var CurrentWorldAmbience<public> : radio_device = radio_device:

    Channel<private> : log = log{Channel := DeviceLog}


    @editable
    MusicLoops<public> : music_loop_tracks = music_loop_tracks:
    @editable    
    AmbientLoops<public> : ambient_loop_tracks = ambient_loop_tracks:
    @editable
    EndStingers<public> : end_stinger_tracks = end_stinger_tracks:
    @editable
    OneShots<public> : one_shot_tracks = one_shot_tracks:


    SetRadioDevices<public>(Radio : []radio_device) : void =
        if (not MusicLoops.TitleMusic?):
            set MusicLoops.TitleMusic = option {Radio[0]}

            Channel.Print("[ Device Found: Overriding [Title Music] ]")


        if (not MusicLoops.DayMusic?):
            set MusicLoops.DayMusic = option {Radio[1]}

            Channel.Print("[ Device Found: Overriding [Day Music] ]")


        if (not MusicLoops.NightMusic?):
            set MusicLoops.NightMusic = option {Radio[2]}

            Channel.Print("[ Device Found: Overriding [Night Music] ]")


        if (not MusicLoops.MinigameMusic?):
            set MusicLoops.MinigameMusic = option {array{Radio[3], Radio[4], Radio[5], Radio[6]}}

            Channel.Print("[ Device Found: Overriding [Minigame Music] ]")


        if (not AmbientLoops.DayAmbience?):
            set AmbientLoops.DayAmbience = option {Radio[7]}

            Channel.Print("[ Device Found: Overriding [Day Ambience] ]")


        if (not AmbientLoops.NightAmbience?):
            set AmbientLoops.NightAmbience = option {Radio[8]}

            Channel.Print("[ Device Found: Overriding [Night Ambience] ]")


        if (not AmbientLoops.IndoorAmbience?):
            set AmbientLoops.IndoorAmbience = option {Radio[9]}

            Channel.Print("[ Device Found: Overriding [Indoor Ambience] ]")


        
    SetAudioDevices<public>(Audio : []audio_player_device) : void =
        if (not EndStingers.TitleES?):
            set EndStingers.TitleES = option{Audio[0]}

            Channel.Print("[ Device Found: Overriding [Title End Stinger] ]")


        if (not EndStingers.DayES?):
            set EndStingers.DayES = option{Audio[1]}

            Channel.Print("[ Device Found: Overriding [Day End Stinger] ]")


        if (not EndStingers.NightES?):
            set EndStingers.NightES = option{Audio[2]}

            Channel.Print("[ Device Found: Overriding [Night End Stinger] ]")


        if (not EndStingers.MinigameES?):
            set EndStingers.MinigameES = option{array{Audio[3], Audio[4], Audio[5], Audio[6]}}

            Channel.Print("[ Device Found: Overriding [Minigame End Stinger] ]")


        if (not OneShots.ScoreCue?):
            set OneShots.ScoreCue = option{Audio[7]}

            Channel.Print("[ Device Found: Overriding [Score Cue] ]")


        if (not OneShots.TransitionCues?):
            set OneShots.TransitionCues = option{array{Audio[8], Audio[9], Audio[10]}}

            Channel.Print("[ Device Found: Overriding [Transition Cues] ]")


        
music_loop_tracks<public> := class<concrete>:

    @editable
    var TitleMusic<public> : ?radio_device = false
    @editable
    var DayMusic<public> : ?radio_device = false
    @editable
    var NightMusic<public> : ?radio_device = false
    @editable
    var MinigameMusic<public>: ?[]radio_device = false



ambient_loop_tracks<public> := class<concrete>:

    @editable
    var DayAmbience<public> : ?radio_device = false
    @editable
    var NightAmbience<public> : ?radio_device = false
    @editable
    var IndoorAmbience<public> : ?radio_device = false



end_stinger_tracks<public> := class<concrete>:

    @editable
    var TitleES<public> : ?audio_player_device = false
    @editable
    var DayES<public> : ?audio_player_device = false
    @editable
    var NightES<public> : ?audio_player_device = false
    @editable
    var MinigameES<public> : ?[]audio_player_device = false



one_shot_tracks<public> := class<concrete>:

    @editable
    var ScoreCue<public> : ?audio_player_device = false
    @editable
    var TransitionCues<public> : ?[]audio_player_device = false
