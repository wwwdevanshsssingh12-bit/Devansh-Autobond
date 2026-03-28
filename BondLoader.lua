--[=[
    💎 DEVANSH PREMIUM AUTO-BOND (STRICT TARGETING FIX)
    Architecture: Teleport-Chunking, Anti-Gravity, Strict 'bond' + 'serverEntity' Extraction
    Developer: Devansh
]=]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- RINGTA CONFIGURATION 
-- ==========================================
local FarmConfig = {
    Axis = "Z",                -- Change to "X" if the map runs sideways
    SweepDistance = 80000,     -- Travels 0 to 80,000 meters
    StepSize = 500,            -- Teleports 500 studs at a time
    HoverHeight = 50,          
    
    MainWaitTime = 0.8,        -- Wait time at each stop for the town to load
    CollectWaitTime = 0.3,     -- Wait time to pick up the bond
    
    TotalCollected = 0,
    RunCollected = 0
}

local ActionableRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Network"):WaitForChild("RemoteEvent"):WaitForChild("Actionable")

-- ==========================================
-- PREMIUM FULL-SCREEN UI
-- ==========================================
local SecureUI = (gethui and gethui()) or CoreGui
local HubName = "DevanshRingtaClone"

if SecureUI:FindFirstChild(HubName) then SecureUI[HubName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = HubName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
ScreenGui.Parent = SecureUI

local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
Background.BackgroundTransparency = 0.15 
Background.BorderSizePixel = 0
Background.Parent = ScreenGui

local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 600, 0, 300)
Container.Position = UDim2.new(0.5, -300, 0.5, -150)
Container.BackgroundTransparency = 1
Container.Parent = Background

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Text = "DEVANSH BOND FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 42
Title.BackgroundTransparency = 1
Title.Parent = Container

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 40)
Status.Position = UDim2.new(0, 0, 0, 100)
Status.Text = "STRICT TARGETING ACTIVE"
Status.TextColor3 = Color3.fromRGB(50, 255, 50)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 22
Status.BackgroundTransparency = 1
Status.Parent = Container

local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1, 0, 0, 50)
Stats.Position = UDim2.new(0, 0, 1, -50)
Stats.Text = "0 bonds collected (0 this run)"
Stats.TextColor3 = Color3.fromRGB(0, 255, 255)
Stats.Font = Enum.Font.GothamBold
Stats.TextSize = 26
Stats.BackgroundTransparency = 1
Stats.Parent = Container

local function UpdateTrackerUI()
    Stats.Text = string.format("%d bonds collected (%d this run)", FarmConfig.TotalCollected, FarmConfig.RunCollected)
end

-- ==========================================
-- STRICT TARGETING ENGINE (FIXED)
-- ==========================================
local function FindBondsInChunk()
    local bonds = {}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- STRICT FILTER: Must be a Model, and MUST be named exactly "bond" (ignoring capitals)
        if obj:IsA("Model") and string.lower(obj.Name) == "bond" then
            local networkID = obj:GetAttribute("serverEntity")
            if networkID then
                local part = obj:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    table.insert(bonds, {Model = obj, Part = part, ID = networkID})
                end
            end
        end
    end
    
    return bonds
end

local function ExecuteCollection(bondData, root)
    -- Teleport directly to the bond
    root.CFrame = CFrame.new(bondData.Part.Position + Vector3.new(0, 1.5, 0))
    
    -- Wait to ensure the server registers we are standing on it
    task.wait(FarmConfig.CollectWaitTime)
    
    -- Fire Remote with the exact ID
    pcall(function() ActionableRemote:FireServer(bondData.ID) end)
    
    -- Native Touch Failsafe
    if firetouchinterest then
        firetouchinterest(root, bondData.Part, 0)
        task.wait(0.05)
        firetouchinterest(root, bondData.Part, 1)
    end
    
    FarmConfig.TotalCollected = FarmConfig.TotalCollected + 1
    FarmConfig.RunCollected = FarmConfig.RunCollected + 1
    UpdateTrackerUI()
    
    if bondData.Model then bondData.Model:Destroy() end
end

-- ==========================================
-- THE 1:1 RINGTA TELEPORT ENGINE
-- ==========================================
local function StartRingtaSweep()
    task.spawn(function()
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        
        while not root do
            task.wait(1)
            character = LocalPlayer.Character
            root = character and character:FindFirstChild("HumanoidRootPart")
        end
        
        -- Apply Anti-Gravity
        local antiGravity = Instance.new("BodyVelocity")
        antiGravity.Velocity = Vector3.new(0, 0, 0)
        antiGravity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        antiGravity.Parent = root
        
        -- Noclip
        task.spawn(function()
            while task.wait() do
                if LocalPlayer.Character then
                    for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end
        end)
        
        local currentDistance = 0
        local lockedOtherAxis = FarmConfig.Axis == "Z" and root.Position.X or root.Position.Z
        
        while true do
            if not character or not character:FindFirstChild("Humanoid") then task.wait(1) continue end
            
            -- 1. Teleport (Step forward)
            local targetPos
            if FarmConfig.Axis == "Z" then
                targetPos = Vector3.new(lockedOtherAxis, FarmConfig.HoverHeight, currentDistance)
            else
                targetPos = Vector3.new(currentDistance, FarmConfig.HoverHeight, lockedOtherAxis)
            end
            
            root.CFrame = CFrame.new(targetPos)
            
            -- 2. Ringta 'Main Wait Time'
            Status.Text = string.format("LOADING CHUNK AT %dm...", currentDistance)
            task.wait(FarmConfig.MainWaitTime)
            
            -- 3. Scan & Collect ONLY Bonds
            local chunkBonds = FindBondsInChunk()
            if #chunkBonds > 0 then
                Status.Text = string.format("FOUND %d BONDS! COLLECTING...", #chunkBonds)
                Status.TextColor3 = Color3.fromRGB(0, 255, 255)
                
                for _, bondData in ipairs(chunkBonds) do
                    ExecuteCollection(bondData, root)
                end
                
                Status.Text = string.format("TELEPORT SWEEP ACTIVE (0 - %dm)", FarmConfig.SweepDistance)
                Status.TextColor3 = Color3.fromRGB(50, 255, 50)
            end
            
            -- 4. Move to next chunk
            currentDistance = currentDistance + FarmConfig.StepSize
            
            -- Loop back to 0 when we hit 80,000
            if currentDistance > FarmConfig.SweepDistance then
                currentDistance = 0
                task.wait(1)
            end
        end
    end)
end

-- AUTO-EXECUTE
StartRingtaSweep()
