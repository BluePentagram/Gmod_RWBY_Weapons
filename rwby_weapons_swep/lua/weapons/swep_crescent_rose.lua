--[[--------------
   End of SCK
--------------]]
-- init.
if SERVER then
	util.AddNetworkString("Cresent_HoldType")
	AddCSLuaFile()
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
elseif CLIENT then
	-- cl_init
	-- include()
	SWEP.PrintName = "Crescent Rose"
	SWEP.Slot = 2
	SWEP.SlotPos = 20
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = false
	local RedColor = Color(201, 12, 20, 255)

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
	end)

	-- CrescentWeapon:CameraPos(gun)
	local scope = surface.GetTextureID("vgui/rwbyicons/cr_scope")

	function SWEP:DrawHUD()
		local ply = self:GetOwner()

		-- draw.SimpleText("This is a 'WIP' Weapon of the "..self.PrintName..". Gun Mode? "..tostring(self.Gun)..". Ammo Type:"..self.Primary.Ammo,"Default",x, y,Color(194,30,86,255))
		if self.Zoomed then
			surface.SetDrawColor(RedColor)
			local scrW = ScrW()
			local scrH = ScrH()
			local x = scrW / 2
			local y = scrH / 2
			local scope_size = scrH
			-- crosshair
			local gap = 80
			local length = scope_size
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)
			gap = 0
			length = 50
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)
			surface.SetDrawColor(0, 0, 0, 255)
			-- cover edges
			local sh = scope_size / 2
			local w = (x - sh) + 2
			surface.DrawRect(0, 0, w, scope_size)
			surface.DrawRect(x + sh - 2, 0, w, scope_size)
			-- cover gaps on top and bottom of screen
			surface.DrawLine(0, 0, scrW, 0)
			surface.DrawLine(0, scrH - 1, scrW, scrH - 1)
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawLine(x, y, x + 1, y + 1)
			surface.SetTexture(scope)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
		end

		local tex = "nodraw"
		local texcolor = Color(255, 255, 255, 255)

		if self.Primary.Ammo == "rwby_dust_fire" then
			tex = surface.GetTextureID("vgui/rwbyicons/dust_fire")
			texcolor = Color(180, 0, 0, 255)
		elseif self.Primary.Ammo == "rwby_dust_electric" then
			tex = surface.GetTextureID("vgui/rwbyicons/dust_electric")
			texcolor = Color(180, 180, 0, 255)
		elseif self.Primary.Ammo == "rwby_dust_gravity" then
			tex = surface.GetTextureID("vgui/rwbyicons/dust_gravity")
			texcolor = Color(139, 0, 139, 255)
		end

		if tex ~= "nodraw" then
			surface.SetTexture(tex)
			surface.SetDrawColor(texcolor)
			surface.DrawTexturedRect(ScrW() - 192, ScrH() - 176, 64, 64)
		end

		if not ply:Alive() or ply:InVehicle() or LocalPlayer():GetActiveWeapon().Zoomed then return end
		local localPly = LocalPlayer()
		local t = {}
		t.start = localPly:GetShootPos()
		t.endpos = t.start + localPly:GetAimVector() * 90000
		t.filter = localPly
		local tr = util.TraceLine(t)
		local pos = tr.HitPos:ToScreen()
		surface.SetDrawColor(255, 25, 25, 255)
		surface.DrawLine(pos.x - 5, pos.y, pos.x - 8, pos.y)
		surface.DrawLine(pos.x + 5, pos.y, pos.x + 8, pos.y)
		surface.DrawLine(pos.x, pos.y - 5, pos.x, pos.y - 8)
		surface.DrawLine(pos.x, pos.y + 5, pos.x, pos.y + 8)
	end

	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetTexture(surface.GetTextureID("vgui/entities/crescentrose_weapon_select"))
		local fsin = 0

		if self.BounceWeaponIcon == true then
			fsin = math.sin(CurTime() * 10) * 5
		end

		y = y + 10
		x = x + 10
		wide = wide - 20
		surface.DrawTexturedRect(x + fsin, y - fsin, wide - fsin * 2, (wide / 2) + fsin)
		self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
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
SWEP.ViewModelBoneMods = {} -- ["ValveBiped.Base"] = { scale = Vector(1, 1, 1), pos = Vector(-30, 0, 0), angle = Angle(0, 0, 0) }

