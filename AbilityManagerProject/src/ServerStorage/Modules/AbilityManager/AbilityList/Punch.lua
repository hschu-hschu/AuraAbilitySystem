local ActionFactory = require(game.ServerStorage.Modules.AbilityManager.ActionFactory)

local Skill = {
	Name = "Punch",
	Cooldown = 0.5;
	Damage = 15;
}

local startupAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 83175481400092,
	Effect = game.ServerStorage.Assets.VFX.Abilitys.StrongPunch,
	Duration = 0.3,
	Speed = 4;
}

local damageAction = require(script.Parent.Parent.ActionFactory.Damage)

local hitboxAction = ActionFactory.CreateAction {
	Type = "Hitbox",
	Size = Vector3.new(4, 4, 4),
	Offset = CFrame.new(0, 0, -3),
	Shape = "Box";
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
	startupAction;
	hitboxAction;
}
--Skill.CurrentAction = nil


return Skill
