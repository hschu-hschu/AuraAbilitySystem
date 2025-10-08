-- I made it, but didn't use XD

local ActionSequence = {}

function ActionSequence.Do(action)
	return {
		Type = "Do",
		Action = action
	}
end

function ActionSequence.Async(action)
	return {
		Type = "Async",
		Action = action
	}
end

function ActionSequence.Repeat(action, count, interval)
	return {
		Type = "Repeat",
		Action = action,
		Count = count or 1,
		Interval = interval or 0
	}
end

function ActionSequence.Run(sequence, character)
	for _, entry in ipairs(sequence) do
		if entry.Type == "Do" then
			entry.Action:Play(character)

		elseif entry.Type == "Async" then
			task.spawn(entry.Action.Play, entry.Action, character)

		elseif entry.Type == "Repeat" then
			for i = 1, entry.Count do
				entry.Action:Play(character)
				task.wait(entry.Interval)
			end
		else
			warn("Unknown action type:", entry.Type)
		end
	end
end

return ActionSequence
