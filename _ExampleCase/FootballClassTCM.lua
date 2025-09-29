------ <PENGUIN TEST CASE MODULE 🐧> ------
local AutomatedTesting: Folder = game.ReplicatedStorage.AutomatedTesting
local TestCaseClass: ModuleScript = require(AutomatedTesting.PenguinTest) 


------ <MODULE(S) TO TEST> ------
local FootballClass: ModuleScript = require(script.Parent) 


------ <REFERENCES> ------
local footballModel: BasePart = game.ServerStorage.Football


------ <ROOT> ------ 
local TestCaseFile: TestCaseObject = TestCaseClass.new() 


------ <FUNCTIONS> ------ 
-- < [⚙️] INITATION & CLASS MANAGEMENT METHODS [⚙️] > --

-- 📋 [⚙️] <FootballClass.new() ✨⚽> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <✅>] 
TestCaseFile:SetMethod("<FootballClass.new() ⚙⚽> trying valid origin parameters - [Happy Path 🌈]", function() 
	local football: FootballObject = FootballClass.new(Vector3.new(20, 50, 20)) 
	assert(football ~= "Error! Invalid Origin!") 
	football:Destroy() 
end)


TestCaseFile:SetMethod("<FootballClass.new() ⚙⚽> sending invalid origin and spawn parameters - [Sad Path 💀]", function() 
	local arguments: {} = {
		"Hello World!", 123456789, true, false, {}, math.pi, nil
	}
	for _, argument in arguments do 
		local message: string = FootballClass.new(argument, false) 
		assert(message == "Error! Invalid Origin!")
	end 
	
	local arguments: {} = {
		"Hello World!", 123456789, {}, math.pi, nil, Vector3.one
	}
	for _, argument in arguments do 
		local football: FootballObject = FootballClass.new(Vector3.new(0, 0, 0), argument) 
		if typeof(argument) == typeof(true) then 
			task.delay(5, function()
				football:Destroy()
			end)
		end
		
		assert(football == "Error! Invalid AutoSpawn!") 
	end
end) 


-- 📋 [⚙️] <FootballClass:SpawnBall() 🌟⚽> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <N/A>] 
TestCaseFile:SetMethod("<FootballClass:SpawnBall() 🌟⚽> spawning ball - [Happy Path 🌈]", function() 
	local football: FootballObject = FootballClass.new(Vector3.new(30, 20, 30), false)
	assert(football ~= nil)
	
	football:SpawnBall()
	assert(typeof(football.Instance) == typeof(footballModel))
	
	task.delay(5, function()
		football:Destroy()
	end)
end)


-- < [🍎] PHYSICS METHODS [🍎] > -- 

-- 📋 [🍎] <FootballClass:ApplyImpulse() 🔥⚽> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <✅>]
TestCaseFile:SetMethod("<FootballClass:ApplyImpulse() 🔥⚽> validate whether :ApplyImpulse() sets network ownership correctly - [Happy Path 🌈]", function() 
	task.spawn(function()
		local player: Player = game.Players:WaitForChild("LungmaDEV", 10)
		if not player then return end

		local football: FootballObject = FootballClass.new(Vector3.new(50, 20, 50)) 
		task.delay(15, function() 
			football:Destroy() 
		end) 

		local ball: BasePart = football.Instance 
		ball:SetNetworkOwner(player) 

		task.wait(4)

		assert(ball:GetNetworkOwner() == player)
		
		local MOCK_FORCE = Vector3.new(-47.839447021484375, 52.42742919921875, 73.70833587646484)
		local MOCK_DELAY = 0.5

		football:ApplyImpulse(MOCK_FORCE, MOCK_DELAY)

		task.delay(0.2, function()
			assert(ball.AssemblyLinearVelocity ~= (Vector3.one * 0))
		end)
	end)
end) 


