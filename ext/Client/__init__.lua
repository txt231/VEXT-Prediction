

function Predict(weapon, deltaTime)


    if weapon == nil then
        return nil
    end


    local WeaponData = weapon.data
    if WeaponData == nil then
        return nil
    end

	-- Upcast
    WeaponData = _G[WeaponData.typeInfo.name](WeaponData)

    local FiringData = WeaponData.weaponFiring

    if FiringData == nil then
        return nil
    end

    local PrimaryFire = FiringData.primaryFire

    if PrimaryFire == nil then
        return nil
    end

    local ProjectileData = PrimaryFire.shot.projectileData

    if ProjectileData == nil then
        return nil
    end

    -- nice upcast
    ProjectileData = _G[ProjectileData.typeInfo.name](ProjectileData)

    if not ProjectileData:Is("BulletEntityData") and 
       not ProjectileData:Is("GrenadeEntityData") and 
       not ProjectileData:Is("MissileEntityData") then
        return nil
    end 


    local HitPositions = {}


    -- yo, where the hell is ClientWeapon and Shootspace
    local Shootspace = ClientUtils:GetCameraTransform()


    local Velocity = Shootspace.left*PrimaryFire.shot.initialSpeed.x + Shootspace.up*PrimaryFire.shot.initialSpeed.y + Shootspace.forward*(-1.0*PrimaryFire.shot.initialSpeed.z)
    local CurrentPosition = Shootspace.trans + PrimaryFire.shot.initialPosition--+ Shootspace.left*PrimaryFire.shot.initialSpeed.x + Shootspace.up*PrimaryFire.shot.initialSpeed.y + Shootspace.forward*PrimaryFire.shot.initialSpeed.z

    local TimeToLive = ProjectileData.timeToLive
    local Stop = false

    local LastHitPosition = CurrentPosition

    while TimeToLive >= 0 do
        
        if Stop == true then
			-- lua has no break, only gotos iirc
            return HitPositions
        end

        local Normal = Vec3(0,0,0)
        local Bounced = false

        local NextPosition = CurrentPosition + Velocity*deltaTime

        local hit = RaycastManager:Raycast(CurrentPosition, NextPosition, RayCastFlags.CheckDetailMesh | RayCastFlags.DontCheckWater)

        if hit ~= nil then

            local IsPassingThrough = false


            --if hit.material & MaterialFlags.MfPenetrable then
            --    IsPassingThrough = true
            --end

            
            

            Normal = hit.normal
            
			-- should maybe cache theese checks, so it doesnt do it every loop
            if ProjectileData:Is("GrenadeEntityData") then

                local HitDistance = LastHitPosition:Distance(hit.position)
                local RealDistance = CurrentPosition:Distance(NextPosition)

                


                LastHitPosition = hit.position

                if IsPassingThrough == false then

                    --print("HitDistance " .. tostring(HitDistance))
                    --print("CalcDistance " .. tostring(RealDistance))

                    if Velocity.magnitude >= ProjectileData.minBounceSpeed then

						-- i cant remember why i added this check, might be for the ghetto raycast fix
                        if HitDistance > (deltaTime*0.2) then

                            Velocity = Velocity + hit.normal*(-2.0*Velocity:Dot(hit.normal))

                            Velocity = Velocity * ProjectileData.collisionSpeedMultiplier

                            -- ghetto raycast fix
                            NextPosition = hit.position

                            --NextPosition = NextPosition + Velocity*(deltaTime*0.2)

                            Bounced = true
                        end
                    else
                        Velocity = Vec3(0,0,0)
                        Stop = true
                    end
                end

            else
                if IsPassingThrough == true then
                    Stop = false
                else
                    Stop = true
                end
            end
        end

        

        HitPositions[#HitPositions+1]= {
            currentPosition = CurrentPosition,
            nextPosition = NextPosition,
            normal = Normal,
            stop = Stop,
            bounced = Bounced,
        }

        CurrentPosition = NextPosition

        Velocity.y = Velocity.y + (ProjectileData.gravity*deltaTime)


        if ProjectileData:Is("MissileEntityData") then
            local Direction = Vec3(0,0,0)

            if Velocity.magnitude > 0.0 then
                Direction = Velocity:Normalize()
            end

            local Speed = Velocity.magnitude + ProjectileData.engineStrength*deltaTime

            if Speed > ProjectileData.maxSpeed then
                Speed = ProjectileData.maxSpeed
            end

            Velocity = Direction*Speed
        end

        TimeToLive = TimeToLive - deltaTime
    end

    return HitPositions 
end


Events:Subscribe("UI:DrawHud", function(a)


    local localPlayer = PlayerManager:GetLocalPlayer()

    if localPlayer == nil then
        return
    end

    local soldier = localPlayer.soldier

    if soldier == nil then
        return
    end

    local weaponsComponent = soldier.weaponsComponent

    if weaponsComponent == nil then
        return
    end

    local weapon = weaponsComponent.currentWeapon

    if weapon == nil then
        return
    end

	-- doing this with 30 tickrate, should use real tickrate (might degrade performance)	
    local Results = Predict(weapon, 1.0/30.0)

    if Results == nil then
        return
    end

    for i, j in pairs(Results) do

        DebugRenderer:DrawLine(j.currentPosition, j.nextPosition,Vec4(0,1,0,0.5), Vec4(0,1,0,0.5))

        if j.stop == true then
            DebugRenderer:DrawSphere(j.nextPosition,0.2,Vec4(1,0,0,0.2), false, false)
        elseif j.bounced == true then
            DebugRenderer:DrawSphere(j.nextPosition,0.1,Vec4(0,0,1,0.2), false, false)
        end
    end

end)