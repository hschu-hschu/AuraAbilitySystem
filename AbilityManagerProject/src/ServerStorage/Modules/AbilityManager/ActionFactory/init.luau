-- Thanks to @nofair2002 for contributing this code.
local ActionFactory = {}
local handlers = {}

local Debris = game:GetService("Debris")

for _, child in pairs(script:GetChildren()) do
	if child:IsA("ModuleScript") then
		local success, module = pcall(require, child)
		if success then
			handlers[child.Name] = module			
		else
			warn("Failed to load handler:", child.Name)
		end
	end
end

function ActionFactory.CreateAction(actionData)
	local actionType = actionData.Type
	local handler = handlers[actionType]
	if not handler then
		error(`[ActionFactory] Unknown action type: {actionType}`)
	end

	return handler.Create(actionData)
end


local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local HandlerFunctions = {}
HandlerFunctions.Garbages = {}

function HandlerFunctions:Cancel()
	for i, v in pairs(self.Garbages)do
		if type(v) == "function" then
			v()
			continue
		end
		
		if v:IsA("AnimationTrack") or v:IsA("Sound") then
			v:Stop()
		elseif v:IsA("ParticleEmitter") then
			v.Enabled = false
			Debris:AddItem(v, v.Lifetime.Max) 
		end
	end
	table.clear(self.Garbages)
end

function HandlerFunctions:PlayAnimation(Character, AnimationId)
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end
	local Animator = Humanoid:FindFirstChild("Animator")
	if not Animator then
		return
	end
	local Animation = Instance.new("Animation")
	Animation.AnimationId = Content.fromAssetId(AnimationId).Uri
	local Track = Animator:LoadAnimation(Animation)
	
	table.insert(HandlerFunctions.Garbages, Track)
	
	Track:Play(0)
	return Track
end

function HandlerFunctions:PlayParticleEmitter(particle:ParticleEmitter)
	local emitCount = particle:GetAttribute("EmitCount")
	local emitDelay = particle:GetAttribute("EmitDelay")
	local emitDuraction = particle:GetAttribute("EmitDuraction")

	table.insert(HandlerFunctions.Garbages, particle)

	task.delay(particle:GetAttribute("EmitDelay") or 0, function()
		if emitDuraction then
			particle.Enabled = true
			task.wait(emitDuraction)
			particle.Enabled = false
		elseif emitCount then
			particle:Emit(emitCount)
		end
	end)
end

function HandlerFunctions:PlaySound(sound:Sound)
	sound:Play()
	table.insert(HandlerFunctions.Garbages, sound)
end

function HandlerFunctions:EmitEffects(parent:Instance)
	for _, instance:Instance in parent:GetDescendants() do
		if instance:IsA("ParticleEmitter") then
			self:PlayParticleEmitter(instance)
		elseif instance:IsA("Sound") then
			self:PlaySound(instance)
		end
	end
end

function HandlerFunctions:DisabledCollision(Character:Instance)
	for _,part in Character:GetChildren() do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.CanCollide = false
		end
	end
end

function HandlerFunctions:FadeTransparent(Character:Instance)
	for _,part in Character:GetDescendants() do
		if (part:IsA("BasePart") or part:IsA("Decal")) and part.Name ~= "HumanoidRootPart" then
			TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 0}):Play()
		end
	end
end

function HandlerFunctions:Fade(Character:Instance)
	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 0
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	Highlight.OutlineTransparency = 1
	Highlight.FillColor = Color3.new(0, 0, 0)
	Highlight.Parent = Character
	TweenService:Create(Highlight, TweenInfo.new(0.5), {FillTransparency = 1}):Play()
	game.Debris:AddItem(Highlight,0.5)
end

function HandlerFunctions:DisableAllParticles(Character:Instance)
	for _,part in Character:GetDescendants() do
		if part:IsA("ParticleEmitter") or part:IsA("BillboardGui") then
			part.Enabled = true
			if part:GetAttribute("LockedToPart") then
				part.LockedToPart = part:GetAttribute("LockedToPart")
			end
		end
	end
end

function HandlerFunctions:RayCast(Origin,ActualDirection,Speed,projectile,ProjectileDuration, deltaTime)
	local raycastDirection = ActualDirection
	local cast = workspace:Raycast(Origin,raycastDirection)
	return cast
end

function HandlerFunctions:Fire(Origin, Direction, Speed, projectile, duration)
	local Position = Origin
	local CooldownTime = workspace:GetServerTimeNow() + (duration or 10)
	local cast

	repeat
		local deltaTime = RunService.Heartbeat:Wait()
		local ActualDirection = Direction * Speed * deltaTime
		local NewPosition = Position + ActualDirection

		cast = self:RayCast(Position, ActualDirection, Speed, projectile)

		local distance = (NewPosition - Position).Magnitude
		local center = (NewPosition + Position) / 2

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.Color = BrickColor.random().Color
		part.Size = Vector3.new(0.3, 0.3, distance)
		part.CFrame = CFrame.lookAt(center, NewPosition)
		part.Parent = workspace
		game.Debris:AddItem(part, 1)

		if cast then
			Position = cast.Position
			projectile:PivotTo(CFrame.lookAt(Position, Position + Direction))
			break
		end

		Position = NewPosition
		projectile:PivotTo(CFrame.lookAt(Position, Position + Direction))

	until workspace:GetServerTimeNow() > CooldownTime

	return cast
end

for _, v in pairs(handlers)do
	v.F =  HandlerFunctions
end

return ActionFactory