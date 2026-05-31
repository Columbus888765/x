local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Norex hub",
	Footer = "version: hi",
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Main = Window:AddTab("Main"),
	Raids = Window:AddTab("Raids"),
	Players = Window:AddTab("Players"),
	["UI Settings"] = Window:AddTab("UI Settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Groupbox")

local FamilyGroupBox = Tabs.Players:AddLeftGroupbox("Family Roll")

local loopEnabled = true
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")
local Player = game:GetService("Players").LocalPlayer

local kickCategories = {
	Common = false,
	Rare = false,
	Epic = false,
	Legendary = false,
	Mythical = false
}

local selectedFamilies = {}
local familyList = {
	"Ackerman", "Arlert", "Azumabito", "Braun", "Braus", 
	"Finger", "Fritz", "Galliard", "Grice", "Helos", 
	"Kirstein", "Kruger", "Ksaver", "Leonhart", "Reiss", 
	"Smith", "Springer", "Tybur", "Yeager", "Zoe"
}

for _, fam in ipairs(familyList) do
	selectedFamilies[fam] = false
end

FamilyGroupBox:AddToggle("RollToggle", {
	Text = "Auto Roll",
	Default = false,
	Callback = function(Value)
		loopEnabled = Value
		if Value then
			task.spawn(function()
				while loopEnabled do
					local success, result1, result2, currentFamily, result4, rolledList = pcall(function()
						return Remote:InvokeServer("Family", "Roll")
					end)
					
					if success and rolledList and type(rolledList) == "table" then
						local latestRoll = rolledList[#rolledList]
						if latestRoll and latestRoll.Family and latestRoll.Rarity then
							local rolledFamily = latestRoll.Family
							local rolledRarity = latestRoll.Rarity
							
							local displayFamily = rolledFamily or "Unknown"
							local displayRarity = rolledRarity or "Unknown"
							
							Library:Notify({
								Title = "العائلة: " .. tostring(displayFamily),
								Content = "[" .. tostring(displayRarity) .. "]",
								Duration = 1.2,
							})
							
							if kickCategories[rolledRarity] == true or selectedFamilies[rolledFamily] == true then
								loopEnabled = false
								Toggles.RollToggle:SetValue(false)
								Player:Kick("جاتك هذه العائلة: " .. rolledFamily .. " [" .. rolledRarity .. "]")
								break
							end
						end
					end
					task.wait(0.5)
				end
			end)
		end
	end
})

FamilyGroupBox:AddDivider()

FamilyGroupBox:AddToggle("Cat_Common", {
	Text = "Kick Common",
	Default = false,
	Callback = function(Value) kickCategories.Common = Value end
})
FamilyGroupBox:AddToggle("Cat_Rare", {
	Text = "Kick Rare",
	Default = false,
	Callback = function(Value) kickCategories.Rare = Value end
})
FamilyGroupBox:AddToggle("Cat_Epic", {
	Text = "Kick Epic",
	Default = false,
	Callback = function(Value) kickCategories.Epic = Value end
})
FamilyGroupBox:AddToggle("Cat_Legendary", {
	Text = "Kick Legendary",
	Default = false,
	Callback = function(Value) kickCategories.Legendary = Value end
})
FamilyGroupBox:AddToggle("Cat_Mythical", {
	Text = "Kick Mythical",
	Default = false,
	Callback = function(Value) kickCategories.Mythical = Value end
})

FamilyGroupBox:AddDivider()

FamilyGroupBox:AddDropdown("FamilyKickDropdown", {
	Values = familyList,
	Default = {},
	Multi = true,
	Text = "Select Families to Kick",
	Callback = function(Value)
		for _, fam in ipairs(familyList) do
			selectedFamilies[fam] = Value[fam] or false
		end
	end
})

FamilyGroupBox:AddDivider()

LeftGroupBox:AddButton("Shadow Ban?", function()
	local player = game:GetService("Players").LocalPlayer
	local isBlacklisted = player:GetAttribute("Blacklisted")
	local isExploiter = player:GetAttribute("Exploiter")

	if isBlacklisted or isExploiter then
		Library:Notify({
			Title = "You are Banned!",
			Content = "Shadow ban detected",
			Duration = 5,
		})
	else
		Library:Notify({
			Title = "You are NOT Banned",
			Content = "Account is clean",
			Duration = 5,
		})
	end
end)

local SwordKillEnabled = false local RocketKillEnabled = false local AutoReadyEnabled = false

LeftGroupBox:AddToggle("AutoReady", {
    Text = "Auto Ready",
    Default = false,
    Callback = function(Value)
        AutoReadyEnabled = Value
        if Value then
            task.spawn(function()
                local GuiService = game:GetService("GuiService")
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local Player = game:GetService("Players").LocalPlayer
                local PlayerGui = Player:WaitForChild("PlayerGui")

                local Rewards = PlayerGui:WaitForChild("Interface"):WaitForChild("Rewards")

                local function runCode()
                    local targetButton = Rewards:WaitForChild("Main"):WaitForChild("Info"):WaitForChild("Main"):WaitForChild("Buttons"):WaitForChild("Retry")
                    task.wait(2)
                    GuiService.SelectedObject = targetButton
                    task.wait(1)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end

                if Rewards.Visible then
                    runCode()
                else
                    local connection
                    connection = Rewards:GetPropertyChangedSignal("Visible"):Connect(function()
                        if Rewards.Visible then
                            connection:Disconnect()
                            runCode()
                        end
                    end)
                end
            end)
        end
    end
})

LeftGroupBox:AddToggle("SwordKill", {
	Text = "Sword Kill",
	Default = false,

	Callback = function(Value)
		SwordKillEnabled = Value

		if Value then
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local RunService = game:GetService("RunService")
				local Workspace = game:GetService("Workspace")

				local LocalPlayer = Players.LocalPlayer
				local Event = ReplicatedStorage.Assets.Remotes.POST
				local TitansFolder = Workspace:WaitForChild("Titans")
				local CharactersFolder = Workspace:WaitForChild("Characters")

				local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

				LocalPlayer.CharacterAdded:Connect(function(char)
					Character = char
					HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
				end)

				local Rig = CharactersFolder:WaitForChild(LocalPlayer.Name):WaitForChild("Rig_" .. LocalPlayer.Name)
				local LeftHand = Rig:WaitForChild("LeftHand")

				local Blades = table.freeze({
					LeftHand:WaitForChild("Blade_1"),
					LeftHand:WaitForChild("Blade_2"),
					LeftHand:WaitForChild("Blade_3"),
					LeftHand:WaitForChild("Blade_4"),
					LeftHand:WaitForChild("Blade_5"),
					LeftHand:WaitForChild("Blade_6"),
					LeftHand:WaitForChild("Blade_7"),
				})

				local zero = Vector3.zero
				local SPEED = 500
				local HEIGHT = 300

				local CurrentTitan
				local CurrentNape
				local CachedTitans = {}

				local block = Instance.new("Part")
				block.Name = "FlyBlock"
				block.Size = Vector3.new(18, 2, 10)
				block.Anchored = true
				block.CanCollide = false
				block.Transparency = 1
				block.Position = HumanoidRootPart.Position
				block.Parent = Workspace

				local flyingUp = true

				local function UpdateTitans()
					table.clear(CachedTitans)

					for _, titan in ipairs(TitansFolder:GetChildren()) do
						local humanoid = titan:FindFirstChild("Humanoid")
						local hitboxes = titan:FindFirstChild("Hitboxes")
						local hit = hitboxes and hitboxes:FindFirstChild("Hit")
						local nape = hit and hit:FindFirstChild("Nape")

						if humanoid and humanoid.Health > 0 and nape then
							CachedTitans[#CachedTitans + 1] = {
								Titan = titan,
								Nape = nape
							}
						end
					end
				end

				TitansFolder.ChildAdded:Connect(UpdateTitans)
				TitansFolder.ChildRemoved:Connect(UpdateTitans)

				local function BladesVisible()
					return Blades[1].Transparency < 1
				end

				local function GetClosestTitan()
					local rootPos = HumanoidRootPart.Position
					local closestData
					local shortest = math.huge

					for i = 1, #CachedTitans do
						local data = CachedTitans[i]

						if data.Titan.Parent then
							local distance = (rootPos - data.Nape.Position).Magnitude

							if distance < shortest then
								shortest = distance
								closestData = data
							end
						end
					end

					return closestData
				end

				local searchTimer = 0
				local remoteTimer = 0

				local heartbeatConn
				heartbeatConn = RunService.Heartbeat:Connect(function(delta)
					if not SwordKillEnabled then
						heartbeatConn:Disconnect()

						if block then
							block:Destroy()
						end

						return
					end

					searchTimer += delta
					remoteTimer += delta

					if not CurrentTitan or not CurrentTitan.Parent then
						CurrentTitan = nil
						CurrentNape = nil
					end

					if CurrentTitan then
						local humanoid = CurrentTitan:FindFirstChild("Humanoid")

						if not humanoid or humanoid.Health <= 0 then
							CurrentTitan = nil
							CurrentNape = nil
							UpdateTitans()
							return
						end
					end

					if not CurrentTitan and searchTimer >= 0.1 then
						searchTimer = 0

						UpdateTitans()

						local targetData = GetClosestTitan()

						if targetData then
							CurrentTitan = targetData.Titan
							CurrentNape = targetData.Nape
							flyingUp = true
						end
					end

					local nape = CurrentNape

					if not nape then
						return
					end

					local targetPoint

					if flyingUp then
						targetPoint = Vector3.new(
							block.Position.X,
							nape.Position.Y + HEIGHT,
							block.Position.Z
						)

						if math.abs(block.Position.Y - (nape.Position.Y + HEIGHT)) <= 5 then
							flyingUp = false
						end
					else
						targetPoint = Vector3.new(
							nape.Position.X,
							nape.Position.Y + HEIGHT,
							nape.Position.Z
						)
					end

					local direction = targetPoint - block.Position
					local distance = direction.Magnitude

					if distance > 1 then
						local move = math.min(SPEED * delta, distance)
						block.Position = block.Position + direction.Unit * move
					end

					HumanoidRootPart.AssemblyLinearVelocity = zero
					HumanoidRootPart.AssemblyAngularVelocity = zero
					HumanoidRootPart.CFrame = CFrame.new(block.Position)

					if remoteTimer >= 1 then
						remoteTimer = 0

						if BladesVisible() then
							Event:FireServer("Attacks", "Slash", true)
							Event:FireServer("Hitboxes", "Register", nape, 226.99119567871, 0.058780193328857)
						end
					end
				end)
			end)
		end
	end,
})

