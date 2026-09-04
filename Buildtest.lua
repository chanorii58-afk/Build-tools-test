local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local _, CoreGui = pcall(function() return game:GetService("CoreGui") end)
local Mouse = LocalPlayer:GetMouse()

local spawnFn = task and task.spawn or spawn
local waitFn = task and task.wait or wait

local function sendAlert(message, hexColor, color3)
spawnFn(function()
local success = false
pcall(function()
local tcs = game:GetService("TextChatService")
if tcs and tostring(tcs.ChatVersion) == "Enum.ChatVersion.TextChatService" then
local textChannels = tcs:FindFirstChild("TextChannels")
local channel = textChannels and (textChannels:FindFirstChild("RBXSystem") or textChannels:FindFirstChild("RBXGeneral"))
if channel then
channel:DisplaySystemMessage("<font color='" .. hexColor .. "'>" .. message .. "</font>")
success = true
end
end
end)

if not success then
local attempts = 0
while not success and attempts < 15 do
success = pcall(function()
game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
Text = message,
Color = color3 or Color3.fromRGB(255, 255, 255),
Font = Enum.Font.SourceSansBold,
TextSize = 18
})
end)
if not success then
waitFn(0.5)
attempts = attempts + 1
end
end
end
end)
end

local materialMap = {
SmoothPlastic = "smooth",
Plastic = "plastic",
Wood = "wood",
WoodPlanks = "planks",
Brick = "bricks",
Glass = "glass",
Slate = "stone",
Cobblestone = "pebble",
Marble = "marble",
Ice = "ice",
Grass = "grass",
Sand = "sand",
Snow = "snow",
Granite = "granite",
DiamondPlate = "steel",
CorrodedMetal = "metal",
Metal = "metal",
Asphalt = "asphalt",
Concrete = "concrete",
Pavement = "pavement",
Neon = "neon"
}

local function getMaterialStr(mat)
local matName = ""
if typeof(mat) == "EnumItem" then
matName = mat.Name
else
matName = tostring(mat)
local matchStr = matName:match("Enum%.Material%.(.+)")
if matchStr then
matName = matchStr
end
end

if materialMap[matName] then
return materialMap[matName]
end

for _, v in pairs(materialMap) do
if v == string.lower(matName) then
return v
end
end

return "plastic"
end

local function getEvent(toolName)
local bt = LocalPlayer.Backpack:FindFirstChild(toolName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(toolName))
if bt and bt:FindFirstChild("Script") and bt.Script:FindFirstChild("Event") then
return bt.Script.Event
end
return nil
end

local antiGriefActive = false
local protectedGrid = {}

local function getPosKey(pos)
return string.format("%.2f_%.2f_%.2f", pos.X, pos.Y, pos.Z)
end

local function getInfiniteBuildArgs(targetPos, root)
local sPos = root and root.Position or targetPos
local bricks = workspace:FindFirstChild("Bricks")
if bricks then
for _, p in ipairs(bricks:GetDescendants()) do
if p:IsA("BasePart") then
local diff = targetPos - p.Position
if math.abs(diff.Magnitude - 4) < 0.2 then
local normal = Enum.NormalId.Top
if diff.X > 3 then normal = Enum.NormalId.Right
elseif diff.X < -3 then normal = Enum.NormalId.Left
elseif diff.Y > 3 then normal = Enum.NormalId.Top
elseif diff.Y < -3 then normal = Enum.NormalId.Bottom
elseif diff.Z > 3 then normal = Enum.NormalId.Back
elseif diff.Z < -3 then normal = Enum.NormalId.Front
end
return p, normal, sPos
end
end
end
end
return workspace.Terrain, Enum.NormalId.Top, targetPos, sPos
end

local function getBlockOwner(part)
if not part then return nil end
local ownerTag = part:FindFirstChild("Owner") or part:FindFirstChild("creator") or part:FindFirstChild("Player")
if ownerTag then
if ownerTag:IsA("ObjectValue") and ownerTag.Value then
return ownerTag.Value.Name
elseif ownerTag:IsA("StringValue") then
return ownerTag.Value
end
end
if Players:FindFirstChild(part.Name) then
return part.Name
end
return nil
end

local function getAntiGriefBuildTool()
if LocalPlayer.Backpack:FindFirstChild("Anti-Grief Build") then LocalPlayer.Backpack["Anti-Grief Build"]:Destroy() end
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Anti-Grief Build") then LocalPlayer.Character["Anti-Grief Build"]:Destroy() end

local t = Instance.new("Tool")
t.Name = "Anti-Grief Build"
t.RequiresHandle = true
t.CanBeDropped = false

local h = Instance.new("Part")
h.Name = "Handle"
h.Size = Vector3.new(1.2, 1.8, 0.2)
h.Color = Color3.fromRGB(30, 30, 150)
h.Material = Enum.Material.SmoothPlastic
h.CanCollide = false
h.Parent = t

local screen = Instance.new("Part")
screen.Name = "Screen"
screen.Size = Vector3.new(1.1, 1.7, 0.22)
screen.Color = Color3.fromRGB(10, 10, 50)
screen.Material = Enum.Material.Neon
screen.CanCollide = false
screen.Massless = true
screen.Parent = t

local lw = Instance.new("WeldConstraint")
lw.Part0 = h
lw.Part1 = screen
lw.Parent = h
screen.CFrame = h.CFrame

local gui = Instance.new("ScreenGui")
gui.Name = "AntiGriefBuildGui"
gui.ResetOnSpawn = false

