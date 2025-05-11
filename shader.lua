local lighting = game:GetService("Lighting")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

-- Backup original settings to restore later
local originalBrightness = lighting.Brightness
local originalColorCorrection = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
local originalBlur = lighting:FindFirstChildOfClass("BlurEffect")
local originalSunRays = lighting:FindFirstChildOfClass("SunRaysEffect")
local originalBloom = lighting:FindFirstChildOfClass("BloomEffect")

-- Clean up any existing effects first
if originalColorCorrection then originalColorCorrection:Destroy() end
if originalBlur then originalBlur:Destroy() end
if originalSunRays then originalSunRays:Destroy() end
if originalBloom then originalBloom:Destroy() end

-- Create new effects
local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Brightness = 0.1
colorCorrection.Contrast = 0.5
colorCorrection.Saturation = 0.5
colorCorrection.TintColor = Color3.fromRGB(255, 240, 230)
colorCorrection.Parent = lighting

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.5
bloom.Size = 20
bloom.Threshold = 0.8
bloom.Parent = lighting

local blur = Instance.new("BlurEffect")
blur.Size = 2
blur.Parent = lighting

local sunRays = Instance.new("SunRaysEffect")
sunRays.Intensity = 0.2
sunRays.Spread = 0.5
sunRays.Parent = lighting

local shaderEnabled = true
local function toggleShader()
    shaderEnabled = not shaderEnabled
    
    if shaderEnabled then
        colorCorrection.Enabled = true
        bloom.Enabled = true
        blur.Enabled = true
        sunRays.Enabled = true
    else
        colorCorrection.Enabled = false
        bloom.Enabled = false
        blur.Enabled = false
        sunRays.Enabled = false
    end
end

local userInputService = game:GetService("UserInputService")
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        toggleShader()
    end
end)

-- Function to clean up when script is terminated
local function cleanUp()
    if colorCorrection then colorCorrection:Destroy() end
    if blur then blur:Destroy() end
    if sunRays then sunRays:Destroy() end
    if bloom then bloom:Destroy() end
    
    lighting.Brightness = originalBrightness
end

print("Shader effect enabled. Press P to toggle on/off.")

while wait(1) do
    -- Add any dynamic effects here if needed
end