SWEP.VElements = {
	["Crescent Rose Scythe"] = {
		type = "Model",
		model = "models/blueflytrap/rwby/crescent_rose.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(6.75, 0.5, -15),
		angle = Angle(-90, -5, 180),
		size = Vector(0.5, 0.5, 0.5),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},
	["Crescent Rose Rife"] = {
		type = "Model",
		model = "models/blueflytrap/rwby/crescent_rose.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(-38.94, 23.01, -7.08),
		angle = Angle(-178.41, 38.23, -90),
		size = Vector(0.5, 0.5, 0.5),
		color = Color(255, 255, 255, 0),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}
}

SWEP.WElements = {
	["Crescent Rose"] = {
		type = "Model",
		model = "models/blueflytrap/rwby/crescent_rose.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(5.699, 0.519, -15.065),
		angle = Angle(-87, 0, 180),
		size = Vector(0.5, 0.5, 0.5),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}
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
DEFINE_BASECLASS(SWEP.Base)
SWEP.Zoomed = false
SWEP.Primary.ClipSize = 18
SWEP.Primary.Damage = 300
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "rwby_dust"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = 50
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DustElectricDam = 30

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end
	local owner = self:GetOwner()

	if owner:KeyDown(IN_USE) then
		if not IsFirstTimePredicted() then return end
		-- if SERVER then return end
		self:ChangeMode()
		self.ReloadingTime = CurTime() + 1

		return
	else
		if not self.Gun then
			self.ReloadingTime = CurTime() + 1
		else
			self:DefaultReload(ACT_VM_RELOAD)
			self:SendWeaponAnim(ACT_VM_RELOAD)
			local AnimationTime = owner:GetViewModel():SequenceDuration()
			self.ReloadingTime = CurTime() + AnimationTime
			self:SetNextPrimaryFire(CurTime() + AnimationTime)
			self:SetNextSecondaryFire(CurTime() + AnimationTime)
		end
	end
	-- end
end

local vector_origin = Vector(0, 0, 0)

--https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/terrortown/entities/entities/ttt_c4/shared.lua#L161-L198
local function findPlayersInRadius(center, radius)
	-- It seems intuitive to use FindInSphere here, but that will find all ents
	-- in the radius, whereas there exist only ~16 players. Hence it is more
	-- efficient to cycle through all those players and do a Lua-side distance
	-- check.
	local r = radius ^ 2 -- square so we can compare with dotproduct directly
	-- pre-declare to avoid realloc
	local d = 0.0
	local diff = nil
	local players = {}

	for _, ent in ipairs(player.GetAll()) do
		if IsValid(ent) then
			-- dot of the difference with itself is distance squared
			diff = center - ent:GetPos()
			d = diff:Dot(diff)

			if d < r then
				players[#players + 1] = ent
			end
		end
	end

	return players
end

local ammoFuncs = {
	["rwby_dust_fire"] = function(owner)
		local eyeTrace = owner:GetEyeTrace()
		local playersToBurn = findPlayersInRadius(eyeTrace.HitPos, 80) --ents.FindInSphere(owner:GetEyeTrace().HitPos, 80)

		for _, v in ipairs(playersToBurn) do
			if v:IsPlayer() or v:IsNPC() or v:GetClass() == "prop_physics" then
				v:Ignite(25)
			end
		end

		local Dust_Explosion = ents.Create("env_explosion")
		Dust_Explosion:SetPos(eyeTrace.HitPos)
		Dust_Explosion:Spawn()
		Dust_Explosion:SetKeyValue("iMagnitude", 50)
		Dust_Explosion:Fire("Explode", 0, 0)
		Dust_Explosion:EmitSound("BaseGrenade.Explode", 100, 100)
	end,
	["rwby_dust_electric"] = function(owner, wep)
		local eyeTrace = owner:GetEyeTrace()

		if not eyeTrace.Entity:IsWorld() then
			local playersToZap = findPlayersInRadius(eyeTrace.HitPos, 80) --ents.FindInSphere(eyeTrace.HitPos, 80)
			local shock = false
			local Elec_Rand = {}

			for _, v in ipairs(playersToZap) do
				if v:IsPlayer() and v ~= owner then
					if not shock then
						shock = true
					end

					table.insert(Elec_Rand, v)
				end
			end

			if shock then
				local Elec_Tar = math.random(1, #Elec_Rand)

				-- Elec_Rand[Elec_Tar]:Ignite(1)
				if Elec_Rand[Elec_Tar]:Health() > wep.DustElectricDam then
					Elec_Rand[Elec_Tar]:SetHealth(Elec_Rand[Elec_Tar]:Health() - wep.DustElectricDam)
				else
					Elec_Rand[Elec_Tar]:Kill()
				end
			end
		end
	end,
	["rwby_dust_gravity"] = function(owner, wep)
		if not owner:IsOnGround() then
			owner:SetVelocity(-owner:GetAimVector() * 700)
		end
	end
}

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if not self.Gun then
		owner:SetAnimation(PLAYER_ATTACK1)
		self:EmitSound(Sound("WeaponFrag.Throw"))

		-- for some reason not always true
		if owner.LagCompensation then
			owner:LagCompensation(true)
		end

		local spos = owner:GetShootPos()
		local sdest = spos + (owner:GetAimVector() * 80)

		local tr_main = util.TraceLine({
			start = spos,
			endpos = sdest,
			filter = owner,
			mask = MASK_SHOT_HULL
		})

		local hitEnt = tr_main.Entity

		if IsValid(hitEnt) or tr_main.HitWorld then
			self:SendWeaponAnim(ACT_VM_HITCENTER)

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
					owner:LagCompensation(false)

					owner:FireBullets({
						Num = 1,
						Src = spos,
						Dir = owner:GetAimVector(),
						Spread = vector_origin,
						Tracer = 0,
						Force = 1,
						Damage = self.Secondary.Damage
					})
				else
					util.Effect("Impact", edata)
				end
			end
		else
			self:SendWeaponAnim(ACT_VM_MISSCENTER)
		end

		owner:LagCompensation(false)
	else
		if self:Clip1() > 0 then
			self:EmitSound("weapons/sg552/sg552-1.wav")
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self:ShootBullet(self.Primary.Damage, 1, 0)
			self:TakePrimaryAmmo(1)

			if SERVER and ammoFuncs[self.Primary.Ammo] then
				ammoFuncs[self.Primary.Ammo](owner, self)
			end

			owner:ViewPunch(Angle(-2, 0, 0))

			if SERVER and not owner:IsOnGround() and self.Primary.Ammo ~= "rwby_dust_gravity" then
				owner:SetVelocity(-owner:GetAimVector() * 500)
			end
		else
			self:EmitSound("weapons/sg552/sg552_boltpull.wav")
		end
	end

	self:SetNextPrimaryFire(CurTime() + 0.9)
end

function SWEP:TakePrimaryAmmo(num)
	if self:Clip1() <= 0 then
		if self:Ammo1() <= 0 then return end
		self:GetOwner():RemoveAmmo(num, self:GetPrimaryAmmoType())

		return
	end

	self:SetClip1(self:Clip1() - num)
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	local owner = self:GetOwner()

	-- Custom Dust Type will be added later
	if self.Gun and not owner:KeyDown(IN_USE) then
		self:CresentRoseWeaponScope()
	end

	if owner:KeyDown(IN_USE) then
		if SERVER then
			owner:GiveAmmo(self:Clip1(), self.Primary.Ammo, true)
		end

		if self.Primary.Ammo == "rwby_dust" then
			self.Primary.Ammo = "rwby_dust_fire"
		elseif self.Primary.Ammo == "rwby_dust_fire" then
			self.Primary.Ammo = "rwby_dust_electric"
		elseif self.Primary.Ammo == "rwby_dust_electric" then
			self.Primary.Ammo = "rwby_dust_gravity"
		else
			self.Primary.Ammo = "rwby_dust"
		end

		self:SetClip1(0)
	end
end

function SWEP:CresentRoseWeaponScope()
	if self:GetNextSecondaryFire() > CurTime() then return end
	local owner = self:GetOwner()
	local bRosesights = not self.Zoomed
	self.Zoomed = bRosesights

	if SERVER then
		self.Zoomed = bRosesights

		if self.Zoomed then
			owner:SetFOV(22, 0.3)
		else
			owner:SetFOV(0, 0.3)
		end
	end

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:Think()
	local owner = self:GetOwner()

	-- self.Owner:NextThink( CurTime() )
	if owner:GetVelocity():Length() > 650 then
		local OurEnt = owner
		local part = EffectData()
		local ownerPos = OurEnt:GetPos()

		if OurEnt ~= NULL then
			part:SetStart(ownerPos + vector_origin)
			part:SetOrigin(ownerPos + vector_origin)
			part:SetEntity(OurEnt)
			part:SetScale(1)
			util.Effect("rosepetals", part)
		end
	end
	-- return true;
end

function SWEP:AdjustMouseSensitivity()
	if SERVER then return end

	return (self.Zoomed and 0.2) or nil
end

function SWEP:ChangeMode()
	local owner = self:GetOwner()
	if self.Zoomed then
		self.Zoomed = false

		if SERVER then
			owner:SetFOV(0, 0.3)
		end
	end

	if self.Gun then
		self.Gun = false
		self.Hold = "melee2"
		owner:GetViewModel(0):SetWeaponModel(self.ViewModel, self)

		if CLIENT then
			self.VElements["Crescent Rose Rife"].color.a = 0
			self.VElements["Crescent Rose Scythe"].color.a = 255
		end
	else
		self.Gun = true
		self.Hold = "crossbow"
		CrescentToGun(self)
	end

	if CLIENT then return end
	self:SetWeaponHoldType(self.Hold)
	net.Start("Cresent_HoldType")
	net.WriteEntity(self)
	net.WriteString(self.Hold)
	net.Broadcast()
end

function CrescentToGun(self)
	self:GetOwner():GetViewModel(0):SetWeaponModel(self.ViewModel2, self)

	if CLIENT then
		self.VElements["Crescent Rose Rife"].modelEnt:ResetSequence("unfold_from_fifle")
		self.VElements["Crescent Rose Rife"].modelEnt:SetPlaybackRate(1)
		self.VElements["Crescent Rose Rife"].color.a = 255
		self.VElements["Crescent Rose Scythe"].color.a = 0
	end
end

function SWEP:ShootBullet(damage, num_bullets, aimcone)
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Spread = Vector(aimcone, aimcone, 0)
	bullet.Tracer = 1
	bullet.TracerName = "Tracer"
	bullet.Force = 5
	bullet.Damage = damage
	bullet.AmmoType = self.Primary.Ammo
	self:GetOwner():FireBullets(bullet)
	self:ShootEffects()
end

function SWEP:ShootEffects()
	if self.Gun then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:GetOwner():MuzzleFlash()
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	end
end

function SWEP:Deploy()
	BaseClass.Deploy(self)

	if self.Gun then
		CrescentToGun(self)
	end

	if CLIENT and IsValid(self:GetOwner()) then
		local vm = self:GetOwner():GetViewModel()

		if IsValid(vm) then
			self:ResetBonePositions(vm)
			vm:SetColor(Color(0, 0, 0, 1))
			vm:SetMaterial("models/effects/vol_light001")
		end
	end

	if SERVER then
		timer.Simple(0.1, function()
			if self.First then
				self.First = false

				return
			end

			self:SetWeaponHoldType(self.Hold)
			net.Start("Cresent_HoldType")
			net.WriteEntity(self)
			net.WriteString(self.Hold)
			net.Broadcast()
		end)
	end

	return true
end

function SWEP:Equip(ply)
	if ply:IsNPC() then
		self.Gun = true
	end

	if not gamemode.Get("darkrp") then
		ply:GiveAmmo(50, "rwby_dust")
		ply:GiveAmmo(50, "rwby_dust_fire")
		ply:GiveAmmo(50, "rwby_dust_electric")
		ply:GiveAmmo(50, "rwby_dust_gravity")
	end
end

function SWEP:Holster()
	BaseClass.Holster(self)
	self.Zoomed = false

	return true
end

function SWEP:ContextScreenClick()
	return false
end