/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

/*--------------
   End of SCK
--------------*/

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
	-- Crescent Rose Camera Position Settings Start
	rosecam		= 100		-- The Actal Distance of the camera
	rosepos		= rosecam	-- The Actal Distance of the camera
	rosemul		= 3			-- Speed of camera movement
	rosemin		= -500		-- How Far it zoom's in 
	rosemax		= 100		-- How Far it zoom's out
	-- Crescent Rose Camera Position Settings End
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
		CrescentWeapon:CameraPos(gun)
	end)

	function SWEP:DrawHUD()
		local ply = self.Owner
		local x = 20
		local y = ScrH() - 20
		local wep = ply:GetActiveWeapon()

		-- draw.SimpleText("This is a 'WIP' Weapon of the "..self.PrintName..". Gun Mode? "..tostring(self.Gun)..". Ammo:"..ply:GetAmmoCount( wep:GetPrimaryAmmoType() ),"Default",x, y,Color(194,30,86,255))
		-- draw.SimpleText(rosepos,"Default",x, y - 20,Color(194,30,86,255))
		
		if !self.Owner:Alive() or self.Owner:InVehicle() then return end
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

	hook.Add( "CalcView", "CrescentVeiw", function( ply, pos, angles, fov )
		if ( !IsValid( ply ) or !ply:Alive() or ply:InVehicle() or ply:GetViewEntity() != ply ) then return end
		if ( !LocalPlayer().GetActiveWeapon or !IsValid( LocalPlayer():GetActiveWeapon() ) or LocalPlayer():GetActiveWeapon():GetClass() != "swep_crescent_rose" ) then return end
		local trace = util.TraceHull( {
		start = pos,
		endpos = pos - angles:Forward() * rosepos + angles:Right() * 15,
		filter = { ply:GetActiveWeapon(), ply },
		mins = Vector( -4, -4, -4 ),
		maxs = Vector( 4, 4, 4 ),
		} )
		local traent = trace.Entity
		if ( trace.HitWorld or traent:IsPlayer() or traent:IsNPC() or trace.Hit ) then pos = trace.HitPos else pos = pos - angles:Forward() * rosepos + angles:Right() * 15  end
	
		return {
			origin = pos,
			angles = angles,
			drawviewer = true
		}
	end )
	
	
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
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

SWEP.ViewModelBoneMods = {}
-- SWEP.VElements = {
	-- ["Crescent Rose"] = { type = "Model", model = "models/blueflytrap/rwby/crescent_rose.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.75, 0.5, -15), angle = Angle(-90, -5, 180), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
-- }
SWEP.WElements = {
	["Crescent Rose"] = { type = "Model", model = "models/blueflytrap/rwby/crescent_rose.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.699, 0.519, -15.065), angle = Angle(-87, 0, 180), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
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

SWEP.Primary.ClipSize = 6
SWEP.Primary.Damage = 300
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "rwby_dust"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = 30
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end

	if self.Owner:KeyDown(IN_USE) then
		if not IsFirstTimePredicted() then return end
		-- if SERVER then return end
		self:ChangeMode()
		self.ReloadingTime = CurTime() + 1
		return
	else
		if !self.Gun then
			-- self.Owner:PrintMessage(HUD_PRINTTALK,"Crescent Rose DEBUG: RELOAD FUCTION CALLED - Scythe Form")
			self.ReloadingTime = CurTime() + 1
			/*
			Getting Stuck In walls and needs more work			
			*/
			-- local ply = self.Owner
			-- local pos = ply:GetPos()
			-- local ang = ply:GetAimVector()
			-- local eye = ply:GetEyeTraceNoCursor()
			-- local DLOC1 = pos + ( ang * 1000 )
			-- local DLOC2 = pos + ( ang * 1000 )
			
			-- local spos = self.Owner:GetShootPos()
			-- local sdest = spos + (self.Owner:GetAimVector() * 1250)
			
			-- local tr_line = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
			-- local TeleLoc = tr_line.Entity
			
			-- ( trace.HitWorld or traent:IsPlayer() or traent:IsNPC() or trace.Hit ) --
			
			-- if !tr_line.HitSky == true then
				-- if (TeleLoc:IsWorld() or tr_line.Hit) then
						-- self.Owner:SetPos(eye.HitPos)
				-- else
					-- self.Owner:SetPos(DLOC1)
				-- end
			-- end
		else
			-- self.Owner:PrintMessage(HUD_PRINTTALK,"Crescent Rose DEBUG: RELOAD FUCTION CALLED - Gun Form")
			self:DefaultReload( ACT_VM_RELOAD )
			-- self:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_VM_RELOAD , true )
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
	if !self.Gun then   
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
					if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" or hitEnt:IsNPC() then
						util.Effect("BloodImpact", edata)
						self.Owner:LagCompensation(false)
						self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=self.Secondary.Damage})
					else
						util.Effect("Impact", edata)
					end
				end
			else
				self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
			end

	self.Owner:LagCompensation(false)
	else
		if( self:Clip1() > 0 ) then
			self:EmitSound("weapons/sg552/sg552-1.wav")
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			self:ShootBullet( self.Primary.Damage, 1, 0)
			self:TakePrimaryAmmo( 1 )
			self.Owner:ViewPunch( Angle( -2, 0, 0 ) )

		-- if ( SERVER && IsValid( tr.Entity ) ) then
		if ( SERVER and !self.Owner:IsOnGround()) then
			self.Owner:SetVelocity( -self.Owner:GetAimVector() * 500 )
		end
			
			
		else
			self:EmitSound("weapons/sg552/sg552_boltpull.wav")
		end
	end
	self:SetNextPrimaryFire( CurTime() + 0.9 )
