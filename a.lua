local plr = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local coins = {"Coin_Server", "CoinVisual", "MainCoin"}
local coinsSet = {}
local currentTarget = nil
local targetTime = 0
local isTweening = false

for _, name in pairs(coins) do
    coinsSet[name] = true
end

local function setupNoclip()
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

setupNoclip()

char.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") then
        child.CanCollide = false
    end
end)

function Tween(P1)
    local Distance = (P1.Position - hrp.Position).Magnitude
    local Speed = 200
    
    if Distance < 150 then
        Speed = 5000
    elseif Distance < 200 then
        Speed = 1500
    elseif Distance < 300 then
        Speed = 800
    elseif Distance < 500 then
        Speed = 500
    elseif Distance < 1000 then
        Speed = 250
    elseif Distance >= 1000 then
        Speed = 250
    end
    
    local virtualFloor = Instance.new("Part")
    virtualFloor.Size = Vector3.new(20, 1, 20) 
    virtualFloor.Anchored = true
    virtualFloor.CanCollide = true
    virtualFloor.Transparency = 1
    virtualFloor.Name = "VirtualFloor"
    
    local function updateFloorPosition()
        if virtualFloor and virtualFloor.Parent then
            virtualFloor.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
        end
    end
    
    virtualFloor.Parent = workspace
    updateFloorPosition()
    
    local floorConnection = rs.Heartbeat:Connect(updateFloorPosition)
    
    isTweening = true
    local tween = ts:Create(
        hrp,
        TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),
        {CFrame = P1}
    )
    tween:Play()
    
    _G.Clip = true
    tween.Completed:Connect(function()
        isTweening = false
        _G.Clip = false
        
        if floorConnection then
            floorConnection:Disconnect()
        end
        if virtualFloor and virtualFloor.Parent then
            virtualFloor:Destroy()
        end
    end)
end

local function findNearestCoin(excludeTarget)
    local nearest = nil
    local minDist = math.huge
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and coinsSet[obj.Name] and obj ~= excludeTarget then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = obj
            end
        end
    end
    
    return nearest
end

rs.Heartbeat:Connect(function()
    if isTweening then return end
    
    local currentTime = tick()
    
    if not currentTarget or not currentTarget.Parent or currentTime - targetTime > 0.5 then
        if currentTarget and currentTarget.Parent then
            pcall(function()
                currentTarget:Destroy()
            end)
        end
        
        currentTarget = findNearestCoin(currentTarget)
        targetTime = currentTime
    end
    
    if currentTarget and currentTarget.Parent then
        Tween(currentTarget)
    end
end)
local plr = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local coins = {"Coin_Server", "CoinVisual", "MainCoin"}
local coinsSet = {}
local currentTarget = nil
local targetTime = 0

for _, name in pairs(coins) do
    coinsSet[name] = true
end

local function setupNoclip()
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

setupNoclip()

char.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") then
        child.CanCollide = false
    end
end)

local function findNearestCoin(excludeTarget)
    local nearest = nil
    local minDist = math.huge
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and coinsSet[obj.Name] and obj ~= excludeTarget then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = obj
            end
        end
    end
    
    return nearest
end

rs.Heartbeat:Connect(function()
    local currentTime = tick()
    
    if not currentTarget or not currentTarget.Parent or currentTime - targetTime > 0.5 then
        if currentTarget and currentTarget.Parent then
            pcall(function()
                currentTarget:Destroy()
            end)
        end
        
        currentTarget = findNearestCoin(currentTarget)
        targetTime = currentTime
    end
    
    if currentTarget and currentTarget.Parent then
        hrp.CFrame = CFrame.new(currentTarget.Position)
    end
end)
