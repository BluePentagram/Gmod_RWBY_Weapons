

AddCSLuaFile()
AddCSLuaFile("cl_init.lua")
game.AddAmmoType {
	name = "rwby_dust",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 15
}
game.AddAmmoType {
	name = "rwby_dust_fire",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 15
}
game.AddAmmoType {
	name = "rwby_dust_electric",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 15
}
game.AddAmmoType {
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

version = "1.3"
function VersionCheck()
	http.Fetch("https://raw.githubusercontent.com/BluePentagram/Gmod_RWBY_Weapons/master/version.txt", function( body, len, headers, code)
		local githubversion = body
		if githubversion > version then 
			if SERVER then
				print("RWBY Weapons: Version is different, Server Version: "..version..", Steam Version: "..githubversion)
			elseif CLIENT then
				chat.AddText( Color( 25, 25, 25 ), "RWBY Weapons: ", color_white, "Server version is different, Server Version: "..version..", Steam Version: "..githubversion )
			end
		elseif githubversion == version then
			print("RWBY Weapons: Version is up to date, Version: "..version)
		elseif githubversion < version then
			if SERVER then
				print("RWBY Weapons: Using a Beta version, Beta Version: "..version..". Steam Version: "..githubversion)
			elseif CLIENT then
				chat.AddText( Color( 25, 25, 25 ), "RWBY Weapons: ", color_white, "Server Using a Beta version, Beta Version: "..version..". Steam Version: "..githubversion )
			end	
		end
	end)
end
timer.Simple(5, function() VersionCheck() end) 

RWBYWeapons = {"swep_crescent_rose","swep_myrtenaster","swep_magnhild","swep_croceamors"}
if CLIENT then
	hook.Add( "CalcView", "RWBY3RDCamera", function( ply, pos, angles, fov )
		if ( !IsValid( ply ) or !ply:Alive() or ply:InVehicle() or ply:GetViewEntity() != ply ) then return end
		if ( !LocalPlayer().GetActiveWeapon or !IsValid( LocalPlayer():GetActiveWeapon() ) or !table.HasValue(RWBYWeapons, LocalPlayer():GetActiveWeapon():GetClass()) or !GetConVar("cl_rwby_thirdperson"):GetBool() or LocalPlayer():GetActiveWeapon().Zoomed ) then return end
		local trace = util.TraceHull( {
		start = pos,
		endpos = pos - angles:Forward() * 100 + angles:Right() * 15,
		filter = { ply:GetActiveWeapon(), ply },
		mins = Vector( -4, -4, -4 ),
		maxs = Vector( 4, 4, 4 ),
		} )
		local traent = trace.Entity
		if ( trace.HitWorld or traent:IsPlayer() or traent:IsNPC() or trace.Hit ) then pos = trace.HitPos else pos = pos - angles:Forward() * 100 + angles:Right() * 15  end
	
		return {
			origin = pos,
			angles = angles,
			drawviewer = true
		}
	end )
end
