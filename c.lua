local player = game.Players.LocalPlayer
local deviceSelectUI = player.PlayerGui:WaitForChild("DeviceSelect"):WaitForChild("Container"):WaitForChild("Phone")

while deviceSelectUI.Parent.Parent.Enabled do
    local args = {"Phone"}
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("ChangeLastDevice"):FireServer(unpack(args))
    wait(0.1)
end

-- Đây là nơi để thêm script chính của bạn
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local userInterface = player:WaitForChild("PlayerGui")

local maps = {
    "Factory", "BioLab", "House2", "Hospital3", "Workplace", "MilBase", "Bank2", "Hotel2", "Mansion2", "Office3", "PoliceStation", "ResearchFacility", "Hotel", "VampireCastle"
}

local character = nil
local humanoidRootPart = nil
local humanoid = nil
local autoFarmEnabled = true
local noclipEnabled = true
local mapFirstCoinCollected = {}
local virtualFloor = nil
local floorConnection = nil
local noclipConnection = nil
local autoFarmCoroutine = nil

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = userInterface
screenGui.Name = "AutoFarmGui"
screenGui.DisplayOrder = 999999

local statusFrame = Instance.new("Frame", screenGui)
statusFrame.Size = UDim2.new(0, 200, 0, 30)
statusFrame.Position = UDim2.new(0.5, -100, 0, 10)
statusFrame.BackgroundColor3 = Color3.new(0, 0, 0)
statusFrame.BackgroundTransparency = 0.5

local statusLabel = Instance.new("TextLabel", statusFrame)
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.Text = "AutoFarm: ACTIVE"
statusLabel.TextColor3 = Color3.new(0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextScaled = true

local function updateCharacterReferences()
    character = player.Character
    if character then
        humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        humanoid = character:FindFirstChild("Humanoid")
        return true
    end
    return false
end

local function waitForCharacter()
    while not character or not humanoidRootPart or not humanoid do
        if player.Character then
            updateCharacterReferences()
        end
        wait(0.5)
    end
end

local function createVirtualFloor()
    if virtualFloor then
        virtualFloor:Destroy()
    end
    
    if not humanoidRootPart then
        return
    end
    
    virtualFloor = Instance.new("Part")
    virtualFloor.Size = Vector3.new(20, 1, 20) 
    virtualFloor.Anchored = true
    virtualFloor.CanCollide = true
    virtualFloor.Transparency = 1
    virtualFloor.Name = "VirtualFloor"
    virtualFloor.Parent = workspace
    
    local function updateFloorPosition()
        if virtualFloor and virtualFloor.Parent and humanoidRootPart and humanoidRootPart.Parent then
            virtualFloor.CFrame = CFrame.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y - 3.5, humanoidRootPart.Position.Z)
        end
    end
    
    updateFloorPosition()
    
    if floorConnection then
        floorConnection:Disconnect()
    end
    floorConnection = RunService.Heartbeat:Connect(updateFloorPosition)
end

local function destroyVirtualFloor()
    if virtualFloor then
        virtualFloor:Destroy()
        virtualFloor = nil
    end
    if floorConnection then
        floorConnection:Disconnect()
        floorConnection = nil
    end
end

