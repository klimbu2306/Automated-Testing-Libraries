-- <PENGUIN TEST CASE MODULE 🐧>
local AutomatedTesting = game.ReplicatedStorage.AutomatedTesting
local TestCaseClass = require(AutomatedTesting.PenguinTest) 


-- <MODULE(S) TO TEST>
local PickleModule = require(AutomatedTesting.PickleModule) 
local RegexModule = require(AutomatedTesting.PickleModule.Regex)


-- <ROOT> -- 
local TestCaseFile = TestCaseClass.new()


-- <MAIN METHODS> --

-- 📋 [1] <StepFile.New() 🪜> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - ✅ (N/A)] 
TestCaseFile:SetMethod("<StepFile.New() 🪜> creating a new file 📝 - [happy path 🌈]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)
end) 


-- 📋 [2] <:ExecuteStep() ⚽⚔️> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <✅>] 
TestCaseFile:SetMethod("<:ExecuteStep() ⚽⚔️> with good anonymous function 😊 - [happy path 🌈]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)

	local stepContext: StepContext = FooStepFile:ExecuteStep(function() end) 
	assert(stepContext.Success)
end) 


TestCaseFile:SetMethod("<:ExecuteStep() ⚽⚔️> with bad arguments 🤖 - [sad path 💀]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)
	
	local argumentQueue = {
		nil, "Hello World!", 123456789, true, false, {}
	}
	
	for _, argument in argumentQueue do 
		local stepContext: StepContext = FooStepFile:ExecuteStep(argument) 
		assert(stepContext.ErrorMessage) 
		if argument == nil then assert(stepContext.ErrorMessage == "<Warning!> :ExecuteStep() Requires StepObject Arg!") end 
	end 
end) 


-- 📋 [3] <:ExecuteFeatureFile() 🔫📂> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <✅>]
TestCaseFile:SetMethod("<:ExecuteFeatureFile() 🔫📂> executing an entire feature file ⚔️ - [happy path 🌈]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)

	local function foo(file: {})
		return "Pass"
	end 
	
	local featureFile: string = [[
	SCENARIO: This is a Test Scenario!
	GIVEN this statement
	]]

	local keyword: string = "@given"
	local statement: string = "this statement"

	local step: StepObject = FooStepFile:AddStep(keyword, statement, foo) 
	local context: Context = FooStepFile:ExecuteFeatureFile(featureFile) 
	assert(context == "Pass")
end) 


TestCaseFile:SetMethod("<:ExecuteFeatureFile() 🔫📂> self.Context may be accessed by any method correctly 🏐 - [happy path 🌈]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)

	local function foo(file: {}) 		
		if not file.Context.Counter then
			file.Context.Counter = 0
		end
		
		file.Context.Counter += 1
	end 

	local featureFile: string = [[
	SCENARIO: This is a Test Scenario!
	GIVEN this statement 
	WHEN this statement 
	THEN this statement 
	]]

	
	for _, keyword: string in {"@given", "@when", "@then"} do
		local statement: string = "this statement"
		local step: StepObject = FooStepFile:AddStep(keyword, statement, foo) 
	end
	
	FooStepFile:ExecuteFeatureFile(featureFile) 
	assert(FooStepFile.Context.Counter == 3) 
end) 


