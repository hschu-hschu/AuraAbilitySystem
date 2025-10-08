local Startup = {}

function Startup.Create(data)
	local action = {}

	action.F = Startup.F
	
	function action:Play(character)
		if data.AnimationId then
			self.F:PlayAnimation(character, data.AnimationId)
		end
		if data.Effect then
			local TargetCFrame = character:FindFirstChild("HumanoidRootPart").CFrame
			local effect = data.Effect:Clone()
			effect.Parent = workspace
			effect:PivotTo(TargetCFrame)
			self.F:EmitEffects(effect)
			game.Debris:AddItem(effect,10)
		end
		local previousSpeed
		if data.Speed then
			local Humanoid = character:FindFirstChild("Humanoid")
			if Humanoid then
				Humanoid.WalkSpeed = data.Speed
			end	
		end
		task.wait(data.Duration or 1)
		if data.Speed then
			local Humanoid = character:FindFirstChild("Humanoid")
			if Humanoid then
				Humanoid.WalkSpeed = 16
			end	
		end
	end

	return action
end

return Startup