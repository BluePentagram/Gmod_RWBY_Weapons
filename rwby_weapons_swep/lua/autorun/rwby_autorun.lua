

//AddCSLuaFile()
//AddCSLuaFile("client/cl_rwby_weapons.lua")
if !ConVarExists( "rwby_max_ammo_dust") then
	CreateConVar( "rwby_max_ammo_dust", 72, {FCVAR_REPLICATED, FCVAR_ARCHIVE} )
end
if !ConVarExists( "rwby_max_ammo_dust_fire") then
	CreateConVar( "rwby_max_ammo_dust_fire", 36, {FCVAR_REPLICATED, FCVAR_ARCHIVE} )
end
if !ConVarExists( "rwby_max_ammo_dust_electric") then
	CreateConVar( "rwby_max_ammo_dust_electric", 36, {FCVAR_REPLICATED, FCVAR_ARCHIVE} )
end
if !ConVarExists( "rwby_max_ammo_dust_gravity") then
	CreateConVar( "rwby_max_ammo_dust_gravity", 36, {FCVAR_REPLICATED, FCVAR_ARCHIVE} )
end

hook.Add( "Initialize", "RWBYAmmoInitialize", function()
	game.AddAmmoType {
		name		= "rwby_dust",
		dmgtype		= DMG_BULLET,
		tracer		= TRACER_LINE,
		plydmg		= 0,
		npcdmg		= 0,
		force		= 2000,
		minsplash	= 10,
		maxsplash	= 15,
		maxcarry	= "rwby_max_ammo_dust"
	}
	game.AddAmmoType {
		name		= "rwby_dust_fire",
		dmgtype		= DMG_BULLET,
		tracer		= TRACER_LINE,
		plydmg		= 0,
		npcdmg		= 0,
		force		= 2000,
		minsplash	= 10,
		maxsplash	= 15,
		maxcarry	= "rwby_max_ammo_dust_fire"
	}
	game.AddAmmoType {
		name		= "rwby_dust_electric",
		dmgtype		= DMG_BULLET,
		tracer		= TRACER_LINE,
		plydmg		= 0,
		npcdmg		= 0,
		force		= 2000,
		minsplash	= 10,
		maxsplash	= 15,
		maxcarry	= "rwby_max_ammo_dust_electric"
	}
	game.AddAmmoType {
		name		= "rwby_dust_gravity",
		dmgtype		= DMG_BULLET,
		tracer		= TRACER_LINE,
		plydmg		= 0,
		npcdmg		= 0,
		force		= 2000,
		minsplash	= 10,
		maxsplash	= 15,
		maxcarry	= "rwby_max_ammo_dust_gravity"
	}
	print("RWBY Weapons: Added Custom Dust Ammo Types!")
end )




local pow = function(ply, cmd, args)
	print( "Dust Ammo: "..game.GetAmmoMax(game.GetAmmoID( "rwby_dust" )))
	print( "Fire Ammo: "..game.GetAmmoMax(game.GetAmmoID( "rwby_dust_fire" )))
	print( "Electric Ammo: "..game.GetAmmoMax(game.GetAmmoID( "rwby_dust_electric" )))
	print( "Gravity Ammo: "..game.GetAmmoMax(game.GetAmmoID( "rwby_dust_gravity" )))
end

concommand.Add("rwby_test_ammo" , pow)

/*
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
*/
