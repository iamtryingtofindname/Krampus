--// KRAMPUS \\--
-- Da Hood Auto Farm Script v3.4
-- obfuscating is for losers

if not shared.KrampusLoader then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Krampus/main/loader",true))()
end

shared.KrampusLoader(2788229376,"Auto Farm",function(initTopBarButton,topLeft,topRight,extra)
	local workspace = game:GetService("Workspace")
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")

	local player = Players.LocalPlayer
	local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()

	local enabled = false
	local ToggleButton = initTopBarButton(function(self)
		enabled = not enabled
		shared.__farm = enabled
		local state = self.Background.State
		if enabled then
			state.Text = "ON"
			controls:Disable()
		else
			state.Text = "OFF"
			controls:Enable()
		end
	end) -- Makes a topbar button

	local State = Instance.new("TextLabel")
	State.Name = "State"
	State.Parent = ToggleButton:WaitForChild("Background")
	State.AnchorPoint = Vector2.new(0.5, 0.5)
	State.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	State.BackgroundTransparency = 1
	State.Position = UDim2.new(0.5, -1, 0.5, 0)
	State.Size = UDim2.new(0.75, 0, 0.75, 0)
	State.Font = Enum.Font.GothamBold
	State.Text = "OFF"
	State.TextColor3 = Color3.fromRGB(255, 255, 255)
	State.TextScaled = true
	State.TextSize = 14
	State.TextWrapped = true

	local HB = RunService.Heartbeat

	local afkPoint = CFrame.new(-798.5,-39.425,-843.75)--CFrame.new(13,12,205)
	local afkOffset = Vector3.new(15,0,7)
	local registerOffset = CFrame.new(0, -2, 1)
	local pickupCooldown = 0.05

	local cashiers = workspace:WaitForChild("Cashiers")
	local drops = workspace:WaitForChild("Ignored"):WaitForChild("Drop")

	local start = os.clock()

	local function yield(length)
		if length then
			return wait(length)
		else
			return HB:wait()
		end
	end

	local function getCharacter()
		return player.Character or player.CharacterAdded:wait()
	end

	local function getRoot(arg)
		local char = arg or getCharacter()
		repeat yield() until not char or char.PrimaryPart
		if char then
			return char.PrimaryPart
		end
	end

	local function getBoth()
		local char = getCharacter()
		local root = getRoot(char)
		return char,root
	end

	local function resetCharacter()
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
			local shouldReturn = false
			local charAdded = nil
			charAdded = player.CharacterAdded:Connect(function(char)
				character = char
				repeat yield() until charAdded
				charAdded:disconnect()
				shouldReturn = true
				return
			end)
			local st = os.clock()
			repeat yield() until shouldReturn or os.clock()-st > 15
			pcall(function()
				charAdded:disconnect()
			end)
			start = os.clock()
			return
		else
			player:LoadCharacter()
		end
	end

	local function mobile()
		local char = getCharacter()

		if char then

			local humanoid = char:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then

				local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")

				if torso then
					local motor = torso:FindFirstChildOfClass("Motor6D")

					if motor then
						return true
					else
						return false
					end
				else
					return false
				end

			else
				return false
			end

		else
			return false
		end
	end

	local function getNearestRegister()
		local character = getCharacter()
		local root = character.PrimaryPart
		if not root then return end
		local rootPos = root.Position
		local maxdistance = math.huge
		local target
		for _,register in pairs(cashiers:GetChildren()) do
			if register:FindFirstChild("Head") and register:FindFirstChild("Humanoid") and register.Humanoid.Health > 0 then
				local distance = (rootPos-register.Head.Position).magnitude
				if distance < maxdistance then
					target = register
					maxdistance = distance
				end
			end
		end
		return target
	end

	coroutine.resume(coroutine.create(function()
		local character,root = getBoth()

		local goal = nil
		local pause = false
		local inAfkSpot = false
		local offset = Vector3.new()
		local generator = Random.new()

		local update = HB:Connect(function()
			character,root = getBoth()
			if enabled and not pause and goal and character and root and mobile() then
				root.CFrame = goal
				-- Holds out money just cuz why not
				local Wallet = player.Backpack:FindFirstChild("Wallet") or character:FindFirstChild("Wallet")
				local Combat = player.Backpack:FindFirstChild("Combat") or character:FindFirstChild("Combat")

				if Wallet and character then
					Wallet.Parent = character
				end

				if Combat and character then
					Combat.Parent = character
				end
			end
		end)

		while yield() do
			if enabled then
				local register = getNearestRegister()

				character,root = getBoth()

				if root then
					if register then
						-- Opens the register
						goal = register.Head.CFrame * registerOffset

						start = os.clock()
						inAfkSpot = false

						repeat
							yield()
							pcall(function()
								if not enabled then
									return
								end
								local didWait = false
								while HB:wait() do
									character,root = getBoth()

									if character then
										if mobile() then
											break
										else
											didWait = true
											start = os.clock()
										end
									end
								end
								if didWait and shared.__hide then
									pause = true
									wait(3)
									start = os.clock()
									pause = false
								end
								local Combat = player.Backpack:FindFirstChild("Combat") or character:FindFirstChild("Combat")
								if not Combat then
									if not enabled then
										return
									end
									wait(1)
									if not enabled then
										return
									end
									character,root = getBoth()
									Combat = player.Backpack:FindFirstChild("Combat") or character:FindFirstChild("Combat")
									if not Combat and enabled then
										resetCharacter()
										return
									else
										start = os.clock()
									end
								end

								character,root = getBoth()
								Combat.Parent = character

								if os.clock()-start > 8 then
									resetCharacter()
									return
								end

								if mobile() then
									Combat:Activate()
								end
							end)
						until not enabled or (not register or register.Humanoid.Health < 0)
						pcall(function()
							if not enabled then
								return
							end
							character,root = getBoth()
							for i, v in pairs(drops:GetDescendants()) do
								if not enabled then
									return
								end
								if v:IsA("ClickDetector") and v.Parent and v.Parent.Name:find("Money") then
									if (v.Parent.Position - root.Position).magnitude <= 18 then
										repeat
											if not enabled or (v.Parent.Position - root.Position).magnitude >= 18 then
												return
											end
											character,root = getBoth()
											yield(pickupCooldown)
											fireclickdetector(v)
										until not v or not v.Parent.Parent or (v.Parent.Position - root.Position).magnitude > 18
									end
								end
							end
						end)
						if enabled then
							yield(1.15)
						else
							character,root = getRoot()
							if root then
								root.Anchored = false
							end
							local Combat = player.Backpack:FindFirstChild("Combat") or character:FindFirstChild("Combat")
							if Combat then
								Combat.Parent = player.Backpack
							end
							local Wallet = player.Backpack:FindFirstChild("Wallet") or character:FindFirstChild("Wallet")
							if Wallet then
								Wallet.Parent = player.Backpack
							end
						end
					else
						if not inAfkSpot then
							-- Come up with a new offset
							print("New offset!")
							offset = Vector3.new(generator:NextNumber(-afkOffset.x,afkOffset.x),generator:NextNumber(-afkOffset.y,afkOffset.y),generator:NextNumber(-afkOffset.z,afkOffset.z))
							inAfkSpot = true
						end
						if (root.Position-afkPoint.Position).magnitude>3 then
							goal = afkPoint + offset
						end
					end
				else
					resetCharacter()
				end
				yield()
			end
		end
	end))
	ToggleButton.Parent = topLeft
end)
