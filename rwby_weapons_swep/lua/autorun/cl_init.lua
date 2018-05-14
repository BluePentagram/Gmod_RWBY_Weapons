


if SERVER then return end

if !ConVarExists( "cl_rwby_thirdperson") and CLIENT then
	CreateConVar( "cl_rwby_thirdperson", 1, {FCVAR_ARCHIVE} )
end

hook.Add( "PopulateToolMenu", "rwby_q_settings", function()
	spawnmenu.AddToolMenuOption( "Utilities", "RWBY", "RWBY Settings", "RWBY Settings", "", "", function( panel )
		panel:ClearControls()
		panel:CheckBox( "Enable Third Person", "cl_rwby_thirdperson", 0, 1 )
		panel:Help("Enables third person for the Crescent Rose.")
		-- Add stuff here
	end )
end )