LeftGroupBox:AddToggle("RocketKill", {
Text = "Rocket Kill",
Default = false,

Callback = function(Value)  
	RocketKillEnabled = Value  

	if Value then  
		task.spawn(function()  
			local Players = game:GetService("Players")  
			local RunService = game:GetService("RunService")  
			local ReplicatedStorage = game:GetService("ReplicatedStorage")  

			local player = Players.LocalPlayer  

			local block = Instance.new("Part")  
			block.Name = "gg1"  
			block.Size = Vector3.new(18, 2, 10)  
			block.Anchored = true  
			block.CanCollide = false  
			block.Transparency = 1  
			block.Parent = workspace  

			local SPEED = 500  
			local HEIGHT = 300  
			local ATTACK_DISTANCE = 20000  
			local MAX_TARGETS = 10  

			local currentTitan = nil  
			local currentTargets = {}  

			local GET = ReplicatedStorage.Assets.Remotes.GET  
			local POST = ReplicatedStorage.Assets.Remotes.POST  

			local skipGui = player.PlayerGui:WaitForChild("Interface"):WaitForChild("Skip")  

			local function IsPaused()  
				return skipGui.Visible == true  
			end  

			local function getChar()  
				return player.Character or player.CharacterAdded:Wait()  
			end  

			local char = getChar()  
			local hrp = char:FindFirstChild("HumanoidRootPart")  

			if hrp then  
				block.Position = hrp.Position  
			end  

			local function getPriorityBlock()  
				local priority = workspace:FindFirstChild("511511")  
				if priority and priority:IsA("BasePart") then  
					return priority  
				end  
				return nil  
			end  

			local function getClosestTargets()  
				local targets = {}  
				local titansFolder = workspace:WaitForChild("Titans")  

				local character = getChar()  
				local root = character:FindFirstChild("HumanoidRootPart")  

				if not root then  
					return targets  
				end  

				local priorityBlock = getPriorityBlock()  

				if priorityBlock then  
					table.insert(targets, {  
						Titan = priorityBlock,  
						Nape = priorityBlock,  
						Distance = 0,  
						IsBlock = true  
					})  
					return targets  
				end  

				for _, titan in ipairs(titansFolder:GetChildren()) do  
					local humanoid = titan:FindFirstChild("Humanoid")  

					local nape = titan:FindFirstChild("Hitboxes")  
						and titan.Hitboxes:FindFirstChild("Hit")  
						and titan.Hitboxes.Hit:FindFirstChild("Nape")  

					if humanoid and humanoid.Health > 0 and nape then  
						local distance = (root.Position - nape.Position).Magnitude  

						if distance <= ATTACK_DISTANCE then  
							table.insert(targets, {  
								Titan = titan,  
								Nape = nape,  
								Distance = distance  
							})  
						end  
					end  
				end  

				table.sort(targets, function(a, b)  
					return a.Distance < b.Distance  
				end)  

				local selected = {}  

				for i = 1, math.min(MAX_TARGETS, #targets) do  
					table.insert(selected, targets[i])  
				end  

				return selected  
			end  

			local function targetsDead()  
				if #currentTargets == 0 then  
					return true  
				end  

				for _, data in ipairs(currentTargets) do  
					if data.IsBlock then  
						if workspace:FindFirstChild("511511") then  
							return false  
						end  
					else  
						local titan = data.Titan  
						if titan and titan.Parent then  
							local humanoid = titan:FindFirstChild("Humanoid")  
							if humanoid and humanoid.Health > 0 then  
								return false  
							end  
						end  
					end  
				end  

				return true  
			end  

			local heartbeatConnection  
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)  
				if not RocketKillEnabled then  
					if heartbeatConnection then  
						heartbeatConnection:Disconnect()  
					end  

					if block then  
						block:Destroy()  
					end  

					return  
				end  

				if IsPaused() then  
					return  
				end  

				local c = getChar()  
				local root = c:FindFirstChild("HumanoidRootPart")  

				if not root then  
					return  
				end  

				currentTargets = getClosestTargets()  

				if #currentTargets > 0 then  
					currentTitan = currentTargets[1].Titan  
				else  
					currentTitan = nil  
					return  
				end  

				if not currentTitan then  
					return  
				end  

				local targetPosition  

				if currentTitan:IsA("BasePart") then  
					targetPosition = currentTitan.Position  
				else  
					local titanRoot = currentTitan:FindFirstChild("HumanoidRootPart")  
						or currentTitan:FindFirstChild("Head")  
						or currentTitan.PrimaryPart  

					if not titanRoot then  
						return  
					end  

					targetPosition = titanRoot.Position  
				end  

				local targetPoint = Vector3.new(  
					targetPosition.X,  
					targetPosition.Y + HEIGHT,  
					targetPosition.Z  
				)  

				local direction = targetPoint - block.Position  
				local distance = direction.Magnitude  

				if distance > 1 then  
					local move = math.min(SPEED * dt, distance)  
					block.Position = block.Position + direction.Unit * move  
				end  

				block.Position = Vector3.new(  
					block.Position.X,  
					targetPoint.Y,  
					block.Position.Z  
				)  

				root.AssemblyLinearVelocity = Vector3.zero  
				root.CFrame = CFrame.new(block.Position)  
				root.AssemblyAngularVelocity = Vector3.zero  
			end)  

			local function attackTargets()  
				if IsPaused() then  
					return  
				end  

				local priorityBlock = getPriorityBlock()  

				if priorityBlock then  
					for i = 1, 30 do  
						if IsPaused() then return end  
						POST:FireServer("Spears", "S_Explode", priorityBlock.Position, 1.8282463550568)  
					end  
					GET:InvokeServer("Spears", "S_Fire", "1")  
					return  
				end  

				for _, data in ipairs(currentTargets) do  
					if IsPaused() then return end  

					local target = data.Nape  
					if target and target.Parent then  
						POST:FireServer("Spears", "S_Explode", target.Position, 1.8282463550568)  
						POST:FireServer("Spears", "S_Explode", target.Position, 1.8282463550568)  
					end  
				end  

				GET:InvokeServer("Spears", "S_Fire", "1")  
			end  

			while RocketKillEnabled do  
				if not IsPaused() then  
					currentTargets = getClosestTargets()  
					if #currentTargets > 0 then  
						attackTargets()  
					end  
				end  

				task.wait()  
			end  

			if heartbeatConnection then  
				heartbeatConnection:Disconnect()  
			end  

			if block then  
				block:Destroy()  
			end  
		end)  
	end  
end,

})

 
local AutoReloadEnabled = false
local AutoBladeReloadEnabled = false

