if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/Items/ammocrate_smg1.mdl")
		self:SetBodygroup(1, 1)
		self:PhysicsInit(SOLID_VPHYSICS) -- Make us work with physics,
		self:SetMoveType(MOVETYPE_VPHYSICS) -- after all, gmod is a physics
		self:SetSolid(SOLID_VPHYSICS) -- Toolbox
		local phys = self:GetPhysicsObject()

		if phys:IsValid() then
			phys:Wake()
		end

		self.animationdoing = false
		self.animationstart = false
		self.animationsecendstage = false
		self.animationtime = 0
		self:SetSequence(1)
	end

	function ENT:Use(activator, caller)
	end

	local ammoTypes = {"rwby_dust", "rwby_dust_fire", "rwby_dust_electric", "rwby_dust_gravity"}

	function ENT:AcceptInput(ply, caller)
		if caller:IsValid() and caller:IsPlayer() and not self.animationdoing and not self.animationstart then
			local ran1, ran2 = 1, 50
			local ammoAmount = math.random(ran1, ran2)

			for i = 1, 4 do
				caller:GiveAmmo(ammoAmount, ammoTypes[i], false)
				ammoAmount = math.random(ran1, ran2)
			end

			self.animationstart = true
		end
	end

	function ENT:Think()
		self:NextThink(CurTime())

		if self.animationstart then
			self.animationstart = false
			self.animationdoing = true
			self:ResetSequence(1) -- Open
			self:SetPlaybackRate(1)
			local AnimationTime = self:SequenceDuration()
			self.animationtime = CurTime() + AnimationTime
		end

		if self.animationdoing and CurTime() >= self.animationtime then
			if not self.animationsecendstage then
				self.animationsecendstage = true
				self:ResetSequence(2) -- Close
				self:SetPlaybackRate(1)
				local AnimationTime = self:SequenceDuration()
				self.animationtime = CurTime() + AnimationTime
			else
				self.animationsecendstage = false
				self.animationdoing = false
			end
		end

		return true
	end
elseif CLIENT then
	-- This is where the cl_init.lua stuff goes
	surface.CreateFont("DustFont_Crate", {
		font = "Default",
		extended = false,
		size = 120,
		weight = 400,
		antialias = true,
	})


	local redColor = Color(200, 25, 25, 255)
	function ENT:Draw()
		local Pos = self:GetPos()
		local Ang = self:GetAngles()
		self:DrawModel()
		Ang:RotateAroundAxis(Ang:Right(), 90)
		Ang:RotateAroundAxis(Ang:Forward(), 180)
		Ang:RotateAroundAxis(Ang:Up(), -90)
		-- if(ply:GetPos():Distance(Pos) < 300) then
		cam.Start3D2D(Pos + Ang:Up() * 16 + -Ang:Right() * 15, Ang, 0.10)
		draw.DrawText("Dust", "DustFont_Crate", 0, 0, redColor, TEXT_ALIGN_CENTER)
		local texture = surface.GetTextureID("vgui/rwbyicons/dust_fire")

		for i = 1, 3 do
			if i == 1 then
				texture = surface.GetTextureID("vgui/rwbyicons/dust_fire")
			elseif i == 2 then
				texture = surface.GetTextureID("vgui/rwbyicons/dust_electric")
			else
				texture = surface.GetTextureID("vgui/rwbyicons/dust_gravity")
			end

			surface.SetTexture(texture)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawTexturedRect(-300 + (i * 120), 120, 128, 128)
		end

		cam.End3D2D()
		-- end
	end
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Dust Ammo Crate"
ENT.Author = "Blue-Pentagram"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true
ENT.AdminOnly = false
ENT.Category = "RWBY"