local function startNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    noclipConnection = RunService.Heartbeat:Connect(function()
        if noclipEnabled and character and character.Parent then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function teleportToCoin(coin)
    if not humanoidRootPart or not coin then
        return
    end
    
    humanoidRootPart.CFrame = coin.CFrame

    if coin:FindFirstChild("TouchInterest") then
        firetouchinterest(humanoidRootPart, coin, 0)
        firetouchinterest(humanoidRootPart, coin, 1)
    end

    wait(0.1)
    
    if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
end

local function tweenToCoin(coin)
    if not humanoidRootPart or not coin then
        return
    end
    
    local distance = (humanoidRootPart.Position - coin.Position).Magnitude
    local walkSpeed = 16
    local adjustedSpeed = walkSpeed * 1.2
    local tweenSpeed = distance / adjustedSpeed
    tweenSpeed = math.max(tweenSpeed, 0.5)

    local tweenInfo = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
    local tweenGoal = {CFrame = coin.CFrame}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)
    tween:Play()

    local completed = false
    local connection
    connection = tween.Completed:Connect(function()
        completed = true
        connection:Disconnect()
    end)
    
    while not completed and humanoidRootPart and humanoidRootPart.Parent and humanoid and humanoid.Health > 0 do
        wait(0.1)
    end
    
    if not completed then
        tween:Cancel()
        if connection then
            connection:Disconnect()
        end
        return
    end

    if coin:FindFirstChild("TouchInterest") and humanoidRootPart then
        firetouchinterest(humanoidRootPart, coin, 0)
        firetouchinterest(humanoidRootPart, coin, 1)
    end

    wait(0.1)
    
    if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
end

local function startAutoFarm()
    if autoFarmCoroutine then
        coroutine.close(autoFarmCoroutine)
    end
    
    autoFarmCoroutine = coroutine.create(function()
        while autoFarmEnabled do
            if not character or not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
                statusLabel.Text = "AutoFarm: WAITING FOR RESPAWN"
                statusLabel.TextColor3 = Color3.new(1, 1, 0)
                waitForCharacter()
                createVirtualFloor()
                startNoclip()
                statusLabel.Text = "AutoFarm: ACTIVE"
                statusLabel.TextColor3 = Color3.new(0, 1, 0)
            end
            
            for _, mapName in ipairs(maps) do
                if not autoFarmEnabled then
                    break
                end
                
                if not character or not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
                    break
                end
                
                local map = workspace:FindFirstChild(mapName)
                if map then
                    local coinContainer = map:FindFirstChild("CoinContainer")
                    if coinContainer then
                        local coins = {}
                        for _, coin in ipairs(coinContainer:GetChildren()) do
                            if coin:IsDescendantOf(workspace) and coin:FindFirstChild("CoinVisual") then
                                table.insert(coins, coin)
                            end
                        end
                        
                        if #coins > 0 then
                            table.sort(coins, function(a, b)
                                if a:IsA("BasePart") and b:IsA("BasePart") and humanoidRootPart then
                                    return (humanoidRootPart.Position - a.Position).Magnitude < (humanoidRootPart.Position - b.Position).Magnitude
                                end
                                return false
                            end)
                            
                            local firstCoin = coins[1]
                            if not mapFirstCoinCollected[mapName] then
                                if firstCoin:FindFirstChild("CoinVisual") then
                                    teleportToCoin(firstCoin.CoinVisual)
                                    mapFirstCoinCollected[mapName] = true
                                end
                            else
                                if firstCoin:FindFirstChild("CoinVisual") then
                                    teleportToCoin(firstCoin.CoinVisual)
                                end
                                for _, coin in ipairs(coins) do
                                    if not autoFarmEnabled then
                                        break
                                    end
                                    if not character or not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
                                        break
                                    end
                                    if coin:FindFirstChild("CoinVisual") then
                                        tweenToCoin(coin.CoinVisual)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            wait(1)
        end
    end)
    
    coroutine.resume(autoFarmCoroutine)
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    local hrp = character:WaitForChild("HumanoidRootPart")
    local hum = character:WaitForChild("Humanoid")
    humanoidRootPart = hrp
    humanoid = hum
    createVirtualFloor()
    startNoclip()
    humanoid.Died:Connect(function()
        destroyVirtualFloor()
        stopNoclip()
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
    onCharacterAdded(player.Character)
end

player.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then
        local rejoinButton = Instance.new("TextButton", screenGui)
        rejoinButton.Size = UDim2.new(0, 200, 0, 50)
        rejoinButton.Position = UDim2.new(0.5, -100, 0, 50)
        rejoinButton.Text = "Rejoin Game"
        rejoinButton.TextScaled = true
        rejoinButton.MouseButton1Click:Connect(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end)
    end
end)

startAutoFarm()
