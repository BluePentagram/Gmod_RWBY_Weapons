

local steamidverify = {
"STEAM_0:1:32764843", -- Blue
"STEAM_0:1:32764843", -- Santa
"STEAM_0:1:104608249", -- Jezz
"STEAM_0:0:73429079", -- Divine 
}
if SERVER then
 	
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel( "models/Items/ammocrate_smg1.mdl" )
		self:SetBodygroup( 1, 1 ) 
		
		self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
		self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
		self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
		
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
		
		self.animationdoing = false
		self.animationstart = false
		self.animationsecendstage = false
		
		self.animationtime = 0
		self:SetSequence( 1 )
		ShouldRemove()
	end
	

	function ENT:Use( activator, caller )

	end
 
	function ENT:AcceptInput(ply, caller)
		if caller:IsPlayer() && !self.animationdoing && !self.animationstart then
			if caller:IsValid() then
				DustGive = math.random(1,30) 
				caller:GiveAmmo( DustGive, "rwby_dust", false )
			end
			self.animationstart = true
			ShouldRemove()
		end
	end
	
	function ENT:Think()
		self:NextThink(CurTime());
		if self.animationstart then
			self.animationstart = false
			self.animationdoing = true
			self:ResetSequence( 1 ) -- Open
			self:SetPlaybackRate(1)
			local AnimationTime = self:SequenceDuration()
			self.animationtime = CurTime() + AnimationTime
		end
		if self.animationdoing && CurTime() >= self.animationtime then
			if !self.animationsecendstage then
				self.animationsecendstage = true
				self:ResetSequence( 2 ) -- Close
				self:SetPlaybackRate(1)
				local AnimationTime = self:SequenceDuration()
				self.animationtime = CurTime() + AnimationTime
			else
				self.animationsecendstage = false
				self.animationdoing = false
			end
		end
		return true; 
	end

	function ShouldRemove()
	local remove = true
		for k,v in pairs( player.GetAll() ) do
			if table.HasValue(steamidverify, v:SteamID()) then
				remove = false
				return false
			end
			if remove == true then
				self:Remove()
			end
		end	
	end

	
elseif CLIENT then // This is where the cl_init.lua stuff goes
	function ENT:Draw()
		self:DrawModel()
	end
end
  
ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.PrintName 		= "Dust Ammo Crate"
ENT.Author 			= "Blue-Pentagram"
ENT.Spawnable 		= true
ENT.AutomaticFrameAdvance = true 
ENT.AdminOnly		= false
ENT.Category 		= "RWBY - Test"