LeftGroupBox:AddToggle("AutoReload", {
	Text = "Auto Reload (Rocket / Sword)",
	Default = false,

	Callback = function(Value)
		AutoReloadEnabled = Value

		if Value then
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")

				local LocalPlayer = Players.LocalPlayer

				local POST = ReplicatedStorage:WaitForChild("Assets")
					:WaitForChild("Remotes")
					:WaitForChild("POST")

				local SearchFolders = {
					workspace.Borders,
					workspace.Characters,
					workspace.Climbable,
					workspace.Debris,
					workspace.Hooks,
					workspace.Unclimbable,
				}

				local function FindRefill()
					for _, folder in ipairs(SearchFolders) do
						local refill = folder:FindFirstChild("Refill", true)
						if refill then
							return refill
						end
					end
				end

				local function GetBladeParts()
					local characterFolder = workspace.Characters:FindFirstChild(LocalPlayer.Name)
					if not characterFolder then return end
					local rig = characterFolder:FindFirstChild("Rig_" .. LocalPlayer.Name)
					if not rig then return end
					local leftHand = rig:FindFirstChild("LeftHand")
					if not leftHand then return end
					local blades = {}
					for i = 1, 7 do
						local blade = leftHand:FindFirstChild("Blade_" .. i)
						if blade then table.insert(blades, blade) end
					end
					return blades
				end

				local function AllBladesVisible()
					local blades = GetBladeParts()
					if not blades then return false end
					for _, blade in ipairs(blades) do
						if blade.Transparency ~= 0 then return false end
					end
					return true
				end

				local function AllBladesHidden()
					local blades = GetBladeParts()
					if not blades then return false end
					for _, blade in ipairs(blades) do
						if blade.Transparency ~= 1 then return false end
					end
					return true
				end

				while AutoReloadEnabled do
					pcall(function()
						local top = LocalPlayer.PlayerGui.Interface.HUD.Main.Top["7"]
						local spearsLabel = top.Spears.Spears
						local bladesLabel = top.Blades.Sets

						local spearsText = spearsLabel.Text
						local bladesText = bladesLabel.Text

						local refill = FindRefill()

						if refill then
							if spearsText == "0 / 8" then
								POST:FireServer("Attacks", "Reload", refill)
							end

							if bladesText == "0 / 3" then
								if AllBladesVisible() then
									repeat
										task.wait(0.1)
									until AllBladesHidden() or not AutoReloadEnabled
								end
								if AutoReloadEnabled then
									POST:FireServer("Attacks", "Reload", refill)
								end
							end
						end
					end)

					task.wait(0.1)
				end
			end)
		end
	end,
})

