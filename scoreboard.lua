function HandleScoreboardObjectivesCommand( Player, Scoreboard, SubCommand, Args )
	-- Lookup table for the objective types
	local ObjectiveTypes = {
		dummy = cObjective.otDummy
	}

	local DisplaySlotTypes = {
		sidebar = cScoreboard.dsSidebar,
		belowName = cScoreboard.dsName,
		list = cScoreboard.dsList
	}

	if SubCommand == "add" then
		local ObjectiveName = Args[1]
		local CriteriaType = Args[2]
		local DisplayName = Args[3]
		if CriteriaType == nil or ObjectiveName == nil then
			Player:SendMessageInfo("Usage: /scoreboard objectives <objective name> <criteria type> [<display name>]")
		end
		if ObjectiveTypes[CriteriaType] == nil then
			Player:SendMessageInfo("Couldn't create objective, unknown objective type '"..CriteriaType.."'")
			return
		end
		local Objective = Scoreboard:RegisterObjective(ObjectiveName, DisplayName, ObjectiveTypes[CriteriaType])
		if Objective == nil then
			Player:SendMessageInfo("Could not create objective "..ObjectiveName)
		end
	end
	if SubCommand == "remove" then
		local ObjectiveName = Args[1]
		if Scoreboard:RemoveObjective(ObjectiveName) then
			Player:SendMessageInfo("Removed objective "..ObjectiveName)
		else
			Player:SendMessageInfo("No such objective "..ObjectiveName)
		end
	end
	if SubCommand == "list" then
		Player:SendMessageInfo("Objectives:")
		Scoreboard:ForEachObjective(function (Objective)
			Player:SendMessageInfo(Objective:GetName())
		end)
		Player:SendMessageInfo("That's it!")
	end
	if SubCommand == "setdisplay" then
		local Slot = Args[1]
		local ObjectiveName = Args[2]
		if Slot == nil or ObjectiveName == nil then
			Player:SendMessageInfo("Usage: /scoreboard objectives setdisplay <slot> <objective name>")
			return
		end
		if DisplaySlotTypes[Slot] == nil then
			Player:SendMessageInfo("Unknown display slot type '"..Slot.."'")
			return
		end
		Scoreboard:SetDisplay(ObjectiveName, DisplaySlotTypes[Slot])
	end
end

function HandleScoreboardPlayersCommand( Player, Scoreboard, SubCommand, Args )
	if SubCommand == "list" then
		-- Unimplemented
	end
	if SubCommand == "set" then
		local PlayerName = Args[1]
		local ObjectiveName = Args[2]
		local Score = Args[3]
		LOG("Got Score="..tonumber(Score).." from '"..Args[3].."'")
		Scoreboard:GetObjective(ObjectiveName):SetScore(PlayerName, tonumber(Score))
	end
end

function HandleScoreboardTeamsCommand( Player, Scoreboard, SubCommand, Args )
	-- Color lookup table
	local Colors = {
		black = 0,
		dark_blue = 1,
		dark_green = 2,
		dark_aqua = 3,
		dark_red = 4,
		dark_purple = 5,
		gold = 6,
		gray = 7,
		dark_gray = 8,
		blue = 9,
		green = 10,
		aqua = 11,
		red = 12,
		light_purple = 13,
		yellow = 14,
		white = 15
	}

	if SubCommand == "add" then
		local Name = Split[4]
		local DisplayName = Split[5]
		LOG("Registering a team with name "..Name)
		Scoreboard:RegisterTeam(Name, DisplayName, "", "")
	end
	if SubCommand == "option" then
		local Team = Split[4]
		local Option = Split[5]
		local Value = Split[6]
		if Option == "color" then
			local Color = Colors[Value]
			if Color == nil then
				Player:SendMessageInfo("Unknown color '"..Value.."'")
				return
			end
			Scoreboard:GetTeam(Team):SetColor(tonumber(Value))
		end
	end
	if SubCommand == "join" then
		local Team = Split[4]
		local Player = Split[5]
		Scoreboard:GetTeam(Team):AddPlayer(Player)
	end
end

function HandleScoreboardCommand( Split, Player )
	LOG("Player "..Player:GetName().." called /scoreboard "..table.concat(Split, " "))

	local Scoreboard = Player:GetWorld():GetScoreBoard()

	-- Copy the args
	local Args = {}
	for i=4,100 do
		Args[#Args + 1] = Split[i]
	end

	-- Objective management code
	local Command = Split[2]
	local SubCommand = Split[3]
	--local Args = table.move(Split, 4, 100, 1, {})
	if Command == "objectives" then
		HandleScoreboardObjectivesCommand(Player, Scoreboard, SubCommand, Args)
	end

	-- Player management code
	if Command == "players" then
		HandleScoreboardPlayersCommand(Player, Scoreboard, SubCommand, Args)
	end

	-- Team management code
	-- Teams work by shadowing in each display slot
	-- But, for now at least, we can blindly send all the datas
	if Command == "teams" then
		HandleScoreboardTeamsCommand(Player, Scoreboard, SubCommand, Args)
	end

	return true
end