TestCaseFile:SetMethod("<FootballClass:ApplyImpulse() 🔥⚽> reject any invalid arguments sent to :ApplyImpulse() - [Sad Path 💀]", function() 
	local football: FootballObject = FootballClass.new(Vector3.new(50, 20, 50)) 
	task.delay(5, function() 
		football:Destroy() 
	end) 
	

	local argumentQueue: {} = {
		{"Hello World!", {}}, 
		{true, false}, 
		{{}, {}}, 
		{nil, nil}, 
		{math.pi, {}}, 
		{{}, "Hello World!"}, 
		
		{Vector3.one, false}, 
		{Vector3.one, nil}, 
		{Vector3.one, {}}, 
		{Vector3.one, "Hello World!"}
	}
	
	local outputMessages = {
		["Error! Force is not a Vector3!"] = false,
		["Error! FrictionDelay is not a number!"] = false
	}
	
	for _, arguments in argumentQueue do
		local message: string = football:ApplyImpulse(table.unpack(arguments))
		assert(message ~= nil) 
		
		outputMessages[message] = true 
	end
		
	assert(outputMessages["Error! Force is not a Vector3!"] == true) 
	assert(outputMessages["Error! FrictionDelay is not a number!"] == true) 
end) 


-- 📋 [🍎] <FootballClass:Shoot() 🦶🏻⚽> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <✅>]
TestCaseFile:SetMethod("<FootballClass:Shoot() 🦶🏻⚽> call :Shoot() with sample dataset - [Happy Path 🌈]", function() 
	local argumentQueue: {} = {
		{Vector3.new(0, 10, 0), 10, "Shoot"}, 
		{Vector3.new(10, 0, 0), 7, "Dribble"}, 
		{Vector3.new(0, 0, 10), 4, "Shoot"}, 
		{Vector3.new(10, 0, 0), 3, "Dribble"}, 
		{Vector3.new(0, 10, 0), 8, "Shoot"}, 
		{Vector3.new(0, 0, 10), 9, "Dribble"}, 
		{Vector3.new(0, 10, 0), 3, "Shoot"}, 
		{Vector3.new(10, 0, 0), 5, "Dribble"}, 
		{Vector3.new(0, 10, 0), 7, "Shoot"}, 
		{Vector3.new(0, 0, 100), 5, "Dribble"}, 
		{Vector3.new(0, 10, 0), 2, "Shoot"}, 
	}

	local football: FootballObject = FootballClass.new(Vector3.new(50, 20, 50)) 
	task.delay(5, function() 
		football:Destroy() 
	end) 

	task.spawn(function()
		for _, arguments: {} in argumentQueue do
			football:Shoot(table.unpack(arguments))
			task.wait(0.1)
		end 
	end)
end) 


TestCaseFile:SetMethod("<FootballClass:Shoot() 🦶🏻⚽> testing whether :Shoot() leaks memory - [Sad Path 💀]", function() 
	task.spawn(function()
		local football: FootballObject = FootballClass.new(Vector3.new(90, 20, 90)) 
		task.delay(20, function() 
			football:Destroy() 
		end) 

		football.Instance.Name = "Marked"

		for i = 1, 100 do
			football:Shoot(Vector3.new(0, 1, 0), 1, "Shoot")
			task.wait(0.5)
		end
	end)
end)


