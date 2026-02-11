local p = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local MY_BASE = CFrame.new(396.012, 1.039, 5.902) 

-- Remotes con rutas seguras para ejecutores móviles
local cashRemote = RS:WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("CollectEarnings")
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("UpgradeBrainrot")
local raidRemote = RS:FindFirstChild("BrainrotStolen", true)

local activeButtons = {}

-- FUNCIÓN DE COBRO MULTIPLE (Cobra de todas las máquinas)
local function collectAllCash()
    for i = 1, 20 do -- Barrido del 1 al 20 para agarrar todo el dinero
        pcall(function()
            cashRemote:FireServer(tostring(i))
        end)
    end
    -- También recolecta lo que esté físicamente en el suelo cerca
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("BasePart") and (v.Name:find("Cash") or v.Name:find("Coin")) then
            if (p.Character.HumanoidRootPart.Position - v.Position).Magnitude < 50 then
                firetouchinterest(p.Character.HumanoidRootPart, v, 0)
                task.wait()
                firetouchinterest(p.Character.HumanoidRootPart, v, 1)
            end
        end
    end
end

-- Función de TP Seguro
local function SafeTP(cf)
    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        p.Character.HumanoidRootPart.CFrame = cf
    end
end

-- Función de Raid
local function raidItem(rarity)
    local bases = workspace:FindFirstChild("Brainrot Bases")
    if bases then
        for _, base in pairs(bases:GetChildren()) do
            for _, obj in pairs(base:GetDescendants()) do
                if (obj.Name == "Rarity" or obj.Name == "Mutation") and obj:IsA("TextLabel") then
                    if obj.Text:lower():find(rarity:lower()) then
                        local root = obj.Parent.Parent.Parent
                        if root and root:IsA("BasePart") then
                            SafeTP(root.CFrame)
                            local t = 0
                            while root and root.Parent and t < 22 do
                                pcall(function() raidRemote:FireServer(1) end)
                                task.wait(0.1)
                                t = t + 1
                            end
                            task.wait(0.3)
                            SafeTP(MY_BASE)
                            if activeButtons[rarity] then activeButtons[rarity]() end
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- --- INTERFAZ (ESTILO VIDEO) ---
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 200, 0, 350)
Main.Position = UDim2.new(0.8, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(255, 105, 180); Stroke.Thickness = 2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "YT: LUKZ SCRIPTS"; Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.BorderSizePixel = 0

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -10, 1, -85); Container.Position = UDim2.new(0, 5, 0, 40)
Container.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", Container); UIList.Padding = UDim.new(0, 5)

local function CreateToggle(name, rarity, type)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = "  " .. name; btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.Gotham; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local box = Instance.new("Frame", btn)
    box.Size = UDim2.new(0, 32, 0, 14); box.Position = UDim2.new(1, -38, 0.5, -7)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame", box)
    dot.Size = UDim2.new(0, 10, 0, 10); dot.Position = UDim2.new(0, 2, 0.5, -5)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local enabled = false
    local function update()
        dot.Position = enabled and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        box.BackgroundColor3 = enabled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = enabled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(180, 180, 180)
    end

    if type == "raid" then activeButtons[rarity] = function() enabled = false; update() end end

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled; update()
        task.spawn(function()
            while enabled do
                if type == "freeze" then
                    pcall(function() for _, b in pairs(workspace["Brainrot Bases"]:GetChildren()) do
                        local k = b:FindFirstChild("Killer")
                        if k then for _, m in pairs(k:GetChildren()) do
                            for _, pt in pairs(m:GetDescendants()) do if pt:IsA("BasePart") then pt.Anchored = true end end
                        end end
                    end end)
                elseif type == "cash" then collectAllCash()
                elseif type == "upgrade" then for i=1,50 do pcall(function() upgradeRemote:InvokeServer(tostring(i)) end) end
                elseif type == "raid" then if raidItem(rarity) then break end
                end
                task.wait(1)
            end
        end)
    end)
end

CreateToggle("FREEZE BOSSES", nil, "freeze")
CreateToggle("COLLECT CASH", nil, "cash")
CreateToggle("AUTO UPGRADE", nil, "upgrade")
CreateToggle("AUTO SECRET", "Secret", "raid")
CreateToggle("AUTO MYTHIC", "Mythic", "raid")
CreateToggle("AUTO EPIC", "Epic", "raid")
CreateToggle("AUTO GOLD", "Gold", "raid")

local gobase = Instance.new("TextButton", Main)
gobase.Size = UDim2.new(1, -10, 0, 35); gobase.Position = UDim2.new(0, 5, 1, -40)
gobase.BackgroundColor3 = Color3.fromRGB(255, 105, 180); gobase.Text = "GO TO MY BASE"
gobase.TextColor3 = Color3.fromRGB(10, 10, 10); gobase.Font = Enum.Font.GothamBold; gobase.TextSize = 13; gobase.BorderSizePixel = 0
Instance.new("UICorner", gobase).CornerRadius = UDim.new(0, 4)
gobase.MouseButton1Click:Connect(function() SafeTP(MY_BASE) end)
