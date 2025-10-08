-- Thanks to @nofair2002 for contributing this code.
local AbilityManager = {}

local AbilityList = {}

function Init()
	for i,child in script.AbilityList:GetChildren() do
		local module = require(child)
		AbilityList[module.Name] = module
	end
	script.AbilityList.ChildAdded:Connect(function(child: Instance) 
		local module = require(child)
		AbilityList[module.Name] = module
	end)
end

function AbilityManager.GetAbilityByName(name: string)
	return AbilityList[name]
end

function AbilityManager.ActiveAbility(player, Character, AbilityName)
	local _Ability = AbilityList[AbilityName]
	if not _Ability then
		return
	end
	
	local self = {
		User = player;
		Name = AbilityName;
		Cooldown = _Ability.Cooldown or 3;
		CurrentState = "Ready"; -- Running 2가지로 나뉨
		--FunctionsToRunWhenCancelling = {};
	}
	
	function self:Play()
		if self.CurrentState == "Ready" then
			self.RunQueue = _Ability.ActionList
			self.CurrentQueueIndex = 1
			self.CurrentState = "Running"
			self.RunningThread = task.spawn(function() -- 여기 원래 Skill.Active spawn했었음
				repeat
					local currentAction = self.RunQueue[self.CurrentQueueIndex]
					currentAction:Play(Character)
					if self.CurrentState ~= "Running" then
						return
					end
					self.CurrentQueueIndex += 1
				until self.CurrentQueueIndex > #self.RunQueue
				
				self.CurrentState = "Ready"
			end)
			
			print(`{AbilityName} Activated by {Character.Name}`)
		else
			warn("Ability currentState is not 'Ready': ", self.CurrentState)
		end
	end
	
	function self:Cancel()
		
		if self.RunningThread then
			task.cancel(self.RunningThread)
			self.RunningThread = nil
			self.CurrentState = "Ready"
			self.CurrentQueueIndex = 1
			--for i, v in pairs(self.FunctionsToRunWhenCancelling)do
			--	v()
			--end
		end
	end
	
	print("Ability Initiated: ", self)
	
	return self
end

Init()

return AbilityManager