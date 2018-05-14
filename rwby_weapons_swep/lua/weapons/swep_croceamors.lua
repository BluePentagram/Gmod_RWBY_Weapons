/*--------------
   End of SCK
--------------*/

if SERVER then // init.

	AddCSLuaFile()
	util.AddNetworkString( "rwby_mors_equip_hide" )
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	
elseif CLIENT then // cl_init

	-- include()
	SWEP.PrintName = "Crocea Mors"
	SWEP.Slot = 0
	SWEP.SlotPos = 20
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = false
	RedColor = Color(201,12,20,255)

	net.Receive("rwby_mors_equip_hide", function()
		LocalPlayer():GetViewModel():SetColor(Color(0,0,0,1))
		LocalPlayer():GetViewModel():SetMaterial("models/effects/vol_light001") 
	end)
	
	function SWEP:DrawHUD()
		if !self.Owner:Alive() or self.Owner:InVehicle() then return end
			local ply = LocalPlayer()
			local t = {}
			t.start = ply:GetShootPos()
			t.endpos = t.start + ply:GetAimVector() * 90000
			t.filter = ply
			local tr = util.TraceLine(t)
			local pos = tr.HitPos:ToScreen()
			surface.SetDrawColor(25, 25, 25,255)
			surface.DrawLine(pos.x - 5, pos.y, pos.x - 8, pos.y)
			surface.DrawLine(pos.x + 5, pos.y, pos.x + 8, pos.y)
			surface.DrawLine(pos.x, pos.y - 5, pos.x, pos.y - 8)
			surface.DrawLine(pos.x, pos.y + 5, pos.x, pos.y + 8)
		end
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetTexture( surface.GetTextureID("vgui/entities/crescentrose_weapon_select")  )
		local fsin = 0
		if ( self.BounceWeaponIcon == true ) then
			fsin = math.sin( CurTime() * 10 ) * 5
		end
		y = y + 10
		x = x + 10
		wide = wide - 20
		surface.DrawTexturedRect( x + ( fsin ), y - ( fsin ),	wide-fsin*2 , ( wide / 2 ) + ( fsin ) )
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end

SWEP.HoldType = "melee"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
SWEP.UseHands = true

