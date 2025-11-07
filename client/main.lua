local QBCore = exports['qb-core']:GetCoreObject()

local CurrentAction     = nil
local CurrentActionMsg  = nil
local CurrentActionData = nil
local Licenses          = {}
local CurrentTest       = nil
local CurrentTestType   = nil
local CurrentVehicle    = nil
local CurrentCheckPoint, DriveErrors = 0, 0
local LastCheckPoint    = -1
local CurrentBlip       = nil
--local CurrentZoneType   = nil
--local IsAboveSpeedLimit = false
local LastVehicleHealth = nil

function DrawMissionText(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, true)
end

function StartTheoryTest()
	CurrentTest = 'theory'

	SendNUIMessage({
		openQuestion = true
	})

	SetTimeout(200, function()
		SetNuiFocus(true, true)
	end)
end

function StopTheoryTest(success)
	CurrentTest = nil

	SendNUIMessage({
		openQuestion = false
	})

	SetNuiFocus(false)

	if success then
		TriggerServerEvent('qb-flightschool:server:AddLicense', 'theorytest')
		QBCore.Functions.Notify(Lang:t("passed_test"), "success")
	else
		QBCore.Functions.Notify(Lang:t("failed_test"), "error")
	end
end

function StartFlightTest(type)
    print("spawn")
	-- START DEBUG LINES
	-- Some debugging console information in case your vehicle isnt spawning comment out if you dont want them
	print("Flight test type", type)
	local model = Config.VehicleModels[type]
	print("Vehicle model to spawn:", model)

	-- more debug to check if the vehicle model exists comment these out if you dont want them
	if not model then
		print("ERROR: No Vehicle model found for type:", type)
		return
	end
	-- END DEBUG LINES
    QBCore.Functions.SpawnVehicle(Config.VehicleModels[type], function(vehicle)
        print("spawned")

        -- Vehicle setup
        SetVehicleNumberPlateText(vehicle, "TESTDRIVE" .. tostring(math.random(1000, 9999)))
        SetEntityHeading(vehicle, Config.Zones.VehicleSpawnPoint.Pos.h)
		SetVehicleFuelLevel(vehicle, 100.0)

        -- Wait until vehicle exists and is networked
        local playerPed = PlayerPedId()
        local attempts = 0
        while not DoesEntityExist(vehicle) and attempts < 50 do
            Citizen.Wait(100)
            attempts = attempts + 1
        end

        -- Additional check: if player is not in vehicle, warp
        if not IsPedInVehicle(playerPed, vehicle, false) then
            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        end

        -- Vehicle keys and other setup
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
        SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
        SetVehicleEngineOn(vehicle, true, true)
        SetVehicleDirtLevel(vehicle)
        SetVehicleUndriveable(vehicle, false)
        WashDecalsFromVehicle(vehicle, 1.0)

        -- Flight test state
        CurrentTest       = 'flight'
        CurrentTestType   = type
        CurrentCheckPoint = 0
        LastCheckPoint    = -1
        DriveErrors       = 0
        CurrentVehicle    = vehicle
        LastVehicleHealth = GetEntityHealth(vehicle)
    end, Config.Zones.VehicleSpawnPoint.Pos, true)
end

-- changed original function to grant the appropriate item on completion includes debug console information
-- Stop the flight test (client-side)
function StopFlightTest(success)
    if success then
        QBCore.Functions.Notify(Lang:t("passed_test"), "success")

        -- Trigger server-side item removal and license grant
        if CurrentTestType then
            TriggerServerEvent('qb-flightschool:server:CompleteTest', CurrentTestType)
        else
            print("WARNING: CurrentTestType is nil, cannot give license")
        end

        -- Trigger server license logic if needed
        TriggerServerEvent('qb-flightschool:server:AddLicense', CurrentTestType)
    else
        QBCore.Functions.Notify(Lang:t("failed_test"), "error")
    end

    CurrentTest     = nil
    CurrentTestType = nil
end




--- Rewritten by Byanski_the_Dev for QBox ---
function OpenFlightSchoolMenu()
    local menuOptions = {}

    -- Add the menu header
    menuOptions[#menuOptions+1] = {
        title = Lang:t("driving_school"),
        description = nil,
        disabled = true
    }

    -- Add each license option
    for k, v in pairs(Config.Licenses) do
        menuOptions[#menuOptions+1] = {
            title = v.name,
            description = Lang:t('school_item', { value = v.price }),
            serverEvent = 'qb-flightschool:server:StartTest', -- ✅ fixed
            args = { type = k }
        }
    end

    -- Add a Close option
    menuOptions[#menuOptions+1] = {
        title = 'Close Menu',
        event = 'lib:closeMenu' -- ✅ this is fine, handled by ox_lib
    }

    -- Register and show the menu
    lib.registerContext({
        id = 'flight_school_menu',
        title = Lang:t("driving_school"),
        options = menuOptions
    })

    lib.showContext('flight_school_menu')