local mf = Instance.new("Frame", gui)
mf.Size = UDim2.new(0, 200, 0, 100)
mf.Position = UDim2.new(0.5, -100, 1, -150)
mf.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
local mfc = Instance.new("UICorner", mf); mfc.CornerRadius = UDim.new(0, 10)
mf.Visible = false

local title = Instance.new("TextLabel", mf)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Build Anti-Grief"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.new(1, 1, 1)

local toggleBtn = Instance.new("TextButton", mf)
toggleBtn.Size = UDim2.new(0, 160, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -80, 0.5, -5)
toggleBtn.BackgroundColor3 = antiGriefActive and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
local tbc = Instance.new("UICorner", toggleBtn); tbc.CornerRadius = UDim.new(0, 8)
toggleBtn.Text = antiGriefActive and "ACTIVE" or "INACTIVE"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

local isSpoofing = false

local function isValidBrick(p)
if not p:IsA("BasePart") then return false end
if string.find(string.lower(p.Name), "sign") then return false end
if p:FindFirstChildOfClass("SurfaceGui") then return false end
return true
end

local function snapshotWorkspace()
local grid = {}
local bricks = workspace:FindFirstChild("Bricks")
if bricks then
for _, p in ipairs(bricks:GetDescendants()) do
if isValidBrick(p) then
grid[getPosKey(p.Position)] = { part = p, pos = p.Position, color = p.Color, mat = p.Material, owner = getBlockOwner(p) }
end
end
end
return grid
end

local lastRebuildAttempt = {}

