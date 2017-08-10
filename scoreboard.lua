function HandleScoreboardObjectivesCommand( Player, SubCommand, Args)
	if SubCommand == "add" then
		local ObjectiveName = Args[1]
		local CriteriaType = Args[2]
		local DisplayName = Args[3]
		local Objective = Scoreboard:RegisterObjective(ObjectiveName, DisplayName, ObjectiveTypes[CriteriaType])
		if Objective == nil then
			Player:SendMessageInfo("Could not create objective "..ObjectiveName)
		end
	end
	if SubCommand == "remove" then
		local ObjectiveName = Args[1]
		Scoreboard:RemoveObjective(ObjectiveName)
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
		Scoreboard:SetDisplay(ObjectiveName, tonumber(Slot))
	end
end

function HandleScoreboardPlayersCommand( Player, SubCommand, Args)
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

function HandleScoreboardTeamsCommand( Player, SubCommand, Args)
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

	-- Lookup table for the objective types
	local ObjectiveTypes = {
		dummy = cObjective.otDummy
	};

	-- Objective management code
	local Command = Split[2]
	local SubCommand = Split[3]
	local Args = table.move(Split, 4, 100, 1, {})
	if Command == "objectives" then
		HandleScoreboardObjectivesCommand(Player, SubCommand, Args)
	end

	-- Player management code
	if Command == "players" then
		HandleScoreboardPlayersCommand(Player, SubCommand, Args)
	end

	-- Team management code
	-- Teams work by shadowing in each display slot
	-- But, for now at least, we can blindly send all the datas
	if Command == "teams" then
		HandleScoreboardTeamsCommand(Player, SubCommand, Args)
	end

	return true
end
