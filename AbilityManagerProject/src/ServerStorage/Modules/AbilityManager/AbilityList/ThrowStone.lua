local ActionFactory = require(game.ServerStorage.Modules.AbilityManager.ActionFactory)

local Skill = {
	Name = "ThrowStone",
	Cooldown = 2;
	Damage = 15;
}

local startupAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 104066531200262,
	Duration = 20/60,
	Speed = 1;
}

local recoveryAction = ActionFactory.CreateAction {
	Type = "Startup",
	Duration = 40/60,
	Speed = 1;
}

local damageAction = require(script.Parent.Parent.ActionFactory.Damage)


local shootAction = ActionFactory.CreateAction {
	Type = "FireProjectile",
	Offset = CFrame.new(-1.5, 1, -1),
	Speed = 200,
	Direction = Vector3.new(0,0,-1),
	Effect = game.ServerStorage.Assets.VFX.Abilitys.Stone,
	ProjectileDuration = 0.4,
	--hitEffect = game.ServerStorage.Assets.VFX.Abilitys.LightningStrike; --I didnt make vfx yet
	Lockonable = true;
	OnHit = function(target,character,raycastResult:RaycastResult)
		if raycastResult then
			if target and target:FindFirstChildOfClass("Humanoid") then
				damageAction:Play(target,{
					Type = "Damage",
					Amount = Skill.Damage,
					Effect = game.ServerStorage.Assets.VFX.Abilitys.Hit;
				})
			end
		end
	end;
}

function Skill.Active(Character)
	startupAction:Play(Character)
	shootAction:Play(Character)
	recoveryAction:Play(Character)
end

Skill.ActionList = {
	startupAction,
	shootAction,
	recoveryAction
}

return Skill