LeftGroupBox:AddToggle("AutoBladeReload", {
	Text = "Auto Blade Reload",
	Default = false,

	Callback = function(Value)
		AutoBladeReloadEnabled = Value

		if Value then
			task.spawn(function()
				local Players = game:GetService("Players")
				local VirtualInputManager = game:GetService("VirtualInputManager")

				local LocalPlayer = Players.LocalPlayer

				local function getBlades()
					local playerName = LocalPlayer.Name

					local characterFolder = workspace.Characters:FindFirstChild(playerName)
					if not characterFolder then
						return
					end

					local rig = characterFolder:FindFirstChild("Rig_" .. playerName)
					if not rig then
						return
					end

					local leftHand = rig:FindFirstChild("LeftHand")
					if not leftHand then
						return
					end

					return {
						leftHand.Blade_1,
						leftHand.Blade_2,
						leftHand.Blade_3,
						leftHand.Blade_4,
						leftHand.Blade_5,
						leftHand.Blade_6,
						leftHand.Blade_7,
					}
				end

				local function allTransparency(blades, value)
					for _, part in pairs(blades) do
						if not part or part.Transparency ~= value then
							return false
						end
					end

					return true
				end

				local function pressR()
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
					task.wait(0.05)
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
				end

				local loaded = false

				LocalPlayer.CharacterAdded:Connect(function()
					loaded = false
					task.wait(5)
					loaded = true
				end)

				if LocalPlayer.Character then
					task.wait(5)
					loaded = true
				end

				while AutoBladeReloadEnabled do
					task.wait(0.1)

					if loaded then
						local blades = getBlades()

						if blades and allTransparency(blades, 1) then
							while AutoBladeReloadEnabled do
								local currentBlades = getBlades()

								if not currentBlades then
									break
								end

								if allTransparency(currentBlades, 0) then
									break
								end

								if allTransparency(currentBlades, 1) then
									pressR()
								end

								task.wait(3)
							end
						end
					end
				end
			end)
		end
	end,
})

LeftGroupBox:AddDivider()

LeftGroupBox:AddToggle("BuildingSurvey", {
	Text = "Building survey",
	Default = false,

	Callback = function(Value)
		if Value then
			local Climbable = workspace:FindFirstChild("Climbable")

			if Climbable then
				local Buildings = Climbable:FindFirstChild("Buildings")

				if Buildings then
					Buildings:Destroy()
				end
			end
		end
	end,
})

-- Players Tab
local PlayersGroupBox = Tabs.Players:AddLeftGroupbox("Players")
local PlayersGroupBoxRight = Tabs.Players:AddRightGroupbox("Hitbox")

local HitboxEnabled = false
local HitboxSize = 100
local HitboxTargets = {
	Nape = false,
	Eyes = false,
	RightLeg = false,
	LeftLeg = false,
	RightArm = false,
	LeftArm = false,
}
local originalSizes = {}

local function resetAllTitans()
	for titan, parts in pairs(originalSizes) do
		for part, size in pairs(parts) do
			if part and part.Parent then
				part.Size = size
			end
		end
	end
	originalSizes = {}
