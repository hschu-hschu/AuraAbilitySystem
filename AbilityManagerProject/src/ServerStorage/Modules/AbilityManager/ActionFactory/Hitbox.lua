local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Hitbox = {}
--코드 진짜 대충 적은 겁니다
local Count = 1
function Hitbox.Create(data)
	local action = {CFrame=nil}
	
	action.F = Hitbox.F

	function action:Play(Character)
		local root = Character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		
		local size = data.Size or Vector3.new(4, 4, 4)
		local duration = data.Duration or 0

		local alreadyHit = {}

		local function detect()
			local cframe = if (action.CFrame) then action.CFrame else root.CFrame * data.Offset
			local parts do
				if data.Shape == "Box" then
					parts = Workspace:GetPartBoundsInBox(cframe, size, nil)
					--                                           ^^^^이거 Vector3로 쓰세요
				elseif data.Shape == "Radius" then
					parts = Workspace:GetPartBoundsInRadius(cframe.Position, size, nil)
					--                                                       ^^^^이거 숫자로 쓰세요
				end
			end

			if data.Debug then
				local part = Instance.new("Part")
				part.Size = if (typeof(size)=="Vector3") then size else Vector3.one * size
				part.Shape = if (data.Shape=="Box") then Enum.PartType.Block else Enum.PartType.Ball
				part.CFrame = cframe
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 0.5
				part.Color = Color3.new(1, 0, 0)
				part.Parent = Workspace
				game.Debris:AddItem(part, duration)
			end
			
			for _, part in ipairs(parts) do
				local model = part:FindFirstAncestorOfClass("Model")
				if model and model ~= Character and not alreadyHit[model] then
					alreadyHit[model] = true
					if data.OnHit then
						data.OnHit(model, Character, parts)
					end
				end
			end
			return next(alreadyHit) ~= nil
		end
		task.spawn(function()
			if data.AnimationId then
				action.F:PlayAnimation(Character, data.AnimationId)
			end
			if data.Effect then
				local TargetCFrame = root.CFrame
				local effect = data.Effect:Clone()
				effect.Parent = workspace
				effect:PivotTo(TargetCFrame)
				action.F:EmitEffects(effect)
			end
			task.wait(data.Duration or 1)
		end)

		local endTime = workspace:GetServerTimeNow() + duration
		local function loop()
			while workspace:GetServerTimeNow() < endTime do
				local detected = detect()
				if detected and data.StopOnHit then
					break
				end
				task.wait(0.05)
			end
		end
		
		if duration > 0 then
			loop()
		else
			detect()
		end
	end

	return action
end


return Hitbox