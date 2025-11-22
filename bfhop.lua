local Regions = {
	[1] = "Singapore",
  }
function getRandomRegion()
	t = math.random(1, 6)
return Regions[t]
end
local ServerFunc = {}
function ServerFunc.Hop(self)
	pcall(function()
		task.delay(20,function()
			game:Shutdown()
		end)
		local ticklon = tick()
		repeat
			task.wait()
		until tick() - ticklon >= 1
		local function Hop()
			for r = 1, math.huge do
				game.Players.LocalPlayer.PlayerGui.ServerBrowser.Frame.Filters.SearchRegion.TextBox.Text = getRandomRegion()
				local bP = game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer(r)
				for k, v in pairs(bP) do
					if k ~= game.JobId and v["Count"] < 10 then
						game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", k)
					end
				end
			end
			return false
		end
		if not LoadedHop then
			local function bQ(v)
				if v.Name == "ErrorPrompt" then
					if v.Visible then
						if v.TitleFrame.ErrorTitle.Text == "Teleport Failed" then
							self:Hop()
							v.Visible = false
						end
					end
					v:GetPropertyChangedSignal("Visible"):Connect(function()
						if v.Visible then
							if v.TitleFrame.ErrorTitle.Text == "Teleport Failed" then
								self:Hop()
								v.Visible = false
							end
						end
					end)
				end
			end
			for k, v in pairs(game:GetService("CoreGui").RobloxPromptGui.promptOverlay:GetChildren()) do
				bQ(v)
			end
			game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(bQ)
			LoadedHop = true
		end
		while task.wait(0.1) do
			Hop()
		end
	end)
end

ServerFunc:Hop()
