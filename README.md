# Penguin Test (TDD) + Pickle Module (BDD) Libraries | Luau
- Inside of this project there is a TDD library (named "PenguinTest") and a BDD library (called PickleModule). 
- Each library is self-verifying and has it's own meta test cases. 
- Additionally, there is also an example use case I've put inside of the repo, which demonstrates how the TDD module can be used in a scenario involving programming football physics.

---

## 🐧 Penguin Test - TDD Module
### Getting Started! 
1️⃣ In order to use this Luau TDD in Studio, you need to create an empty '⚙️📜 ModuleScript' which will hold the contents of the unit tests you are about to write!

2️⃣ Once you have this, you need to import BOTH the '🐧 Penguin Test' and the '⚙️📜 ModuleScript' that you want to test! (ex: I am testing the "FootballClass" module)

```luau
------ <PENGUIN TEST CASE MODULE 🐧> ------
local AutomatedTesting: Folder = game.ReplicatedStorage.AutomatedTesting
local TestCaseClass: ModuleScript = require(AutomatedTesting.PenguinTest) 

------ <MODULE(S) TO TEST> ------
local FootballClass: ModuleScript = require(script.Parent) 
```

3️⃣ Now, initialise a new TestCaseFile container, like so!

```luau
------ <ROOT> ------
local TestCaseFile: TestCaseObject = TestCaseClass.new()

...

return TestCaseFile
```

4️⃣ Once you've done this, you can now start adding 'Test Methods' which your program will execute during automated testing!

```luau
-- Implementation #1: Pre-Defined Functions
TestCaseFile:SetMethod("<whatever you want to call the test>", func)

-- Implementation #2: Anonymous Function
TestCaseFile:SetMethod("<whatever you want to call the test>", function()
  -- describe your function here
end)
```

5️⃣ Now that you've added all of your desired test cases to your file, you should import your test case file into a '🌐📜 ServerScript' or a '🌳📜 LocalScript' and then call the `:Begin()` function on your TestCaseFile!

```luau
------ <IMPORTING TEST CASE FILE> ------
local TestCaseFile = require(game.ServerScriptService.TestCaseFile)

------ <RUNNING ALL TEST CASES AT ONCE!> ------
TestCaseFile:Begin()
```

Which essentially covers a basic overview of how to use the 🐧 PenguinTest module!
