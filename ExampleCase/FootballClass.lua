------ <SERVICES> ------
local RunService = game:GetService("RunService")


------ <VARIABLES> ------ 
local FRICTION_COEFFICIENT = 0.6
local SHOOT_MIN_HEIGHT = 1
local REBOUND_WINDOW = 1.5

local SHOOTING_FX = {
	["DirectShot"] = {
		["Trail"] = {true, Color3.fromRGB(42, 227, 255)}, 
		["SFX"] = "Shoot"
	}, 
	["NormalShot"] = {
		["Trail"] = {true, Color3.fromRGB(255, 255, 255)}, 
		["SFX"] = "Kick"
	}
}


------ <ROOT> ------
local FootballClass = {}
FootballClass.SpawnedBalls = {}
FootballClass.__index = FootballClass 


------ <FUNCTIONS> ------
-- < [⚙️] INITATION & CLASS MANAGEMENT METHODS [⚙️] > --
function FootballClass.new(origin: Vector3?, autoSpawn: boolean?) 
	-- typechecking... 
	if origin ~= nil and (typeof(origin) ~= typeof(Vector3.one)) then return "Error! Invalid Origin!" end 
	if autoSpawn ~= nil and (typeof(autoSpawn) ~= typeof(true)) then return "Error! Invalid AutoSpawn!" end 
	autoSpawn = if autoSpawn ~= nil and (typeof(autoSpawn) == typeof(true)) then autoSpawn else true
	
	-- instantiating new football instance...
	local _self = setmetatable({}, FootballClass)
	_self.SpawnOrigin =  origin 
	_self.FrictionThread = nil 
	_self.LastHitType = "Dribble" 
	_self.LastHitTime = tick()
	if autoSpawn then _self:SpawnBall() end
	
	-- adding new football to spawned table... 
	table.insert(FootballClass.SpawnedBalls, _self)
	
	return _self
end


function FootballClass:Destroy() 
	-- clean up instance... 
	if self.Instance then self.Instance:Destroy() end
	table.remove(FootballClass.SpawnedBalls, table.find(FootballClass.SpawnedBalls, self)) 
end


function FootballClass:SpawnBall()
	-- spawn a new ball at position xyz...
	local newBall = game.ServerStorage.Football:Clone()
	newBall.Position = self.SpawnOrigin or Vector3.new(0, 20, 0)
	newBall.Parent = workspace.Footballs 
	self.Instance = newBall
end


function FootballClass.LocateFootballFromInstance(needle: BasePart): FootballObject
	-- locate football from the physical model it's linked with... 
	for _, football: FootballObject in FootballClass.SpawnedBalls do
		if football.Instance == needle then return football end
	end
	return
end


-- < [🍎] PHYSICS METHODS [🍎] > --
function FootballClass:ApplyImpulse(force: Vector3, frictionDelay: number?) 
	--if typeof(force) ~= typeof(Vector3.one) then return "Error! Force is not a Vector3!" end 
	if typeof(frictionDelay) ~= typeof(123) then return "Error! FrictionDelay is not a number!" end
	
	-- applying optional parameters... 
	frictionDelay = frictionDelay or 0 
	
	-- set server-side network ownership of ball...
	local ball: BasePart = self.Instance
	if (not ball) or ball.Parent == nil then return end
	ball:SetNetworkOwner(nil)
	
	-- yield to ensure server has network ownership... 
	local connection: RBXScriptSignal
	connection = RunService.Heartbeat:Connect(function() 
		-- :ApplyImpulse() when network ownership is verified... 
		if ball:GetNetworkOwner() == nil then
			self:CancelMomentum() 
			ball:ApplyImpulse(force * ball.Mass) 
			self:ApplyFriction(frictionDelay)
			self.LastHitTime = tick()
			
			connection:Disconnect(); connection = nil
		end
	end)
	
	-- clean-up dead connections... 
	task.delay(5, function()
		if not connection then return end
		connection:Disconnect(); connection = nil
	end)
end


function FootballClass:Shoot(mouseHit: Vector3, basePower: number, motionType: "Dribble" | "Shoot") 
	-- typechecking... 
	--if typeof(mouseHit) ~= typeof(Vector3.one) then return `Error! MouseHit Invalid Type! {typeof(mouseHit)}, {typeof(Vector3.one)}, {typeof(Vector3.one) ~= typeof(mouseHit)}` end  
	if typeof(basePower) ~= typeof(123) then return "Error! Power Invalid Type!" end 
	if not table.find({"Dribble", "Shoot"}, motionType) then return "Error! Motion Invalid Type!" end
	
	-- applying parameters to football... 
	self.BasePower = basePower
	self.Power = self.BasePower 
	self.Height = if motionType == "Dribble" then 0 else math.clamp(mouseHit.Y + self.BasePower/2.5 , SHOOT_MIN_HEIGHT, 100)
	self.DelayFriction = if motionType == "Dribble" then 0 else 0.5
	
	-- calculating force & direction (based on mouse hit)... 
	local direction: Vector3 = self:GetDirectionFromMouseHit(mouseHit) 
	local force: Vector3 = self:GetForceFromDirection(direction, motionType) 

	-- playing vfx / sfx based on base power... 
	self:ApplyShotFX(motionType)

	-- applying force to ball... 
	self:ApplyImpulse(force, self.DelayFriction)
	self.LastHitType = motionType
	self.LastHitTime = tick()
end


