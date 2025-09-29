-- <MODULE>
local TestCaseClass = require(script.Parent)


-- <ROOT>
local TestCaseFile = {}
TestCaseFile.MetaTestCases = {}
TestCaseFile.SuccessOutput = false


-- <META TEST CASE METHODS> -- 
TestCaseFile.MetaTestCases[":SetMethod() - 'Validate Saved Functions' "] = function()
	-- <create a test class object for "PenguinTest" module>
	local PenguinTestClass = TestCaseClass.new()

	local FOO_KEY = "foo"
	local function foo()
		return "pass"
	end

	PenguinTestClass:SetMethod(FOO_KEY, foo)

	-- <check whether stored test case function = test case function sent for storing>
	local retrievedFoo = PenguinTestClass.TestCases[FOO_KEY]
	assert(retrievedFoo() == foo()) 
end


TestCaseFile.MetaTestCases[":SetMethod() - 'Invalid Parameter Types' "] = function()
	-- <create a test class object for "PenguinTest" module>
	local PenguinTestClass = TestCaseClass.new()

	-- <iterate through bad parameters>
	local Combinations = {
		{123456789, "foo"},
		{"foo", 123456789}, 
		{function() end, "foo"}, 
		{true, 123456789}, 
		{123456789, false}, 
		{true, nil}, 
		{nil, false}, 
		{nil, nil} 
	}

	for _, combination in Combinations do 
		local testCase = PenguinTestClass:SetMethod(combination[1], combination[2]) 
		if testCase then testCase() end
	end 
end


TestCaseFile.MetaTestCases[":Begin() - 'Invalid Test Fixture Methods'"] = function()
	local PenguinTestClass = TestCaseClass.new()
	--[[
	-- <re-enable code segment in cases of future testing (RANDOM PATH)>
	local SuccessOutputChoices = {true, false}
	PenguinTestClass.SuccessOutput = SuccessOutputChoices[math.random(1, 2)]
	--]]

	local FOO_KEY = "foo"
	local function foo(self)
		return "pass"
	end
	
	-- <first, test module can handle invalid test case and test fixture arguments (SAD PATH 😖⚡)>
	local Combinations = {
		{foo, foo, foo, foo},
		{nil, foo, foo, foo},
		{foo, nil, foo, foo},
		{foo, foo, nil, foo},
		{foo, foo, foo, nil},
		{123, foo, foo, foo}, 
		{foo, 123, foo, foo},
		{foo, foo, 123, foo},
		{foo, foo, foo, 123}
	}
	
	
	for _, combination in Combinations do
		PenguinTestClass.TestCases = {
			["ClassSetup"] = combination[1],
			["ClassTeardown"] = combination[2], 
			["MethodSetup"] = combination[3], 
			["MethodTeardown"] = combination[4]
		}
		PenguinTestClass:SetMethod(FOO_KEY, foo)
		
		PenguinTestClass:Begin()
	end
	
	-- <next, test whether correct text fixtures handle correctly (HAPPY PATH 😊🌈)> 
	local function ClassSetup(self)
		self.ClassCounter = 0 
		self.MethodCumulativeCounter = 0 
	end
	
	local function ClassTeardown(self)
		assert(self.ClassCounter ~= nil)
		self.ClassCounter += 1
	end
	
	local function MethodSetup(self)
		self.MethodCounter = 0
	end

	local function MethodTeardown(self)
		self.MethodCounter += 1 
		self.MethodCumulativeCounter += 1
	end
	
	-- <clearing test cases again, now replacing the fake test fixtures with real ones>
	PenguinTestClass.TestCases = {} 
	
	PenguinTestClass.TestCases.ClassSetup = ClassSetup 
	PenguinTestClass.TestCases.ClassTeardown = ClassTeardown 
	PenguinTestClass.TestCases.MethodSetup = MethodSetup 
	PenguinTestClass.TestCases.MethodTeardown = MethodTeardown 
	
	for i = 1, 4 do
		PenguinTestClass.TestCases[`foo {i}`] = foo
	end
	
	assert(PenguinTestClass:Begin() == "Success")
	
	assert(PenguinTestClass.ClassCounter == 1) 
	assert(PenguinTestClass.MethodCounter == 1) 
	assert(PenguinTestClass.MethodCumulativeCounter == 4)
end

TestCaseFile.MetaTestCases[":Begin() - 'Invalid Actual Methods'"] = function()
	local PenguinTestClass = TestCaseClass.new()

	local Combinations = {
		123456789, 
		function() end, 
		"Hello World!",
		true,
		5.257
	}
	
	for _, combination in Combinations do
		PenguinTestClass.TestCases = {
			["foo"] = combination,
		}

		PenguinTestClass:Begin()
	end
end



-- <RUNTIME ENVIRONMENT> -- 
for metaTestName: string, metaTestCase: func in TestCaseFile.MetaTestCases do
	local success, fail = pcall(function() metaTestCase() end) 
		
	if success then
		if TestCaseFile.SuccessOutput == false then continue end
		print(`<Automated Test> {metaTestName}: PASS!`)
	else
		warn(`<Automated Test> {metaTestName}: FAIL! - ("{fail}")`)
	end
end


return TestCaseFile
