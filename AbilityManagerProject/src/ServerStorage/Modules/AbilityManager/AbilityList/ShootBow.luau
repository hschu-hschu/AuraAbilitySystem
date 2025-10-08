local ActionFactory = require(game.ServerStorage.Modules.AbilityManager.ActionFactory)

local Skill = {
	Name = "ShootBow",
}

local startupAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 137133949406559,
	Duration = 76/60,
	Speed = 1;
}

local recoveryAction = ActionFactory.CreateAction {
	Type = "Startup",
	Duration = 34/60,
	Speed = 1;
}

local damageAction = require(script.Parent.Parent.ActionFactory.Damage)


local shootAction = ActionFactory.CreateAction {
	Type = "FireProjectile",
	Offset = CFrame.new(-0.25, 0.2, -1),
	Speed = 100,
	Direction = Vector3.new(0,0,-1),
	Effect = game.ServerStorage.Assets.VFX.Abilitys.Arrow,
	ProjectileDuration = 2,
	--hitEffect = game.ServerStorage.Assets.VFX.Abilitys.LightningStrike; --I didnt make vfx yet
	Lockonable = true;
	OnHit = function(target,character,raycastResult:RaycastResult)
		if raycastResult then
			if target and target:FindFirstChildOfClass("Humanoid") then
				damageAction:Play(target,{
					Type = "Damage",
					Amount = 20,
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
	recoveryAction,
}

return Skill