end

function SWEP:TakePrimaryAmmo( num )
	if ( self:Clip1() <= 0 ) then 
 		if ( self:Ammo1() <= 0 ) then return end
 		self.Owner:RemoveAmmo( num, self:GetPrimaryAmmoType() )
 	return end
 	self:SetClip1( self:Clip1() - num )	
 end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() then return end
	if self.Gun then -- Custom Dust Type will be added later
		-- if self.Owner:KeyDown(IN_USE) then
			-- if SERVER then
				-- self.Owner:GiveAmmo( self:Clip1(), self.Primary.Ammo, true )
			-- end
				-- if self.Primary.Ammo == "rwby_dust" then

				-- self.Primary.Ammo = "pistol"
				-- self.Owner:PrintMessage(HUD_PRINTTALK,"Crescent Rose Debug: Pistol Ammo")
			-- else
				-- self.Primary.Ammo = "rwby_dust"
				-- self.Owner:PrintMessage(HUD_PRINTTALK,"Crescent Rose Debug: Regular Dust")
			-- end
			-- self:SetClip1(0)
		-- else	
			local gun = self.Gun
			self:CameraPos(gun)
		-- end
	end
	-- self.Owner:PrintMessage(HUD_PRINTTALK,"Crescent Rose Debug: SecondaryAttack Test")
end

function SWEP:CameraPos(gun)
	if SERVER then return end
	if !gun then rosecam = rosemax return end
	if rosecam == rosemax then
		rosecam = rosemin
	else
		rosecam = rosemax
	end
end

function SWEP:Think()
	self.Owner:NextThink( CurTime() )
	-- print(self.Owner)
	
	if CLIENT then
		if rosepos != rosecam then
			if rosepos > (rosecam - rosemul) then
				rosepos = rosepos - rosemul
				if rosepos < rosecam then
					rosepos = rosecam
				end
			elseif rosepos < (rosecam + (rosemul * 2)) then
				rosepos = rosepos + rosemul + (rosemul * 2)
				if rosepos > rosecam then
					rosepos = rosecam
				end
			end	
		end
	end
	
	return true;
end

function SWEP:AdjustMouseSensitivity()
	if SERVER then return end
	local YayMath = (rosepos + 500) / 600

	local mousespeed = math.Clamp( YayMath, 0.25, 1 )
	return mousespeed
end

function SWEP:ChangeMode()
	if self.Gun then
		self.Gun = false 
		self.Hold = "melee2"
	else
		self.Gun = true 
		self.Hold = "crossbow"
	end	
	if CLIENT then return end
	self:SetWeaponHoldType( self.Hold )
	net.Start("Cresent_HoldType")
		net.WriteEntity(self)
		net.WriteString(self.Hold)
	net.Broadcast()
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
	-- bullet.AmmoType 	= "rwby_dust"
	bullet.AmmoType 	= self.Primary.Ammo

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end

function SWEP:ShootEffects()
	if self.Gun then
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )	// View model animation
	self.Owner:MuzzleFlash()				// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )		// 3rd Person Animation
	end
end

function SWEP:Deploy()
	if SERVER then
		timer.Simple( 0.01, function() 
			if self.First then self.First = false return end
			self:SetWeaponHoldType( self.Hold )
			net.Start("Cresent_HoldType")
				net.WriteEntity(self)
				net.WriteString(self.Hold)
			net.Broadcast()
		end)
	end
	return true
end

function SWEP:Equip( ply )
	if ( ply:IsNPC() ) then 
		self.Gun = true
	end
end

function SWEP:ContextScreenClick() 
	return false
end