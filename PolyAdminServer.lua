--[[
	For the HiddenDevs person who is going over my application:
	This admin command utility will use 2 different kinds of commands: Generic and Admin.
	Generic commands are for the normalers who are ranked but do not have admin permissions (e.g, walkspeed, jumppower, kill)
	Admin commands are for the moderators or admins in the game that have access to admin parts of the game (e.g kick, ban, announce)
	ReplicatedStorage.PolyCMDBridge will be used to communicate between the server and the client with the commands being handled on the server
	ReplicatedStorage.PolyInfo will be used to send notifcations to the client from the server
]]
-- Begin Utils and CMD metatable stuff--
-- Begin Utils --
local Utils = {}
local CachedConfig = nil
function Utils:GetConfig()
	if(CachedConfig ~= nil) then
		return CachedConfig
	end
	CachedConfig = shared.DataStore:GetAsync("Config")
	return CachedConfig
end
function Utils:IsOwner(Player: Player)
	local UserID = tostring(Player.UserId)
	return UserID == tostring(Utils:GetConfig().Owner)
end
function Utils:IsPlayerBanned(Player: Player)
	local UserID = tostring(Player.UserId)
	local Config = Utils:GetConfig()
	-- If this is not equal to nil, the player clearly is banned, as their user ID is in the banned user ID registry
	return Config.Banned[UserID] ~= nil
end
function Utils:IsPlayerRanked(Player: Player)
	if(Utils:IsOwner(Player)) then
		return true
	end
	local UserID = tostring(Player.UserId)
	local Config = Utils:GetConfig()
	-- If this is true, it must exist (because I set it to true for each permission)
	if(Config.Admins[UserID] == true or Config.Generic[UserID] == true) then
		return true
	end
	return false
end
function Utils:IsPlayerAdmin(Player: Player)
	if(Utils:IsOwner(Player)) then
		return true
	end
	local UserID = tostring(Player.UserId)
	local Config = Utils:GetConfig()
	-- If this is true, it must exist (because I set it to true for each admin)
	if(Config.Admins[UserID] == true) then
		return true
	end
	return false
end
function Utils:IsPlayerGeneric(Player: Player)
	local UserID = tostring(Player.UserId)
	local Config = Utils:GetConfig()
	-- If this is true, it must exist (because I set it to true for each generic ranked user)
	if(Config.Generic[UserID] == true) then
		return true
	end
	return false
end
-- end Utils
-- CMD --
local CMD = {}
CMD.__index = CMD
function CMD.New(Name, Callback)
	local NewCMD = setmetatable({}, CMD)
	NewCMD.Name = Name
	NewCMD.Callback = Callback
	return NewCMD
end
-- end CMD
-- Begin Command Handler--
--[[
	NOTE: When a command finishes, it'll return a table with 2 values
	[1] = Boolean (Success)
	[2] = String (Error Message)
	When Config.Banned[UserID] ~= nil, that means that the player is not banned since it doesn't exist in the ban registry
]]
local PolyCMDBridge = game:GetService("ReplicatedStorage").Remotes.PolyCMDBridge
local PolyInfo = game:GetService("ReplicatedStorage").Remotes.PolyInfo
local GenericCommands = {}
local AdminCommands = {}
function FindPlayer(PlayerName)
	local Lower = string.lower(PlayerName)
	for I, V in pairs(game.Players:GetPlayers()) do
		-- I will comapare the lowercase name to ensure it is unique
		if string.lower(V.Name) == Lower or string.lower(V.DisplayName) == Lower then
			return V
		end
	end
	return nil
end
function FindTargetPlayer(Player: Player, TargetName: string)
	if(TargetName == "me") then
		return Player
	end
	return FindPlayer(TargetName)
