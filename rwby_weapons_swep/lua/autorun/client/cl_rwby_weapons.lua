


if not ConVarExists( "rwby_3rdperson_weapon") then
	CreateConVar( "rwby_3rdperson_weapon", 0, {FCVAR_ARCHIVE} )
end

hook.Add( "PopulateToolMenu", "rwby_q_settings", function()
	spawnmenu.AddToolMenuOption( "Utilities", "RWBY", "RWBY Settings", "RWBY Settings", "", "", function( panel )
		panel:ClearControls()
		panel:Help("---[Client]---")
		panel:CheckBox( "Enable Third Person", "rwby_3rdperson_weapon", 0, 1 )
		panel:ControlHelp("Enables third person for the Crescent Rose.")
		panel:Help("---[Server]---")
		-- Add Ammo Here
		panel:ControlHelp("these require you set Gmod_maxammo to 0 else it will use's gmod's max ammo of 9999, or whatever that is set to.")
		panel:NumSlider( "#rwby_dust_ammo", "rwby_max_ammo_dust", 0, 9999,false )
		panel:ControlHelp("Default Dust Ammo 72.")
		panel:NumSlider( "#rwby_dust_fire_ammo", "rwby_max_ammo_dust_fire", 0, 9999,false )
		panel:ControlHelp("Default Fire Dust Ammo 36.")
		panel:NumSlider( "#rwby_dust_electric_ammo", "rwby_max_ammo_dust_electric", 0, 9999,false )
		panel:ControlHelp("Default Electric Dust Ammo 36.")
		panel:NumSlider( "#rwby_dust_gravity_ammo", "rwby_max_ammo_dust_gravity", 0, 9999,false )
		panel:ControlHelp("Default Gravity Dust Ammo 36.")

	end )
end )

local RWBYWeapons = {
	["swep_crescent_rose"] = true
}

hook.Add( "CalcView", "RWBY3RDCamera", function( ply, pos, angles, fov )
	if not IsValid(ply) or not ply:Alive() or ply:InVehicle() or ply:GetViewEntity() ~= ply then return end
	local activeweapon = ply:GetActiveWeapon()
	if not IsValid( activeweapon ) or not RWBYWeapons[activeweapon:GetClass()] or not GetConVar("rwby_3rdperson_weapon"):GetBool() or activeweapon.Zoomed then return end

	local trace = util.TraceHull( {
	start = pos,
	endpos = pos - angles:Forward() * 100 + angles:Right() * 15,
	filter = { ply:GetActiveWeapon(), ply },
	mins = Vector( -4, -4, -4 ),
	maxs = Vector( 4, 4, 4 ),
	} )
	
	if trace.Hit then pos = trace.HitPos else pos = pos - angles:Forward() * 100 + angles:Right() * 15  end

	return {
		origin = pos,
		angles = angles,
		drawviewer = true
	}
end )


language.Add("rwby_dust_ammo", "Regular Dust Ammo")
language.Add("rwby_dust_fire_ammo", "Fire Dust Ammo")
language.Add("rwby_dust_electric_ammo", "Electric Dust Ammo")
language.Add("rwby_dust_gravity_ammo", "Gravity Dust Ammo")
