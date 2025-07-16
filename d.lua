repeat wait() until game:IsLoaded()
if getgenv().MyMM2ScriptUI then return end
getgenv().MyMM2ScriptUI = true

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local localPlayer = Players.LocalPlayer

local processedCoins = {}
local currentMurder = nil
local isSafe = false
local circleMovement = nil
local currentCoinCenter = nil

game:GetService("RunService"):Set3dRenderingEnabled(false)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local BlackFrame = Instance.new("Frame")
BlackFrame.Parent = ScreenGui
BlackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackFrame.BorderSizePixel = 0
BlackFrame.Size = UDim2.new(1, 0, 1, 0)
BlackFrame.Position = UDim2.new(0, 0, 0, 0)
BlackFrame.ZIndex = -1

local function cleanupOtherUIs()
    pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        for _, gui in pairs(localPlayer.PlayerGui:GetChildren()) do
            if gui ~= ScreenGui and gui.Name ~= "TheaugHub_MM2" then
                gui.Enabled = false
            end
        end
        for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
            pcall(function()
                gui.Enabled = false
            end)
        end
    end)
end

cleanupOtherUIs()

spawn(function()
    while true do
        wait(1)
        cleanupOtherUIs()
    end
end)

local LogoFrame = Instance.new("Frame")
LogoFrame.Parent = ScreenGui
LogoFrame.BackgroundTransparency = 1
LogoFrame.Size = UDim2.new(0, 600, 0, 180) 
LogoFrame.Position = UDim2.new(0.5, -300, 0.5, -90)
LogoFrame.ZIndex = 10

local MainTitle = Instance.new("TextLabel")
MainTitle.Parent = LogoFrame
MainTitle.BackgroundTransparency = 1
MainTitle.Size = UDim2.new(1, 0, 0.5, 0)
MainTitle.Position = UDim2.new(0, 0, 0, 0)
MainTitle.Text = "Theaug Hub"
MainTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
MainTitle.TextScaled = true
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextStrokeTransparency = 0
MainTitle.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
MainTitle.ZIndex = 11

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = LogoFrame
SubTitle.BackgroundTransparency = 1
SubTitle.Size = UDim2.new(1, 0, 0.20, 0)
SubTitle.Position = UDim2.new(0, 0, 0.5, 0)
SubTitle.Text = "Murder Mystery 2"
SubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SubTitle.TextScaled = true
SubTitle.Font = Enum.Font.Gotham
SubTitle.ZIndex = 11

local CoinsLabel = Instance.new("TextLabel")
CoinsLabel.Parent = LogoFrame
CoinsLabel.BackgroundTransparency = 1
CoinsLabel.Size = UDim2.new(1, 0, 0.23, 0)
CoinsLabel.Position = UDim2.new(0, 0, 0.7, 10)
CoinsLabel.Text = "Coins: Loading..."
CoinsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CoinsLabel.Font = Enum.Font.Gotham
CoinsLabel.TextScaled = true
CoinsLabel.ZIndex = 11

local RenderButton = Instance.new("TextButton")
RenderButton.Parent = ScreenGui
RenderButton.Size = UDim2.new(0, 80, 0, 80)
RenderButton.Position = UDim2.new(0, 50, 0.5, -40)
RenderButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RenderButton.BorderSizePixel = 2
RenderButton.BorderColor3 = Color3.fromRGB(0, 255, 255)
RenderButton.Text = "3D\nOFF"
RenderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RenderButton.TextScaled = true
RenderButton.Font = Enum.Font.GothamBold
RenderButton.ZIndex = 12

local isUIVisible = true
RenderButton.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    
    if isUIVisible then
        game:GetService("RunService"):Set3dRenderingEnabled(false)
        BlackFrame.Visible = true
        LogoFrame.Visible = true
        RenderButton.Text = "3D\nOFF"
        RenderButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        game:GetService("RunService"):Set3dRenderingEnabled(true)
        BlackFrame.Visible = false
        LogoFrame.Visible = false
        RenderButton.Text = "3D\nON"
        RenderButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

