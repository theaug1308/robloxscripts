getgenv().configs = {
    coinFarm = true,
    safeHeight = 100,
    murderDistance = 10,
    coinWaitTime = 0.05,
    loopDelay = 0.01,
    safeWaitTime = 2,
    resetInterval = 300,
    enableAutoReset = true
}

local Players = game:GetService('Players')

local processedCoins = {}
local currentMurder = nil

local function teleportTo(targetCFrame)
    local character = Players.LocalPlayer.Character
    if character and character:FindFirstChild('HumanoidRootPart') then
        character.HumanoidRootPart.CFrame = targetCFrame
        return true
    end
    return false
end

local function findMurder()
    for _, p in pairs(Players:GetPlayers()) do
        local items = p.Backpack
        local character = p.Character
        
        if (items and items:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife")) then
            return p
        end
    end
    return nil
end

local function getDistanceToMurder()
    if not currentMurder or not currentMurder.Character then return math.huge end
    
    local myChar = Players.LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild('HumanoidRootPart') then return math.huge end
    
    local murderChar = currentMurder.Character
    if not murderChar or not murderChar:FindFirstChild('HumanoidRootPart') then return math.huge end
    
    return (myChar.HumanoidRootPart.Position - murderChar.HumanoidRootPart.Position).Magnitude
end

local function flyToSafety()
    local character = Players.LocalPlayer.Character
    if character and character:FindFirstChild('HumanoidRootPart') then
        local currentPos = character.HumanoidRootPart.Position
        local safePos = Vector3.new(currentPos.X, currentPos.Y + getgenv().configs.safeHeight, currentPos.Z)
        character.HumanoidRootPart.CFrame = CFrame.new(safePos)
    end
end

local function autoReset()
    while getgenv().configs.enableAutoReset do
        wait(getgenv().configs.resetInterval)
        if Players.LocalPlayer.Character then
            Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
        end
    end
end

local function findCoins()
    local coins = {}
    local function searchRecursive(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA('BasePart') and child.Name == "Coin_Server" then
                if not processedCoins[child] then
                    table.insert(coins, child)
                end
            end
            searchRecursive(child)
        end
    end
    searchRecursive(game.Workspace)
    return coins
end

local function coinFarm()
    while getgenv().coinFarm == true do
        local coins = findCoins()
        if #coins > 0 then
            local targetCoin = coins[1]
            processedCoins[targetCoin] = true
            if teleportTo(targetCoin.CFrame) then
                wait(0.5)
                processedCoins[targetCoin] = nil
            end
        end
        wait(0.1)
    end
end

local function cleanupProcessedCoins()
    for coin, _ in pairs(processedCoins) do
        if not coin.Parent then
            processedCoins[coin] = nil
        end
    end
end

spawn(function()
    while true do
        wait(5)
        cleanupProcessedCoins()
    end
end)

spawn(function()
    autoReset()
end)

spawn(function()
    coinFarm()
end)
