-- SCP-018, A representation of a paranormal object on a fictional series on the game Garry's Mod.
-- Copyright (C) 2023  MrMarrant aka BIBI.

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

AddCSLuaFile("shared.lua")
include("shared.lua")

local MultSpeed = {}
MultSpeed[0] = 2
MultSpeed[1] = 2
MultSpeed[2] = 0.9
MultSpeed[3] = 0.5

function ENT:Initialize()
	self:SetModel( "models/bouncy_ball/bouncy_ball.mdl" )
	self:RebuildPhysics()
end

function ENT:RebuildPhysics( value )
	local size = 2
	self:PhysicsInitSphere( size, "metal_bouncy" )
	self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysWake()
end

local BounceSound = Sound( "bouncy_ball/ball_noise.mp3" )

function ENT:PhysicsCollide( data, physobj )
	if ( data.Speed > 50 and data.DeltaTime > 0.01) then
		sound.Play( BounceSound, self:GetPos(), 75, math.random( 50, 160 ) )	
	end
	if (data.HitEntity:IsPlayer()) then
		if (data.Speed > 200) then
			data.HitEntity:TakeDamage( data.Speed/30, self, self )
		end
	else
		if (data.Speed > 1500) then
			if data.HitEntity:GetClass() == "func_door" or data.HitEntity:GetClass() == "prop_door_rotating" then
				data.HitEntity:Fire("open")
			else
				data.HitEntity:TakeDamage( 200, self, self )
			end
		end
	end

	-- Bounce like a crazy bitch
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()

	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	local TargetVelocity = NewVelocity * LastSpeed * MultSpeed[self:WaterLevel()]
	physobj:SetVelocity( TargetVelocity )

end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:Use( ply)
	if (self:IsNotMoving()) then
		self:Remove()
		ply:Give("swep_scp018")
	end
end

function ENT:IsNotMoving()
	local Phys = self:GetPhysicsObject()
	if (Phys:GetVelocity():Length() <= 100 or self:GetMoveType() == MOVETYPE_NONE ) then
		return true
	end
	return false
end