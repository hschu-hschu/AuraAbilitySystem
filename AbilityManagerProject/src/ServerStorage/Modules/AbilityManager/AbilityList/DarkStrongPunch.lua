local ActionFactory = require(game.ServerStorage.Modules.AbilityManager.ActionFactory)
local ActionSequence = require(game.ServerStorage.Modules.ActionSequence)



local Skill = {
	Name = "DarkStrongPunch",
	Cooldown = 5;
	Damage = 15;
}

local startupAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 82847330611877,
	Duration = 0.3,
}

local damageAction = require(script.Parent.Parent.ActionFactory.Damage)
local hitboxAction = ActionFactory.CreateAction {
	Type = "Hitbox",
	Effect = game.ServerStorage.Assets.VFX.Abilitys.DarkStrongPunch,
	Size = Vector3.new(6, 6, 15),
	Shape = "Box";
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
	ActionSequence.Run(Skill.ActionList, Character)
end

Skill.ActionList = {
	startupAction;
	hitboxAction;
}

return Skill
