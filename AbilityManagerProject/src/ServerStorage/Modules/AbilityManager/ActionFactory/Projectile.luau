local RunSerive = game:GetService("RunService")


local Projectile = {}


function Projectile:Play(data)
	local Origin = data.Origin
	local Direction = data.Direction.Unit
	local Speed = data.Speed
	local hitEffect = data.hitEffect
	local ProjectileDuration = data.ProjectileDuration
	local filter = data.Filter
	if data.Effect then
		local effect = data.Effect:Clone()
		effect:PivotTo(CFrame.new(Origin,Direction))
		effect.Parent = workspace
		self.F:EmitEffects(effect)
		
		local hitInformation = self.F:Fire(Origin,Direction,Speed,effect,ProjectileDuration,filter) :: RaycastResult
		
		if hitInformation then
			if hitEffect then
				local newHitEffect = hitEffect:Clone()
				newHitEffect.Parent = workspace
				newHitEffect:PivotTo(CFrame.new(hitInformation.Position,hitInformation.Normal))
				self.F:EmitEffects(newHitEffect)
			end
		end
		
		game.Debris:AddItem(effect,2)
		
		return hitInformation
	end
end

return Projectile