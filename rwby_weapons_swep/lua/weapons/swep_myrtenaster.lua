

if SERVER then // init.

	AddCSLuaFile()
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	MyrtCamera		= 100		-- The Actal Distance of the camera
	MyrtCamPos		= MyrtCamera	-- The Actal Distance of the camera
elseif CLIENT then // cl_init

	-- include()
	SWEP.PrintName = "Myrtenaster"
	SWEP.Slot = 0
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = false
	-- Crescent Rose Camera Position Settings Start
	MyrtCamera		= 100		-- The Actal Distance of the camera
	MyrtCamPos		= MyrtCamera	-- The Actal Distance of the camera
	-- Crescent Rose Camera Position Settings End

	function SWEP:DrawHUD()
		local ply = self.Owner
		local x = 20
		local y = ScrH() - 20
		local wep = ply:GetActiveWeapon()

		draw.SimpleText("This is a 'WIP' Weapon of the "..self.PrintName..". Glypth Mode? "..tostring(self.Gun)..". Ammo Type:"..self.Primary.Ammo,"Default",x, y,Color(194,30,86,255))
		-- draw.SimpleText(MyrtCamPos,"Default",x, y - 20,Color(194,30,86,255))
			

		local tex = "nodraw"
		-- tex = surface.GetTextureID("vgui/rwbyicons/dust_fire") 
		
			if self.Primary.Ammo == "rwby_dust_fire" then
				tex = surface.GetTextureID("vgui/rwbyicons/dust_fire") 
			elseif self.Primary.Ammo == "rwby_dust_electric" then
				tex = surface.GetTextureID("vgui/rwbyicons/dust_electric") 
			elseif self.Primary.Ammo == "rwby_dust_gravity" then
				tex = surface.GetTextureID("vgui/rwbyicons/dust_gravity")
			end
			
		if tex != "nodraw" then
			surface.SetTexture(tex)
			surface.SetDrawColor(0,0,0,255)
			surface.DrawTexturedRect(ScrW()-192,ScrH()-176,64,64)
		end

		if !self.Owner:Alive() or self.Owner:InVehicle() then return end
			local ply = LocalPlayer()
			local t = {}
			t.start = ply:GetShootPos()
			t.endpos = t.start + ply:GetAimVector() * 90000
			t.filter = ply
			local tr = util.TraceLine(t)
			local pos = tr.HitPos:ToScreen()
			surface.SetDrawColor(200, 200, 200,255)
			surface.DrawLine(pos.x - 5, pos.y, pos.x - 8, pos.y)
			surface.DrawLine(pos.x + 5, pos.y, pos.x + 8, pos.y)
			surface.DrawLine(pos.x, pos.y - 5, pos.x, pos.y - 8)
			surface.DrawLine(pos.x, pos.y + 5, pos.x, pos.y + 8)
		end

	hook.Add( "CalcView", "MyrtCameroa", function( ply, pos, angles, fov )
		if ( !IsValid( ply ) or !ply:Alive() or ply:InVehicle() or ply:GetViewEntity() != ply ) then return end
		if ( !LocalPlayer().GetActiveWeapon or !IsValid( LocalPlayer():GetActiveWeapon() ) or LocalPlayer():GetActiveWeapon():GetClass() != "swep_myrtenaster" ) then return end
		local trace = util.TraceHull( {
		start = pos,
		endpos = pos - angles:Forward() * MyrtCamPos + angles:Right() * 15,
		filter = { ply:GetActiveWeapon(), ply },
		mins = Vector( -4, -4, -4 ),
		maxs = Vector( 4, 4, 4 ),
		} )
		local traent = trace.Entity
		if ( trace.HitWorld or traent:IsPlayer() or traent:IsNPC() or trace.Hit ) then pos = trace.HitPos else pos = pos - angles:Forward() * MyrtCamPos + angles:Right() * 15  end
	
		return {
			origin = pos,
			angles = angles,
			drawviewer = true
		}
	end )
end


SWEP.HoldType = "normal"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}

