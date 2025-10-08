local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
--local remote = game.ReplicatedStorage.Remotes:WaitForChild("MouseUpdate")
local UIS = game.UserInputService

UIS.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
	if input.KeyCode ~= Enum.KeyCode.Unknown then
		game.ReplicatedStorage.Remotes.Input:FireServer(input.KeyCode)	
	end
end)

--game:GetService("RunService").RenderStepped:Connect(function()
--	local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
--	local raycastParams = RaycastParams.new()
--	raycastParams.FilterDescendantsInstances = {player.Character}
--	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

--	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)

--	local hitPosition
--	if result then
--		hitPosition = result.Position
--	else
--		hitPosition = unitRay.Origin + unitRay.Direction * 500
--	end

--	remote:FireServer(hitPosition)
--end)
