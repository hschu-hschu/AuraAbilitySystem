-- Thanks to @nofair2002 for contributing this code.

local AbilityManager = require(game.ServerStorage.Modules.AbilityManager)
local AuraManager = require(game.ServerStorage.Modules.AuraManager)

local playerCurrentSkillList = {
	
	
} :: {Player: table}

local playerSkillCooldownList = { -- 스킬 쿨타임 리스트
	
	
} :: {Player: table}

local characterStatusEffectList = {
	
} :: {instance : table}


local AuraAbilityList = {
	["Common"] = { 
		[Enum.KeyCode.E] = "LightningBolt";
		[Enum.KeyCode.F] = "Punch";
		[Enum.KeyCode.R] = "DarkStrongPunch";
		[Enum.KeyCode.Q] = "StrongPunch";
	};
}


local function getPlayerAuraSkills(player)
	
	return  AuraAbilityList[AuraManager.GetAuraFromPlayer(player)] or {}
end



local function OnInputDetected(player,input: Enum.KeyCode)
	
	-- 장착한 아우라에 해당 키에 해당하는 스킬 있음?
	local skillName = getPlayerAuraSkills(player)[input]
	if not skillName then
		--출력 너무 많아서 잠깐 비활성
		--print("no skill for ", input)
		return
	end
	if not AbilityManager.GetAbilityByName(skillName) then
		print(`{skillName}은 존재하지 않는 스킬`)
		return
	end
	
	if playerCurrentSkillList[player] then
		
		-- 스킬 쿨타임 끝났음?
		if playerSkillCooldownList[player][input] then
			print("cooldown not yet finished", playerSkillCooldownList[player][input])
			return
		end
		
		-- 이미 사용중인 스킬 없음?
		if playerCurrentSkillList[player] and playerCurrentSkillList[player].CurrentState ~= "Ready" then
			warn("attempted to 스킬 중복 실행")
			return
		end
	end
	
	
	-- 새 실시간 스킬 개체 생성
	playerCurrentSkillList[player] = AbilityManager.ActiveAbility(player, player.Character,skillName)
	print(playerCurrentSkillList[player])
	-- 스킬 쿨타임 리스트에 추가
	if not playerSkillCooldownList[player] then
		playerSkillCooldownList[player] = {}
	end
	
	playerSkillCooldownList[player][input] = playerCurrentSkillList[player].Cooldown
	
	-- 스킬 발동
	playerCurrentSkillList[player]:Play()
end

game.ReplicatedStorage.Remotes.Input.OnServerEvent:Connect(OnInputDetected)
local LockedTargetSignal = game.ReplicatedStorage.Remotes.LockedTargetSignal

LockedTargetSignal.OnServerEvent:Connect(function(player: Player, target: Part) 
	if player.Character then
		local TargetInfo = player.Character:FindFirstChild("TargetInfo") or Instance.new("ObjectValue",player.Character)
		TargetInfo.Name = "TargetInfo"
		TargetInfo.Value = target
	end
end)

-- 데미지
game.ServerStorage.GiveDamage.Event:Connect(function(character, damage)
	if not character:FindFirstChild("Humanoid") then
		return
	end
	
	if not characterStatusEffectList[character] then
		characterStatusEffectList[character] = {}
	end
	
	-- 무적 상태가 아닌가?
	if characterStatusEffectList[character]["Invincible"] then
		return
	end
	
	characterStatusEffectList[character]["Invincible"] = 0.5 -- 2초 무적
	character.Humanoid:TakeDamage(damage)
	
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	
	-- 플레이어가 스킬 쓰던 도중인가?
	if playerCurrentSkillList[player] and playerCurrentSkillList[player].CurrentState == "Running" then
		playerCurrentSkillList[player]:Cancel()
	end
end)



while true do
	local delta = task.wait()
	for plr, list in pairs(playerSkillCooldownList)do-- 스킬 쿨타임 스레드
		for keycode, timeLeft in pairs(list) do
			list[keycode] -= delta
			if list[keycode] <= 0 then
				list[keycode] = nil
			end
		end
	end
	for chr, list in pairs(characterStatusEffectList)do-- 상태 쿨타임 스레드
		
		if not chr.Parent then
			characterStatusEffectList[chr] = nil
			continue
		end
		
		for name, timeLeft in pairs(list) do
			list[name] -= delta
			if list[name] <= 0 then
				list[name] = nil
			end
		end
	end
end
