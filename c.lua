local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local userInterface = player:WaitForChild("PlayerGui")

local maps = {
    "Factory",
    "BioLab",
    "House2",
    "Hospital3",
    "Workplace",
    "MilBase",
    "Bank2",
    "Hotel2",
    "Mansion2",
    "Office3",
    "PoliceStation",
    "ResearchFacility",
    "Hotel",
    "VampireCastle"
}

print("Debug: Loaded player, character, and maps.")

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = userInterface
screenGui.Name = "AutoFarmGui"
screenGui.DisplayOrder = 999999

local speedValue = 100
local autoFarmEnabled = false
local noclipEnabled = false
local mapFirstCoinCollected = {}

local configFolder = workspace:FindFirstChild("AutoFarmConfig")
if not configFolder then
    configFolder = Instance.new("Folder")
    configFolder.Name = "AutoFarmConfig"
    configFolder.Parent = workspace
end

local speedConfig = Instance.new("IntValue", configFolder)
speedConfig.Name = "SpeedValue"
speedConfig.Value = speedValue

local autoFarmConfig = Instance.new("BoolValue", configFolder)
autoFarmConfig.Name = "AutoFarmEnabled"
autoFarmConfig.Value = autoFarmEnabled

local buttonFrame = Instance.new("Frame", screenGui)
buttonFrame.Size = UDim2.new(0, 200, 0, 50)
buttonFrame.Position = UDim2.new(0.5, -100, 0, 70)

local startStopButton = Instance.new("TextButton", buttonFrame)
startStopButton.Size = UDim2.new(1, 0, 1, 0)
startStopButton.Text = "Start AutoFarm"

startStopButton.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    autoFarmConfig.Value = autoFarmEnabled
    if autoFarmEnabled then
        startStopButton.Text = "Stop AutoFarm"
        noclipEnabled = true
        print("Debug: AutoFarm started.")
        startAutoFarm()
    else
        startStopButton.Text = "Start AutoFarm"
        noclipEnabled = false
        print("Debug: AutoFarm stopped.")
    end
end)

local function noclip()
    while noclipEnabled do
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        wait(0.1)
    end
end

coroutine.wrap(noclip)()

local function teleportToCoin(coin)
    print("Debug: Teleporting to coin: " .. coin:GetFullName())
    humanoidRootPart.CFrame = coin.CFrame

    if coin:FindFirstChild("TouchInterest") then
        print("Debug: Firing touch interest for coin: " .. coin:GetFullName())
        firetouchinterest(humanoidRootPart, coin, 0)
        firetouchinterest(humanoidRootPart, coin, 1)
    end

    wait(0.1)

    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
end

local function tweenToCoin(coin)
    print("Debug: Tweening to coin: " .. coin:GetFullName())
    local distance = (humanoidRootPart.Position - coin.Position).Magnitude

    local walkSpeed = 16
    local adjustedSpeed = walkSpeed * 1.2
    local tweenSpeed = distance / adjustedSpeed

    tweenSpeed = math.max(tweenSpeed, 0.5)

    local tweenInfo = TweenInfo.new(
        tweenSpeed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.InOut
    )
    local tweenGoal = {CFrame = coin.CFrame}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)
    tween:Play()

    if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
        tween.Completed:Wait()

        if coin:FindFirstChild("TouchInterest") then
            print("Debug: Firing touch interest for coin: " .. coin:GetFullName())
            firetouchinterest(humanoidRootPart, coin, 0)
            firetouchinterest(humanoidRootPart, coin, 1)
        end

        wait(0.1)

        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    else
        print("Debug: Player is no longer alive, stopping tween.")
        tween:Cancel()
    end
end

function startAutoFarm()
    coroutine.wrap(function()
        while autoFarmEnabled do
            for _, mapName in ipairs(maps) do
                local map = workspace:FindFirstChild(mapName)
                if map then
                    print("Debug: Found map: " .. mapName)
                    local coinContainer = map:FindFirstChild("CoinContainer")
                    if coinContainer then
                        print("Debug: Found coin container in map: " .. mapName)
                        local coins = {}
                        for _, coin in ipairs(coinContainer:GetChildren()) do
                            if not coin:IsDescendantOf(workspace) then
                                print("Debug: Skipping already collected coin: " .. coin:GetFullName())
                            elseif not coin:FindFirstChild("CoinVisual") then
                                print("Debug: Skipping invalid coin: " .. coin:GetFullName())
                            else
                                table.insert(coins, coin)
                            end
                        end
                        table.sort(coins, function(a, b)
                            if a:IsA("BasePart") and b:IsA("BasePart") then
                                return (humanoidRootPart.Position - a.Position).Magnitude < (humanoidRootPart.Position - b.Position).Magnitude
                            end
                            return false
                        end)
                        if #coins > 0 then
                            local firstCoin = coins[1]
                            if not mapFirstCoinCollected[mapName] then
                                if firstCoin:FindFirstChild("CoinVisual") then
                                    teleportToCoin(firstCoin.CoinVisual)
                                    mapFirstCoinCollected[mapName] = true
                                end
                            else
                                teleportToCoin(firstCoin.CoinVisual)
                                for _, coin in ipairs(coins) do
                                    if not autoFarmEnabled then
                                        print("Debug: AutoFarm stopped, exiting loop.")
                                        return
                                    end
                                    if coin:FindFirstChild("CoinVisual") then
                                        tweenToCoin(coin.CoinVisual)
                                    end
                                end
                            end
                        end
                    else
                        print("Debug: No coin container found in map: " .. mapName)
                    end
                else
                    print("Debug: Map not found: " .. mapName)
                end
            end
            wait(1)
        end
    end)()
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    print("Debug: Character respawned, GUI remains visible.")
    if autoFarmEnabled then
        print("Debug: Resuming AutoFarm after respawn.")
        startAutoFarm()
    end
end)

player.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then
        local rejoinButton = Instance.new("TextButton", screenGui)
        rejoinButton.Size = UDim2.new(0, 200, 0, 50)
        rejoinButton.Position = UDim2.new(0.5, -100, 0, 130)
        rejoinButton.Text = "Rejoin Game"
        rejoinButton.MouseButton1Click:Connect(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end)
    end
end)
