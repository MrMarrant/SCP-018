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

AddCSLuaFile()
AddCSLuaFile( "cl_init.lua" )

SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.Spawnable = true

SWEP.Category = "SCP"
SWEP.ViewModel = Model( "models/weapons/v_scp018.mdl" )
SWEP.WorldModel = ""

SWEP.ViewModelFOV = 65
SWEP.HoldType = "fist"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false

-- Variables Personnal to this weapon --
-- [[ STATS WEAPON ]]
SWEP.PrimaryCooldown = 3

function SWEP:Initialize()
end

function SWEP:Deploy()
	local ply = self:GetOwner()
	local speedAnimation = GetConVarNumber( "sv_defaultdeployspeed" )
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetPlaybackRate( speedAnimation )
	local VMAnim = ply:GetViewModel()
	local NexIdle = VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate() 
	self:SetNextPrimaryFire( CurTime() + NexIdle )
	self:SetNextSecondaryFire( CurTime() + NexIdle )
	timer.Simple(NexIdle, function()
		if(!self:IsValid()) then return end
		self:SendWeaponAnim( ACT_VM_IDLE )
	end)
	return true
end

function SWEP:OnDrop()
	local ply = self:GetOwner()
	local SCP018 = ents.Create( "scp_018" )
	SCP018:SetPos(ply:GetPos() + ply:GetAngles():Up() * 10 + ply:GetAngles():Forward()*10)
	SCP018:Spawn()
	SCP018:Activate()
	local Phys = self:GetPhysicsObject()

end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	self:SetNextPrimaryFire( CurTime() + self.PrimaryCooldown )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	local VMAnim = self:GetOwner():GetViewModel()
	local NexIdle = VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate()
	NexIdle = NexIdle - 0.3
	timer.Simple(NexIdle, function()
		if(!self:IsValid()) then return end
		self:DropSCP018(false)
	end)
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	self:SetNextSecondaryFire( CurTime() + self.PrimaryCooldown )
	self:DropSCP018(true)
end

function SWEP:DropSCP018(OnGround)
	local Ply = self:GetOwner()
	local LookForward = Ply:EyeAngles():Forward()
	local LookUp = Ply:EyeAngles():Up()
	local SCP018 = ents.Create( "scp_018" )
	local DistanceToPos = OnGround and 50 or 30
	local PosObject = Ply:GetShootPos() + LookForward * DistanceToPos + LookUp
	if (OnGround) then
		PosObject.z = Ply:GetPos().z
	end
	SCP018:SetPos( PosObject )
	SCP018:SetAngles( Ply:EyeAngles() )
	SCP018:Spawn()
	SCP018:Activate()
	local Phys = SCP018:GetPhysicsObject()
	if (!OnGround) then
		local Velocity = Ply:GetAimVector()
		Velocity = Velocity * 200 + LookUp * 200
		Velocity = Velocity + (VectorRand() * 5) 
		Phys:SetVelocity( Velocity )
	end
	Phys:AddAngleVelocity(Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5))*5)
	self:Remove()
end