end


RegisterNUICallback('question', function(data, cb)
	SendNUIMessage({
		openSection = 'question'
	})
	cb()
end)

RegisterNUICallback('close', function(data, cb)
	StopTheoryTest(true)
	cb()
end)

RegisterNUICallback('kick', function(data, cb)
	StopTheoryTest(false)
	cb()
end)

RegisterNetEvent('qb-flightschool:client:StartTest', function(type)
	if type == "theorytest" then
		StartTheoryTest()
	else
		StartFlightTest(type)
	end
end)

--Creation Markers
local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

--Create markers for flight school
CreateThread(function()
    while true do
        Wait(5)
        local inRange = false
        local pos = GetEntityCoords(PlayerPedId())
		local SchoolDistance = #(pos - Config.Zones.FlightSchool.Pos)
		if SchoolDistance < 20 then
			inRange = true
			DrawMarker(2, Config.Zones.FlightSchool.Pos.x, Config.Zones.FlightSchool.Pos.y, Config.Zones.FlightSchool.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)
			if SchoolDistance < 1 then
				DrawText3Ds(Config.Zones.FlightSchool.Pos.x, Config.Zones.FlightSchool.Pos.y, Config.Zones.FlightSchool.Pos.z, Lang:t('drive_school_e'))
				if IsControlJustReleased(0, 38) then
					OpenFlightSchoolMenu()
				end
			end
		end                
        if not inRange then
            Wait(1000)
        end
    end
end)

--Create Blip for School
CreateThread(function()
	local SchoolFlBlip = AddBlipForCoord(Config.Zones.FlightSchool.Pos.x, Config.Zones.FlightSchool.Pos.y, Config.Zones.FlightSchool.Pos.z)
	SetBlipSprite(SchoolFlBlip, 251)
	SetBlipColour(SchoolFlBlip, 4)
	SetBlipScale(SchoolFlBlip, 0.6)
	SetBlipDisplay(SchoolFlBlip, 4)
	SetBlipAsShortRange(SchoolFlBlip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(Lang:t('driving_school_blip'))
	EndTextCommandSetBlipName(SchoolFlBlip)
end)



-- Block UI
CreateThread(function()
	while true do
		Wait(1)

		if CurrentTest == 'theory' then
			local playerPed = PlayerPedId()

			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisablePlayerFiring(playerPed, true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		else
			Wait(500)
		end
	end
end)

-- Drive test
CreateThread(function()
	while true do

		Wait(0)

		if CurrentTest == 'flight' then
			local playerPed      = PlayerPedId()
			local coords         = GetEntityCoords(playerPed)
			local nextCheckPoint = CurrentCheckPoint + 1

			if Config.CheckPoints[nextCheckPoint] == nil then
				if DoesBlipExist(CurrentBlip) then
					RemoveBlip(CurrentBlip)
				end

				CurrentTest = nil

				QBCore.Functions.Notify(Lang:t("driving_test_complete"), "primary")

				if DriveErrors < Config.MaxErrors then
					StopFlightTest(true)
				else
					StopFlightTest(false)
				end
			else

				if CurrentCheckPoint ~= LastCheckPoint then
					if DoesBlipExist(CurrentBlip) then
						RemoveBlip(CurrentBlip)
					end

					CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
					SetBlipRoute(CurrentBlip, 1)

					LastCheckPoint = CurrentCheckPoint
				end

				local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)

				if distance <= 7000.0 then
					DrawMarker(6, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 20.5, 20.5, 20.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
				end

				if distance <= 3.0 then
					Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle)
					CurrentCheckPoint = CurrentCheckPoint + 1
				end
			end
		else
			-- not currently taking driver test
			Wait(500)
		end
	end
end)

-- Speed / Damage control
CreateThread(function()
	while true do
		Wait(10)

		if CurrentTest == 'flight' then

			local playerPed = PlayerPedId()

			if IsPedInAnyVehicle(playerPed, false) then

				local vehicle      = GetVehiclePedIsIn(playerPed, false)
				local health = GetEntityHealth(vehicle)
				if health < LastVehicleHealth then

					DriveErrors = DriveErrors + 1

					QBCore.Functions.Notify(Lang:t("you_damaged_veh"), "error")
					QBCore.Functions.Notify(Lang:t("errors", {value = DriveErrors, value2 = Config.MaxErrors}), "error")

					-- avoid stacking faults
					LastVehicleHealth = health
					Wait(1500)
				end
			end
		else
			-- not currently taking driver test
			Wait(500)
		end
	end
end)
