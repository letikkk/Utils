--!strict

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GoodSignal = require(script:WaitForChild("GoodSignal"))
local Types = require(script:WaitForChild("Types"))

local Cooldown = {}
Cooldown.__index = Cooldown

Cooldown.__tostring = function(self: Types.Cooldown)
	return `Cooldown on {self.name} is {self.cooldown} at the start`
end

local PlayerCooldowns: {[Player]: {[string]: number}} = {} -- [player]: {string = number}

local CooldownCache: {[string] : Types.Cooldown} = {} 

--[PRIVATE FUNCTIONS]--

local function ensurePlayer(plr: Player): {[string]: number}
	if not PlayerCooldowns[plr] then
		PlayerCooldowns[plr] = {}
	end
	return PlayerCooldowns[plr]
end

--[PUBLIC FUNCTIONS]--

function Cooldown.createCooldown(plr: Player?, name: string?, cooldown: number?)
	local self = setmetatable({}, Cooldown) :: Types.Cooldown

	self.player = plr or nil;
	self.name = name or "Placeholder";
	self.cooldown = cooldown or 0;

	self.cooldownStarted = GoodSignal.new();
	self.cooldownEnded = GoodSignal.new();

	self._key = HttpService:GenerateGUID(false);

	return self
end



--[PUBLIC METHODS]--

function Cooldown.StopCooldown(plr: Player, key: string)
	ensurePlayer(plr)
	
	if PlayerCooldowns[plr][key] then
		PlayerCooldowns[plr][key] = 0
	end
end

function Cooldown.StopAllCooldowns(plr: Player)
	ensurePlayer(plr)
	if not next(PlayerCooldowns[plr]) then
		warn("no current cooldowns")
		return
	end
	
	for cd, value in PlayerCooldowns[plr] do
		Cooldown.StopCooldown(plr, cd)
	end
	
end

function Cooldown.getAllCooldowns(plr: Player): {[string]: number}
	ensurePlayer(plr)
	
	return PlayerCooldowns[plr]
end

function Cooldown.getCooldown(plr: Player, key: string): number
	ensurePlayer(plr)

	
	return PlayerCooldowns[plr][key]
end

function Cooldown.getCooldownByKey(key: string) : Types.Cooldown | nil
	if not CooldownCache[key] then
		warn("no cooldown with key: ", key)
		return nil
	end
	
	return CooldownCache[key]
end

function Cooldown.start(self: Types.Cooldown) 

	CooldownCache[self._key] = self

	if not self.player then
		warn("plr is not defined")
	end
	ensurePlayer(self.player)
		
	if typeof(self.cooldown) == "number" then
		
		PlayerCooldowns[self.player][self.name] = self.cooldown
		self.cooldownStarted:Fire(self.name, self.player)
		
		task.spawn(function()
			
			self._connection = RunService.Heartbeat:Connect(function(dt)
				local cooldown = PlayerCooldowns[self.player][self.name]
				
				if cooldown then
					
					PlayerCooldowns[self.player][self.name] -= dt
					
					if PlayerCooldowns[self.player][self.name] <= 0 then
						
						PlayerCooldowns[self.player][self.name] = nil
						self.cooldownEnded:Fire(self.name, self.player)
						self:stop()
					end
				end
			end)
		end)
	end
end

function Cooldown.stop(self: Types.Cooldown)
	local cooldownObj: Types.Cooldown | nil = Cooldown.getCooldownByKey(self._key)

	if not cooldownObj then
		error("cooldown object has been already stopped")
		return
	end

	self:_clear(false)
end



function Cooldown:destroy()
	local cooldownObj: Types.Cooldown | nil = Cooldown.getCooldownByKey(self._key)
	
	if not cooldownObj then
		error("cooldown object has been already stopped")
		return
	end
	
	self:_clear(true)
end



--[PRIVATE METHODS]--

function Cooldown:_clear(clean: boolean)
	
	if self._connection then
		self._connection:Disconnect()
	end
	
	self.cooldownStarted:DisconnectAll()
	
	if clean then
		self.cooldownEnded:DisconnectAll()
	else
		self.cooldownEnded:Fire()
	end
	
	CooldownCache[self._key] = nil
	PlayerCooldowns[self.player][self.name] = nil
	
	print("hitbox has been cleared")
	
end


return Cooldown
