-- Cool Cam.

local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local TARGET_TAG_NAME = "Target"
local TARGET_CHANGE_TIME = 0.1


local LockedTargetSignal = game.ReplicatedStorage.Remotes.LockedTargetSignal
local ScreenGui = script.Parent
local Camera = Workspace.CurrentCamera
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local playerRoot: BasePart = Player.Character and Player.Character:WaitForChild("HumanoidRootPart")
local playerhumanoid : Humanoid = Player.Character and Player.Character:WaitForChild("Humanoid")
local PlayerPosition = Vector3.zero
local CameraTargetPosition = Vector3.zero
local CameraPosition = nil
local CameraLookAt = Vector3.zero
local FinalCameraPosition = Vector3.zero
local lastRootPosition = playerRoot.Position
local MovementDirectionLerp = nil

local IsLockOnActive
local previousMousePosition = Vector2.zero
local TargetList = CollectionService:GetTagged(TARGET_TAG_NAME)

local target = 0 -- 0: None
local lastTargetChangeTime = 0

local filter = RaycastParams.new()
filter.FilterType = Enum.RaycastFilterType.Exclude
filter.FilterDescendantsInstances = { Player.Character, table.unpack(TargetList) }

Player.CharacterAdded:Connect(function(Character)
	playerRoot = Character:WaitForChild("HumanoidRootPart")
	playerhumanoid = Character:WaitForChild("Humanoid")
	table.insert(filter.FilterDescendantsInstances, Character)
end)

-- Create the pointing frame (lock-on cursor)
local function CreatePointingFrame()
	local Frame = Instance.new("ImageLabel")
	Frame.AnchorPoint = Vector2.new(.5, .5)
	Frame.Image = "rbxassetid://6430908053"
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.fromOffset(20, 20)
	Frame.Parent = ScreenGui
	return Frame
end

local Frame = CreatePointingFrame()
local TestPointFrames = {}  -- This will hold the frames for the red points

-- Create the white frame in the bottom-right corner
local function CreateWhiteFrame()
	local whiteFrame = Instance.new("Frame")
	whiteFrame.AnchorPoint = Vector2.new(1, 1)
	whiteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	whiteFrame.Size = UDim2.fromOffset(300, 300)
	whiteFrame.Position = UDim2.new(1, -10, 1, -10)
	whiteFrame.Parent = ScreenGui
	return whiteFrame
end

local whiteFrame = CreateWhiteFrame()
whiteFrame.Visible = false
-- Create X and Y axes within the white frame
local function CreateAxisLine(parent, size, position, color)
	local axisLine = Instance.new("Frame")
	axisLine.AnchorPoint = Vector2.new(0.5, 0.5)
	axisLine.Size = size
	axisLine.Position = position
	axisLine.BackgroundColor3 = color
	axisLine.BackgroundTransparency = 0
	axisLine.Parent = parent
	return axisLine
end

-- Create the X and Y axis lines with longer size
local xAxis = CreateAxisLine(whiteFrame, UDim2.fromOffset(600, 2), UDim2.new(0.5, 0, 0.5, 0), Color3.new(1, 0, 0))  -- X-axis, longer
local yAxis = CreateAxisLine(whiteFrame, UDim2.fromOffset(2, 600), UDim2.new(0.5, 0, 0.5, 0), Color3.new(0, 1, 0))  -- Y-axis, longer

local function ToggleLockOn()
	IsLockOnActive = not IsLockOnActive
	Frame.Visible = IsLockOnActive
	if IsLockOnActive then
		Camera.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseIconEnabled = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	else
		Camera.CameraType = Enum.CameraType.Custom
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		CameraPosition = nil
		MovementDirectionLerp = nil
		target = 0
		UserInputService.MouseIconEnabled = true
	end
end


local function SetCamera()
	if not playerhumanoid then return end
	if not playerRoot then return end
	if target == 0 then return end
	PlayerPosition = playerRoot.Position
	CameraLookAt = TargetList[target].Position
	CameraTargetPosition = (CFrame.lookAt(PlayerPosition, CameraLookAt) * CFrame.new(0, 6, 14)).Position
	
	if CameraPosition then
		
	end
	CameraPosition = 
		if CameraPosition then 
			CameraPosition:Lerp(CameraTargetPosition, 0.03) 
		else
			Camera.CFrame.Position
	
	local MovementDirection = playerRoot.AssemblyLinearVelocity/60 --playerhumanoid.MoveDirection
	
	MovementDirectionLerp = 
		if MovementDirectionLerp then
			MovementDirectionLerp:Lerp(MovementDirection, 0.1)
		else 
			MovementDirection
		
	
	local cameraCast = Workspace:Raycast(PlayerPosition, CameraPosition - PlayerPosition, filter)
	if cameraCast then
		FinalCameraPosition = cameraCast.Position + CFrame.lookAt(CameraPosition, CameraLookAt).LookVector
	else
		FinalCameraPosition = CameraPosition
	end
	--playerRoot.CFrame = CFrame.lookAt(PlayerPosition, Vector3.new(CameraLookAt.X, PlayerPosition.Y, CameraLookAt.Z))

	Camera.CFrame = CFrame.new(FinalCameraPosition, CameraLookAt) - MovementDirectionLerp
	
	lastRootPosition = playerRoot.Position
end

local function OnInputBegan(input: InputObject, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl then
		ToggleLockOn()
	end
end

local MouseMovement = Vector2.new(0, 0)
local function GetMouseMovement()
	--local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
	--local delta = mousePosition - previousMousePosition
	--previousMousePosition = mousePosition
	return MouseMovement--delta
end

local function RotateVector(vector, angle)
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)
	return Vector2.new(
		vector.X * cosAngle - vector.Y * sinAngle,
		vector.X * sinAngle + vector.Y * cosAngle
	)
