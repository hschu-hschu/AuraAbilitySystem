local ActionFactory = require(game.ServerStorage.Modules.AbilityManager.ActionFactory)

local Skill = {
	Name = "StrongPunch",
	Cooldown = 5;
	Damage = 15;
}

local startupAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 83175481400092,
	Duration = 0.3,
}
local damageAction = require(script.Parent.Parent.ActionFactory.Damage)

local hitboxAction = ActionFactory.CreateAction {
	Type = "Hitbox",
	Shape = "Box";
	Effect = game.ServerStorage.Assets.VFX.Abilitys.StrongPunch,
	Size = Vector3.new(6, 6, 15),
	Offset = CFrame.new(0, 0, -7),
	Duration = 0.1,
	StopOnHit = true;
	Debug = true;
	OnHit = function(target,attacker)
		damageAction:Play(target,{
			Type = "Damage",
			Amount = Skill.Damage,
			Effect = game.ServerStorage.Assets.VFX.Abilitys.Hit;
		})
	end
}


function Skill.Active(Character)
	startupAction:Play(Character)
	hitboxAction:Play(Character)
end

Skill.ActionList = {
	startupAction,
	hitboxAction,
}

return Skill