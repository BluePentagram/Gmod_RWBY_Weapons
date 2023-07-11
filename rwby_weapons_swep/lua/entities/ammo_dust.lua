if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/Items/BoxSRounds.mdl")
		self:PhysicsInit(SOLID_VPHYSICS) -- Make us work with physics,
		self:SetMoveType(MOVETYPE_VPHYSICS) -- after all, gmod is a physics
		self:SetSolid(SOLID_VPHYSICS) -- Toolbox
		local phys = self:GetPhysicsObject()

		if phys:IsValid() then
			phys:Wake()
		end
	end

	function ENT:Use(activator, caller)
		caller:GiveAmmo(self.AMMOGIVE, "rwby_dust")
		caller:GiveAmmo(self.AMMOGIVE, "rwby_dust_fire", false)
		caller:GiveAmmo(self.AMMOGIVE, "rwby_dust_electric", false)
		caller:GiveAmmo(self.AMMOGIVE, "rwby_dust_gravity", false)
		self:Remove()
	end

	function ENT:Think()
	end
elseif CLIENT then
	-- This is where the cl_init.lua stuff goes
	surface.CreateFont("DustFont", {
		font = "Default",
		extended = false,
		size = 40,
		weight = 400,
		antialias = true,
	})

	function ENT:Draw()
		local ply = LocalPlayer()
		local Pos = self:GetPos()
		local Ang = self:GetAngles()
		self:DrawModel()
		-- Ang:RotateAroundAxis(Ang:Right(), 90)
		Ang:RotateAroundAxis(Ang:Up(), 90)

		if ply:GetPos():Distance(Pos) < 300 then
			cam.Start3D2D(Pos + Ang:Up() * 11.6 + -Ang:Right() * 2.5, Ang, 0.10)
			draw.DrawText("Dust", "DustFont", 0, 0, Color(200, 25, 25, 255), TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	end
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Dust Ammo"
ENT.Author = "Blue-Pentagram"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "RWBY"
ENT.AMMOGIVE = 20