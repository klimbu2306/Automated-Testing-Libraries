-- <MODULES> -- 
local Regex = require(script.Regex)


-- <ROOT> --
local PickleModule = {} 
PickleModule.StepFile = {}
PickleModule.StepFile.__index = PickleModule.StepFile


-- <CUSTOM TYPES> --
type StepObject = PickleModule.Steps 


-- <FUNCTIONS (StepFile)> -- 
function PickleModule.StepFile.New(name: string)
	local _self = setmetatable({}, PickleModule.StepFile)
	
	-- <__init__(self)>
	_self.Dict = {} 
	_self.Context = {}  
	_self.Name = name or "foo" 
		
	return _self
end


function PickleModule.StepFile:ExecuteFeatureFile(featureFile: string, outputSuggestions: "ON" | "OFF"): Context	
	outputSuggestions = outputSuggestions or "ON"
	
	local statementQueues: {string} = Regex.RegexStringFile(featureFile) 
	if statementQueues == "Fail" or (statementQueues == nil) then 
		if outputSuggestions == "ON" then warn(`<Suggestion> the seperator "SCENARIO:" must appear at least ONCE within the <file>\n[[\n{featureFile}\n]]`); end
		return "Fail" 
	end
	
	local backgroundQueues: {string} = statementQueues.Background
	local scenarioQueues: {string} = statementQueues.Scenario 
	
	local scenarioContext: {} = {}
			
	local function ExecuteStatementQueues(statementQueues: {string})	
		for scenario: string, statementQueue: {string} in statementQueues do 
			-- <setup context from env>
			if statementQueues == scenarioQueues then ExecuteStatementQueues(backgroundQueues) end
			
			for _, statement: string in statementQueue do 
				local step: StepObject = self.Dict[statement] 

				if not step then
					warn(`<warning> FOLLOWING STEP HAS NOT BEEN IMPLEMENTED:\n<@{statement}>\n\nPLEASE IMPLEMENT VIA NOTATION 💻🔢:\n<StepsFile>:AddStep("@<keyword>","<statement>",function(file)\n\nend)\n\n in Steps File!\n(ACCESS CONTEXT VIA <file.Context>)\n`)
					return "Fail"
				end
				
				local stepContext: StepContext = PickleModule.StepFile:ExecuteStep(step)
				
				if stepContext.Fail then warn(`<Error> Current Step Failed! {stepContext.ErrorMessage}`); return "Fail" end
			end
		end
		
		return
	end 
	
	ExecuteStatementQueues(scenarioQueues) 
	
	return "Pass"
end


function PickleModule.StepFile:AddStep(keyword: string, statement: string, method: Method) 	
	
	-- <set up meta method properties>
	local metaProperties = {}
	metaProperties.__index = self
	metaProperties.__call = method
	
	-- <create new instance of "StepObject" Class>
	local _self = setmetatable({}, metaProperties)
	
	-- <__init__(self)> -- 
	_self.Keyword = keyword 
	_self.Statement = statement
	
	local stepId = Regex.FormatStatement(`{_self.Keyword}{_self.Statement}`)
	self.Dict[stepId] = _self 
		
	return _self
end 


function PickleModule.StepFile:ExecuteStep(stepObject: StepObject): StepContext 
	local stepContext = {}
	
	if not stepObject then 
		stepContext.Fail = true; 
		stepContext.ErrorMessage = "<Warning!> :ExecuteStep() Requires StepObject Arg!";
		return stepContext 
	end
			
	local success, fail = pcall(function() 
		stepContext.Return = stepObject(self) 
		stepContext.Success = true
	end) 
	
	if fail then stepContext.Fail = true; stepContext.ErrorMessage = fail end 
		
	return stepContext
end


return PickleModule
