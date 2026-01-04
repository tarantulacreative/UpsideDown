
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

tagged_base_platform<public> := class(tag):

# -----------------------------------------------------------------------------------------------------------------

tagged_player_device<public> := class(tag):


tagged_csd_camera<public> := class(tagged_player_device):

tagged_csd_hud_parameters<public> := class(tagged_player_device):

tagged_csd_transitions<public> := class(tagged_player_device):

tagged_csd_additive<public> := class(tagged_player_device):

tagged_csd_quest_1<public> := class(tagged_player_device):
    
tagged_csd_quest_2<public> := class(tagged_player_device):
    
tagged_csd_quest_3<public> := class(tagged_player_device):

tagged_tracker_quest_1<public> := class(tagged_player_device):
    
tagged_tracker_quest_2<public> := class(tagged_player_device):
    
tagged_tracker_quest_3<public> := class(tagged_player_device):
    
tagged_popup_title_sequence<public> := class(tagged_player_device):
    
tagged_popup_dialog_box<public> := class(tagged_player_device):
    
tagged_chair_player_seat<public> := class(tagged_player_device):
    

# -----------------------------------------------------------------------------------------------------------------

tagged_world_device<public> := class(tag):


tagged_mode_detector<public> := class(tagged_world_device):

tagged_debug_messages<public> := class(tagged_world_device):
    
tagged_hud<public> := class(tagged_world_device):

tagged_trackable_inputs<public> := class(tagged_world_device):

tagged_teleporter<public> := class(tagged_world_device):

tagged_radio_tracks<public> := class(tagged_world_device):
    
tagged_audio_tracks<public> := class(tagged_world_device):


tagged_third_person_controller<public> := class(tagged_world_device):
    

tagged_player_camera<public> := class(tagged_world_device):

tagged_interaction_camera<public> := class(tagged_world_device):

tagged_player_menu_camera<public> := class(tagged_world_device):


# -------------------------------------------------------------


tagged_lobby_checkbox<public> := class(tagged_world_device):
    































