--==[ NeoAura - Server Version ]==--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function createAura(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Cria 8 partes neon ao redor do jogador
    local parts = {}
    for i = 1, 8 do
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Shape = Enum.PartType.Ball
        part.Material = Enum.Material.Neon
        part.Size = Vector3.new(0.5, 0.5, 0.5)
        part.Color = Color3.fromHSV(i / 8, 1, 1)
        part.Name = "NeoAuraRing"
        part.Parent = workspace
        table.insert(parts, part)
    end

    local angle = 0
    local mode = "Ring"
    local speed = 2

    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if not player.Parent then
            for _, p in pairs(parts) do p:Destroy() end
            connection:Disconnect()
            return
        end

        angle += speed * dt

        for i, part in ipairs(parts) do
            local theta = math.rad((i - 1) * 360 / #parts + angle * 360)
            local offset
            if mode == "Ring" then
                offset = Vector3.new(math.cos(theta), 0, math.sin(theta)) * 4
            else
                offset = Vector3.new(0, math.cos(theta) * 3, math.sin(theta) * 3)
            end
            part.Position = hrp.Position + offset
        end
    end)

    -- Remove os anéis ao morrer
    character:WaitForChild("Humanoid").Died:Connect(function()
        for _, p in ipairs(parts) do
            if p and p.Parent then p:Destroy() end
        end
        connection:Disconnect()
    end)
end

-- Quando o jogador entrar ou respawnar
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        createAura(player)
    end)
end)

-- Garante que todos jogadores atuais também recebam
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        createAura(player)
    else
        player.CharacterAdded:Connect(function()
            wait(1)
            createAura(player)
        end)
    end
end
