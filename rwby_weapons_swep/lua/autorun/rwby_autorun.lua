

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