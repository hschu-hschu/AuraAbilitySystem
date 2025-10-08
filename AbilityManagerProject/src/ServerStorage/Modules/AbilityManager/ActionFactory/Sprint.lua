local TweenService = game:GetService("TweenService")

local Sprint = {}


function Sprint.Create(data)
	local action = {}
	
	action.F = Sprint.F
	
	function action:Play(character)
		local Track
		if data.AnimationId then
			Track = self.F:PlayAnimation(character, data.AnimationId)
		end
		if data.Effect then
			local TargetCFrame = character:FindFirstChild("HumanoidRootPart").CFrame
			local effect = data.Effect:Clone()
			effect.Parent = workspace
			effect:PivotTo(TargetCFrame)
			local weld = Instance.new("Motor6D")
			weld.Part0 = effect
			weld.Part1 = character.HumanoidRootPart
			weld.Parent = effect
			self.F:EmitEffects(effect)
			game.Debris:AddItem(effect,data.Duration+2)
		end
		character.Humanoid.WalkSpeed = data.Speed or 16
		task.wait(data.Duration or 1)
		character.Humanoid.WalkSpeed = 16
		if Track then
			Track:Stop()
		end
	end

	return action
end

return Sprint