TestCaseFile:SetMethod("<FootballClass:Shoot() 🦶🏻⚽> throw invalid MouseHit / Power argument into :Shoot() - [Sad Path 💀]", function() 
	local arguments1: {} = {
		{math.pi, true, "Dribble"}, 
		{math.pi, "Hello World!", "Dribble"}, 
		{true, math.pi, "Dribble"}, 
		{true, {}, "Dribble"}, 
		{CFrame.new(0, 0, 0), CFrame.new(0, 0, 0), "Dribble"}, 
		{CFrame.new(0, 0, 0), false, "Dribble"}, 
		{false, CFrame.new(0, 0, 0), "Dribble"}, 
		{{}, false, "Dribble"}, 
		{nil, {}, "Dribble"}, 
		{math.pi, nil, "Dribble"}, 
		{nil, nil, nil}
	} 

	local arguments2: {} = {
		{Vector3.one, false, "Dribble"}, 
		{Vector3.one, CFrame.new(0, 0, 0), "Dribble"}, 
		{Vector3.one, false, "Dribble"}, 
		{Vector3.one, {}, "Dribble"}, 
		{Vector3.one, nil, "Dribble"}, 
		{Vector3.one, nil, "Dribble"}, 
	}
	
	local arguments3: {} = {
		{Vector3.one, 1, 123456789}, 
		{Vector3.one, 1, {}}, 
		{Vector3.one, 1, true}, 
		{Vector3.one, 1, false}, 
		{Vector3.one, 1, nil}, 
		{Vector3.one, 1, "Hello World!"}, 
	}

	-- <testing error catching for "MouseHit" parameter> -- 
	local football: FootballObject = FootballClass.new(Vector3.new(70, 20, 70)) 
	task.delay(5, function() 
		football:Destroy() 
	end)

	for _, argument in arguments1 do  
		local message: string = football:Shoot(argument[1], argument[2], "Shoot") 
		assert(message == "Error! MouseHit Invalid Type!") 
	end 

	-- <testing error catching for "Power" parameter> --
	for _, argument in arguments2 do 
		local message: string = football:Shoot(argument[1], argument[2], "Shoot") 
		assert(message == "Error! Power Invalid Type!") 
	end 
	
	-- <testing error catching for "MotionType" parameter> --
	for _, argument in arguments3 do 
		local message: string = football:Shoot(argument[1], argument[2], argument[3]) 
		assert(message == "Error! Motion Invalid Type!") 
	end 
end) 

-- test if two people try to hit :Shoot() at same time


-- 📋 [🍎] <FootballClass.ApplyFriction() 🚗⚽> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <✅>] 
TestCaseFile:SetMethod("<FootballClass.ApplyFriction() 🚗⚽> sending valid time delay parameters - [Happy Path 🌈]", function() 
	local arguments: {} = {
		1, 2, 3, nil
	}

	local football: FootballObject = FootballClass.new(Vector3.new(70, 20, 70)) 
	task.delay(5, function()
		football:Destroy()
	end) 

	for _, argument in arguments do
		local message: string = football:ApplyFriction() 
		assert(message ~= "Error! Invalid 'DelayTime' Data Type!")
	end
end) 


TestCaseFile:SetMethod("<FootballClass.ApplyFriction() 🚗⚽> sending invalid time delay parameters - [Sad Path 💀]", function() 
	local arguments: {} = {
		"Hello World!", true, false, {} 
	}

	local football: FootballObject = FootballClass.new(Vector3.new(-50, 20, -50)) 
	task.delay(5, function()
		football:Destroy()
	end) 

	for _, argument in arguments do
		local message: string = football:ApplyFriction(argument) 
		assert(message == "Error! Invalid 'DelayTime' Data Type!")
	end

	local message: string = football:ApplyFriction(nil) 
	assert(message ~= "Error! Invalid 'DelayTime' Data Type!")
end) 


-- 📋 [🍎] <FootballClass:CancelFriction() 🍃⚽> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <N/A>] 
TestCaseFile:SetMethod("<FootballClass:CancelFriction() 🍃⚽> stopping any friction methods being applied - [Happy Path 🌈]", function() 
	local football: FootballObject = FootballClass.new(Vector3.new(0, 0, 0), false)
	assert(football ~= nil)

	football.FrictionThread = coroutine.create(function() end)
	football:CancelFriction() 
	assert(football.FrictionThread == nil)
end)


-- 📋 [🍎] <FootballClass:GetForceFromDirection() 🧭⚽> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <⛔>]; [Sad Path(s) 💀 - <⛔>] 
TestCaseFile:SetMethod("<FootballClass:GetForceFromDirection() 🧭⚽> pass in valid arguments - [Happy Path 🌈]", function() 
	local football: FootballObject = FootballClass.new(Vector3.new(0, 0, 0), false)
	assert(football ~= nil)
	
	local argumentQueue = {
		{Vector3.one, "Dribble"}
	}
	
	football.BasePower = 1
	
	football:GetForceFromDirection(Vector3.one, "Dribble") 
end)


return TestCaseFile