end
GenericCommands["ranktype"] = CMD.New("ranktype", function(Player: Player, Args)
	if(not Utils:IsPlayerRanked(Player)) then
		return {false, "You are not ranked, how the hell do you even have this GUI?!"}
	end
	if(Utils:IsPlayerGeneric(Player)) then
		PolyInfo:FireClient(Player, {[1] =  "Rank Type", [2] = "Rank type: Generic"})
	elseif(Utils:IsPlayerAdmin(Player)) then
		PolyInfo:FireClient(Player, {[1] =  "Rank Type", [2] = "Rank type: Admin"})
	end
	return {true, nil}
end)		
GenericCommands["speed"] = CMD.New("speed", function(Player: Player, Args)
	local Target = Args[1]
	local Speed = tonumber(Args[2])-- I'ma ensure the walkspeed is a number
	local TargetPlayer = FindTargetPlayer(Player, Target)
	if(TargetPlayer ~= nil) then
		local Character = TargetPlayer.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		if(Humanoid ~= nil) then
			Humanoid.WalkSpeed = Speed
			return {true, nil}
		end
		return {false, string.format("Player %s's humanoid is not found!", TargetPlayer.DisplayName)}
	end
	return {false, string.format("Player %s does not exist!", Target)}
end)
-- Alias for speed
GenericCommands["ws"] = CMD.New("ws", function(Player: Player, Args)
	local Target = Args[1]
	local Speed = tonumber(Args[2])-- I'ma ensure the walkspeed is a number
	local TargetPlayer = FindTargetPlayer(Player, Target)
	if(TargetPlayer ~= nil) then
		local Character = TargetPlayer.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		if(Humanoid ~= nil) then
			Humanoid.WalkSpeed = Speed
			return {true, nil}
		end
		return {false, string.format("Player %s's humanoid is not found!", TargetPlayer.DisplayName)}
	end
	return {false, string.format("Player %s does not exist!", Target)}
end)
GenericCommands["jumppower"] = CMD.New("jumppower", function(Player: Player, Args)
	local Target = Args[1]
	local JumpPower = tonumber(Args[2]) -- I'ma ensure the jumppower is a number
	local TargetPlayer = FindTargetPlayer(Player, Target)
	if(TargetPlayer ~= nil) then
		local Character = TargetPlayer.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		if(Humanoid ~= nil) then
			Humanoid.JumpPower = JumpPower
			return {true, nil}
		end
		return {false, string.format("Player %s's humanoid is not found!", TargetPlayer.DisplayName)}
	end
	return {false, string.format("Player %s does not exist!", Target)}
end)
-- Alias for jumppower
GenericCommands["jp"] = CMD.New("jp", function(Player: Player, Args)
	local Target = Args[1]
	local JumpPower = tonumber(Args[2]) -- I'ma ensure the jumppower is a number
	local TargetPlayer = FindTargetPlayer(Player, Target)
	if(TargetPlayer ~= nil) then
		local Character = TargetPlayer.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		if(Humanoid ~= nil) then
			Humanoid.JumpPower = JumpPower
			return {true, nil}
		end
		return {false, string.format("Player %s's humanoid is not found!", TargetPlayer.DisplayName)}
	end
	return {false, string.format("Player %s does not exist!", Target)}
end)
GenericCommands["kill"] = CMD.New("kill", function(Player: Player, Args)
	local Target = Args[1]
	local TargetPlayer = FindTargetPlayer(Player, Target)
	if(TargetPlayer ~= nil) then
		if(TargetPlayer:FindFirstChild("Character") and TargetPlayer.Character:FindFirstChild("Humanoid")) then
			TargetPlayer.Character.Humanoid.Health = 0
			return {true, nil}
		end
		return {false, string.format("Player %s's humanoid is not found!", TargetPlayer.DisplayName)}
	end
	return {false, string.format("Player %s does not exist!", Target)}
end)
GenericCommands["btools"] = CMD.New("btools", function(Player: Player, Args)
	local Target = Args[1]
	local HopperBin = Instance.new("HopperBin")
	HopperBin.BinType = Enum.BinType.Hammer
	HopperBin.Parent = Player.Backpack
	return {true, nil}
end)
AdminCommands["kick"] = CMD.New("kick", function(Player: Player, Args)
	local Target = Args[1]	
	local Reason = table.concat(Args, " ", 2)
	local TargetPlayer = FindPlayer(Target)
	if(TargetPlayer ~= nil) then
		TargetPlayer:Kick(Reason)
		return {true, nil}
	end
	return {false, string.format("Player %s does not exist!", Target)}
end)
AdminCommands["ban"] = CMD.New("ban", function(Player: Player, Args)
	local Target = Args[1]	
	local Reason = table.concat(Args, " ", 2)
	local TargetPlayer = FindPlayer(Target)
	if(TargetPlayer ~= nil) then
		local Config = Utils:GetConfig()
		local UserID = tostring(TargetPlayer.UserId)
		if(UserID == tostring(Config.Owner)) then -- GG if you try to ban the owner
			return {false, "You cannot ban the owner!"}
		end
		if(Config.Banned[UserID] ~= nil) then
			return {false, string.format("Player %s is already banned!", TargetPlayer.Name)}
		end
		Config.Banned[UserID] = Reason
		shared.DataStore:SetAsync("Config", Config) -- We will save the config to the datastore
		TargetPlayer:Kick(string.format("You have been banned from this game. Reason: %s", Config.Banned[UserID]))
		return {true, nil}
	end
	return {false, string.format("Player %s does not exist!", Target)}
end)
AdminCommands["unban"] = CMD.New("unban", function(Player: Player, Args)
	local Target = Args[1]	
	local Reason = table.concat(Args, " ", 2)
	local TargetPlayer = FindPlayer(Target)
	if(TargetPlayer ~= nil) then
		local UserID = tostring(TargetPlayer.UserId)
		local Config = Utils:GetConfig()
		-- If the player is not banned, then Config.Banned[UserID] will obviously be nil in this case since the player is not found in the registry
		if(Config.Banned[UserID] == nil) then
			return {false, string.format("Player with user ID %s is not banned!", UserID)}
		end
		Config.Banned[UserID] = nil
		shared.DataStore:SetAsync("Config", Config)
		return {true, nil}
	end
	return {false, string.format("Player %s does not exist!", Target)}
end)
AdminCommands["shutdown"] = CMD.New("shutdown", function(Player: Player, Args)
	local Reason = table.concat(Args, " ", 1) -- We will combine all the args into 1 string
	task.spawn(function()
		for I,V in game.Players:GetPlayers() do
			V:Kick(string.format("The server has been shutdown! Reason: %s", Reason))
		end
	end)
	return {true, nil}
end)
AdminCommands["cmds"] = CMD.New("cmds", function(Player: Player, Args)
	local Reason = table.concat(Args, " ", 1)
	-- Parent cmd list to the callers PlayerGui
	local CMDListGui = script.CmdsList:Clone()
	CMDListGui.Parent = Player.PlayerGui
	return {true, nil}
end)
PolyCMDBridge.OnServerInvoke = function(Player: Player, CommandName: string, Args)
	print("Command recieved! Name: " .. CommandName)
	local IsRanked = Utils:IsPlayerRanked(Player) 
	-- I will check for 2 types of commands here, if the command exists in one of the 2, then it'll be found, if not then we will throw an error to the client that executed the command
	local Command = GenericCommands[CommandName]
	local AdminCommand = AdminCommands[CommandName]
	if(Command ~= nil) then
		-- Is the caller player at least a generic admin user or an admin user?
		if(Utils:IsPlayerRanked(Player)) then
			local Result = Command.Callback(Player, Args)
			-- Did the command succeed?
			if(Result[1] == true) then
				return "CmdSuccess"
			else
				return {"CmdFail", Result[2]}
			end
		else
			return {"CmdFail", string.format("You do not have permission to use command %s!", CommandName)}
		end
	elseif(AdminCommand ~= nil) then
		if(Utils:IsPlayerAdmin(Player)) then
			local Result = AdminCommand.Callback(Player, Args)
			-- Did the command succeed?
			if(Result[1] == true) then
				return "CmdSuccess"
			else
				return {"CmdFail", Result[2]}
			end
		else
			return {"CmdFail", string.format("You do not have permission to use command %s!", CommandName)}
		end
	else
		return {"CmdFail", string.format("Command %s does not exist!", CommandName)}
	end