end

local function getActiveTargets()
	local active = {}
	for name, enabled in pairs(HitboxTargets) do
		if enabled then table.insert(active, name) end
	end
	return active
end

local function setupTitan(titan)
	local humanoid = titan:FindFirstChildOfClass("Humanoid")
	local hitFolder = titan:FindFirstChild("Hitboxes")
	if not humanoid or not hitFolder then return end
	local hit = hitFolder:FindFirstChild("Hit")
	if not hit then return end

	if not originalSizes[titan] then
		originalSizes[titan] = {}
	end

	local activeTargets = getActiveTargets()
	for _, name in ipairs(activeTargets) do
		local part = hit:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			if not originalSizes[titan][part] then
				originalSizes[titan][part] = part.Size
			end
			part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
		end
	end

	humanoid.AncestryChanged:Connect(function(_, parent)
		if not parent and originalSizes[titan] then
			for part, size in pairs(originalSizes[titan]) do
				if part and part.Parent then part.Size = size end
			end
			originalSizes[titan] = nil
		end
	end)
end

local function refreshAllTitans()
	resetAllTitans()
	if not HitboxEnabled then return end
	local Titans = workspace:FindFirstChild("Titans")
	if not Titans then return end
	for _, titan in ipairs(Titans:GetChildren()) do
		setupTitan(titan)
	end
end

PlayersGroupBoxRight:AddToggle("HitboxToggle", {
	Text = "Hitbox",
	Default = false,
	Callback = function(Value)
		HitboxEnabled = Value
		if Value then
			local Titans = workspace:WaitForChild("Titans")
			for _, titan in ipairs(Titans:GetChildren()) do
				setupTitan(titan)
			end
			Titans.ChildAdded:Connect(function(titan)
				if HitboxEnabled then
					task.wait(1)
					setupTitan(titan)
				end
			end)
		else
			resetAllTitans()
		end
	end,
})

PlayersGroupBoxRight:AddSlider("HitboxSizeSlider", {
	Text = "Hitbox Size",
	Default = 100,
	Min = 10,
	Max = 500,
	Rounding = 0,
	Callback = function(value)
		HitboxSize = value
		if HitboxEnabled then
			refreshAllTitans()
		end
	end,
})

