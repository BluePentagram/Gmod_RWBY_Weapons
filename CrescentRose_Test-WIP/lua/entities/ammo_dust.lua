

local steamidverify = {
"STEAM_0:1:32764843", -- Blue
"STEAM_0:1:32764843", -- Santa
"STEAM_0:1:104608249", -- Jezz
"STEAM_0:0:73429079", -- Divine 
}
if SERVER then
 	
	AddCSLuaFile()
	
	function ENT:Initialize()
		self:SetModel( "models/Items/BoxSRounds.mdl" )
		
		self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
		self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
		self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
		
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
	
	function ENT:Use( activator, caller )
		caller:GiveAmmo( 10, "rwby_dust" )
		self:Remove()
	end
 
	function ENT:Think()
	end
 
elseif CLIENT then // This is where the cl_init.lua stuff goes
	function ENT:Draw()
		self:DrawModel()
	end
end
  
ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.PrintName 		= "Dust Ammo"
ENT.Author 			= "Blue-Pentagram"
ENT.Spawnable 		= true
ENT.AdminOnly		= false
ENT.Category 		= "RWBY - Test"