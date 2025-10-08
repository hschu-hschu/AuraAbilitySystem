local ActionFactory = require(game.ServerStorage.Modules.AbilityManager.ActionFactory)

local Skill = {
	Name = "LightningBolt",
	Cooldown = 5;
	Damage = 20;
}

local startupAction = ActionFactory.CreateAction {
	Type = "Startup",
	AnimationId = 76394554110589,
	Duration = 20/60,
	Speed = 5; --character's speed
}

local chargeAction = ActionFactory.CreateAction {
	Type = "Startup",
	Duration = 110/60,
	Speed = 5;
	Effect = game.ServerStorage.Assets.VFX.Abilitys.Charge;
}

--THIS IS TEST CODE
function OpenDoor()
	local part = workspace.Door
	local tween = game.TweenService:Create(part,TweenInfo.new(5),{CFrame = part.CFrame+Vector3.new(0,17,0)})
	task.wait(1)
	tween:Play()
	part["Rock moving"]:Play()
	tween.Completed:Wait()
	part["Rock moving"]:Stop()
	part["Rock Hit Sound"]:Play()
end

local hitboxAction = ActionFactory.CreateAction {
	Type = "Hitbox",
	Size = 5,
	Shape = "Radius";
	Duration = 0.1,
	StopOnHit = true;
	Debug = true;
	--OnHit = function(target,attacker,parts)
		
	--end,
}
local damageAction = require(script.Parent.Parent.ActionFactory.Damage)


local boltThrowAction = ActionFactory.CreateAction {
	Type = "FireProjectile",
	Offset = CFrame.new(2, 6, 0),
	Speed = 400,
	Direction = Vector3.new(-1,-2.5,-30),
	Effect = game.ServerStorage.Assets.VFX.Abilitys.LightningBolt,
	ProjectileDuration = 2,
	Duraction = 0.3,
	hitEffect = game.ServerStorage.Assets.VFX.Abilitys.LightningStrike;
	Lockonable = true;
	OnHit = function(target,character,raycastResult:RaycastResult)
		if raycastResult then
			hitboxAction.CFrame = CFrame.new(raycastResult.Position,raycastResult.Normal)
			hitboxAction:Play(character)
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
	chargeAction:Play(Character)
	boltThrowAction:Play(Character)
end

Skill.ActionList = {
	startupAction;
	chargeAction;
	boltThrowAction;
}

return Skill