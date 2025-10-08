local ActionFactory = require(game.ServerStorage.Modules.AbilityManager.ActionFactory)
local ActionSequence = require(game.ServerStorage.Modules.ActionSequence)

local Skill = {
	Name = "SpiningAttack",
	Cooldown = 5;
	Damage = 50;
}

local startupAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 135901906304940,
	Duration = 2/3, --40/60 Frame
	Speed = 1;
}

local sprintAction = ActionFactory.CreateAction {
	Type = "Sprint",
	AnimationId = 76596114719590,
	Duration = 5,
	Speed = 20;
}

local damageAction = require(script.Parent.Parent.ActionFactory.Damage)
local spiningAttack = ActionFactory.CreateAction {
	Type = "Hitbox",
	Size = Vector3.new(4, 4, 4),
	Shape = "Box",
	Offset = CFrame.new(0, 0, -6),
	Duration = 1/2,
	thread = false;
	Debug = false;
	OnHit = function(target,attacker)
		damageAction:Play(target,{
			Type = "Damage",
			Amount = Skill.Damage/10,
			Effect = game.ServerStorage.Assets.VFX.Abilitys.Hit;
		})
	end
}

function Skill.Active(Character)
	ActionSequence.Run(Skill.ActionList, Character)
end

Skill.ActionList = {
	ActionSequence.Do(startupAction),
	ActionSequence.Async(sprintAction),
	ActionSequence.Repeat(spiningAttack,5,0.2),
}

return Skill
