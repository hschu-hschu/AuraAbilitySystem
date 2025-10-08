local TweenService = game:GetService("TweenService")

local Disappear = {}

function Disappear.Create(data)
	local action = {}
	
	action.F = Disappear.F

	function action:Play(character)
		if data.AnimationId then
			self.F:PlayAnimation(character, data.AnimationId)
		end
		if data.Effect then
			local TargetCFrame = character:FindFirstChild("HumanoidRootPart").CFrame
			local effect = data.Effect:Clone()
			effect.Parent = workspace
			effect:PivotTo(TargetCFrame)
			game.Debris:AddItem(effect,2)
			self.F:EmitEffects(effect)
		end
		local TargetCFrame = character:FindFirstChild("HumanoidRootPart").CFrame
		Instance.new("Explosion",workspace).Position= TargetCFrame.Position
		self.F:DisabledCollision(character)
		self.F:FadeTransparent(character)
		self.F:DisableAllParticles(character)
		task.wait(data.Duration or 1)
	end

	return action
end

return Disappear