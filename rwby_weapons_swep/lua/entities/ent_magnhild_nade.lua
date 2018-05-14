

if SERVER then
 	
	AddCSLuaFile()
	
	function ENT:Initialize()
		self:SetModel( "models/props_junk/PopCan01a.mdl" )
		
		self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
		self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
		self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
		timer.Simple(6,function()
			if IsValid(self) then
				local Magnhild_Explosion = ents.Create("env_explosion")
				Magnhild_Explosion:SetPos(self:GetPos())
			
				Magnhild_Explosion:Spawn()
				Magnhild_Explosion:SetKeyValue("iMagnitude", 50)
				Magnhild_Explosion:Fire("Explode", 0, 0)
				Magnhild_Explosion:EmitSound("BaseGrenade.Explode", 100, 100)
				self:Remove()
			end
		end)
	end
	
	function ENT:Use( activator, caller )
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

ENT.PrintName 		= "Magnhild Nade"
ENT.Author 			= "Blue-Pentagram"
ENT.Spawnable 		= false
ENT.AdminOnly		= false
ENT.Category 		= "RWBY"