task.spawn(function()
    while true do
        local success, err = pcall(function()
            local profileData = game:GetService("ReplicatedStorage").Remotes.Inventory.GetProfileData:InvokeServer()
            if profileData and profileData.Coins then
                local currentCoins = tostring(profileData.Coins)
                CoinsLabel.Text = "Coins: " .. currentCoins
            end
        end)
        
        if not success then
            CoinsLabel.Text = "Coins: Error"
        end
        
        wait(2)
    end
end)

repeat task.wait() until Players.LocalPlayer and Players.LocalPlayer.PlayerGui

local LocalPlayer = Players.LocalPlayer

while LocalPlayer.PlayerGui:FindFirstChild("DeviceSelect") do 
	for i,v in pairs(getconnections(LocalPlayer.PlayerGui.DeviceSelect.Container.Phone.Button.MouseButton1Click)) do 
		v:Fire()
	end
end

local function isBagFull()
	local success2, coinCount = pcall(function()
		return game:GetService("Players").LocalPlayer.PlayerGui.MainGUI.Game.CoinBags.Container.Coin.CurrencyFrame.Icon.Coins.Text
	end)
	if success2 and coinCount then
		local current = tonumber(coinCount)
		print(current)
		return current and current >= 40
	end

	return false
end

local function teleportTo(targetCFrame)
	local character = Players.LocalPlayer.Character
	if character and character:FindFirstChild('HumanoidRootPart') then
		character.HumanoidRootPart.CFrame = targetCFrame
		return true
	end
	return false
end

local function startCircleMovement(centerPosition)
	if circleMovement then
		circleMovement:Disconnect()
	end

	currentCoinCenter = centerPosition
	local angle = 0
	local radius = 0.5
	local speed = 2

	circleMovement = RunService.Heartbeat:Connect(function()
		local character = Players.LocalPlayer.Character
		if character and character:FindFirstChild('HumanoidRootPart') and currentCoinCenter then
			angle = angle + speed * 0.1
			local x = currentCoinCenter.X + math.cos(angle) * radius
			local z = currentCoinCenter.Z + math.sin(angle) * radius
			character.HumanoidRootPart.CFrame = CFrame.new(x, currentCoinCenter.Y, z)
		end
	end)
end

local function stopCircleMovement()
	if circleMovement then
		circleMovement:Disconnect()
		circleMovement = nil
	end
	currentCoinCenter = nil
end

local function findMurder()
	for _, p in pairs(Players:GetPlayers()) do
		if p == Players.LocalPlayer then continue end
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
		isSafe = true
		stopCircleMovement()
	end
end

local function returnToGround()
	local character = Players.LocalPlayer.Character
	if character and character:FindFirstChild('HumanoidRootPart') then
		local raycast = workspace:Raycast(character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0))
		if raycast then
			local groundPos = raycast.Position + Vector3.new(0, 5, 0)
			character.HumanoidRootPart.CFrame = CFrame.new(groundPos)
		end
		isSafe = false
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
			local isCoin = false
			for _, coinName in pairs(getgenv().configs.coinNames) do
				if child.Name == coinName then
					isCoin = true
					break
				end
			end
			if child:IsA('BasePart') and isCoin then
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
	while getgenv().configs.coinFarm == true and task.wait() do
		currentMurder = findMurder()
		local distanceToMurder = getDistanceToMurder()

		if not LocalPlayer:GetAttribute("Alive") then continue end
		
		if isBagFull() then
			flyToSafety()
			continue
		end

		if distanceToMurder < getgenv().configs.murderDistance then
			if not isSafe then
				flyToSafety()
				wait(getgenv().configs.safeWaitTime)
			end
		else
			if isSafe then
				returnToGround()
				wait(0.5)
			end
		end

		if not isSafe then
			local coins = findCoins()
			if #coins > 0 then
				local targetCoin = coins[1]
				processedCoins[targetCoin] = true

				if teleportTo(targetCoin.CFrame) then
					startCircleMovement(targetCoin.Position)
					wait(getgenv().configs.coinWaitTime)
				end

				wait(math.random(0.3, 0.8))

				spawn(function()
					wait(2)
					processedCoins[targetCoin] = nil
				end)
			else
				stopCircleMovement()
			end
		end

		wait(getgenv().configs.loopDelay)
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
		wait(10)
		cleanupProcessedCoins()
	end
end)

spawn(function()
	autoReset()
end)

spawn(function()
	coinFarm()
end)
