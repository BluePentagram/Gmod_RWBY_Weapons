AddCSLuaFile()

game.AddAmmoType{
	name = "rwby_dust",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 15
}

game.AddAmmoType{
	name = "rwby_dust_fire",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 15
}

game.AddAmmoType{
	name = "rwby_dust_electric",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 15
}

game.AddAmmoType{
	name = "rwby_dust_gravity",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 15
}

print("RWBY Weapons: Added Custom Dust Ammo Types!")
local version = "1.3"

local function VersionCheck()
	http.Fetch("https://raw.githubusercontent.com/BluePentagram/Gmod_RWBY_Weapons/master/version.txt", function(body, len, headers, code)
		local githubversion = body

		if githubversion > version then
			if SERVER then
				print("RWBY Weapons: Version is different, Server Version: " .. version .. ", Steam Version: " .. githubversion)
			elseif CLIENT then
				chat.AddText(Color(25, 25, 25), "RWBY Weapons: ", color_white, "Server version is different, Server Version: " .. version .. ", Steam Version: " .. githubversion)
			end
		elseif githubversion == version then
			print("RWBY Weapons: Version is up to date, Version: " .. version)
		elseif githubversion < version then
			if SERVER then
				print("RWBY Weapons: Using a Beta version, Beta Version: " .. version .. ". Steam Version: " .. githubversion)
			elseif CLIENT then
				chat.AddText(Color(25, 25, 25), "RWBY Weapons: ", color_white, "Server Using a Beta version, Beta Version: " .. version .. ". Steam Version: " .. githubversion)
			end
		end
	end)
end

timer.Simple(5, function()
	VersionCheck()
end)

local RWBYWeapons = {
	["swep_crescent_rose"] = true,
	["swep_myrtenaster"] = true,
	["swep_magnhild"] = true,
	["swep_croceamors"] = true
}

if CLIENT then
	local cl_rwby_thirdperson
	if not ConVarExists("cl_rwby_thirdperson") then
		cl_rwby_thirdperson = CreateConVar("cl_rwby_thirdperson", 1, {FCVAR_ARCHIVE})
	end

	hook.Add("PopulateToolMenu", "RWBYPopulateToolMenu", function()
		spawnmenu.AddToolMenuOption("Utilities", "RWBY", "RWBY Settings", "RWBY Settings", "", "", function(panel)
			panel:ClearControls()
			panel:CheckBox("Enable Third Person", "cl_rwby_thirdperson", 0, 1)
			panel:Help("Enables third person for the Crescent Rose.")
		end)
	end)

	local localPlayer = LocalPlayer()

	hook.Add("CalcView", "RWBYCalcView", function(ply, pos, angles, fov)
		if not IsValid(ply) or not ply:Alive() or ply:InVehicle() or ply:GetViewEntity() ~= ply then return end

		if not IsValid(localPlayer) then
			localPlayer = LocalPlayer()

			return
		end

		local activeWeapon = localPlayer.GetActiveWeapon and localPlayer:GetActiveWeapon()

		if not IsValid(activeWeapon) or not RWBYWeapons[activeWeapon:GetClass()] or activeWeapon.Zoomed or not cl_rwby_thirdperson:GetBool() then return end

		local trace = util.TraceHull({
			start = pos,
			endpos = pos - angles:Forward() * 100 + angles:Right() * 15,
			filter = {activeWeapon, ply},
			mins = Vector(-4, -4, -4),
			maxs = Vector(4, 4, 4),
		})

		local traceEnt = trace.Entity

		if trace.HitWorld or traceEnt:IsPlayer() or traceEnt:IsNPC() or trace.Hit then
			pos = trace.HitPos
		else
			pos = pos - angles:Forward() * 100 + angles:Right() * 15
		end

		return {
			origin = pos,
			angles = angles,
			drawviewer = true
		}
	end)
end