SWEP.VElements = {
	["Crocea"] = { type = "Model", model = "models/jazzmcfly/rwby/jaune/jaune_sword.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, -1.558, 0.518), angle = Angle(-90, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Mors"] = { type = "Model", model = "models/jazzmcfly/rwby/jaune/jaune_shield.mdl", bone = "ValveBiped.Bip01_L_UpperArm", rel = "", pos = Vector(-3.636, 0, -1.558), angle = Angle(0, -90, -38), size = Vector(0.3, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["Crocea"] = { type = "Model", model = "models/jazzmcfly/rwby/jaune/jaune_sword.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 4.5, -1.558), angle = Angle(-90, 0, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Mors"] = { type = "Model", model = "models/jazzmcfly/rwby/jaune/jaune_shield.mdl", bone = "ValveBiped.Bip01_L_UpperArm", rel = "", pos = Vector(27.5, 6.752, 0.4), angle = Angle(80, 0, 0), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
-------------------------------------------

SWEP.Author = "Blue-Pentagram"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Category = "RWBY Weapons"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Base = "swep_rwby_sck_base"
SWEP.Block = false
SWEP.OldWalkSpeed = 0
SWEP.OldRunSpeed = 0
DEFINE_BASECLASS( SWEP.Base )

SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 40
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Reload()

end
 
function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
	if not IsValid(self.Owner) then return end
	if self.Owner.Block then return end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound( Sound( "WeaponFrag.Throw" ) )
	
	if !self.Owner.LagCompensation then -- for some reason not always true
		self.Owner:LagCompensation(true)
	end

	local spos = self.Owner:GetShootPos()
	local sdest = spos + (self.Owner:GetAimVector() * 80)
	
	local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
	local hitEnt = tr_main.Entity
	

	if IsValid(hitEnt) or tr_main.HitWorld then
		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
		if not (CLIENT and (not IsFirstTimePredicted())) then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetSurfaceProp(tr_main.SurfaceProps)
			edata:SetHitBox(tr_main.HitBox)
			--edata:SetDamageType(DMG_CLUB)
			edata:SetEntity(hitEnt)
			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" or hitEnt:IsNPC() then
				util.Effect("BloodImpact", edata)
				self.Owner:LagCompensation(false)
				self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=self.Primary.Damage})
			else
				util.Effect("Impact", edata)
			end
		end
	else
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	end

	self.Owner:LagCompensation(false)
	local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
	self:SetNextPrimaryFire(CurTime() + AnimationTime)
end

function SWEP:SecondaryAttack()
		-- if !self.Block then 
			-- self.Block = true 
			-- print("Blocking Now")
		-- end
end

function SWEP:Think()
	local ViewMors = self.VElements["Mors"]
	if !self.Owner:KeyDown( IN_ATTACK2 ) then
		if self.Owner.Block then
			self.Owner.Block = false
			ResetBones(self.Owner)

			self.Owner:SetWalkSpeed(self.Owner.OldWalkSpeed) 
			self.Owner:SetRunSpeed(self.Owner.OldRunSpeed) 
		end
		if ViewMors.angle.z >= -38 then
			ViewMors.angle.z = ViewMors.angle.z - 2
		end
	else
		if !self.Owner.Block then
			self.Owner.Block = true

			self.Owner.OldWalkSpeed = self.Owner:GetWalkSpeed()
			self.Owner.OldRunSpeed = self.Owner:GetRunSpeed()

			self.Owner:SetWalkSpeed(self.Owner:GetWalkSpeed() * 0.4 ) 
			self.Owner:SetRunSpeed(self.Owner:GetRunSpeed() * 0.2 ) 
			SetUpBones(self.Owner)
		end
		if ViewMors.angle.z <= 22 then
			ViewMors.angle.z = ViewMors.angle.z + 2
		end
	end
end

function SWEP:AdjustMouseSensitivity()

end

function SWEP:Deploy()
	HideVeiwModel(self.Owner)
	return true
end

function SWEP:Equip( ply )
	timer.Simple(0.1,function()
		net.Start("rwby_mors_equip_hide")
		net.Send(ply)
	end)
	return true
end

function SWEP:Holster()
	if !IsValid(self.Owner) then return end
	BaseClass.Holster( self )
	self.Owner:GetViewModel():SetColor(Color(255,255,255,255))
	self.Owner:GetViewModel():SetMaterial("") 
	ResetBones(self.Owner)
	return true
end

function BoneVar(MorsUser)
	BoneOne = MorsUser:LookupBone( "ValveBiped.Bip01_L_UpperArm" ) 
	BoneTwo = MorsUser:LookupBone( "ValveBiped.Bip01_L_Forearm" ) 
end

function SWEP:ContextScreenClick() 
	return false
end

function HideVeiwModel(MorsUser)
	if !IsValid(MorsUser) then return end
	MorsUser:GetViewModel():SetColor(Color(0,0,0,1))
	MorsUser:GetViewModel():SetMaterial("models/effects/vol_light001") 
end

hook.Add( "EntityTakeDamage", "SheildBlocking", function( target , dmginfo )
	if IsValid(target) and ( target:IsPlayer() and target.Block ) then
		if dmginfo:IsFallDamage() then return end
		if dmginfo:IsExplosionDamage() then
			dmginfo:ScaleDamage( 0.6 )
		else
			dmginfo:ScaleDamage( 0.4 )
		end
	end
end )

function SetUpBones(MorsUser)
	if !IsValid(MorsUser) then return end
	BoneVar(MorsUser)
	MorsUser:ManipulateBoneAngles( BoneOne, Angle(0,-25,20) )	--UpperArm
	MorsUser:ManipulateBoneAngles( BoneTwo, Angle(0,0,0) )	--ForeArm
end

function ResetBones(MorsUser)
	if !IsValid(MorsUser) then return end
	BoneVar(MorsUser)
	MorsUser:ManipulateBoneAngles( BoneOne, Angle(0,0,0) )	--UpperArm
	MorsUser:ManipulateBoneAngles( BoneTwo, Angle(0,0,0) )	--ForeArm
end