function FootballClass:ApplyFriction(delayTime: number?) 
	-- typechecking...
	if delayTime ~= nil and typeof(delayTime) ~= typeof(123) then return "Error! Invalid 'DelayTime' Data Type!" end 
	delayTime = if typeof(delayTime) == typeof(123) then delayTime else 0
	if not self.Instance then return "Error! FootballObject does not have an Instance in Workspace.Footballs!" end
	
	-- cancel previous :ApplyFriction() threads...
	self:CancelFriction()
		
	self.FrictionThread = coroutine.create(function()
		local ball: BasePart = self.Instance
		task.wait(delayTime)
		
		-- slow down velocity and torque of moving ball... 
		for i = 1, 25 do
			ball.AssemblyLinearVelocity = Vector3.new(
				ball.AssemblyLinearVelocity.X * FRICTION_COEFFICIENT, 
				ball.AssemblyLinearVelocity.Y, 
				ball.AssemblyLinearVelocity.Z * FRICTION_COEFFICIENT
			) 
			
			ball.AssemblyAngularVelocity = Vector3.new(
				ball.AssemblyAngularVelocity.X * FRICTION_COEFFICIENT, 
				ball.AssemblyAngularVelocity.Y * FRICTION_COEFFICIENT, 
				ball.AssemblyAngularVelocity.Z * FRICTION_COEFFICIENT
			) 
			
			task.wait(0.5)
		end 
	end)
	
	coroutine.resume(self.FrictionThread)
end 


function FootballClass:CancelFriction()
	-- typechecking... 
	if (self.FrictionThread) and (typeof(self.FrictionThread) == typeof(task.spawn(function() end))) then 
		-- cancel running :ApplyFriction() thread if it exists...
		coroutine.close(self.FrictionThread) 
		self.FrictionThread = nil
	end
end 


function FootballClass:GetForceFromDirection(direction: Vector3, motionType: "Dribble" | "Shoot"): Vector3 
	-- calculate duration (and make duration faster if power boost applies)... 
	local isDirectShot: boolean = (self:CalculateShotType() == "DirectShot")
	local duration = math.log(1.01 + direction.Magnitude * 0.01) 	
	duration = if (isDirectShot and self.BasePower > 7) then duration * 0.5 else duration
	
	-- apply log formula to get force (+ gravity for arc motions)...
	local force = direction / duration 
	force = if motionType == "Shoot" then force + Vector3.new(0, game.Workspace.Gravity * 0.5 * duration, 0) else force 
	return force
end


function FootballClass:CancelMomentum() 
	-- set torque and velocity to zero 
	local ball: BasePart = self.Instance 
	ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	ball.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end


function FootballClass:GetDirectionFromMouseHit(mouseHit: Vector3): Vector3 
	-- apply extra power boost if base power high enough... 
	local isDirectShot: boolean = (self:CalculateShotType() == "DirectShot")
	self.Power = if isDirectShot and (self.BasePower > 7) then self.Power * 1.5 else self.Power
	self.Height = if isDirectShot then math.clamp(self.Height, SHOOT_MIN_HEIGHT, 1_000) else self.Height
	
	-- calculate direction... 
	local direction: Vector3
	local x: number = (mouseHit.X * self.Power/10)
	local y: number = (self.Height)
	local z: number = (mouseHit.Z * self.Power/10)
	direction = Vector3.new(x, y, z) 
	
	return direction
end


function FootballClass:CalculateShotType(): "DirectShot" | "NormalShot"
	-- determine what type of shot is being taken ("Direct Shot" | "Normal Shot")... 
	local reboundTime: number = (tick() - self.LastHitTime)
	local fastRebound: boolean = reboundTime < REBOUND_WINDOW
	local directShotPower: boolean = (self.BasePower > 6.5) 
	
	if (self.LastHitType == "Shoot" and fastRebound and directShotPower) then
		return "DirectShot" 
	else 
		return "NormalShot" 
	end
end


-- <[⭐] VFX / SFX METHODS [⭐]> -- 
function FootballClass:ApplyShotFX(motionType: "Dribble" | "Shoot") 	
	if motionType == "Shoot" then 
		-- play sfx / vfx for shooting...
		local ShotType = self:CalculateShotType()
		self:AdjustTrail(table.unpack(SHOOTING_FX[ShotType].Trail)) 
		self:PlaySFX(SHOOTING_FX[ShotType].SFX)
		
	elseif motionType == "Dribble" then
		-- play sfx / vfx for dribbling...
		self:AdjustTrail(false)
		self:PlaySFX("Kick")
	end
end


function FootballClass:AdjustTrail(visibility: boolean?, color: Color3?) 
	-- setting up optional parameters... 
	visibility = if typeof(visibility) == typeof(true) and visibility ~= nil then visibility else true
	color = color or Color3.fromRGB(255, 255, 255)
	
	-- locate trail in ball and apply changes... 
	local ball: BasePart = self.Instance
	local trail: Trail = ball:FindFirstChild("Trail")
	if not trail then return end
	trail.Color = ColorSequence.new(color)
	trail.Enabled = visibility
end


function FootballClass:PlaySFX(name: string) 
	-- :Play() sfx file inside of the ball...
	local ball: BasePart = self.Instance 
	local sfx: Sound = ball:FindFirstChild(name)
	if not sfx then return end
	sfx:Play()
end 
------ <END OF FUNCTIONS> ------


------ <RUNTIME ENVIRONMENT> ------
local football = FootballClass.new()


return FootballClass