TestCaseFile:SetMethod("<:ExecuteFeatureFile() 🔫📂> checking that valid background descriptions are ran by pickle module 🎭 - [happy path 🌈]", function()
	local FooStepFile = PickleModule.StepFile.New("Testing Background Test...")
	assert(#FooStepFile == 0)

	local function foo(file: {})
		if not file.Context.Counter then
			file.Context.Counter = 0
		end

		file.Context.Counter += 1
	end 

	local featureFile: string = [[
	BACKGROUND: This is a Test Background! 
	GIVEN this bg statement 
	
	SCENARIO: This is a Test Scenario! 
	GIVEN this statement 
	WHEN this statement 
	THEN this statement 
	]]


	for _, keyword: string in {"@given", "@when", "@then"} do
		local statement: string = "this statement"
		local step: StepObject = FooStepFile:AddStep(keyword, statement, foo) 
	end 
	
	FooStepFile:AddStep("@given", "this bg statement", function(file: {})
		file.Context.Setup = true
	end)

	FooStepFile:ExecuteFeatureFile(featureFile) 
	
	assert(FooStepFile.Context.Counter == 3) 
	assert(FooStepFile.Context.Setup == true) 
end) 


TestCaseFile:SetMethod("<:ExecuteFeatureFile() 🔫📂> validating that background only resets feature file context PER scenario 🎭 - [happy path 🌈]", function()
	local FooStepFile = PickleModule.StepFile.New("Testing Background Test...")
	assert(#FooStepFile == 0)
	
	local function foo(file: {})
		file.Context.BackgroundCounter += 1
	end 

	local featureFile: string = [[
	BACKGROUND: This is a Test Background! 
	GIVEN this bg statement 
	
	SCENARIO: This is a Test Scenario! 
	GIVEN this statement 
	WHEN this statement 
	THEN this statement 
	
	SCENARIO: This is a Test Scenario II! 
	GIVEN this statement II
	WHEN this statement II
	THEN this statement II
	]]
	
	for _, generalStatement: string in {"this statement", "this statement II"} do
		for _, keyword: string in {"@given", "@when", "@then"} do
			local statement: string = generalStatement
			local step: StepObject = FooStepFile:AddStep(keyword, statement, foo) 
		end 
	end

	FooStepFile:AddStep("@given", "this bg statement", function(file: {})
		file.Context.BackgroundCounter = 1
	end)

	FooStepFile:ExecuteFeatureFile(featureFile) 
	assert(FooStepFile.Context.BackgroundCounter == 4) 
end) 


TestCaseFile:SetMethod("<:ExecuteFeatureFile() 🔫📂>  executing an empty feature file 🗑️ - [sad path 💀]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)

	local function foo(file: {})
		return "Pass"
	end 

	local featureFile: string = [[
	SCENARIO: This is a Test Scenario!
	
	]]

	local keyword: string = "@given"
	local statement: string = "this statement"

	local step: StepObject = FooStepFile:AddStep(keyword, statement, foo) 
	local context: Context = FooStepFile:ExecuteFeatureFile(featureFile) 
	assert(context == "Pass")
end) 


TestCaseFile:SetMethod("<:ExecuteFeatureFile() 🔫📂> executing a feature file with no scenario 🚫 - [sad path 💀]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)
	
	local function foo(file: {})
		return "Pass"
	end 

	local featureFile: string = [[

	]]

	local keyword: string = "@given"
	local statement: string = "this statement"

	local step: StepObject = FooStepFile:AddStep(keyword, statement, foo) 
	local context: Context = FooStepFile:ExecuteFeatureFile(featureFile, "OFF") 
	assert(context == "Fail")
end) 


-- [4] <:AddStep() 🌱> 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - <✅>]
TestCaseFile:SetMethod("<:AddStep() 🌱>  validate defined method correctly instantiates 📝 - [happy path 🌈]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)

	local function foo(file: {})
		return "Pass"
	end

	local keyword: string = "@given"
	local statement: string = "this statement"

	local step: StepObject = FooStepFile:AddStep(keyword, statement, foo) 
	local stepContext: StepContext = FooStepFile:ExecuteStep(step) 

	assert(stepContext.Return) 
	assert(stepContext.Return == foo())
end) 

TestCaseFile:SetMethod("<StepFile.New() 🪜> validate anonymous method can be correctly fired - [happy path 🌈]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)

	local keyword: string = "@given"
	local statement: string = "this statement"

	local step: StepObject = FooStepFile:AddStep(keyword, statement, function() return end)
	local stepContext: StepContext = FooStepFile:ExecuteStep(step)
end)


TestCaseFile:SetMethod("<StepFile.New() 🪜> check whether invalid attempts to declare method become rejected - [sad path 💀]", function()
	local FooStepFile = PickleModule.StepFile.New()
	assert(#FooStepFile == 0)

	local argumentQueues = {
		{"412412792", 32141412, function() return end},
		{543434634, function() return end, "431532524523"},
		{function() return end, "53asgiousad89gua", 435923809}, 
		{true, function() return end, 5.75673453}, 
		{function() return end, true, 5.75673453}, 
		{5.75673453, function() return end, true}, 
		{{}, {}, {}}
	}

	for _, argumentQueue: {} in argumentQueues do 
		local keyword: string = argumentQueue[1] 
		local statement: string = argumentQueue[2] 

		local step: StepObject = FooStepFile:AddStep(argumentQueue[1], argumentQueue[2], argumentQueue[3]) 
		local stepContext: StepContext = FooStepFile:ExecuteStep(step)
	end 
end) 


-- <REGEX METHODS> -- 

-- 📋 [1] <.DetectEmptyLine() 🕵🏻> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - ✅] 

TestCaseFile:SetMethod("<.DetectEmptyLine() 🕵🏻> passing in blank strings 🪹 - [happy path 🌈]", function()
	local arguments = {
		"     ", -- basic space characters
		"	", -- special whitespace characters
		[[
		       
		]], -- basic space characters in multi-line 
		[[
						
		]] -- special whitespace characters in multi-line
	}
	
	-- <validate that we ARE actually testing different characters>
	assert(#string.split(arguments[1], " ") > #string.split(arguments[2], " "))
	
	for _, argument in arguments do
		assert(RegexModule.DetectEmptyLine(argument) == true)
	end
end) 


TestCaseFile:SetMethod("<.DetectEmptyLine() 🕵🏻> passing in valid string which isn't empty - [happy path 🌈]", function()
	local arguments = {
		"Hello World", 
		"Apples", 
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
	}

	for _, argument in arguments do
		assert(RegexModule.DetectEmptyLine(argument) == false)
	end
end)


TestCaseFile:SetMethod("<.DetectEmptyLine() 🕵🏻> passing in invalid arguments in place of strings - [sad path 💀]", function()
	local arguments = {
		41252352, true, function() end, {}
	}
	
	for _, argument in arguments do
		assert(RegexModule.DetectEmptyLine(argument) == false)
	end
end) 


-- 📋 [2] <.FormatStatement() 📄> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - ✅] 

TestCaseFile:SetMethod("<.FormatStatement() 📄> passing in standard statement lines - [happy path 🌈]", function()
	local arguments = {
		"@given this thing happens", 
		"@when this other thing happens", 
		"@then this thing will happen",

		"given this format is used",
		"when this other format thing happens", 
		"then this final format thing will happen", 

		"GIVEN ALL CAPS ARE USED", 
		"WHEN THIS OTHER STATEMENT IS IN ALL CAPS", 
		"THEN ALL THESE OTHER STATEMENT THINGS WILL HAPPEN", 
		
		"	@given this statement with a tab", 
		"	@when this other statement with a tab", 
		"	@then this final statement with a tab",
	}

	for _, argument in arguments do
		local statement = RegexModule.FormatStatement(argument)
		
		assert(statement == string.lower(statement))
		assert(statement == table.concat(string.split(statement, " "), ""))
		assert(statement == table.concat(string.split(statement, "	"), ""))

	end
end)


TestCaseFile:SetMethod("<.FormatStatement() 📄> passing in any range of bad arguments - [sad path 💀]", function()
	local arguments = {
		41252352, true, function() end, {}
	}

	for _, argument in arguments do 
		local statement = RegexModule.FormatStatement(argument)
		assert(not statement)
	end
end)


-- 📋 [3] <.CategoriseStatementQueues() 🧩> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - ✅] 
TestCaseFile:SetMethod("<.CategoriseStatementQueues() 🧩> pass in standard queues - [happy path 🌈]", function()
	local mockRegexQueue = {
		["BACKGROUND: This is a Test Background! "] = {
			"giventhisbgstatement"	
		},
		["SCENARIO: This is a Test Scenario!"] = {
			"giventhisstatement",
			"whenthisstatement", 
			"thenthisstatement"
		}
	}

	local statementQueues = RegexModule.CategoriseStatementQueues(mockRegexQueue) 
	local backgroundQueue, scenarioQueue = {}, {}
	
	for _, statementQueue: {string} in statementQueues.Background do
		for _, statement: string in statementQueue do
			table.insert(backgroundQueue, " ")
		end
	end 
	
	for _, statementQueue: {string} in statementQueues.Scenario do
		for _, statement: string in statementQueue do
			table.insert(scenarioQueue, " ")
		end
	end 
	
	assert(#backgroundQueue == 1) 
	assert(#scenarioQueue > 1) 
end)

TestCaseFile:SetMethod("<.CategoriseStatementQueues() 🧩> passing in invalid argument types and empty queue - [sad path 💀]", function()
	local arguments = {
		41252352, true, function() end 
	}

	for _, argument in arguments do 
		local statementQueue = RegexModule.CategoriseStatementQueues(argument) 
		assert(not statementQueue)
	end
end)


-- 📋 [4] <.RegexStringFile() 🧵> -- 
-- 📎 Paths Covered: [Happy Path(s) 🌈 - <✅>]; [Sad Path(s) 💀 - ✅] 
TestCaseFile:SetMethod("<.RegexStringFile() 🧵> validate correct regex() of feature file; test order of statements in feature file match that of the output statement queues - [happy path 🌈]", function()
	local mockFeatureFile = [[
	BACKGROUND: This is a Test Background!
	GIVEN this bg statement
	
	SCENARIO: This is a Test Scenario!
	GIVEN this statement
	WHEN this statement
	THEN this statement
	]]
	
	local mockStatementQueues = {}
	mockStatementQueues.Background = {
		["BACKGROUND: This is a Test Background!"] = {
			[1] = "giventhisbgstatement"
		}
	}
	mockStatementQueues.Scenario = {
		["SCENARIO: This is a Test Scenario!"] = {
			[1] = "giventhisstatement",
			[2] = "whenthisstatement",
			[3] = "thenthisstatement"
		}
	}

	local statementQueues = RegexModule.RegexStringFile(mockFeatureFile)
	assert(statementQueues ~= "Fail") 
	
	assert(mockStatementQueues.Background["BACKGROUND: This is a Test Background!"][1] == statementQueues.Background["BACKGROUND: This is a Test Background!"][1]) 
	assert(mockStatementQueues.Scenario["SCENARIO: This is a Test Scenario!"][1] == statementQueues.Scenario["SCENARIO: This is a Test Scenario!"][1]) 
	assert(mockStatementQueues.Scenario["SCENARIO: This is a Test Scenario!"][2] == statementQueues.Scenario["SCENARIO: This is a Test Scenario!"][2]) 
	assert(mockStatementQueues.Scenario["SCENARIO: This is a Test Scenario!"][3] == statementQueues.Scenario["SCENARIO: This is a Test Scenario!"][3]) 

end)

TestCaseFile:SetMethod("<.RegexStringFile() 🧵> passing in invalid argument types and empty queue - [sad path 💀]", function()
	local arguments = {
		41252352, true, function() end 
	}

	for _, argument in arguments do 
		local statementQueue = RegexModule.RegexStringFile(argument) 
		assert(statementQueue == "Fail")
	end
end)

return TestCaseFile
