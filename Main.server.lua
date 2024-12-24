-- Nik/Johnny_D3pp
-- 0.0.1 - December 2024

--[[
	Includes useful tools for builders
--]]

local actor = script.Parent
local folder = actor.Parent
local camera = workspace.CurrentCamera :: Camera?
	
local main = {
	Version = "0.0.2",
}

local function createHighlight(part : BasePart, color : Color3?, text : string?)
	local highlight = part:Clone()
	for _,v in highlight:GetChildren() do
		if v:IsA("SpecialMesh") then continue end
		
		v:Destroy()
	end
	
	if highlight:IsA("MeshPart") then highlight.TextureID = "" end
	
	highlight.Anchored = true
	highlight.Color = color or Color3.new(1,1,0)
	highlight.Transparency = 0.75
	highlight.Material = Enum.Material.Neon
	highlight.Size = part.Size + Vector3.new(0.25,0.25,0.25) 
	highlight.CFrame = part.CFrame
	
	local UI = Instance.new("BillboardGui")
	UI.AlwaysOnTop = true
	UI.Size = UDim2.fromOffset(200,50)
	
	local label = Instance.new("TextLabel", UI)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true
	label.TextStrokeTransparency = 1
	label.Size = UDim2.fromScale(1,1)
	label.Text = text or part.Name
	
	UI.Parent = highlight

	return highlight
end

function main:ShowUnanchored(state : boolean)
	if state then
		local folder = camera:FindFirstChild("#HighlightedParts")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "#HighlightedParts"
			folder.Parent = camera
		end
		
		for _,p in workspace:GetDescendants() do
			if p.Name ~= "Terrain" and p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(camera) then
				local h = createHighlight(p, Color3.new(1,1,0), p.Name)
				h:SetAttribute("Type", "Unanchor")
				h.Parent = folder
			end
		end
	else
		if camera:FindFirstChild("#HighlightedParts") then
			for _,c in camera["#HighlightedParts"]:GetChildren() do
				if c:GetAttribute("Type") == "Unanchor" then c:Destroy() end
			end
			
			if #camera["#HighlightedParts"]:GetChildren() == 0 then camera["#HighlightedParts"]:Destroy() end
		end
	end
end

function main:ShowLocked(state : boolean)
	if state then
		local folder = camera:FindFirstChild("#HighlightedParts")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "#HighlightedParts"
			folder.Parent = camera
		end

		for _,p in workspace:GetDescendants() do
			if p.Name ~= "Terrain" and p:IsA("BasePart") and p.Locked and not p:IsDescendantOf(camera) then
				local h = createHighlight(p, Color3.new(1,0,0), p:GetFullName())
				h:SetAttribute("Type", "Lock")
				h.Parent = folder
			end
		end
	else
		if camera:FindFirstChild("#HighlightedParts") then
			for _,c in camera["#HighlightedParts"]:GetChildren() do
				if c:GetAttribute("Type") == "Lock" then c:Destroy() end
			end

			if #camera["#HighlightedParts"]:GetChildren() == 0 then camera["#HighlightedParts"]:Destroy() end
		end
	end
end

function main:Run()
	
	local toolbar = plugin:CreateToolbar("BuilderTools")
	
	local unanchoredButton = toolbar:CreateButton("Unanchored Detector","Highlights all unanchored parts on the map.","rbxassetid://129899967141649")
	local lockedButton = toolbar:CreateButton("Locked Detector","Highlights all locked parts on the map.","rbxassetid://129899967141649")
	local faceButton = toolbar:CreateButton("Remove Double Faces","Removes duplicate face decals on rigs.","rbxassetid://129899967141649")
	
	local buttonOn1 = false
	unanchoredButton.Click:Connect(function()
		buttonOn1 = not buttonOn1
		main:ShowUnanchored(buttonOn1)
	end)
	
	local buttonOn2 = false
	lockedButton.Click:Connect(function()
		buttonOn2 = not buttonOn2
		main:ShowLocked(buttonOn2)
	end)
	
	local buttonOn3 = false
	faceButton.Click:Connect(function()
		if buttonOn3 then return end
		buttonOn3 = true
			
		for _,head in workspace:GetDescendants() do
			if head:IsA("BasePart") and head.Name == "Head" then
				local model = head:FindFirstAncestorWhichIsA("Model")
				local decals = {}

				for _,d in head:GetChildren() do
					if d:IsA("Decal") and d.Name == "face" then
						table.insert(decals, d)
					end
				end
				
				if #decals <= 1 then
					continue
				end

				for i=1,#decals do
					if i == 1 then continue end

					print(`{decals[i].Name} decal has been removed from {model and model.Name or head.Name} with asset ID {decals[i].Texture}.`)
					decals[i]:Destroy()
				end
			end
		end
		
		task.wait(1)
		faceButton:SetActive(false)
		buttonOn3 = false
	end)
end

main:Run()
