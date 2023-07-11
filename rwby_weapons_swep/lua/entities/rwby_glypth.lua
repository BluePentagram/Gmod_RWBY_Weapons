if SERVER then
	AddCSLuaFile()

	function ENT:Use(activator, caller)
	end
elseif CLIENT then
	-- This is where the cl_init.lua stuff goes
	function ENT:Draw()
		local Pos = self:GetPos()
		local Ang = self:GetAngles()
		-- self:DrawModel()
		-- Ang:RotateAroundAxis(Ang:Right(), 90)
		-- Ang:RotateAroundAxis(Ang:Up(), 0)
		-- if(ply:GetPos():Distance(Pos) < 300) then
		local Rotate = CurTime() * 10
		cam.Start3D2D(Pos + Ang:Up() * 1 + -Ang:Right() * 0, Ang, .5)
		tex = surface.GetTextureID("vgui/rwbyicons/Weiss_Glypth")
		surface.SetTexture(tex)
		surface.SetDrawColor(0, 0, 0, 255)
		-- surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(0, 0, self.GlypthSize1, self.GlypthSize1, Rotate)
		cam.End3D2D()
		Ang:RotateAroundAxis(Ang:Right(), 180)
		cam.Start3D2D(Pos + Ang:Up() * 1 + -Ang:Right() * 0, Ang, .5)
		-- local Rotate = -CurTime() * 10
		tex = surface.GetTextureID("vgui/rwbyicons/Weiss_Glypth")
		surface.SetTexture(tex)
		surface.SetDrawColor(0, 0, 0, 255)
		-- surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(0, 0, self.GlypthSize1, self.GlypthSize1, -Rotate)
		cam.End3D2D()
	end
end

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:DrawShadow(false)

	-- self.GlypthSize = 256
	-- self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	-- self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	-- self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	-- local phys = self:GetPhysicsObject()
	-- if (phys:IsValid()) then
	-- phys:Wake()
	-- end
	-- Do 2 timers 1 to Make smaller 
	timer.Simple(50, function()
		if IsValid(self) then
			-- self:Remove() 
			self.GlypthSize2 = 0
		end

		timer.Simple(0.2, function()
			if IsValid(self) and SERVER then
				self:Remove()
			end
		end)
	end)
end

function ENT:Think()
	-- print(self.GlypthSize1.."/"..self.GlypthSize2)
	if SERVER then return end

	if self.GlypthSize1 ~= self.GlypthSize2 then
		-- print("Think Run")
		if self.GlypthSize1 <= self.GlypthSize2 then
			self.GlypthSize1 = self.GlypthSize1 + self.GlypthGrow
		else
			-- self.GlypthSize1 = self.GlypthSize2
			if self.GlypthSize1 >= self.GlypthSize2 then
				self.GlypthSize1 = self.GlypthSize1 + -self.GlypthGrow
			end
		end
		-- if self.GlypthSize1 >= self.GlypthSize2 then
		-- self.GlypthSize1 = self.GlypthSize1 - 20
		-- else
		-- self.GlypthSize1 = self.GlypthSize2
		-- if SERVER then self:Remove() end
		-- end
		-- print(self.GlypthSize1.."/"..self.GlypthSize2)
	end
	-- if SERVER then
	-- if (self.GlypthSize1 == self.GlypthSize2 and self.ToRemove) then
	-- self:Remove()
	-- end
	-- end
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Glypth"
ENT.Author = "Blue-Pentagram"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "RWBY"
ENT.GlypthSize1 = 0
ENT.GlypthSize2 = 512
ENT.GlypthGrow = 16