SWEP.WElements = {
	["Myrtenaster"] = { type = "Model", model = "models/blueflytrap/rwby/myrtenaster.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(4.675, 0.8, 7), angle = Angle(101.688, -180, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


SWEP.Author = "Blue-Pentagram"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "swep_rwby_sck_base"
SWEP.Category = "RWBY Weapons"
SWEP.Spawnable = true
SWEP.AdminOnly = false
-- SWEP.Hold = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "rwby_dust"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Think()
	self.Owner:NextThink( CurTime() )
	local ply = self.Owner
	-- for i = 0, ply:GetBoneCount() - 1 do
		-- local boneName = ply:GetBoneName(i)
		-- local boneIndex = ply:LookupBone(boneName)
		-- ply:ManipulateBonePosition( boneIndex, Vector(0,0,0) )
		-- ply:ManipulateBoneAngles( boneIndex, Angle(CurTime()*20,CurTime()*50,CurTime()*35) )
	-- end
	return true;
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	local ply = self.Owner
	PlayAnnimation(ply)
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	local ply = self.Owner
	Bone_Reset(ply)
	Speed_Glypth(ply)
end

function SWEP:Deploy()
	local ply = self.Owner
	Bone_Reset(ply)
	return true
end

function SWEP:Holster( wep )
	BoneOne = self.Owner:LookupBone( "ValveBiped.Bip01_L_UpperArm" ) 
	BoneTwo = self.Owner:LookupBone( "ValveBiped.Bip01_L_Forearm" ) 
	--- Bone Positions
	-- self.Owner:ManipulateBonePosition( BoneOne, Vector(0,0,0) ) 
	--- Bone Angles
	self.Owner:ManipulateBoneAngles( BoneOne, Angle(0,0,0) )	--UpperArm
	self.Owner:ManipulateBoneAngles( BoneTwo, Angle(0,0,0) )	--ForeArm
	return true
end

/*
ValveBiped.Bip01_R_Hand
ValveBiped.Bip01_R_Forearm
ValveBiped.Bip01_R_Foot
ValveBiped.Bip01_R_Thigh
ValveBiped.Bip01_R_Calf
ValveBiped.Bip01_R_Shoulder
ValveBiped.Bip01_R_Elbow
*/

function Get_Bones(ply)
	BoneOne = ply:LookupBone( "ValveBiped.Bip01_L_UpperArm" ) 
	BoneTwo = ply:LookupBone( "ValveBiped.Bip01_L_Forearm" ) 
end

function PlayAnnimation(ply)
	Get_Bones(ply)
	ply:ManipulateBoneAngles( BoneOne, Angle(-10,-25,-20) )	--UpperArm
	ply:ManipulateBoneAngles( BoneTwo, Angle(-10,-25,-20) )	--ForeArm
end

function Bone_Reset(ply)
	Get_Bones(ply)
	ply:ManipulateBoneAngles( BoneOne, Angle(-10,-25,-20) )	--UpperArm
	ply:ManipulateBoneAngles( BoneTwo, Angle(-10,-25,-20) )	--ForeArm
end

function Speed_Glypth(ply)
	if CLIENT then return end
	local offset = 0
	local ply_sho = ply:GetShootPos()
	local ply_aim = ply:GetAimVector()
	-- local ply_aim = Vector(ply:GetAimVector().x,ply:GetAimVector().y,1)
	local ply_pos = ply:GetPos()
	for i=1,4 do
		timer.Simple( i*0.08, function()
			local Glypth = ents.Create( "rwby_glypth" )
			if ( !IsValid( Glypth ) ) then return end 
			-- = ply:GetShootPos()
			-- t.endpos = t.start + ply:GetAimVector() * 90000
			
			
			
			-- Glypth:SetPos( Vector(0,0,0) )
			-- Glypth:SetPos( Vector(ply_sho.x + ply_aim.x * offset, ply_sho.y + ply_aim.y * offset, ply_pos.z) )
			Glypth:SetPos( Vector(ply_sho.x + ply_aim.x * offset, ply_sho.y + ply_aim.y * offset, ply_pos.z) )
			print("---------------------")
			print(ply_aim)
			print("---------------------")
			Glypth:Spawn()
			offset = offset + 256
		end)
	end 
end

concommand.Add( "BoneTest", function( ply, cmd, args )
	-- local ply = LocalPlayer()
	print('List of bones (i, name, index, position, angle):')
	for i = 0, ply:GetBoneCount() - 1 do
		local boneName = ply:GetBoneName(i)
		local boneIndex = ply:LookupBone(boneName)
		local bonePos, boneAng = ply:GetBonePosition(boneIndex)
		print(i, boneName, boneIndex, bonePos, boneAng)
	end
end )

concommand.Add( "RWBY_Reset_All_Bones", function( ply, cmd, args )
	local ply = LocalPlayer()
	print("Player's Bone Reset")
	for i = 0, ply:GetBoneCount() - 1 do
		local boneName = ply:GetBoneName(i)
		local boneIndex = ply:LookupBone(boneName)
		ply:ManipulateBonePosition( boneIndex, Vector(0,0,0) )
		ply:ManipulateBoneAngles( boneIndex, Angle(0,0,0) )
	end
end )
