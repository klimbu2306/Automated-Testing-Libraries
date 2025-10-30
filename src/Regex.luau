-- <ROOT> -- 
local RegexModule = {}


-- <FUNCTIONS> --
function RegexModule.DetectEmptyLine(line: string): boolean
	if typeof(line) ~= typeof("string") then return false end
	
	local regexLine: string = table.concat(string.split(string.gsub(string.gsub(line, "\n", ""), "	", ""), " "), "")
	local isEmpty = (regexLine == "")	
	if isEmpty then return true end
	return false
end


function RegexModule.FormatStatement(line: string): string
	if typeof(line) ~= typeof("string") then return end
	
	local statement: string = ""
	statement = table.concat(string.split(line, " "), "")
	statement = string.lower(statement) 
	statement = table.concat(string.split(statement, "	"), "")
	
	if string.find(statement, "@") then
		statement = string.gsub(statement, "@", "")
	end
	
	return statement
end


function RegexModule.CategoriseStatementQueues(regexQueues: {string}): {}
	if typeof(regexQueues) ~= typeof({}) then return end
	
	local statementQueues = {} 
	statementQueues.Background = {}
	statementQueues.Scenario = {}
	
	for key: string, statementQueue: {string} in regexQueues do
		if string.find(key, "SCENARIO:") then
			statementQueues.Scenario[key] = statementQueue
		end
	end
	
	for key: string, statementQueue: {string} in regexQueues do
		if string.find(key, "BACKGROUND:") then
			statementQueues.Background[key] = statementQueue
		end
	end
	
	return statementQueues
end


function RegexModule.RegexStringFile(file: string): {} 
	if typeof(file) ~= typeof("string") then return "Fail" end
	if not string.find(file, "SCENARIO:") then return "Fail" end
	
	local lines: {string} = string.split(file, "\n") 
	local regexQueues: {string} = {}

	local scenario: string = ""

	for _, line: string in lines do
		if string.find(line, "SCENARIO:") or string.find(line, "BACKGROUND:") then
			scenario = table.concat(string.split(line, "	"), "")
			regexQueues[scenario] = {}
			continue
		end

		if RegexModule.DetectEmptyLine(line) then continue end
		if scenario == "" then continue end 
		
		local statement = RegexModule.FormatStatement(line)
		table.insert(regexQueues[scenario], statement) 
	end
		
	local statementQueues: {} = RegexModule.CategoriseStatementQueues(regexQueues)
	
	return statementQueues
end


return RegexModule
