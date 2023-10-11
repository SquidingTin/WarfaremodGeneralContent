if Game.IsMultiplayer and CLIENT then return end

function WR.IsEnemyPOW(character, FriendlyTeam)
    if character.isHuman == true
    and character.IsDead == false
    and character.JobIdentifier ~= FriendlyTeam
    and character.LockHands == true
    then
        return true
    else
        return false
    end
end

-- Thanks Mellon <3
function WR.SpawnInventoryItems(Items, TargetInventory)
    for Item in Items do
        local ItemPrefab = Item.Prefab
        local ItemInventory = Item.OwnInventory
        -- Spawn items inside inventory of its container
        Entity.Spawner.AddItemToSpawnQueue(ItemPrefab, TargetInventory, nil, nil, function(WorldItem)
            -- Spawn item inside other items
            if ItemInventory ~= nil then
                ItemsInInventory = Item.OwnInventory.FindAllItems(predicate, false, list)
                WR.SpawnInventoryItems(ItemsInInventory, WorldItem.OwnInventory)
            end
        end)
    end
end