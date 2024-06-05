

-- list.Add( "NPCUsableWeapons", { class = "swep_crescent_rose", title = "Crescent Rose" } )
if SERVER then // init.

	util.AddNetworkString( "Cresent_HoldType" )
	AddCSLuaFile()
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true

elseif CLIENT then // cl_init

	-- include()
	SWEP.PrintName = "Crescent Rose"
	SWEP.Slot = 2
	SWEP.SlotPos = 20
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = false
	RedColor = Color(201,12,20,255)

	net.Receive("Cresent_HoldType", function()
		local CrescentWeapon = net.ReadEntity()
		local CrescentHold = net.ReadString()
		local GunP = CrescentWeapon.WElements["Crescent Rose"].pos
		local GunA = CrescentWeapon.WElements["Crescent Rose"].angle
		CrescentWeapon:SetWeaponHoldType(CrescentHold)
		if CrescentHold == "melee2" then
			CrescentWeapon.WElements["Crescent Rose"].modelEnt:ResetSequence("fold_to_rife") -- To Gun
			CrescentWeapon.WElements["Crescent Rose"].modelEnt:SetPlaybackRate(1)
			GunP.x = 5.699
			GunP.y = 0.519
			GunP.z = -15.065
			
			GunA.x = -90
			GunA.y = -5
			GunA.z = 180	
		else
			CrescentWeapon.WElements["Crescent Rose"].modelEnt:ResetSequence("unfold_from_fifle") -- To Melee
			CrescentWeapon.WElements["Crescent Rose"].modelEnt:SetPlaybackRate(1)
			GunP.x = 16
			GunP.y = -0.5
			GunP.z = -2
			
			GunA.x = -9
			GunA.y = 0
			GunA.z = 180
		end
		-- CrescentWeapon:CameraPos(gun)
	end)
	local scope = surface.GetTextureID("vgui/rwbyicons/cr_scope")
	function SWEP:DrawHUD()
		local ply = self.Owner
		local x = 20
		local y = ScrH() - 20
		--draw.SimpleText("This is a 'WIP' Weapon of the "..self.PrintName..". Gun Mode? "..tostring(self.Gun)..". Ammo Type:"..self.Primary.Ammo,"Default",x, y,Color(194,30,86,255))
		
		if self.Zoomed then
			surface.SetDrawColor( RedColor )
			
			local scrW = ScrW()
			local scrH = ScrH()
			
			local x = scrW / 2
			local y = scrH / 2
			local scope_size = scrH
			
			-- crosshair
			local gap = 80
			local length = scope_size
			surface.DrawLine( x - length, y, x - gap, y )
			surface.DrawLine( x + length, y, x + gap, y )
			surface.DrawLine( x, y - length, x, y - gap )
			surface.DrawLine( x, y + length, x, y + gap )
			
			gap = 0
			length = 50
			surface.DrawLine( x - length, y, x - gap, y )
			surface.DrawLine( x + length, y, x + gap, y )
			surface.DrawLine( x, y - length, x, y - gap )
			surface.DrawLine( x, y + length, x, y + gap )
			
			surface.SetDrawColor( 0,0,0,255 )
			-- cover edges
			local sh = scope_size / 2
			local w = (x - sh) + 2
			surface.DrawRect(0, 0, w, scope_size)
			surface.DrawRect(x + sh - 2, 0, w, scope_size)
			
			-- cover gaps on top and bottom of screen
			surface.DrawLine( 0, 0, scrW, 0 )
			surface.DrawLine( 0, scrH - 1, scrW, scrH - 1 )
			
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawLine(x, y, x + 1, y + 1)
			
			surface.SetTexture(scope)
			surface.SetDrawColor(0,0,0,255)
			
			surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
		end

		local tex = "nodraw"
		if self.Primary.Ammo == "rwby_dust_fire" then
			tex = surface.GetTextureID("vgui/rwbyicons/dust_fire") 
			texcolor = Color(180,0,0,255)
		elseif self.Primary.Ammo == "rwby_dust_electric" then
			tex = surface.GetTextureID("vgui/rwbyicons/dust_electric") 
			texcolor = Color(180,180,0,255)
		elseif self.Primary.Ammo == "rwby_dust_gravity" then
			tex = surface.GetTextureID("vgui/rwbyicons/dust_gravity")
			texcolor = Color(139,0,139,255)
		end
		if tex != "nodraw" then
			surface.SetTexture(tex)
			surface.SetDrawColor(texcolor)

			surface.DrawTexturedRect(ScrW()-192,ScrH()-176,64,64)
		end
		
		if !self.Owner:Alive() or self.Owner:InVehicle() or LocalPlayer():GetActiveWeapon().Zoomed then return end
			local ply = LocalPlayer()
			local t = {}
			t.start = ply:GetShootPos()
			t.endpos = t.start + ply:GetAimVector() * 90000
			t.filter = ply
			local tr = util.TraceLine(t)
			local pos = tr.HitPos:ToScreen()
			surface.SetDrawColor(255, 25, 25,255)
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


