/*--------------
   End of SCK
--------------*/

if SERVER then // init.

	util.AddNetworkString( "MagnhildSwitch" )
	AddCSLuaFile()
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
elseif CLIENT then // cl_init

	-- include()
	SWEP.PrintName = "Magnhild"
	SWEP.Slot = 2
	SWEP.SlotPos = 20
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = false
	
	net.Receive("MagnhildSwitch", function()
		local MagnhildWeapon = net.ReadEntity()
		local MagnhildHold = net.ReadString()
		MagnhildWeapon:SetWeaponHoldType(MagnhildHold)
		if MagnhildHold == "melee2" then
			MagnhildWeapon.WElements["Magnhild_Melee"].color.a = 255 -- To Gun
			MagnhildWeapon.WElements["Magnhild_Grande"].color.a = 0 -- To Gun
			else
			MagnhildWeapon.WElements["Magnhild_Melee"].color.a = 0 -- To Gun
			MagnhildWeapon.WElements["Magnhild_Grande"].color.a = 255 -- To Gun
		end
	end)	
	
end


SWEP.HoldType = "melee2"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}

SWEP.WElements = {
	["Magnhild_Grande"] = { type = "Model", model = "models/jazzmcfly/rwby/nora/nora_magnhild_grenade_launcher.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(16.5, 0, 3.635), angle = Angle(160.13, 0, 0), size = Vector(0.699, 0.699, 0.699), color = Color(255, 255, 255, 0), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Magnhild_Melee"] = { type = "Model", model = "models/jazzmcfly/rwby/nora/nora_magnhild_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.4, 1.557, 20.26), angle = Angle(-178.831, 180, 0), size = Vector(0.699, 0.699, 0.699), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
-------------------------------------------

SWEP.Author = "Blue-Pentagram"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Category = "RWBY Weapons"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Gun = false
SWEP.First = true
SWEP.Hold = "melee2"
SWEP.Base = "swep_rwby_sck_base"
DEFINE_BASECLASS( SWEP.Base )

SWEP.Primary.ClipSize = 6
SWEP.Primary.Damage = 300
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "rwby_dust"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = 50
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"



function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end

	if self.Owner:KeyDown(IN_USE) then
		if not IsFirstTimePredicted() then return end
			-- if SERVER then return end
			self:ChangeMode()
			self.ReloadingTime = CurTime() + 1
		return
	else
		if !self.Gun then
			self.ReloadingTime = CurTime() + 1
		else
			self:DefaultReload( ACT_VM_RELOAD )
			self:SendWeaponAnim(  ACT_VM_RELOAD  )

			local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
			self.ReloadingTime = CurTime() + AnimationTime
			self:SetNextPrimaryFire(CurTime() + AnimationTime)
			self:SetNextSecondaryFire(CurTime() + AnimationTime)
		end
	end	
	-- end
end
 
function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if not IsValid(self.Owner) then return end
	if !self.Gun then
		if self.Owner.LagCompensation then -- for some reason not always true
			self.Owner:LagCompensation(true)
		end	
		if self.Owner:KeyDown(IN_ATTACK2) then
			if( self:Clip1() > 0 ) then
				self:TakePrimaryAmmo( 1 )
				self.Owner:SetVelocity( Vector( 0, 0, 750 ) )
			end
		else
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self:EmitSound( Sound( "WeaponFrag.Throw" ) )
			

	
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
						self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=self.Secondary.Damage})
					else
						util.Effect("Impact", edata)
					end
				end
			else
				self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
			end
		end	
	self.Owner:LagCompensation(false)
	else
		if( self:Clip1() > 0 ) then
			self:EmitSound("weapons/sg552/sg552-1.wav")
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			if SERVER then self:ShootBullet( self.Primary.Damage, 1, 0) end
			self:TakePrimaryAmmo( 1 )
			self.Owner:ViewPunch( Angle( -2, 0, 0 ) )
	    
		-- if ( SERVER and !self.Owner:IsOnGround()) then
			-- if self.Primary.Ammo == "rwby_dust_gravity" then
				-- self.Owner:SetVelocity( -self.Owner:GetAimVector() * 700 )
			-- else
				-- self.Owner:SetVelocity( -self.Owner:GetAimVector() * 500 )
			-- end
		-- end
		else
			self:EmitSound("weapons/sg552/sg552_boltpull.wav")
		end
	end
	self:SetNextPrimaryFire( CurTime() + 0.9 )
end

function SWEP:TakePrimaryAmmo( num )
	if ( self:Clip1() <= 0 ) then 
 		if ( self:Ammo1() <= 0 ) then return end
 		self.Owner:RemoveAmmo( num, self:GetPrimaryAmmoType() )
 	return end
 	self:SetClip1( self:Clip1() - num )	
 end

function SWEP:SecondaryAttack()
end

function SWEP:ChangeMode()
	if self.Gun then
		self.Gun = false 
		self.Hold = "melee2"
	else
		self.Gun = true 
		self.Hold = "crossbow"
	end	
	if CLIENT then return end
	self:SetWeaponHoldType( self.Hold )
	net.Start("MagnhildSwitch")
		net.WriteEntity(self)
		net.WriteString(self.Hold)
	net.Broadcast()
end

function SWEP:ShootBullet( damage, num_bullets, aimcone )
	
	local ent = ents.Create( "ent_magnhild_nade" )

	if ( !IsValid( ent ) ) then return end

	-- ent:SetModel( "models/props_junk/PopCan01a.mdl" )

	ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if ( !IsValid( phys ) ) then ent:Remove() return end

	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 1000
	velocity = velocity + ( VectorRand() * 10 ) -- a random element
	phys:ApplyForceCenter( velocity )
end

function SWEP:ShootEffects()
	if self.Gun then
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:Equip( ply )
	if !gamemode.Get("darkrp") then 
		ply:GiveAmmo( 50, "rwby_dust" )
		ply:GiveAmmo( 50, "rwby_dust_fire" )
		ply:GiveAmmo( 50, "rwby_dust_electric" )
		ply:GiveAmmo( 50, "rwby_dust_gravity" )
	end
end

function SWEP:Holster()
	BaseClass.Holster( self )
	return true
end

function SWEP:ContextScreenClick() 
	return false
end