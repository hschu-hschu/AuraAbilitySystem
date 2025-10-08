local ActionFactory = require(game.ServerStorage.Modules.AbilityManager.ActionFactory)

local Skill = {
	Name = "SprintAttack",
	Cooldown = 5;
	Damage = 15;
}

local startupAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 135901906304940,
	Duration = 2/3, --40/60 Frame
	Speed = 1;
}


local sprintAction = ActionFactory.CreateAction {
	Type = "Sprint",
	AnimationId = 110512061362074,
	Duration = 1,
	Speed = 50;
}

local dropkickAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 83175481400092,

	Duration = 0.1,
	Speed = 70;
}


local damageAction = require(script.Parent.Parent.ActionFactory.Damage)
local sprintHitbox = ActionFactory.CreateAction {
	Type = "Hitbox",
	Size = Vector3.new(4, 4, 4),
	Shape = "Box",
	Offset = CFrame.new(0, 0, -6),
	Duration = 2,
	thread = true;
	StopOnHit = true;
	Debug = false;
	OnHit = function(target,attacker)
		dropkickAction:Play(attacker)
		damageAction:Play(target,{
			Type = "Damage",
			Amount = Skill.Damage,
			Effect = game.ServerStorage.Assets.VFX.Abilitys.Hit;
		})
	end
}




function Skill.Active(Character)
	startupAction:Play(Character)
	sprintHitbox:Play(Character)
	sprintAction:Play(Character)
end

Skill.ActionList = {
	startupAction;
	sprintHitbox;
	sprintAction;
	dropkickAction;
}

return Skill