end

local function setLockOnTarget(mouseMovedDirection: Vector2, deltaTime)
	if not IsLockOnActive then return end
	
	local screenCenter = Vector2.new(ScreenGui.AbsoluteSize.X, ScreenGui.AbsoluteSize.Y) / 2
	local adjustedMouseDirection = mouseMovedDirection / deltaTime

	local target2DLocationList = {}
	for i, v in TargetList do
		local target2DLocation, isOnScreen = Camera:WorldToViewportPoint(v.Position)
		if isOnScreen then
			target2DLocationList[i] = Vector2.new(target2DLocation.X, target2DLocation.Y)
		end
	end
	local currentTargetLocation = target2DLocationList[target]

	if target == 0 then
		local closestDistance = math.huge
		local closestTarget = nil
		for i, v in target2DLocationList do
			local distance = (v - screenCenter).Magnitude
			if distance < closestDistance then
				currentTargetLocation = target2DLocationList[i]
				closestDistance = distance
				closestTarget = i
			end
		end
		if closestTarget then
			target = closestTarget
			
			lastTargetChangeTime = tick()
		else
			ToggleLockOn()
			return
		end
	else
		local targetPart = TargetList[target]
		if targetPart and targetPart:IsA("BasePart") then
			local target2DLocation, isOnScreen = Camera:WorldToViewportPoint(targetPart.Position)
			if isOnScreen then
				Frame.Position = UDim2.fromOffset(target2DLocation.X, target2DLocation.Y)
				Frame.Visible = IsLockOnActive
			end
		end
	end
	
	if tick() - lastTargetChangeTime < TARGET_CHANGE_TIME then
		return
	end

	if adjustedMouseDirection.Magnitude > 500 then
		local rotationAngle = math.atan2(adjustedMouseDirection.Y, adjustedMouseDirection.X)
		local closestDistance = math.huge
		local closestTarget = nil
		local previousTargetLocation = TargetList[target]

		-- 회전된 위치 계산
		local rotatedPositions = {}

		for i, targetPart in TargetList do
			if not targetPart:IsA("BasePart") then continue end
			local target2DLocation, isOnScreen = Camera:WorldToViewportPoint(targetPart.Position)
			if not isOnScreen then continue end

			local relativePosition = Vector2.new(target2DLocation.X, target2DLocation.Y) - currentTargetLocation
			local invertedVector = Vector2.new(relativePosition.X,-relativePosition.Y)
			local rotatedPosition = RotateVector(invertedVector, rotationAngle)
			table.insert(rotatedPositions, {index = i, rotatedPosition = rotatedPosition})
		end

		for _, rotatedData in pairs(rotatedPositions) do
			local rotatedPosition = rotatedData.rotatedPosition
			local distance = rotatedPosition.X

			if distance < closestDistance and distance > 0 then
				closestDistance = distance
				closestTarget = rotatedData.index
			end
		end
		
		if closestTarget then
			target = closestTarget
			lastTargetChangeTime = tick()
		end
		
		for i, rotatedData in pairs(rotatedPositions) do
			local rotatedPosition = rotatedData.rotatedPosition
			local scaledPosition = Vector2.new(rotatedPosition.X * 1/3, rotatedPosition.Y * 1/3)
			if not TestPointFrames[i] then
				local testPoint = Instance.new("TextLabel")
				testPoint.AnchorPoint = Vector2.new(0.5, 0.5)
				testPoint.Size = UDim2.fromOffset(40, 40)
				testPoint.TextScaled = true
				testPoint.BackgroundTransparency = 0
				testPoint.BackgroundColor3 = Color3.new(1,0,0)
				testPoint.Text = TargetList[i].Parent.Name
				testPoint.Parent = whiteFrame
				TestPointFrames[i] = testPoint
			end
			xAxis.Rotation = math.deg(rotationAngle)
			yAxis.Rotation = math.deg(rotationAngle)
			TestPointFrames[i].Position = UDim2.new(0, scaledPosition.X + 150, 0, scaledPosition.Y + 150)
		end
	end
end

local function OnLockonActive(deltaTime)
	if not IsLockOnActive then return end
	TargetList = CollectionService:GetTagged(TARGET_TAG_NAME)
	if not TargetList[target] then
		target = 0
	end
	local mouseMovedDirection = GetMouseMovement()
	setLockOnTarget(mouseMovedDirection, deltaTime)
end

local cutscenePlaying = false
local lastTarget = target
local function OnRenderStepped(deltaTime)
	if cutscenePlaying then return end
	OnLockonActive(deltaTime)
	SetCamera()
	
	if lastTarget ~= target then
		lastTarget = target
		LockedTargetSignal:FireServer(TargetList[target])
	end
end

-- Cutscene
-- game.ReplicatedStorage.Remotes.Cutscene.OnClientEvent:Connect(function(Name)
	-- if Name == "Door1" then
	-- 	cutscenePlaying = true
	-- 	Camera.CameraType = Enum.CameraType.Scriptable
	-- 	Camera.CFrame = workspace.Cam.CFrame
	-- 	task.wait(4)
	-- 	cutscenePlaying = false
	-- end
-- end)

UserInputService.InputChanged:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		MouseMovement = input.Delta
	end
end)

RunService.RenderStepped:Connect(OnRenderStepped)
UserInputService.InputBegan:Connect(OnInputBegan)