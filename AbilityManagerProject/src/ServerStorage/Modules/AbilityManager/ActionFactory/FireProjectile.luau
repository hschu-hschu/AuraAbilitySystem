local Projectile = require(script.Parent.Projectile)

local module = {}

function module.Create(data)
	local action = {}
	local Offset = data.Offset

	action.F = module.F

	function action:Play(character)
		local pivot = character:GetPivot()
		local worldOrigin = (pivot * Offset).Position
		local worldDirection = pivot:VectorToWorldSpace(data.Direction).Unit
		if data.Lockonable then
			local TargetInfo = character:FindFirstChild("TargetInfo")
			if TargetInfo then
				local targetRoot = TargetInfo.Value
				if targetRoot then
					worldDirection = (targetRoot.Position - worldOrigin).Unit
				end
			end
		end
		local filter = RaycastParams.new()
		filter.FilterType = Enum.RaycastFilterType.Exclude
		filter.FilterDescendantsInstances = {character}
		local projectiledata = {
			Origin = worldOrigin,
			Direction = worldDirection,
			Speed = data.Speed,
			hitEffect = data.hitEffect,
			ProjectileDuration = data.ProjectileDuration,
			Effect =  data.Effect,
			Filter = filter
		}

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.Color = Color3.new(0, 0, 1)
		part.CFrame = CFrame.lookAt(projectiledata.Origin, projectiledata.Origin + projectiledata.Direction)
		part.Parent = workspace
		game.Debris:AddItem(part,2)
		task.spawn(function()
			local hitInformation = Projectile:Play(projectiledata)
			if data.OnHit then
				if hitInformation then
					local model = hitInformation.Instance:FindFirstAncestorOfClass("Model")
					if model then
						data.OnHit(model, character,hitInformation)
					end
				end
			end
		end)
		
		task.wait(data.Duration or 0)
	end

	return action
end

return module
