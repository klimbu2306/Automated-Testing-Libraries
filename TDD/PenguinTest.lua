-- <ROOT> --
local TestCaseClass = {}
TestCaseClass.MetaTestCases = {}
TestCaseClass.__index = TestCaseClass

-- <FUNCTIONS> --
function TestCaseClass.new()
	local _self = setmetatable({}, TestCaseClass)
	
	-- <__init__(self)> --
	_self.TestCases = {}
	_self.SuccessOutput = false
	
	return _self
end


function TestCaseClass:SetMethod(testName: string, method: func) 
	local invalidParameters = (typeof(testName) ~=  typeof("string")) or typeof(method) ~= typeof(function() end)
	if invalidParameters then return end 

	-- < setting test case methods > --
	local functions: {func} = self.TestCases 
	functions[testName] = method
	
	return method
end

function TestCaseClass:Begin()
	local testCases: {func} = self.TestCases 
	
	-- <check for test fixtures > 
	local function foo() end
	local ClassSetupExists = (typeof(testCases["ClassSetup"]) == typeof(foo))
	local ClassTeardownExists = (typeof(testCases["ClassTeardown"]) == typeof(foo))
	local MethodSetupExists = (typeof(testCases["MethodSetup"]) == typeof(foo))
	local MethodTeardownExists = (typeof(testCases["MethodTeardown"]) == typeof(foo))
			
	-- <class environment setup...>
	if ClassSetupExists then testCases["ClassSetup"](self) end 
	
	-- <iterate through all given test cases>
	local testCases: {func} = self.TestCases 
	for testName: string, testCase: func in testCases do 
		if table.find({"ClassSetup", "ClassTeardown", "MethodSetup", "MethodTeardown"}, testName) then continue end
		if not (typeof(testCase) == typeof(foo)) then continue end
		
		-- <method setup>
		if MethodSetupExists then testCases["MethodSetup"](self) end
		
		-- <execute test case>		
		local success, fail = pcall(function() testCase(self) end)
		if success then
			if self.SuccessOutput then print(`<Automated Test> {testName}: PASS! ✅`) end
		else
			warn(`<Automated Test> {testName}: FAIL! - ("{fail}") ⛔`)
		end
		
		-- <method teardown>
		if MethodTeardownExists then testCases["MethodTeardown"](self) end
	end
	
	-- <class environment teardown...>
	if ClassTeardownExists then testCases["ClassTeardown"](self) end 
	
	return "Success" 
end

return TestCaseClass
