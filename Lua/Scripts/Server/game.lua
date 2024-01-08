if not Game.IsMultiplayer or (Game.IsMultiplayer and CLIENT) then return end

WR.Game = {}
WR.Game.roundwinner = "..."
WR.Game.roundend = false
WR.Game.roundtimerdelay = 1200
WR.Game.roundtimertick = 1200


Hook.add("think", "WR.RoundEnd", function()

    if WR.Game.roundend == false then return end
    -- end round after 20 secs
    WR.Game.roundtimertick = WR.Game.roundtimertick-1
    if WR.Game.roundtimertick <= 0 then
        WR.Game.roundtimertick = WR.Game.roundtimerdelay
        WR.Game.roundend = false
        Game.ExecuteCommand("end")
    end

end)

Hook.add("WR.gameobjective.xmlhook", "WR.gameobjective", function(effect, deltaTime, item, targets, worldPosition)

    if WR.Game.roundend == true then return end

    local tags = item.Tags
    local rect = item.WorldRect
    local Teams = {}
    Teams.attacker = {}
    Teams.attackerteam = {}
    Teams.defender = {}
    -- gets the defender & attacker strings from tags placed in the sub editor
    -- the first two '_' are dummy vars
    local _, _, defendertag = string.find(tags, 'defender="(.-)"')
    local _, _, attackertag = string.find(tags, 'attacker="(.-)"')
    local _, _, winnertag = string.find(tags, 'winnerifcaptured="(.-)"')

    -- gets the total number of attackers on the team
    for key,player in pairs(Client.ClientList) do
        if player.Character and (player.Character.JobIdentifier == attackertag and not player.Character.IsDead) then
            Teams.attackerteam[#Teams.attackerteam+1] = player
        end
    end
    if #Teams.attackerteam <= 0 then return end
    -- gets the number of players present
    for key,player in pairs(Client.ClientList) do
        if player.Character and (math.abs(player.Character.WorldPosition.X - rect.X - rect.Width/2) <= rect.Width/2 and math.abs(player.Character.WorldPosition.Y - rect.Y + rect.Height/2) <= rect.Height/2) then
            if player and (player.Character.JobIdentifier == defendertag and not (player.Character.IsDead or player.Character.IsUnconscious)) then
                Teams.defender[#Teams.defender+1] = player
            elseif player and (player.Character.JobIdentifier == attackertag and not (player.Character.IsDead or player.Character.IsUnconscious)) then
                Teams.attacker[#Teams.attacker+1] = player
            end
        end
    end
    -- if there is more then 50% of the alive attacker team present and no defender then the round ends with attacker victory
    if math.abs(#Teams.attacker/#Teams.attackerteam) > 0.5 and #Teams.defender == 0 then
        WR.Game.roundwinner = string.gsub(winnertag, "_", " ") or "Unknown winner"
        WR.Game.roundend = true
    end

end)

Hook.add("roundEnd", "WR.RoundEndScreen", function()
    local winnermessage = WR.Game.roundwinner .. " is the winner!"

    Timer.Wait(function()
        WR.SendMessageToAllClients(winnermessage)

        WR.Game.roundwinner = "..."
    end, 3*1000)
end)