SWEP.HoldType = "melee2"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.ViewModel2 = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.UseHands = true

SWEP.ViewModelBoneMods = {
	-- ["ValveBiped.Base"] = { scale = Vector(1, 1, 1), pos = Vector(-30, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.VElements = {
	["Crescent Rose Scythe"] = { type = "Model", model = "models/blueflytrap/rwby/crescent_rose.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.75, 0.5, -15), angle = Angle(-90, -5, 180), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Crescent Rose Rife"] = { type = "Model", model = "models/blueflytrap/rwby/crescent_rose.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-38.94, 23.01, -7.08), angle = Angle(-178.41, 38.23, -90), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 0), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["Crescent Rose"] = { type = "Model", model = "models/blueflytrap/rwby/crescent_rose.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.699, 0.519, -15.065), angle = Angle(-87, 0, 180), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-------------------------------------------

SWEP.Author = "Blue-Pentagram"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Category = "RWBY"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Gun = false
SWEP.First = true
SWEP.Hold = "melee2"
SWEP.Base = "swep_rwby_sck_base"
DEFINE_BASECLASS( SWEP.Base )
SWEP.Zoomed = false

SWEP.Primary.ClipSize = 18
SWEP.Primary.Damage = 300
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "rwby_dust"
SWEP.Primary.LastAmmo = ""
SWEP.Primary.LastAmmoAmount = 0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = 50
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DustElectricDam = 30

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end
	if self.Owner:KeyDown(IN_USE) then
		-- if not IsFirstTimePredicted() then return end
			-- if SERVER then return end
			self:ChangeMode()
			self.ReloadingTime = CurTime() + 1
		-- return
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
	if self.Gun then   
		self:CrescentShoot()
	else
		self:CrescentMelee()
	end
	self:SetNextPrimaryFire( CurTime() + 0.9 )
end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() then return end
	if self.Gun then -- Custom Dust Type will be added later
		if !self.Owner:KeyDown(IN_USE) then
			self:CresentRoseWeaponScope()
		end
	end
	if self.Owner:KeyDown(IN_USE) then
		if SERVER then
			self.Owner:GiveAmmo( self:Clip1(), self.Primary.Ammo, true )
		end
		if self:Clip1() > 0 then
			self.Primary.LastAmmo = self.Primary.Ammo
			self.Primary.LastAmmoAmount = self:Clip1()
		end
		loadeddust = "Regular"
		if self.Primary.Ammo == "rwby_dust" then
			self.Primary.Ammo = "rwby_dust_fire"
			loadeddust = "Fire"
		elseif self.Primary.Ammo == "rwby_dust_fire" then
			self.Primary.Ammo = "rwby_dust_electric"
			loadeddust = "Electic"
		elseif self.Primary.Ammo == "rwby_dust_electric" then
			self.Primary.Ammo = "rwby_dust_gravity"
			loadeddust = "Gravity"
		else
			self.Primary.Ammo = "rwby_dust"
		end
		if self.Primary.Ammo == self.Primary.LastAmmo then
			self:SetClip1(self.Primary.LastAmmoAmount)
			self.Owner:RemoveAmmo( self.Primary.LastAmmoAmount, self.Primary.Ammo )
			self.Primary.LastAmmo = ""
			self.Primary.LastAmmoAmount = 0
			if game.SinglePlayer() then
				self.Owner:PrintMessage(HUD_PRINTTALK,"Crescent Rose: "..loadeddust.." Dust has been selected.")
			end
		else
			self:SetClip1(0)
			if game.SinglePlayer() then
				self.Owner:PrintMessage(HUD_PRINTTALK,"Crescent Rose: "..loadeddust.." Dust is to be loaded.")
			end
		end
	end
end

function SWEP:CresentRoseWeaponScope()
   if self:GetNextSecondaryFire() > CurTime() then return end
   local bRosesights = not self.Zoomed
   self.Zoomed = bRosesights 
   if SERVER then
		self.Zoomed = bRosesights
		if self.Zoomed then
			self.Owner:SetFOV( 22, 0.3 )
		else
			self.Owner:SetFOV( 0, 0.3 )
		end
   end
   self:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:Think()
	-- self.Owner:NextThink( CurTime() )
	if self.Owner:GetVelocity():Length() > 650 then
		local OurEnt = self.Owner
		local part = EffectData()
		if OurEnt ~= NULL then
		part:SetStart( OurEnt:GetPos() + Vector(0,0,0) )
		part:SetOrigin( OurEnt:GetPos() + Vector(0,0,0) )
		part:SetEntity( OurEnt )
		part:SetScale( 1 )
		util.Effect( "rosepetals", part)
		end 
	end
	-- return true;
end

function SWEP:AdjustMouseSensitivity()
	if SERVER then return end
	return (self.Zoomed and 0.2) or nil
end

function SWEP:ChangeMode()
	if self.Zoomed then self.Zoomed = false if SERVER then self.Owner:SetFOV( 0, 0.3 ) end end
	if self.Gun then
		self.Gun = false 
		self.Hold = "melee2"
		self.Owner:GetViewModel( 0 ):SetWeaponModel( self.ViewModel, self )
		if CLIENT then
			self.VElements["Crescent Rose Rife"].color.a = 0
			self.VElements["Crescent Rose Scythe"].color.a = 255
			//print(tostring(self.VElements["Crescent Rose Rife"].modelEnt))
			self.VElements["Crescent Rose Rife"].modelEnt:ResetSequence("fold_to_rife")
			self.VElements["Crescent Rose Rife"].modelEnt:SetPlaybackRate(.5)
			self.VElements["Crescent Rose Scythe"].modelEnt:ResetSequence("fold_to_rife")
			self.VElements["Crescent Rose Scythe"].modelEnt:SetPlaybackRate(.5)
		end
	else
		self.Gun = true 
		self.Hold = "crossbow"
		self:CrescentToGun(self)
	end	
	self:SetWeaponHoldType( self.Hold )
	if CLIENT then return end
	self:SendWeaponStatus()
end

function SWEP:SendWeaponStatus()
	net.Start("Cresent_HoldType")
		net.WriteEntity(self)
		net.WriteString(self.Hold)
	net.Broadcast()
end

function SWEP:CrescentToGun()
	self.Owner:GetViewModel( 0 ):SetWeaponModel( self.ViewModel2, self )
	if CLIENT then
		self.VElements["Crescent Rose Rife"].modelEnt:ResetSequence("unfold_from_fifle")
		self.VElements["Crescent Rose Rife"].modelEnt:SetPlaybackRate(.5)
		self.VElements["Crescent Rose Rife"].color.a = 255
		self.VElements["Crescent Rose Scythe"].color.a = 0
		self.VElements["Crescent Rose Scythe"].modelEnt:ResetSequence("unfold_from_fifle")
		self.VElements["Crescent Rose Scythe"].modelEnt:SetPlaybackRate(.5)
	end
end

function SWEP:Deploy()
	BaseClass.Deploy( self )
	if self.Gun then -- If in gun mode does not go to gun on swap
		self:CrescentToGun(self)
	end
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
			vm:SetColor(Color(0,0,0,1))
			vm:SetMaterial("models/effects/vol_light001")
		end
	end
	if SERVER then
		timer.Simple( 0.1, function() 
			if self.First then self.First = false return end
			self:SetWeaponHoldType( self.Hold )
			if self.Owner:IsPlayer() then
				self:SendWeaponStatus()
			end
		end)
	end
	return true
end
CrescentWarn = true
function SWEP:Equip( ply )
	if game.SinglePlayer() and CrescentWarn then
		self.Owner:PrintMessage(HUD_PRINTTALK,"Crescent Rose: This SWEP does not function correctly with some client elements in singleplayer.")
		CrescentWarn = false
	end
	if ( ply:IsNPC() or ply:IsNextBot() ) then 
		--print("Crescent Rose NPC: "..tostring(ply))
		self.Gun = true
		self.Hold = "crossbow"
		--print("Crescent Rose NPC: "..self.Hold)
		timer.Simple( 0.1, function() 
			self:SendWeaponStatus()
		end)
	end
	print(GetConVar("gmod_maxammo"):GetInt())
	if !gamemode.Get("darkrp") and self.Owner:IsPlayer() and GetConVar("gmod_maxammo"):GetInt() == 9999 then 
		ply:GiveAmmo( 50, "rwby_dust", true )
		ply:GiveAmmo( 50, "rwby_dust_fire", true )
		ply:GiveAmmo( 50, "rwby_dust_electric", true )
		ply:GiveAmmo( 50, "rwby_dust_gravity", true )
		return
	else
		ply:GiveAmmo( 36, "rwby_dust", true )
	end
end

function SWEP:Holster()
	BaseClass.Holster( self )
	self.Zoomed = false
	return true
end

function SWEP:ContextScreenClick() 
	return false
end

function SWEP:CrescentMelee()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound( Sound( "WeaponFrag.Throw" ) )
	
	if self.Owner.LagCompensation then -- for some reason not always true
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
			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" or hitEnt:IsNPC() or hitEnt:IsNextBot() then
				util.Effect("BloodImpact", edata)
				//self.Owner:LagCompensation(false)
				self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=self.Secondary.Damage})
			else
				util.Effect("Impact", edata)
			end
		end
	else
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	end
	self.Owner:LagCompensation(false)
end

function SWEP:CrescentShoot()
	if( self:Clip1() > 0 ) then
		local eyetrace
		if self.Owner:IsPlayer() then -- Here for Bot's not having a eye trace
			eyetrace = self.Owner:GetEyeTrace() 
		end
		//print(eyetrace)
		self:EmitSound("weapons/sg552/sg552-1.wav")
		//self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self:ShootBullet( self.Primary.Damage, 1, 0)
		self:TakePrimaryAmmo( 1 )
		
		if (self.Primary.Ammo == "rwby_dust_fire" and SERVER) then
			local Dust_Burn = ents.FindInSphere( eyetrace.HitPos, 80 ) 
			for _, v in ipairs(Dust_Burn) do
				if v:IsPlayer() or v:IsNPC() or v:IsNextBot() or v:GetClass() == "prop_physics" then
					v:Ignite(25)
				end
			end
			local Dust_Explosion = ents.Create("env_explosion")
			Dust_Explosion:SetPos(eyetrace.HitPos)
	
			Dust_Explosion:SetKeyValue("iMagnitude", 50)
			Dust_Explosion:Fire("Explode", 0, 0)
			Dust_Explosion:EmitSound("BaseGrenade.Explode", 100, 100)
			Dust_Explosion:Spawn()
		end
		if (self.Primary.Ammo == "rwby_dust_electric" and SERVER) then
			if !eyetrace.Entity:IsWorld() then
				local Dust_Elec = ents.FindInSphere( eyetrace.HitPos, 150 ) 
				//local shock = false
				//local Elec_Rand = {}
				for _, v in ipairs(Dust_Elec) do
					if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
						//if eyetrace.Entity != v and v != self.Owner then
						if eyetrace.Entity != v then
							//if !shock then shock = true end
							//table.insert( Elec_Rand, v )
							local randomshockdamage = math.random(1,self.DustElectricDam)
							local dmg = DamageInfo() -- Create a server-side damage information class
							dmg:SetDamage( randomshockdamage )
							dmg:SetAttacker( self:GetOwner() )
							dmg:SetInflictor( self.Weapon or self )
							dmg:SetDamageType( DMG_SHOCK )
							v:TakeDamageInfo( dmg )
						end
					end
				end
				//PrintTable(Elec_Rand)
				//if shock then
				//	local Elec_Tar = Elec_Rand[math.random(1,#Elec_Rand)]
				//	print(Elec_Tar)
				//	local dmg = DamageInfo() -- Create a server-side damage information class
				//	dmg:SetDamage( self.DustElectricDam )
				//	dmg:SetAttacker( self:GetOwner() )
				//	dmg:SetInflictor( self.Weapon or self )
				//	dmg:SetDamageType( DMG_SHOCK )
				//	Elec_Tar:TakeDamageInfo( dmg )
				//end
			end
		end
		if self.Owner:IsOnGround() and self.Owner:IsPlayer() then self.Owner:ViewPunch( Angle( -2, 0, 0 ) ) end
		if ( SERVER and !self.Owner:IsOnGround()) then
			if self.Primary.Ammo == "rwby_dust_gravity" then
				self.Owner:SetVelocity( -self.Owner:GetAimVector() * 700 )
			else
				self.Owner:SetVelocity( -self.Owner:GetAimVector() * 500 )
			end
		end
	else
		self:EmitSound("weapons/sg552/sg552_boltpull.wav")
	end
end

function SWEP:TakePrimaryAmmo( num )
	if ( self:Clip1() <= 0 ) then 
 		if ( self:Ammo1() <= 0 ) then return end
 		self.Owner:RemoveAmmo( num, self:GetPrimaryAmmoType() )
 	return end
 	self:SetClip1( self:Clip1() - num )	
 end
 
function SWEP:ShootBullet( damage, num_bullets, aimcone )
	local bullet = {}

	bullet.Num 			= num_bullets
	bullet.Src 			= self.Owner:GetShootPos()
	bullet.Dir 			= self.Owner:GetAimVector() 
	bullet.Spread 		= Vector( aimcone, aimcone, 0 )	
	bullet.Tracer		= 1
	bullet.TracerName	= "Tracer" 
	bullet.Force		= 5
	bullet.Damage		= damage
	bullet.AmmoType 	= self.Primary.Ammo

	self.Owner:FireBullets( bullet )

	self:ShootEffects()
end

function SWEP:ShootEffects()
	if self.Gun then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:MuzzleFlash()
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end
end
