AddCSLuaFile()
SWEP.PrintName = "Ember Celica"
SWEP.Author = "Blue-Pentagram"
SWEP.Purpose = ""
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Spawnable = true
SWEP.Category = "RWBY Weapons"
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true
ValidModel = "models/jazzmcfly/rwby/yang_xiao_long.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.HitDistance = 48
local SwingSound = Sound("WeaponFrag.Throw")
local HitSound = Sound("Flesh.ImpactHard")

function SWEP:Initialize()
	self:SetHoldType("fist")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Int", 2, "Combo")
end

function SWEP:UpdateNextIdle()
	local vm = self:GetOwner():GetViewModel()
	self:SetNextIdle(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
end

function SWEP:PrimaryAttack(right)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	local anim = "fists_left"

	if right then
		anim = "fists_right"
	end

	if self:GetCombo() >= 2 then
		anim = "fists_uppercut"
	end

	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
	self:EmitSound(SwingSound)
	self:UpdateNextIdle()
	self:SetNextMeleeAttack(CurTime() + 0.2)
	self:SetNextPrimaryFire(CurTime() + 0.9)
	self:SetNextSecondaryFire(CurTime() + 0.9)
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack(true)
end

function SWEP:DealDamage()
	local owner = self:GetOwner()
	local anim = self:GetSequenceName(owner:GetViewModel():GetSequence())
	owner:LagCompensation(true)

	local tr = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * self.HitDistance,
		filter = owner,
		mask = MASK_SHOT_HULL
	})

	if not IsValid(tr.Entity) then
		tr = util.TraceHull({
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * self.HitDistance,
			filter = owner,
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8),
			mask = MASK_SHOT_HULL
		})
	end

	-- We need the second part for single player because SWEP:Think is ran shared in SP
	if tr.Hit and not (game.SinglePlayer() and CLIENT) then
		self:EmitSound(HitSound)
	end

	local hit = false

	if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
		local dmginfo = DamageInfo()
		local attacker = owner

		if not IsValid(attacker) then
			attacker = self
		end

		dmginfo:SetAttacker(attacker)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(math.random(8, 12))

		if anim == "fists_left" then
			dmginfo:SetDamageForce(owner:GetRight() * 4912 + owner:GetForward() * 9998) -- Yes we need those specific numbers
		elseif anim == "fists_right" then
			dmginfo:SetDamageForce(owner:GetRight() * -4912 + owner:GetForward() * 9989)
		elseif anim == "fists_uppercut" then
			dmginfo:SetDamageForce(owner:GetUp() * 5158 + owner:GetForward() * 10012)
			dmginfo:SetDamage(math.random(12, 24))
		end

		tr.Entity:TakeDamageInfo(dmginfo)
		hit = true
	end

	if SERVER and IsValid(tr.Entity) then
		local phys = tr.Entity:GetPhysicsObject()

		if IsValid(phys) then
			phys:ApplyForceOffset(owner:GetAimVector() * 80 * phys:GetMass(), tr.HitPos)
		end
	end

	if SERVER then
		if hit and anim ~= "fists_uppercut" then
			self:SetCombo(self:GetCombo() + 1)
		else
			self:SetCombo(0)
		end
	end

	owner:LagCompensation(false)
end

function SWEP:OnDrop()
	self:Remove() -- You can't drop fists
end

function SWEP:Deploy()
	local ply = self:GetOwner()

	if ply:GetModel() ~= ValidModel then
		ply:StripWeapon("swep_ember_celica")
		ply:PrintMessage(HUD_PRINTTALK, "RWBY Weapons: To use the Ember Celica you need to be this model: " .. ValidModel .. ".")

		return
	end

	ply:SetBodygroup(1, 1)
	local speed = GetConVar("sv_defaultdeployspeed"):GetInt()
	local vm = ply:GetViewModel()
	vm:SetBodygroup(0, 1)
	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
	vm:SetPlaybackRate(speed)
	self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration() / speed)
	self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration() / speed)
	self:UpdateNextIdle()

	if SERVER then
		self:SetCombo(0)
	end

	return true
end

function SWEP:Holster(wep)
	local ply = self:GetOwner()
	ply:SetBodygroup(1, 0)

	if ply then
		local vm = ply:GetViewModel()
		vm:SetBodygroup(0, 1)
	end

	return true
end

function SWEP:Think()
	local vm = self:GetOwner():GetViewModel()
	local idletime = self:GetNextIdle()

	if idletime > 0 and CurTime() > idletime then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)))
		self:UpdateNextIdle()
	end

	local meleetime = self:GetNextMeleeAttack()

	if meleetime > 0 and CurTime() > meleetime then
		self:DealDamage()
		self:SetNextMeleeAttack(0)
	end

	if SERVER and CurTime() > self:GetNextPrimaryFire() + 0.1 then
		self:SetCombo(0)
	end
end

function RemoveEmberFromModel(ply)
	if ply:GetModel() == ValidModel then
		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply:SetBodygroup(1, 2)
			end
		end)
		-- ply:SetBodygroup( 2, 0 ) 
		-- print("Am i Working?")
	end
end

hook.Add("PlayerSpawn", "RemoveEmberFromModel", RemoveEmberFromModel)

concommand.Add("RWBY_Bodygroup", function(ply, cmd, args)
	PrintTable(ply:GetBodyGroups())
end)