end
-- End Command Handler--
-- Init --
local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetDataStore("PolyDataStore")
shared.DataStore = DataStore
local UserID = 0
function OnPlayerAdded(Player: Player)
	if(UserID == 0) then
		UserID = Player.UserId
		local Success, Config = pcall(function() -- To ensure the datastore gets retrieved successfully
			return DataStore:GetAsync("Config")
		end)
		if not Success then
			warn("Failed to get the DataStore! Error: " .. Config)
			Config = nil
		end
		Config = {
			Owner = UserID, -- In this case, I am in the game in studio, so ignore this, this is to debug
			Admins = {}, -- Table full of user ids with admin permissions in our admin commands
			Generic = {},-- Table full of user ids with generic permissions in our admin commands
			Banned = {} -- Table full of user ids that are banned, it will contain Config.Banned[UserID] with the value of the indexed table being true
		}
		DataStore:SetAsync("Config", Config)
		warn("First time setup for Poly Admin has completed!")
		PolyInfo:FireClient(Player, {[1]="Prefix", [2] = "Prefix is \";\" type \"cmds\" to view the commands"})
	end
	local Config = Utils:GetConfig()
	local UserID2 = tostring(Player.UserId)
	-- Lets check the datastore using Utils:IsPlayerBanned to ensure that the user is not banned
	if(Utils:IsPlayerBanned(Player) == true) then
		Player:Kick(string.format("You have been banned from this game. Reason: %s", Config.Banned[UserID2]))
	end
	if(Utils:IsPlayerRanked(Player)) then
		local Clone = script.PolyCMDBar:Clone()
		Clone.Parent = Player:WaitForChild("PlayerGui")
	end
end
game.Players.PlayerAdded:Connect(OnPlayerAdded)
for I,V in pairs(game.Players:GetPlayers()) do
	OnPlayerAdded(V)
end 
-- end init --
