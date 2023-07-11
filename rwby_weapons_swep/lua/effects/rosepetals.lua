function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	local emitter = ParticleEmitter(Pos)

	for i = 1, 1 do
		local particle = emitter:Add("vgui/rwbyeffect/effect_rosepetal", Pos + Vector(math.random(-16, 16), math.random(-16, 16), math.random(0, 64)))

		if particle == nil then
			particle = emitter:Add("vgui/rwbyeffect/effect_rosepetal", Pos + Vector(math.random(-16, 16), math.random(-10, 10), math.random(0, 64)))
		end

		if particle then
			particle:SetVelocity(Vector(0, 0, 0))
			particle:SetLifeTime(3)
			particle:SetDieTime(10)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(1.5)
			particle:SetEndSize(0.1)
			particle:SetAngles(Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)))
			particle:SetAngleVelocity(Angle(0, 0, 0))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetColor(math.random(72, 255), math.random(9), math.random(9), 255)
			particle:SetGravity(Vector(0, 0, -10))
			particle:SetAirResistance(0)
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end