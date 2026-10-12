local CONFIG = {
    ALLOWLIST_ONLY = false,
    APPLY_RAM      = true,
    APPLY_CPU      = true,
    RUNTIME        = true,
    DISABLE_3D     = false,
    MUTE_AUDIO     = true,
    FPS_CAP        = 10,
    DEBUG          = true,
}

local ALLOWLIST = {
    DFIntCSGLevelOfDetailSwitchingDistance    = "0",
    DFIntCSGLevelOfDetailSwitchingDistanceL12 = "0",
    DFIntCSGLevelOfDetailSwitchingDistanceL23 = "0",
    DFIntCSGLevelOfDetailSwitchingDistanceL34 = "0",

    DFFlagTextureQualityOverrideEnabled  = "True",
    DFIntTextureQualityOverride          = "0",
    DFIntDebugFRMQualityLevelOverride    = "1",
    FIntDebugForceMSAASamples            = "1",
    FIntFRMMaxGrassDistance              = "0",
    FIntFRMMinGrassDistance              = "0",
    FIntGrassMovementReducedMotionFactor = "0",
    DFFlagDebugPauseVoxelizer            = "True",
    FFlagDebugGraphicsPreferD3D11        = "True",
    FFlagDebugSkyGray                    = "True",
}

local RAM = {
    DFFlagSkipHighResolutiontextureMipsOnLowMemoryDevices2 = "True",
    DFIntDebugAdditionalNumberOfMipsToSkipForNonAlbedoTextures = "8",
    DFIntTextureCompositorActiveJobs         = "0",
    FIntTextureCompositorLowResFactor        = "4",
    FIntRenderMaxShadowAtlasUsageBeforeDownscale = "1",
    DFIntVideoMaxNumberOfVideosPlaying       = "0",
    DFIntNumAssetsMaxToPreload               = "1",
    DFFlagEnableTexturePreloading            = "False",
    DFFlagEnableSoundPreloading              = "False",
    FFlagPreloadTextureItemsOption4          = "False",
    DFFlagTeleportClientAssetPreloadingEnabled9 = "False",
    FStringTerrainMaterialTable2022          = "",
    FStringTerrainMaterialTablePre2022       = "",
}

local CPU = {
    DFIntTaskSchedulerTargetFps              = tostring(CONFIG.FPS_CAP),
    FFlagGameBasicSettingsFramerateCap5      = "True",
    FFlagTaskSchedulerLimitTargetFpsTo2402 = "True",
    DFIntRenderingThrottleDelayInMS          = "100",
    FIntRenderLocalLightUpdatesMax           = "1",
}

local genv = (type(getgenv) == "function") and getgenv() or {}
local setf = setfflag or genv.setfflag
local getf = getfflag or genv.getfflag

if type(setf) ~= "function" then
    warn("[Optimizer] setfflag not found: executor unsupported or blocked by client.")
    return
end

local applied, failed, suspect = 0, 0, 0

local PREFIXES = {
    "DFFlag", "DFInt", "DFString", "DFLog",
    "SFFlag", "SFInt", "SFString",
    "FFlag", "FInt", "FString", "FLog",
}

local function stripPrefix(name)
    for _, p in ipairs(PREFIXES) do
        if string.sub(name, 1, #p) == p then
            return string.sub(name, #p + 1)
        end
    end
    return name
end

local function trySet(name, value)
    local lastErr
    for _, n in ipairs({ name, stripPrefix(name) }) do
        local ok, err = pcall(setf, n, value)
        if ok then return true, n end
        lastErr = err
    end
    return false, lastErr
end

local function apply(label, tbl)
    for name, value in pairs(tbl) do
        local ok, used = trySet(name, value)
        if not ok then
            failed += 1
            if CONFIG.DEBUG then warn("[Optimizer]", label, name, "ERROR:", used) end
        else
            applied += 1
            if CONFIG.DEBUG and type(getf) == "function" then
                local okr, now = pcall(getf, used)
                if not okr or string.lower(tostring(now)) ~= string.lower(value) then
                    suspect += 1
                    print("[Optimizer]", label, used, "might be ignored")
                end
            end
        end
    end
end

apply("ALLOWLIST", ALLOWLIST)
if not CONFIG.ALLOWLIST_ONLY then
    if CONFIG.APPLY_RAM then apply("RAM", RAM) end
    if CONFIG.APPLY_CPU then apply("CPU", CPU) end
end

print(string.format("[Optimizer] FFlag: set %d | errors %d | suspect %d",
    applied, failed, suspect))

if type(setfpscap) == "function" then
    pcall(setfpscap, CONFIG.FPS_CAP)
end

if not CONFIG.RUNTIME then return end

local Workspace  = game:GetService("Workspace")
local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")

pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
pcall(function() UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
if CONFIG.MUTE_AUDIO then
    pcall(function() UserSettings():GetService("UserGameSettings").MasterVolume = 0 end)
end

pcall(function() Lighting.GlobalShadows = false end)
pcall(function() Lighting.FogEnd = 9e9 end)
if type(sethiddenproperty) == "function" then
    pcall(sethiddenproperty, Lighting, "Technology", Enum.Technology.Compatibility)
end

local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    pcall(function()
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
    end)
    if type(sethiddenproperty) == "function" then
        pcall(sethiddenproperty, terrain, "Decoration", false)
    end
end

local function strip(inst)
    if inst:IsA("BasePart") then
        inst.Material = Enum.Material.SmoothPlastic
        inst.Reflectance = 0
        inst.CastShadow = false
        if inst:IsA("MeshPart") then
            inst.RenderFidelity = Enum.RenderFidelity.Performance
            inst.TextureID = ""
        end
    elseif inst:IsA("Decal") or inst:IsA("Texture")
        or inst:IsA("SurfaceAppearance") or inst:IsA("Atmosphere") then
        inst:Destroy()
    elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
        or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles")
        or inst:IsA("PostEffect") or inst:IsA("Light") then
        inst.Enabled = false
    end
end

task.spawn(function()
    local n = 0
    for _, root in ipairs({ Workspace, Lighting }) do
        for _, inst in ipairs(root:GetDescendants()) do
            pcall(strip, inst)
            n += 1
            if n % 400 == 0 then task.wait() end
        end
    end
    print("[Optimizer] Processed", n, "instances")
end)

Workspace.DescendantAdded:Connect(function(inst)
    task.defer(function() pcall(strip, inst) end)
end)

if CONFIG.DISABLE_3D then
    pcall(function() RunService:Set3dRenderingEnabled(false) end)
end

print("[Optimizer] Completed")