PlayersGroupBoxRight:AddToggle("HitboxTransparencyToggle", {
	Text = "Transparency",
	Default = false,
	Callback = function(Value)
		if Value then
			local Titans = workspace:FindFirstChild("Titans")
			if not Titans then return end
			for _, titan in ipairs(Titans:GetChildren()) do
				local hitFolder = titan:FindFirstChild("Hitboxes")
				if hitFolder then
					local hit = hitFolder:FindFirstChild("Hit")
					if hit then
						for _, part in ipairs(hit:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Transparency = Options.HitboxTransparencySlider.Value
							end
						end
					end
				end
			end
		else
			local Titans = workspace:FindFirstChild("Titans")
			if not Titans then return end
			for _, titan in ipairs(Titans:GetChildren()) do
				local hitFolder = titan:FindFirstChild("Hitboxes")
				if hitFolder then
					local hit = hitFolder:FindFirstChild("Hit")
					if hit then
						for _, part in ipairs(hit:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
					end
				end
			end
		end
	end,
})

PlayersGroupBoxRight:AddSlider("HitboxTransparencySlider", {
	Text = "Transparency",
	Default = 0.55,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Callback = function(value)
		if Toggles.HitboxTransparencyToggle.Value then
			local Titans = workspace:FindFirstChild("Titans")
			if not Titans then return end
			for _, titan in ipairs(Titans:GetChildren()) do
				local hitFolder = titan:FindFirstChild("Hitboxes")
				if hitFolder then
					local hit = hitFolder:FindFirstChild("Hit")
					if hit then
						for _, part in ipairs(hit:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Transparency = value
							end
						end
					end
				end
			end
		end
	end,
})

PlayersGroupBoxRight:AddDivider()

local targetLabels = {
	{ key = "Nape",     text = "الرقبه (Nape)" },
	{ key = "Eyes",     text = "العيون (Eyes)" },
	{ key = "RightLeg", text = "الساق اليمنى (Right Leg)" },
	{ key = "LeftLeg",  text = "الساق اليسرى (Left Leg)" },
	{ key = "RightArm", text = "اليد اليمنى (Right Arm)" },
	{ key = "LeftArm",  text = "اليد اليسرى (Left Arm)" },
}

for _, entry in ipairs(targetLabels) do
	local key = entry.key
	PlayersGroupBoxRight:AddToggle("Hitbox_" .. key, {
		Text = entry.text,
		Default = false,
		Callback = function(Value)
			HitboxTargets[key] = Value
			if HitboxEnabled then
				refreshAllTitans()
			end
		end,
	})
end

local KllEnabled = false
local KllSpeed = 1
local KllDistance = 2000

local KllToggle = PlayersGroupBox:AddToggle("KllToggle", {
	Text = "Kll",
	Default = false,

	Callback = function(Value)
		KllEnabled = Value

		if Value then
			task.spawn(function()
				local player = game:GetService("Players").LocalPlayer
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Event = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("POST")

				local function allBladesInvisible()
					local rig = workspace:FindFirstChild("Characters")
						and workspace.Characters:FindFirstChild(player.Name)
						and workspace.Characters[player.Name]:FindFirstChild("Rig_" .. player.Name)

					if not rig then return false end

					local leftHand = rig:FindFirstChild("LeftHand")
					if not leftHand then return false end

					for i = 1, 7 do
						local blade = leftHand:FindFirstChild("Blade_" .. i)
						if not blade or blade.Transparency ~= 1 then return false end
					end

					return true
				end

				local function getClosestTitan()
					local char = player.Character or player.CharacterAdded:Wait()
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if not hrp then return nil end

					local rootPos = hrp.Position
					local closest = nil
					local minDist = KllDistance + 1

					for _, titan in ipairs(workspace:WaitForChild("Titans"):GetChildren()) do
						local humanoid = titan:FindFirstChild("Humanoid")
						local titanHRP = titan:FindFirstChild("HumanoidRootPart")

						if humanoid and humanoid.Health > 0 and titanHRP then
							local dist = (titanHRP.Position - rootPos).Magnitude
							if dist < minDist and dist <= KllDistance then
								minDist = dist
								closest = titan
							end
						end
					end

					return closest
				end

				while KllEnabled do
					if not allBladesInvisible() then
						local target = getClosestTitan()
						if target then
							Event:FireServer("Attacks", "Slash", true)
							local hitboxes = target:FindFirstChild("Hitboxes")
							if hitboxes then
								local hitFolder = hitboxes:FindFirstChild("Hit")
								if hitFolder then
									local nape = hitFolder:FindFirstChild("Nape")
									if nape then
										Event:FireServer("Hitboxes", "Register", nape, 188, 0)
									end
								end
							end
						end
					end
					if KllSpeed == 0 then
						task.wait()
					else
						task.wait(KllSpeed)
					end
					if not KllEnabled then break end
				end
			end)
		end
	end,
})

local function getSpeedColor(value)
	local t = value / 5
	local r = math.floor(255 * (1 - t))
	local g = math.floor(255 * t)
	return Color3.fromRGB(r, g, 0)
end

local function getDistanceColor(value)
	local t = (value - 100) / (2000 - 100)
	local r = math.floor(255 * t)
	local g = math.floor(255 * (1 - t))
	return Color3.fromRGB(r, g, 0)
end

local function applySliderColor(sliderKey, color)
	pcall(function()
		local slider = Options[sliderKey]
		if slider then
			for _, obj in ipairs(slider.Frame:GetDescendants()) do
				if obj:IsA("Frame") and obj.Name == "Fill" then
					obj.BackgroundColor3 = color
				end
			end
		end
	end)
end

PlayersGroupBox:AddSlider("KllSpeedSlider", {
	Text = "Kll Speed",
	Default = 1,
	Min = 0,
	Max = 5,
	Rounding = 0,
	Callback = function(value)
		KllSpeed = value
		applySliderColor("KllSpeedSlider", getSpeedColor(value))
	end,
})

PlayersGroupBox:AddSlider("KllDistanceSlider", {
	Text = "Kll Distance",
	Default = 2000,
	Min = 100,
	Max = 2000,
	Rounding = 0,
	Callback = function(value)
		KllDistance = value
		applySliderColor("KllDistanceSlider", getDistanceColor(value))
	end,
})

local DropdownGroupBox = Tabs.Main:AddRightGroupbox("Dropdowns")

local RaidsGroupBox = Tabs.Raids:AddLeftGroupbox("Titan Raids")

local AutoRaidEnabled = false
local PriorityExplosionAmount = 10

RaidsGroupBox:AddToggle("AutoRaid", {
	Text = "Auto Raid",
	Default = false,

	Callback = function(Value)
		AutoRaidEnabled = Value

		if Value then
			task.spawn(function()
				local Players = game:GetService("Players")
				local RunService = game:GetService("RunService")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")

				local player = Players.LocalPlayer

				local block = Instance.new("Part")
				block.Name = "gg1"
				block.Size = Vector3.new(18, 2, 10)
				block.Anchored = true
				block.CanCollide = false
				block.Transparency = 1
				block.Parent = workspace

				local SPEED = 500
				local HEIGHT = 300
				local ATTACK_DISTANCE = 20000
				local MAX_TARGETS = 10

				local currentTitan = nil
				local currentTargets = {}

				local CURRENT_MODE = "Female_Titan"

				local GET = ReplicatedStorage.Assets.Remotes.GET
				local POST = ReplicatedStorage.Assets.Remotes.POST

				local skipGui = player.PlayerGui:WaitForChild("Interface"):WaitForChild("Skip")

				local function IsPaused()
					return skipGui.Visible == true
				end

				local function getChar()
					return player.Character or player.CharacterAdded:Wait()
				end

				local function getPriorityBlock()
					local priority = workspace:FindFirstChild("511511")
					if priority and priority:IsA("BasePart") then
						return priority
					end
					return nil
				end

				local function getTitanData(titan)
					local humanoid = titan:FindFirstChild("Humanoid")
					local nape = titan:FindFirstChild("Hitboxes")
						and titan.Hitboxes:FindFirstChild("Hit")
						and titan.Hitboxes.Hit:FindFirstChild("Nape")
					if humanoid and humanoid.Health > 0 and nape then
						return humanoid, nape
					end
					return nil, nil
				end

				local function isTitanAlive(name)
					local titansFolder = workspace:FindFirstChild("Titans")
					if not titansFolder then return false end
					local titan = titansFolder:FindFirstChild(name)
					if not titan then return false end
					local humanoid = titan:FindFirstChild("Humanoid")
					return humanoid and humanoid.Health > 0
				end

				local function getClosestTargets()
					local targets = {}
					local titansFolder = workspace:WaitForChild("Titans")

					local character = getChar()
					local root = character:FindFirstChild("HumanoidRootPart")
					if not root then return targets end

					local priorityBlock = getPriorityBlock()
					if priorityBlock then
						table.insert(targets, {
							Titan = priorityBlock,
							Nape = priorityBlock,
							Distance = 0,
							IsBlock = true
						})
						return targets
					end

					if CURRENT_MODE == "Armored_Titan" then
						if isTitanAlive("Female_Titan") or isTitanAlive("Attack_Titan") then
							for _, titan in ipairs(titansFolder:GetChildren()) do
								local name = titan.Name
								if name ~= "Female_Titan" and name ~= "Attack_Titan" and name ~= "Armored_Titan" then
									local humanoid, nape = getTitanData(titan)
									if humanoid and nape then
										local distance = (root.Position - nape.Position).Magnitude
										if distance <= ATTACK_DISTANCE then
											table.insert(targets, { Titan = titan, Nape = nape, Distance = distance })
										end
									end
								end
							end
							table.sort(targets, function(a, b) return a.Distance < b.Distance end)
							local selected = {}
							for i = 1, math.min(MAX_TARGETS, #targets) do
								table.insert(selected, targets[i])
							end
							return selected
						end
					end

					if CURRENT_MODE == "Female_Titan" or CURRENT_MODE == "Attack_Titan" then
						if isTitanAlive(CURRENT_MODE) then
							local titan = titansFolder:FindFirstChild(CURRENT_MODE)
							local humanoid, nape = getTitanData(titan)
							if humanoid and nape then
								return {{ Titan = titan, Nape = nape, Distance = 0, IsPriorityTitan = true }}
							end
						end

						for _, titan in ipairs(titansFolder:GetChildren()) do
							if titan.Name ~= CURRENT_MODE then
								local humanoid, nape = getTitanData(titan)
								if humanoid and nape then
									local distance = (root.Position - nape.Position).Magnitude
									if distance <= ATTACK_DISTANCE then
										table.insert(targets, { Titan = titan, Nape = nape, Distance = distance })
									end
								end
							end
						end
						table.sort(targets, function(a, b) return a.Distance < b.Distance end)
						local selected = {}
						for i = 1, math.min(MAX_TARGETS, #targets) do
							table.insert(selected, targets[i])
						end
						return selected
					end

					if CURRENT_MODE == "Armored_Titan" then
						if isTitanAlive("Armored_Titan") then
							local titan = titansFolder:FindFirstChild("Armored_Titan")
							local humanoid, nape = getTitanData(titan)
							if humanoid and nape then
								return {{ Titan = titan, Nape = nape, Distance = 0, IsPriorityTitan = true }}
							end
						end
					end

					return targets
				end

				local heartbeatConnection
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if not AutoRaidEnabled then
						heartbeatConnection:Disconnect()
						block:Destroy()
						return
					end

					if IsPaused() then return end

					local char = getChar()
					local root = char:FindFirstChild("HumanoidRootPart")
					if not root then return end

					currentTargets = getClosestTargets()

					if #currentTargets > 0 then
						currentTitan = currentTargets[1].Titan
					else
						currentTitan = nil
						return
					end

					if not currentTitan then return end

					local targetPosition

					if currentTitan:IsA("BasePart") then
						targetPosition = currentTitan.Position
					else
						local titanRoot = currentTitan:FindFirstChild("HumanoidRootPart")
							or currentTitan:FindFirstChild("Head")
							or currentTitan.PrimaryPart
						if not titanRoot then return end
						targetPosition = titanRoot.Position
					end

					local targetPoint = Vector3.new(
						targetPosition.X,
						targetPosition.Y + HEIGHT,
						targetPosition.Z
					)

					local direction = targetPoint - block.Position
					local distance = direction.Magnitude

					if distance > 1 then
						local move = math.min(SPEED * dt, distance)
						block.Position = block.Position + direction.Unit * move
					end

					block.Position = Vector3.new(
						block.Position.X,
						targetPoint.Y,
						block.Position.Z
					)

					root.AssemblyLinearVelocity = Vector3.zero
					root.CFrame = CFrame.new(block.Position)
					root.AssemblyAngularVelocity = Vector3.zero
				end)

				local function attackTargets()
					if IsPaused() then return end

					local priorityBlock = getPriorityBlock()
					if priorityBlock then
						for i = 1, PriorityExplosionAmount do
							if IsPaused() then return end
							POST:FireServer("Spears", "S_Explode", priorityBlock.Position, 1.8282463550568)
						end
						GET:InvokeServer("Spears", "S_Fire", "1")
						return
					end

					for _, data in ipairs(currentTargets) do
						if IsPaused() then return end
						local target = data.Nape
						if target and target.Parent then
							local explosions = data.IsPriorityTitan and 10 or 2
							for i = 1, explosions do
								if IsPaused() then return end
								POST:FireServer("Spears", "S_Explode", target.Position, 1.8282463550568)
							end
						end
					end

					if IsPaused() then return end
					GET:InvokeServer("Spears", "S_Fire", "1")
				end

				while AutoRaidEnabled do
					if not IsPaused() then
						currentTargets = getClosestTargets()
						if #currentTargets > 0 then
							attackTargets()
						end
					else
						task.wait(0.1)
					end
					task.wait()
				end

				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end

				if block then
					block:Destroy()
				end
			end)
		end
	end,
})

RaidsGroupBox:AddSlider("PriorityExplosionSlider", {
	Text = "Priority Explosions",
	Default = 10,
	Min = 5,
	Max = 100,
	Rounding = 0,
	Callback = function(Value)
		PriorityExplosionAmount = Value
	end,
})

local AutoOpenChestEnabled = false

RaidsGroupBox:AddToggle("AutoOpenChest", {
	Text = "Auto Open Chest",
	Default = false,

	Callback = function(Value)
		AutoOpenChestEnabled = Value

		if Value then
			task.spawn(function()
				local GuiService = game:GetService("GuiService")
				local VirtualInputManager = game:GetService("VirtualInputManager")
				local Player = game:GetService("Players").LocalPlayer
				local PlayerGui = Player:WaitForChild("PlayerGui")

				local Interface = PlayerGui:WaitForChild("Interface")
				local Chests = Interface:WaitForChild("Chests")

				local function clickButton(button)
					GuiService.SelectedObject = button
					task.wait(0.5)
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
				end

				local function waitForColor(button, targetColor)
					while AutoOpenChestEnabled do
						local color = button.BackgroundColor3

						if math.floor(color.R * 255) == targetColor.R and
							math.floor(color.G * 255) == targetColor.G and
							math.floor(color.B * 255) == targetColor.B then
							break
						end

						for i = 1, 5 do
							if not AutoOpenChestEnabled then
								return
							end

							clickButton(button)
							task.wait(0.3)
						end

						task.wait(3)
					end
				end

				local function runCode()
					local Premium = Chests:WaitForChild("Premium")
					local Free = Chests:WaitForChild("Free")
					local Finish = Chests:WaitForChild("Finish")

					local targetColor = {R = 25, G = 25, B = 25}

					task.wait(2)

					clickButton(Premium)
					task.wait(3)
					waitForColor(Premium, targetColor)

					task.wait(0.5)

					clickButton(Free)
					task.wait(3)
					waitForColor(Free, targetColor)

					task.wait(0.5)

					if AutoOpenChestEnabled then
						clickButton(Finish)
					end
				end

				if Chests.Visible then
					runCode()
				else
					local connection

					connection = Chests:GetPropertyChangedSignal("Visible"):Connect(function()
						if Chests.Visible and AutoOpenChestEnabled then
							connection:Disconnect()
							runCode()
						end
					end)
				end
			end)
		end
	end,
})

local AutoSkipEnabled = false

RaidsGroupBox:AddToggle("AutoSkip", {
	Text = "Auto Skip",
	Default = false,

	Callback = function(Value)
		AutoSkipEnabled = Value

		if Value then
			task.spawn(function()
				local GuiService = game:GetService("GuiService")
				local VirtualInputManager = game:GetService("VirtualInputManager")
				local Player = game:GetService("Players").LocalPlayer
				local PlayerGui = Player:WaitForChild("PlayerGui")

				local Interface = PlayerGui:WaitForChild("Interface")
				local Skip = Interface:WaitForChild("Skip")
				local Interact = Skip:WaitForChild("Interact")

				local function clickButton(button)
					GuiService.SelectedObject = button
					task.wait(0.5)
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
				end

				Skip:GetPropertyChangedSignal("Visible"):Connect(function()
					if Skip.Visible and AutoSkipEnabled then
						task.wait(3)

						if AutoSkipEnabled then
							clickButton(Interact)
						end
					end
				end)

				if Skip.Visible and AutoSkipEnabled then
					task.wait(3)

					if AutoSkipEnabled then
						clickButton(Interact)
					end
				end
			end)
		end
	end,
})

local AutoBuyEnabled = false

DropdownGroupBox:AddDropdown("AutoBuyDropdown", {
	Values = { "Max Horses", "Regen", "Gas Refill", "Upgrade" },

	Multi = true,
	Default = {},

	Text = "Auto Buy",

	Callback = function(Value)
		local hasSelection = false
		for _, v in pairs(Value) do
			if v then hasSelection = true break end
		end

		if hasSelection and not AutoBuyEnabled then
			AutoBuyEnabled = true

			task.spawn(function()
				local Event = game:GetService("ReplicatedStorage").Assets.Remotes.GET

				while AutoBuyEnabled do
					local Selected = Options.AutoBuyDropdown.Value

					local anySelected = false
					for _, v in pairs(Selected) do
						if v then anySelected = true break end
					end

					if not anySelected then
						AutoBuyEnabled = false
						break
					end

					if Selected["Max Horses"] then
						Event:InvokeServer("Waves", "Upgrade", { "Max" })
						task.wait(1)
					end

					if Selected["Regen"] then
						Event:InvokeServer("Waves", "Upgrade", { "Regen" })
						task.wait(1)
					end

					if Selected["Gas Refill"] then
						Event:InvokeServer("Waves", "Upgrade", { "Refills" })
						task.wait(1)
					end

					if Selected["Upgrade"] then
						Event:InvokeServer(
							"Equipment",
							"Upgrade",
							{
								"Blade_Durability",
								"ODM_Damage",
								"ODM_Gas",
								"ODM_Range",
								"ODM_Control",
								"Crit_Chance",
								"Crit_Damage",
								"ODM_Speed"
							}
						)
						task.wait(1)
					end

					task.wait()
				end
			end)
		elseif not hasSelection then
			AutoBuyEnabled = false
		end
	end,
})





Library:OnUnload(function()
	print("Unloaded!")
end)

-- Ban Status Notification
task.spawn(function()
	local player = game:GetService("Players").LocalPlayer

	local function checkAndNotify()
		local isBlacklisted = player:GetAttribute("Blacklisted")
		local isExploiter = player:GetAttribute("Exploiter")

		if isBlacklisted or isExploiter then
			Library:Notify({
				Title = "Banned",
				Content = "Shadow ban detected",
				Duration = 5,
			})
		else
			Library:Notify({
				Title = "Not Banned",
				Content = "Account is clean",
				Duration = 5,
			})
		end
	end

	player:GetAttributeChangedSignal("Blacklisted"):Connect(checkAndNotify)
	player:GetAttributeChangedSignal("Exploiter"):Connect(checkAndNotify)

	checkAndNotify()
end)



 

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddSlider("UICornerSlider", {
	Text = "Corner Radius",
	Default = Library.CornerRadius,
	Min = 0,
	Max = 20,
	Rounding = 0,
	Callback = function(value)
		Window:SetCornerRadius(value)
	end
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddToggle("AutoHideUI", {
	Text = "Auto Hide UI",
	Default = false,
	Callback = function(Value)
		if Value then
			Window:Toggle(false)
		end
	end,
})

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