toggleBtn.MouseButton1Click:Connect(function()
antiGriefActive = not antiGriefActive
if antiGriefActive then
toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
toggleBtn.Text = "ACTIVE"
protectedGrid = {}
lastRebuildAttempt = {}

local initGrid = snapshotWorkspace()
local count = 0
for k, v in pairs(initGrid) do
protectedGrid[k] = { pos = v.pos, color = v.color, mat = v.mat, owner = v.owner }
count = count + 1
end

sendAlert("Build Anti-Grief active! Robust memory stored: " .. tostring(count) .. " blocks.", "#00FF00", Color3.fromRGB(0, 255, 0))

spawnFn(function()
while antiGriefActive do
waitFn(1)
local currentGrid = snapshotWorkspace()
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local hrp = char and char:FindFirstChild("HumanoidRootPart")

if hum and hrp then
local buildEvent = getEvent("Build")
local paintEvent = getEvent("Paint")

local toBuild = {}
local toPaint = {}

local now = tick()
for k, saved in pairs(protectedGrid) do
local cur = currentGrid[k]

local isMyBlock = (saved.owner == LocalPlayer.Name)
local hasNoOwner = (saved.owner == nil)
local shouldProtect = isMyBlock or hasNoOwner

if not cur then
if shouldProtect then
if not lastRebuildAttempt[k] or (now - lastRebuildAttempt[k] > 5) then
table.insert(toBuild, {key = k, saved = saved})
end
else
protectedGrid[k] = nil
end
elseif cur.color ~= saved.color or cur.mat ~= saved.mat then
if shouldProtect then
if not lastRebuildAttempt[k] or (now - lastRebuildAttempt[k] > 5) then
table.insert(toPaint, {key = k, part = cur.part, saved = saved})
end
else
protectedGrid[k].color = cur.color
protectedGrid[k].mat = cur.mat
end
end
end

if (#toBuild > 0 or #toPaint > 0) and (buildEvent or paintEvent) then
local currentTool = char:FindFirstChildOfClass("Tool")
local bTool = LocalPlayer.Backpack:FindFirstChild("Build") or char:FindFirstChild("Build")
local pTool = LocalPlayer.Backpack:FindFirstChild("Paint") or char:FindFirstChild("Paint")

if bTool or pTool then
isSpoofing = true
if #toBuild > 0 and bTool then hum:EquipTool(bTool)
elseif #toPaint > 0 and pTool then hum:EquipTool(pTool) end
waitFn(0.05)
hum:UnequipTools()
waitFn(0.05)
if currentTool then hum:EquipTool(currentTool) end
isSpoofing = false
end

if #toBuild > 0 and buildEvent then
sendAlert("Anti-Grief detected " .. tostring(#toBuild) .. " missing blocks. Restoring...", "#FFA500", Color3.fromRGB(255, 165, 0))
for i, data in ipairs(toBuild) do
if not antiGriefActive then break end
lastRebuildAttempt[data.key] = now
pcall(function()
local tBlock, tNorm, tHit, spoofFallback = getInfiniteBuildArgs(data.saved.pos, hrp)
buildEvent:FireServer(tBlock, tNorm, tHit, "normal", spoofFallback)
end)
waitFn(0.06)
end
waitFn(0.5)
end

if #toPaint > 0 and paintEvent then
for i, pd in ipairs(toPaint) do
if not antiGriefActive then break end
lastRebuildAttempt[pd.key] = now
pcall(function()
local matStr = getMaterialStr(pd.saved.mat)
paintEvent:FireServer(pd.part, Enum.NormalId.Top, hrp.Position, "both 🤝", pd.saved.color, matStr, "")
end)
waitFn(0.06)
end
waitFn(0.5)
end

-- Fast-paint newly built blocks in the same cycle
if #toBuild > 0 and paintEvent and pTool then
waitFn(1.2) -- Wait for server to replicate new blocks
local postBuildGrid = snapshotWorkspace()
local newlyBuiltToPaint = {}

for _, data in ipairs(toBuild) do
local newCur = postBuildGrid[data.key]
if newCur and (newCur.color ~= data.saved.color or newCur.mat ~= data.saved.mat) then
table.insert(newlyBuiltToPaint, {part = newCur.part, saved = data.saved})
end
end

if #newlyBuiltToPaint > 0 then
isSpoofing = true
hum:EquipTool(pTool)
waitFn(0.05)
hum:UnequipTools()
waitFn(0.05)
if currentTool then hum:EquipTool(currentTool) end
isSpoofing = false

for i, pd in ipairs(newlyBuiltToPaint) do
if not antiGriefActive then break end
pcall(function()
local matStr = getMaterialStr(pd.saved.mat)
paintEvent:FireServer(pd.part, Enum.NormalId.Top, hrp.Position, "both 🤝", pd.saved.color, matStr, "")
end)
waitFn(0.06)
end
waitFn(0.5)
end
end
end

for k, cur in pairs(currentGrid) do
if not protectedGrid[k] then
protectedGrid[k] = {pos = cur.pos, color = cur.color, mat = cur.mat, owner = cur.owner}
end
end
end
end)
else
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
toggleBtn.Text = "INACTIVE"
protectedGrid = {}
lastRebuildAttempt = {}
sendAlert("Build Anti-Grief deactivated. Memory cleared.", "#FF0000", Color3.fromRGB(255, 0, 0))
end
end)

t.Equipped:Connect(function()
pcall(function() gui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
mf.Visible = true
end)

t.Unequipped:Connect(function()
if isSpoofing then return end
gui.Parent = nil
mf.Visible = false
end)

t.Parent = LocalPlayer.Backpack
end

local currentShape = "square wall"
local hologramFolder = nil
local hologramParts = {}
local rsConnection = nil
local rotY = 0
local rotX = 0

local function clearHologram()
if hologramFolder then pcall(function() hologramFolder:Destroy() end) end
hologramFolder = nil
hologramParts = {}
end

local function getShapeOffsets(shapeType)
local offsets = {}
if shapeType == "square wall" then
for x = -2, 2 do for y = 0, 4 do table.insert(offsets, Vector3.new(x*4, y*4, 0)) end end
elseif shapeType == "square floor" then
for x = -2, 2 do for z = -2, 2 do table.insert(offsets, Vector3.new(x*4, 0, z*4)) end end
elseif shapeType == "circle wall" then
for x = -2, 2 do
for y = -2, 2 do
if (x*x) + (y*y) <= 5 then table.insert(offsets, Vector3.new(x*4, (y+2)*4, 0)) end
end
end
elseif shapeType == "circle floor" then
for x = -2, 2 do
for z = -2, 2 do
if (x*x) + (z*z) <= 5 then table.insert(offsets, Vector3.new(x*4, 0, z*4)) end
end
end
elseif shapeType == "heart wall" then
local pts = { {0,-1}, {-1,0},{0,0},{1,0}, {-2,1},{-1,1},{0,1},{1,1},{2,1}, {-2,2},{-1,2},{0,2},{1,2},{2,2}, {-1,3},{1,3} }
for _, p in ipairs(pts) do table.insert(offsets, Vector3.new(p[1]*4, (p[2]+1)*4, 0)) end
elseif shapeType == "star floor" then
local pts = { {0,2}, {-2,1},{-1,1},{0,1},{1,1},{2,1}, {-1,0},{0,0},{1,0}, {-1,-1},{1,-1}, {-2,-2},{2,-2} }
for _, p in ipairs(pts) do table.insert(offsets, Vector3.new(p[1]*4, 0, p[2]*4)) end
elseif shapeType == "diamond wall" then
for x = -2, 2 do
for y = -2, 2 do
if math.abs(x) + math.abs(y) <= 2 then table.insert(offsets, Vector3.new(x*4, (y+2)*4, 0)) end
end
end
elseif shapeType == "diamond floor" then
for x = -2, 2 do
for z = -2, 2 do
if math.abs(x) + math.abs(z) <= 2 then table.insert(offsets, Vector3.new(x*4, 0, z*4)) end
end
end
elseif shapeType == "hollow circle floor" then
for x = -3, 3 do
for z = -3, 3 do
local distSq = x*x + z*z
if distSq <= 12 and distSq >= 3 then table.insert(offsets, Vector3.new(x*4, 0, z*4)) end
end
end
elseif shapeType == "3D cube" then
for x = -1, 1 do
for y = 0, 2 do
for z = -1, 1 do table.insert(offsets, Vector3.new(x*4, y*4, z*4)) end
end
end
elseif shapeType == "sphere" then
for x = -2, 2 do
for y = -2, 2 do
for z = -2, 2 do
if x*x + y*y + z*z <= 6 then table.insert(offsets, Vector3.new(x*4, (y+2)*4, z*4)) end
end
end
end
elseif shapeType == "3D rectangle" then
for x = -2, 2 do
for y = 0, 1 do
for z = -1, 1 do table.insert(offsets, Vector3.new(x*4, y*4, z*4)) end
end
end
elseif shapeType == "3D heart" then
local pts = { {0,-1}, {-1,0},{0,0},{1,0}, {-2,1},{-1,1},{0,1},{1,1},{2,1}, {-2,2},{-1,2},{0,2},{1,2},{2,2}, {-1,3},{1,3} }
for z = -1, 1 do
for _, p in ipairs(pts) do table.insert(offsets, Vector3.new(p[1]*4, (p[2]+1)*4, z*4)) end
end
end
return offsets
end

local function updateHologramShape()
clearHologram()
hologramFolder = Instance.new("Folder")
hologramFolder.Name = "WallBuilderHolo"
pcall(function() hologramFolder.Parent = workspace.CurrentCamera end)

local offsets = getShapeOffsets(currentShape)
for _, offset in ipairs(offsets) do
local p = Instance.new("Part")
p.Size = Vector3.new(4, 4, 4)
p.Anchored = true
p.CanCollide = false
p.Transparency = 0.5
p.Color = Color3.fromRGB(0, 150, 255)
p.Material = Enum.Material.Neon
p.Parent = hologramFolder
table.insert(hologramParts, {part = p, offset = offset})
end
end

local function getWallBuilderTool()
if LocalPlayer.Backpack:FindFirstChild("Wall Builder") then LocalPlayer.Backpack["Wall Builder"]:Destroy() end
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Wall Builder") then LocalPlayer.Character["Wall Builder"]:Destroy() end

local t = Instance.new("Tool")
t.Name = "Wall Builder"
t.RequiresHandle = true

local h = Instance.new("Part")
h.Name = "Handle"
h.Size = Vector3.new(1, 1, 1)
h.Color = Color3.fromRGB(255, 150, 0)
h.Material = Enum.Material.Neon
h.Parent = t

local gui = Instance.new("ScreenGui")
gui.Name = "WallBuilderGui"
gui.ResetOnSpawn = false

local mf = Instance.new("Frame", gui)
mf.Size = UDim2.new(0, 150, 0, 260)
mf.Position = UDim2.new(1, -160, 0.5, -130)
mf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mf.BackgroundTransparency = 0.2
local mfc = Instance.new("UICorner", mf); mfc.CornerRadius = UDim.new(0, 8)
mf.Visible = false

local catFrame = Instance.new("Frame", mf)
catFrame.Size = UDim2.new(1, -10, 0, 25)
catFrame.Position = UDim2.new(0, 5, 0, 5)
catFrame.BackgroundTransparency = 1

local catShapesBtn = Instance.new("TextButton", catFrame)
catShapesBtn.Size = UDim2.new(0.5, -2, 1, 0)
catShapesBtn.Position = UDim2.new(0, 0, 0, 0)
catShapesBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
catShapesBtn.Text = "Shapes"
catShapesBtn.TextColor3 = Color3.new(1, 1, 1)
catShapesBtn.Font = Enum.Font.GothamBold
catShapesBtn.TextSize = 10
local csc = Instance.new("UICorner", catShapesBtn); csc.CornerRadius = UDim.new(0, 4)

local cat3DBtn = Instance.new("TextButton", catFrame)
cat3DBtn.Size = UDim2.new(0.5, -2, 1, 0)
cat3DBtn.Position = UDim2.new(0.5, 2, 0, 0)
cat3DBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
cat3DBtn.Text = "3D Shapes"
cat3DBtn.TextColor3 = Color3.new(1, 1, 1)
cat3DBtn.Font = Enum.Font.GothamBold
cat3DBtn.TextSize = 10
local c3c = Instance.new("UICorner", cat3DBtn); c3c.CornerRadius = UDim.new(0, 4)

local sf = Instance.new("ScrollingFrame", mf)
sf.Size = UDim2.new(1, -10, 1, -125)
sf.Position = UDim2.new(0, 5, 0, 35)
sf.BackgroundTransparency = 1
sf.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", sf)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local shapeCategories = {
["Shapes"] = {"square wall", "square floor", "circle wall", "circle floor", "heart wall", "star floor", "diamond wall", "diamond floor", "hollow circle floor"},
["3D Shapes"] = {"3D cube", "sphere", "3D rectangle", "3D heart"}
}
local currentCategory = "Shapes"

local function populateShapes()
for _, child in ipairs(sf:GetChildren()) do
if child:IsA("TextButton") then child:Destroy() end
end
for i, shapeName in ipairs(shapeCategories[currentCategory]) do
local btn = Instance.new("TextButton", sf)
btn.Size = UDim2.new(1, -8, 0, 25)
btn.BackgroundColor3 = (currentShape == shapeName) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
btn.Text = shapeName
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamSemibold
btn.TextSize = 11
btn.LayoutOrder = i
local btnc = Instance.new("UICorner", btn); btnc.CornerRadius = UDim.new(0, 5)

btn.MouseButton1Click:Connect(function()
currentShape = shapeName
for _, child in ipairs(sf:GetChildren()) do
if child:IsA("TextButton") then
child.BackgroundColor3 = (child.Text == currentShape) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
end
end
updateHologramShape()
end)
end
sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

catShapesBtn.MouseButton1Click:Connect(function()
currentCategory = "Shapes"
catShapesBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
cat3DBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
populateShapes()
end)

cat3DBtn.MouseButton1Click:Connect(function()
currentCategory = "3D Shapes"
cat3DBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
catShapesBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
populateShapes()
end)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

populateShapes()

local rotFrame = Instance.new("Frame", mf)
rotFrame.Size = UDim2.new(1, -10, 0, 50)
rotFrame.Position = UDim2.new(0, 5, 1, -85)
rotFrame.BackgroundTransparency = 1

local function makeRotBtn(txt, p, s, action)
local b = Instance.new("TextButton", rotFrame)
b.Size = s
b.Position = p
b.Text = txt
b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
b.TextColor3 = Color3.new(1, 1, 1)
b.Font = Enum.Font.GothamBold
b.TextSize = 10
local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0, 4)
b.MouseButton1Click:Connect(action)
end
makeRotBtn("Rot Up", UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -2, 0.5, -2), function() rotX = (rotX + 90) % 360 end)
makeRotBtn("Rot Dn", UDim2.new(0.5, 2, 0, 0), UDim2.new(0.5, -2, 0.5, -2), function() rotX = (rotX - 90) % 360 end)
makeRotBtn("Rot L", UDim2.new(0, 0, 0.5, 2), UDim2.new(0.5, -2, 0.5, -2), function() rotY = (rotY + 90) % 360 end)
makeRotBtn("Rot R", UDim2.new(0.5, 2, 0.5, 2), UDim2.new(0.5, -2, 0.5, -2), function() rotY = (rotY - 90) % 360 end)

local buildBtn = Instance.new("TextButton", mf)
buildBtn.Size = UDim2.new(1, -10, 0, 26)
buildBtn.Position = UDim2.new(0, 5, 1, -31)
buildBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
buildBtn.Text = "Build"
buildBtn.TextColor3 = Color3.new(1, 1, 1)
buildBtn.Font = Enum.Font.GothamBold
buildBtn.TextSize = 12
local buildBtnc = Instance.new("UICorner", buildBtn); buildBtnc.CornerRadius = UDim.new(0, 5)

buildBtn.MouseButton1Click:Connect(function()
if #hologramParts == 0 then return end
local buildEvent = getEvent("Build")
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
if buildEvent then
local positionsToBuild = {}
for _, h in ipairs(hologramParts) do
if h.part then
table.insert(positionsToBuild, h.part.Position)
end
end

local hum = char and char:FindFirstChildOfClass("Humanoid")
local bTool = LocalPlayer.Backpack:FindFirstChild("Build") or (char and char:FindFirstChild("Build"))
if bTool and hum then
hum:EquipTool(bTool)
waitFn(0.05)
hum:UnequipTools()
waitFn(0.05)
local wbTool = LocalPlayer.Backpack:FindFirstChild("Wall Builder")
if wbTool then
hum:EquipTool(wbTool)
end
end

spawnFn(function()
for _, pos in ipairs(positionsToBuild) do
pcall(function()
local tBlock, tNorm, tHit, spoofFallback = getInfiniteBuildArgs(pos, root)
buildEvent:FireServer(tBlock, tNorm, tHit, "normal", spoofFallback)
end)
waitFn(0.06)
end
end)
end
end)

t.Equipped:Connect(function()
pcall(function() gui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
mf.Visible = true

updateHologramShape()

rsConnection = game:GetService("RunService").RenderStepped:Connect(function()
if not hologramFolder then return end
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
if not root then return end

local targetCFrame = root.CFrame * CFrame.new(0, 0, -6)
local target = targetCFrame.Position

local snapX = math.floor(target.X/4)*4
local snapY = math.floor(target.Y/4)*4 + 2
local snapZ = math.floor(target.Z/4)*4

local rotationCFrame = CFrame.Angles(math.rad(rotX), math.rad(rotY), 0)

for _, h in ipairs(hologramParts) do
if h.part then
local rotatedOffset = rotationCFrame * h.offset
h.part.Position = Vector3.new(snapX + rotatedOffset.X, snapY + rotatedOffset.Y, snapZ + rotatedOffset.Z)
end
end
end)
end)

t.Unequipped:Connect(function()
gui.Parent = nil
mf.Visible = false
if rsConnection then rsConnection:Disconnect(); rsConnection = nil end
clearHologram()
end)

t.Parent = LocalPlayer.Backpack
end

local function getDestroyerTool()
if LocalPlayer.Backpack:FindFirstChild("Destroyer") then LocalPlayer.Backpack["Destroyer"]:Destroy() end
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Destroyer") then LocalPlayer.Character["Destroyer"]:Destroy() end

local t = Instance.new("Tool")
t.Name = "Destroyer"
t.RequiresHandle = true

local h = Instance.new("Part")
h.Name = "Handle"
h.Size = Vector3.new(1, 1, 1)
h.Color = Color3.fromRGB(255, 0, 0)
h.Material = Enum.Material.Neon
h.Parent = t

local mouseDownConn
local mouseUpConn
local startX, startY = 0, 0
t.Equipped:Connect(function()
mouseDownConn = Mouse.Button1Down:Connect(function()
startX, startY = Mouse.X, Mouse.Y
end)

mouseUpConn = Mouse.Button1Up:Connect(function()
local dist = math.sqrt((Mouse.X - startX)^2 + (Mouse.Y - startY)^2)
if dist < 15 then
local target = Mouse.Target
local delEvent = getEvent("Delete")
local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if target and target:IsDescendantOf(workspace:FindFirstChild("Bricks") or workspace) and delEvent and hrp then
spawnFn(function()
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local currentTool = char and char:FindFirstChildOfClass("Tool")
if hum then
local dTool = LocalPlayer.Backpack:FindFirstChild("Delete") or (char and char:FindFirstChild("Delete"))
if dTool then hum:EquipTool(dTool) end
waitFn(0.01)
if currentTool then hum:EquipTool(currentTool) else hum:UnequipTools() end
end
local op = OverlapParams.new()
local bricksFolder = workspace:FindFirstChild("Bricks")
if bricksFolder then
op.FilterDescendantsInstances = {bricksFolder}
op.FilterType = Enum.RaycastFilterType.Include
end

local visited = {[target] = true}
local currentLevel = {target}
local limit = 25000
local count = 0

while #currentLevel > 0 and count < limit do
local nextLevel = {}

for _, nodeBlock in ipairs(currentLevel) do
if nodeBlock.Parent then
local bounds = workspace:GetPartBoundsInBox(nodeBlock.CFrame, nodeBlock.Size + Vector3.new(3, 3, 3), op)
for _, neighbor in ipairs(bounds) do
if neighbor:IsA("BasePart") and not visited[neighbor] then
visited[neighbor] = true
table.insert(nextLevel, neighbor)
end
end

pcall(function()
if protectedGrid and getPosKey then
protectedGrid[getPosKey(nodeBlock.Position)] = nil
end
delEvent:FireServer(nodeBlock, hrp.Position)
end)
count = count + 1
if count >= limit then break end
end
end

currentLevel = nextLevel
waitFn(0.05)
end
end)
end
end
end)
end)

t.Unequipped:Connect(function()
if mouseDownConn then mouseDownConn:Disconnect() end
if mouseUpConn then mouseUpConn:Disconnect() end
end)

t.Parent = LocalPlayer.Backpack
end

local infBtoolsActive = false
local infBtoolsConn = nil

local function toggleInfBtools(state)
infBtoolsActive = state
if infBtoolsActive then
sendAlert("Infinite Btools Enabled! Works automatically with Delete, Build, and Paint tools.", "#00FF00", Color3.fromRGB(0, 255, 0))

if not infBtoolsConn then
infBtoolsConn = Mouse.Button1Down:Connect(function()
if not infBtoolsActive then return end

local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if not hrp then return end

local currentTool = char:FindFirstChildOfClass("Tool")
if not currentTool then return end

local toolName = currentTool.Name
local target = Mouse.Target
local hit = Mouse.Hit

if toolName == "Delete" then
if target and target:IsDescendantOf(workspace) then
local delEvent = getEvent("Delete")
if delEvent then
pcall(function() delEvent:FireServer(target, hrp.Position) end)
end
end
elseif toolName == "Build" then
if hit then
local buildEvent = getEvent("Build")
if buildEvent then
pcall(function()
local tBlock, tNorm, tHit, spoofFallback = getInfiniteBuildArgs(hit.Position, hrp)
buildEvent:FireServer(tBlock, tNorm, tHit, "normal", spoofFallback)
end)
end
end
elseif toolName == "Paint" then
if target and target:IsDescendantOf(workspace) then
local paintEvent = getEvent("Paint")
if paintEvent then
pcall(function()
local pColor = Color3.fromRGB(163, 162, 165)
local pMat = "plastic"

if currentTool:FindFirstChild("Color") and currentTool.Color:IsA("Color3Value") then
pColor = currentTool.Color.Value
elseif currentTool:FindFirstChild("BrickColor") and currentTool.BrickColor:IsA("BrickColorValue") then
pColor = currentTool.BrickColor.Value.Color
end

if currentTool:FindFirstChild("Material") and currentTool.Material:IsA("StringValue") then
pMat = currentTool.Material.Value
end

paintEvent:FireServer(target, Enum.NormalId.Top, hrp.Position, "both 🤝", pColor, pMat, "")
end)
end
end
end
end)
end
else
sendAlert("Infinite Btools Disabled.", "#FF0000", Color3.fromRGB(255, 0, 0))
if infBtoolsConn then
infBtoolsConn:Disconnect()
infBtoolsConn = nil
end
end
end

local function getWorldEditTool()
if LocalPlayer.Backpack:FindFirstChild("World Edit") then LocalPlayer.Backpack["World Edit"]:Destroy() end
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("World Edit") then LocalPlayer.Character["World Edit"]:Destroy() end

local t = Instance.new("Tool")
t.Name = "World Edit"
t.RequiresHandle = true

local h = Instance.new("Part")
h.Name = "Handle"
h.Size = Vector3.new(0.2, 1.5, 0.2)
h.Color = Color3.fromRGB(139, 69, 19)
h.Material = Enum.Material.Wood
h.Parent = t
Instance.new("CylinderMesh", h)

local ferrule = Instance.new("Part")
ferrule.Name = "Ferrule"
ferrule.Size = Vector3.new(0.25, 0.4, 0.25)
ferrule.Color = Color3.fromRGB(192, 192, 192)
ferrule.Material = Enum.Material.Metal
ferrule.Massless = true
ferrule.CanCollide = false
ferrule.Parent = t
Instance.new("CylinderMesh", ferrule)
local fw = Instance.new("WeldConstraint")
fw.Part0 = h
fw.Part1 = ferrule
fw.Parent = h
ferrule.CFrame = h.CFrame * CFrame.new(0, 0.95, 0)

local tip = Instance.new("Part")
tip.Name = "Tip"
tip.Size = Vector3.new(0.3, 0.6, 0.1)
tip.Color = Color3.fromRGB(255, 50, 50)
tip.Material = Enum.Material.SmoothPlastic
tip.Massless = true
tip.CanCollide = false
tip.Parent = t
local tm = Instance.new("SpecialMesh", tip)
tm.MeshType = Enum.MeshType.Sphere
local tw = Instance.new("WeldConstraint")
tw.Part0 = h
tw.Part1 = tip
tw.Parent = h
tip.CFrame = h.CFrame * CFrame.new(0, 1.45, 0)

local gui = Instance.new("ScreenGui")
gui.Name = "WorldEditGui"
gui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(1, -50, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.Text = "WE"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
local tc = Instance.new("UICorner", toggleBtn); tc.CornerRadius = UDim.new(1, 0)

local mainScroll = Instance.new("ScrollingFrame", gui)
mainScroll.Size = UDim2.new(0, 100, 0, 150)
mainScroll.Position = UDim2.new(1, -110, 0.1, 50)
mainScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainScroll.BackgroundTransparency = 0.2
mainScroll.Visible = false
mainScroll.ScrollBarThickness = 4
local msc = Instance.new("UICorner", mainScroll); msc.CornerRadius = UDim.new(0, 6)

local mainLayout = Instance.new("UIListLayout", mainScroll)
mainLayout.Padding = UDim.new(0, 4)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder

local linerBtn = Instance.new("TextButton", mainScroll)
linerBtn.Size = UDim2.new(1, -8, 0, 30)
linerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
linerBtn.Text = "Liner"
linerBtn.TextColor3 = Color3.new(1, 1, 1)
linerBtn.Font = Enum.Font.GothamSemibold
linerBtn.TextSize = 12
local lbc = Instance.new("UICorner", linerBtn); lbc.CornerRadius = UDim.new(0, 4)

local subScroll = Instance.new("ScrollingFrame", gui)
subScroll.Size = UDim2.new(0, 100, 0, 150)
subScroll.Position = UDim2.new(1, -220, 0.1, 50)
subScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
subScroll.BackgroundTransparency = 0.2
subScroll.Visible = false
subScroll.ScrollBarThickness = 4
local ssc = Instance.new("UICorner", subScroll); ssc.CornerRadius = UDim.new(0, 6)

local subLayout = Instance.new("UIListLayout", subScroll)
subLayout.Padding = UDim.new(0, 4)
subLayout.SortOrder = Enum.SortOrder.LayoutOrder

local setPosBtn = Instance.new("TextButton", subScroll)
setPosBtn.Size = UDim2.new(1, -8, 0, 30)
setPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
setPosBtn.Text = "Set pos"
setPosBtn.TextColor3 = Color3.new(1, 1, 1)
setPosBtn.Font = Enum.Font.GothamSemibold
setPosBtn.TextSize = 12
local spbc = Instance.new("UICorner", setPosBtn); spbc.CornerRadius = UDim.new(0, 4)

local weActive = false
local linerActive = false
local posState = 0
local anchorPos = nil
local isSpoofing = false

local holoFolder = nil
local holoPool = {}
local activeHolos = 0
local rsConn = nil

local function clearHolos()
for _, p in ipairs(holoPool) do p.Parent = nil end
activeHolos = 0
if holoFolder then holoFolder:Destroy(); holoFolder = nil end
end

local function getSnap(pos)
return Vector3.new(math.floor(pos.X/4)*4, math.floor(pos.Y/4)*4 + 2, math.floor(pos.Z/4)*4)
end

local function updateHolo(p1, p2)
if not holoFolder then
holoFolder = Instance.new("Folder")
holoFolder.Name = "WEHolo"
pcall(function() holoFolder.Parent = workspace.CurrentCamera end)
end

local minX = math.min(p1.X, p2.X)
local maxX = math.max(p1.X, p2.X)
local minY = math.min(p1.Y, p2.Y)
local maxY = math.max(p1.Y, p2.Y)
local minZ = math.min(p1.Z, p2.Z)
local maxZ = math.max(p1.Z, p2.Z)

local needed = {}
for x = minX, maxX, 4 do
for y = minY, maxY, 4 do
for z = minZ, maxZ, 4 do
table.insert(needed, Vector3.new(x, y, z))
if #needed > 40000 then break end
end
if #needed > 40000 then break end
end
if #needed > 40000 then break end
end

local visualLimit = math.min(#needed, 2000)
for i = 1, visualLimit do
local hp = holoPool[i]
if not hp then
hp = Instance.new("Part")
hp.Size = Vector3.new(4, 4, 4)
hp.Anchored = true
hp.CanCollide = false
hp.Transparency = 0.5
hp.Color = Color3.fromRGB(0, 255, 100)
hp.Material = Enum.Material.Neon
holoPool[i] = hp
end
hp.Position = needed[i]
if hp.Parent ~= holoFolder then hp.Parent = holoFolder end
end

for i = visualLimit + 1, #holoPool do
if holoPool[i].Parent then holoPool[i].Parent = nil end
end
activeHolos = #needed
-- store full positions inside folder as an attribute or just rebuild it on click
return needed
end

toggleBtn.MouseButton1Click:Connect(function()
weActive = not weActive
if weActive then
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
mainScroll.Visible = true
else
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainScroll.Visible = false
subScroll.Visible = false
linerActive = false
linerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
posState = 0
setPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
setPosBtn.Text = "Set pos"
clearHolos()
if rsConn then rsConn:Disconnect(); rsConn = nil end
end
end)

linerBtn.MouseButton1Click:Connect(function()
linerActive = not linerActive
if linerActive then
linerBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
subScroll.Visible = true
else
linerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
subScroll.Visible = false
posState = 0
setPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
setPosBtn.Text = "Set pos"
clearHolos()
if rsConn then rsConn:Disconnect(); rsConn = nil end
end
end)

local lastNeeded = {}
setPosBtn.MouseButton1Click:Connect(function()
if posState == 0 then
posState = 1
setPosBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
setPosBtn.Text = "Build Box"

local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
if root then
anchorPos = getSnap(root.Position - Vector3.new(0, 3, 0))
else
anchorPos = getSnap(Vector3.new(0, 0, 0))
end

local lastSnapPos = nil
if rsConn then rsConn:Disconnect() end
rsConn = game:GetService("RunService").RenderStepped:Connect(function()
local c = LocalPlayer.Character
local r = c and c:FindFirstChild("HumanoidRootPart")
if r and anchorPos then
local currentPos = getSnap(r.Position - Vector3.new(0, 3, 0))
if currentPos ~= lastSnapPos then
lastSnapPos = currentPos
lastNeeded = updateHolo(anchorPos, currentPos)
setPosBtn.Text = "Build (" .. tostring(#lastNeeded) .. ")"
end
end
end)
else
posState = 0
setPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
setPosBtn.Text = "Set pos"

if rsConn then rsConn:Disconnect(); rsConn = nil end

if #lastNeeded > 0 then
local buildEvent = getEvent("Build")
local char = LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")

if buildEvent then
local positionsToBuild = lastNeeded

local hum = char and char:FindFirstChildOfClass("Humanoid")
local bTool = LocalPlayer.Backpack:FindFirstChild("Build") or (char and char:FindFirstChild("Build"))
local weTool = LocalPlayer.Backpack:FindFirstChild("World Edit") or (char and char:FindFirstChild("World Edit"))

if bTool and hum then
isSpoofing = true
hum:EquipTool(bTool)
waitFn(0.05)
hum:UnequipTools()
waitFn(0.05)
if weTool then hum:EquipTool(weTool) end
isSpoofing = false
end

spawnFn(function()
-- 1. Initial Build Phase
for _, pos in ipairs(positionsToBuild) do
if not weActive then break end
pcall(function()
local tBlock, tNorm, tHit, spoofFallback = getInfiniteBuildArgs(pos, root)
buildEvent:FireServer(tBlock, tNorm, tHit, "normal", spoofFallback)
end)
waitFn(0.06)
end

-- 2. Scanner Phase (Check for missing blocks in the exact area built)
while true do
if not weActive then break end
waitFn(1.5) -- Wait for server to process and blocks to replicate

local occupied = {}
local bricks = workspace:FindFirstChild("Bricks")
if bricks then
for _, p in ipairs(bricks:GetDescendants()) do
if p:IsA("BasePart") then
local px, py, pz = math.floor(p.Position.X + 0.5), math.floor(p.Position.Y + 0.5), math.floor(p.Position.Z + 0.5)
occupied[px .. "" .. py .. "" .. pz] = true
end
end
end

local missingBlocks = {}
for _, pos in ipairs(positionsToBuild) do
local px, py, pz = math.floor(pos.X + 0.5), math.floor(pos.Y + 0.5), math.floor(pos.Z + 0.5)
if not occupied[px .. "" .. py .. "" .. pz] then
table.insert(missingBlocks, pos)
end
end

if #missingBlocks > 0 and weActive then
if bTool and hum then
isSpoofing = true
hum:EquipTool(bTool)
waitFn(0.05)
hum:UnequipTools()
waitFn(0.05)
if weTool then hum:EquipTool(weTool) end
isSpoofing = false
end

for _, pos in ipairs(missingBlocks) do
if not weActive then break end
pcall(function()
local tBlock, tNorm, tHit, spoofFallback = getInfiniteBuildArgs(pos, root)
buildEvent:FireServer(tBlock, tNorm, tHit, "normal", spoofFallback)
end)
waitFn(0.06)
end
else
break -- Everything built successfully
end
end
end)
end
end

clearHolos()
lastNeeded = {}
end
end)

t.Equipped:Connect(function()
pcall(function() gui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end)

t.Unequipped:Connect(function()
if isSpoofing then return end
gui.Parent = nil
weActive = false
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainScroll.Visible = false
subScroll.Visible = false
linerActive = false
linerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
posState = 0
setPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
setPosBtn.Text = "Set pos"
clearHolos()
if rsConn then rsConn:Disconnect(); rsConn = nil end
end)

t.Parent = LocalPlayer.Backpack
end

LocalPlayer.Chatted:Connect(function(msg)
if msg:lower() == "/antigriefd" then
spawnFn(getAntiGriefBuildTool)
elseif msg:lower() == "/worldedit" then
spawnFn(getWorldEditTool)
elseif msg:lower() == "/wallbuilder" then
spawnFn(getWallBuilderTool)
elseif msg:lower() == "/destroyer" then
spawnFn(getDestroyerTool)
elseif msg:lower() == "/infbtools" then
toggleInfBtools(true)
elseif msg:lower() == "/unfbtools" then
toggleInfBtools(false)
elseif msg:lower() == "/cmds" then
sendAlert("Build Tools Loaded! Commands: /antigriefd, /worldedit, /wallbuilder, /destroyer, /infbtools, /unfbtools, /cmds", "#00FF00", Color3.fromRGB(0, 255, 0))
sendAlert("created by:sofiakira", "#FF69B4", Color3.fromRGB(255, 105, 180))
end
end)

sendAlert("Build Tools Loaded! Commands: /antigriefd, /worldedit, /wallbuilder, /destroyer, /infbtools, /unfbtools, /cmds", "#00FF00", Color3.fromRGB(0, 255, 0))
sendAlert("created by:sofiakira", "#FF69B4", Color3.fromRGB(255, 105, 180))
