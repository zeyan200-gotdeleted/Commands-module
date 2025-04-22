local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Table of allowed user IDs
local AllowedUserIds = {
	[1] = true,
	[2] = true,
	[3] = true
}

local CommandSystem = {}
CommandSystem.__index = CommandSystem

function CommandSystem.new()
	local self = setmetatable({}, CommandSystem)
	self.Commands = {}
	self.LoopStorage = {}
	self:LoadCommands()
	return self
end

function CommandSystem:LoadCommands()
	local commandListModule = script:FindFirstChildOfClass("ModuleScript")
	if commandListModule then
		self.Commands = require(commandListModule)
	else
		self.Commands = {}
	end
end

function CommandSystem:FindPlayers(caller, arg)
	if not arg or arg == "" then
		return { caller }
	end

	local targets = {}
	arg = arg:lower()

	if arg == "all" then
		return Players:GetPlayers()
	elseif arg == "me" then
		return { caller }
	else
		for _, player in pairs(Players:GetPlayers()) do
			if player.Name:lower():find(arg) then
				table.insert(targets, player)
			end
		end
	end

	return #targets > 0 and targets or { caller }
end

function CommandSystem:FindCommand(commandName)
	for _, command in pairs(self.Commands) do
		if command.Name:lower() == commandName:lower() or (command.Aliases and table.find(command.Aliases, commandName:lower())) then
			return command
		end
	end
	return nil
end

function CommandSystem:OnPlayerChatted(player, message)
	
	if not AllowedUserIds[player.UserId] then
		return
	end

	if message:sub(1, 1) == "!" then
		local args = message:sub(2):split(" ")
		local commandName = args[1] and args[1]:lower() or ""
		local isLoop = commandName:find("loop")
		local isUnloop = commandName:find("unloop")
		local finalCommandName = commandName

		if isLoop and not isUnloop then
			finalCommandName = commandName:gsub("loop", "")
		elseif isUnloop then
			finalCommandName = commandName:gsub("unloop", "")
		end

		local command = self:FindCommand(finalCommandName)
		if command then
			table.remove(args, 1)

			local targets = self:FindPlayers(player, args[1])

			local commandArgs = {}
			if command.Arguments and command.Arguments[1] == "Player" then
				commandArgs = { targets[1] }
				for i = 2, #args do
					table.insert(commandArgs, args[i])
				end
			else
				commandArgs = args
			end

			if command.Loopable and isLoop and not isUnloop then
				local loopKey = `{command.Name} - {player.UserId}`
				self.LoopStorage[loopKey] = coroutine.create(function()
					while task.wait(1) do
						for _, target in pairs(targets) do
							if command.Arguments and command.Arguments[1] == "Player" then
								commandArgs[1] = target
							end
							command.Function(target, commandArgs)
						end
					end
				end)
				coroutine.resume(self.LoopStorage[loopKey])
			elseif isUnloop and command.Loopable then
				local loopKey = `{command.Name} - {player.UserId}`
				if self.LoopStorage[loopKey] then
					coroutine.close(self.LoopStorage[loopKey])
					self.LoopStorage[loopKey] = nil
				end
			else
				for _, target in pairs(targets) do
					if command.Arguments and command.Arguments[1] == "Player" then
						commandArgs[1] = target
					end
					command.Function(target, commandArgs)
				end
			end
		end
	end
end

function CommandSystem:Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			self:OnPlayerChatted(player, message)
		end)
	end)

	for _, player in pairs(Players:GetPlayers()) do
		player.Chatted:Connect(function(message)
			self:OnPlayerChatted(player, message)
		end)
	end
end

local system = CommandSystem.new()
system:Start()

return system
