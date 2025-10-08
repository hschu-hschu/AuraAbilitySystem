local Damage = {}

function Damage:Play(TargetCharacter, data)
	game.ServerStorage.GiveDamage:Fire(TargetCharacter, data.Amount or 5)

	if data.Effect then
		local effect = data.Effect:Clone()
		effect.Parent = workspace
		effect:PivotTo(TargetCharacter:GetPivot())
		self.F:EmitEffects(effect)
		game.Debris:AddItem(effect, 1)
	end
end

return Damage