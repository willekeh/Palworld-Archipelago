local chatView = {}

function chatView.say(messageText)
    local gameState = FindFirstOf("PalGameStateInGame")
    if not (gameState and gameState:IsValid()) then
        return false
    end
    -- MessageId is what the in-game chat shows, why not Message?! 
    -- TDO: This works in singleplayer worlds, but not multiplayer
    -- struct FPalChatMessage
    -- EPalChatCategory Category;                                                        
    -- FString Sender;                                                                  
    -- FGuid SenderPlayerUId;                                                            
    -- FString Message;                                                                  
    -- TArray<FGuid> ReceiverPlayerUIds;                                                 
    -- FName MessageId;                                                                  
    -- TArray<FString> MessageArgKeys;                                                   
    -- TArray<FString> MessageArgValues;                                                 
    gameState:BroadcastChatMessage({
        Category = 1,
        Sender = "Archipelago",
        MessageId = FName(messageText),  
    })
    return true
end

return chatView