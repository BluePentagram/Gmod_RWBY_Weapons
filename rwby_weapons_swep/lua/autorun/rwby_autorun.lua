

AddCSLuaFile()

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

version = "1.2"
beta = false
function VersionCheck()
	http.Fetch("https://raw.githubusercontent.com/BluePentagram/Gmod_RWBY_Weapons/master/version.txt", function( body, len, headers, code)
		local githubversion = body
		if githubversion > version then 
			if SERVER then
				print("RWBY Weapons: Crescent Rose version is different, Server Vesion: "..version..", Github Vesion: "..githubversion)
			elseif CLIENT then
				chat.AddText( Color( 25, 25, 25 ), "RWBY Weapons: ", color_white, "Crescent Rose version is different, Server Vesion: "..version..", Github Vesion: "..githubversion )
			end
		elseif githubversion == version then
			print("RWBY Weapons: Crescent Rose version is up to date, Vesion: "..version)
		elseif githubversion < version then
			print("RWBY Weapons: Crescent Rose Useing a Beta version, Beta Vesion: "..version)
		end
		if beta then
			if SERVER then
				print("RWBY Weapons: You are useing a beta version.")
			elseif CLIENT then
				chat.AddText( Color( 25, 25, 25 ), "RWBY Weapons: ", color_white, "This Current Version is set up as a Beta version." )
			end
		end
	end)
end
timer.Simple(5, function() VersionCheck() end) 