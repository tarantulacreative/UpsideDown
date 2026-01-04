
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

using { World }
using { Utility }

var PlayerSaveData<public> : weak_map(player, player_save_data) = map:

SuccessfulDataSavedMessage<public><localizes> : message = "Player Data Saved"
UnsuccessfulDataSavedMessage<public><localizes> : message = "Unable to Save Data"
SuccessfulDataLoadedMessage<public><localizes> : message = "Player Data Loaded"
UnsuccessfulDataLoadedMessage<public><localizes> : message = "Unable to Load Data"

# -----------------------------------------------------------------------------------------------------------------

player_save_data<public> := class<final><persistable>:

    Version<public> : int = 0

    CurrentStreak<public> : int = 0

    HighestStreak<public> : int = 0
    
    ItemsPurchased<public> : int = 0


MakePlayerSaveData<public><constructor>(SourceData : player_save_data, UpdatedData : player_game_data)<transacts> := player_save_data:
    Version := SourceData.Version
    CurrentStreak := UpdatedData.CurrentStreak
    HighestStreak := UpdatedData.HighestStreak
    ItemsPurchased := UpdatedData.ItemsPurchased





# -----------------------------------------------------------------------------------------------------------------


Save<public>(PlayerContainer : player_container)<transacts> : void =
    if:
        SavedData := PlayerSaveData[PlayerContainer.Agent]
        set PlayerSaveData[PlayerContainer.Agent] = MakePlayerSaveData(SavedData, PlayerContainer.PlayerGameData)
        Print(SuccessfulDataSavedMessage)

    else Print(UnsuccessfulDataSavedMessage)


Load<public>(PlayerContainer : player_container)<transacts> : void =
    if:
        SavedData := PlayerSaveData[PlayerContainer.Agent]
        set PlayerContainer.PlayerGameData = MakePlayerGameData(SavedData)
        Print(SuccessfulDataLoadedMessage)

    else Print(UnsuccessfulDataLoadedMessage)


