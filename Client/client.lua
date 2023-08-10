---@diagnostic disable: param-type-mismatch, missing-parameter
--[[Token]]--
RegisterNetEvent("Fleeca:GetToken")
AddEventHandler("Fleeca:GetToken", function(key)
	ZYD.Token = key
	GetToken()
end)

TriggerServerEvent("Fleeca:GetToken")

GetToken = function()
	while ZYD.Token == nil do Wait(100) end
	local a = math.random(1,4)
	local s = tostring(GetCloudTimeAsInt())
	return {string.sub(ZYD.Token,string.sub(s,9,9),string.sub(s,9,9)),s,a,string.sub(GetGameBuildNumber(),a,a)}
end

--[[Player]]--
CreateThread(function()
	while true do
		ped = PlayerPedId()
		pid = PlayerId()
		veh = GetVehiclePedIsIn(ped,false)
		Wait(1000)
	end
end)

--[[Main thread]]--
CreateThread(function()
	while true do
		local found = false
		local playerCoords = GetEntityCoords(ped)
		for a,b in pairs(ZYD.Heists) do
			for c,d in pairs(b.Doors) do
				if not d.obj[3] and #(playerCoords-d.hack["Coords"]) < 1.0 and veh == 0 then
					if c == "Second" and not b.Doors["First"].obj[3] then break end
					found = true
					ESX.ShowHelpNotification(d.hack["Notifications"]["Help"])
					if IsControlJustPressed(0,51) then
						ESX.TriggerServerCallback("Fleeca:PoliceCount", function(count)
						if count >= ZYD.Config.RequiredCops then
							ESX.TriggerServerCallback("Fleeca:Cooldown", function(can)
								if can or c == "Second" then
								ESX.TriggerServerCallback("Fleeca:HasItem", function(has)
									if has then
										local res = StartHack(d.hack)
										if res == nil then
											-- Hack not handled correctly
										elseif res then
											ESX.ShowNotification(d.hack["Notifications"]["Success"])
											TriggerServerEvent("Fleeca:OpenDoors",a,c,GetToken())
										elseif not res then
											ESX.ShowNotification(d.hack["Notifications"]["Failure"])
										end
									else
										ESX.ShowNotification("Nie posiadasz odpowiednich przedmiotów")
									end
								end, d.hack["ItemRequired"], d.hack["RemoveItem"])
								else
									ESX.ShowNotification("Nie możesz jeszcze rozpocząć napadu!")
								end
							end)
						else
							ESX.ShowNotification("Nie ma wystarczająco funkcjonariuszy na służbie")
						end
						end)
					end
				end
			end
		end

		for _,b in pairs(ZYD.Heists) do
			if b.Doors["First"].obj[3] and b.Doors["Second"].obj[3] then
				local coords = GetEntityCoords(ped)
				for _,d in pairs(b.Loot) do
					if #(d[1]-coords) < 1.0 then
						local entity = GetClosestObjectOfType(coords, 1.5, `hei_prop_hei_cash_trolly_01`, false, false, false)
						if entity ~= 0 and not IsEntityPlayingAnim(entity, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 3) then
							found = true
							ESX.ShowHelpNotification("Naciśnij ~INPUT_CONTEXT~ aby zbierać kasę")
							if IsControlJustPressed(0,51) then
								Grab()
							end
						end
					end
				end
			end
		end

		if not found then
			Wait(1000)
		end
		Wait(3)
	end
end)

--[[Disable key while hacking]]--
DisabledKey = 0
CreateThread(function()
	while true do
		Wait(1)
		if DisabledKey ~= 0 then
			DisableControlAction(0,DisabledKey)
		else
			Wait(200)
		end
	end
end)

--[[Hack]]--
StartHack = function(hack)
	local timeout = 0
	local res
	SetCurrentPedWeapon(ped, `WEAPON_UNARMED`,true)
	DisabledKey = 73
	if #(GetEntityCoords(ped)-hack["Coords"]) > 0.02 then
		TaskGoStraightToCoord(ped, hack["Coords"], 1.0, -1, hack["Heading"], 0)
		repeat
			Wait(500)
			timeout = timeout+1
		until (#(GetEntityCoords(ped)-hack["Coords"]) < 0.02 and (GetEntityHeading(ped)-hack["Heading"] == 10 or GetEntityHeading(ped)-hack["Heading"] == -10)) or timeout == 3
	end

	if timeout == 3 then
		ClearPedTasks(ped)
		SetEntityCoords(ped,hack["Coords"].x, hack["Coords"].y, hack["Coords"].z-1)
		SetEntityHeading(ped,hack["Heading"])
	end
	FreezeEntityPosition(ped,true)
	
	local lib,anim,flag = hack["Animation"][1], hack["Animation"][2], hack["Animation"][3]
	RequestAnimDict(lib)
	while not HasAnimDictLoaded(lib) do
		Wait(1)
	end

	TaskPlayAnimAdvanced(ped, lib, anim, hack["Coords"], 0.0, 0.0, hack["Heading"], 1.0, -1.0, -1, flag, 0.0, 0, 0)

	if hack["Type"] == "keypad" then
		Wait(750)
		-- HACK
		res = true
	elseif hack["Type"] == "drill" then
		RequestModel(`hei_prop_heist_drill`)
		while not HasModelLoaded(`hei_prop_heist_drill`) do
			Wait(1)
		end
		local drill = CreateObject(`hei_prop_heist_drill`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(drill, ped, GetPedBoneIndex(ped, 28422), 0.0, 0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
		ShakeGameplayCam("ROAD_VIBRATION_SHAKE", 1.6)
		TriggerEvent("Drilling:Start",function(status)
			if status == 1 then
				res = true
			else
				res = false
			end
		end)
		while res == nil do	Wait(50) end
		ClearPedTasksImmediately(ped)
		DeleteEntity(drill)
		StopGameplayCamShaking(true)
	end

	DisabledKey = 0
	FreezeEntityPosition(ped,false)
	return res
end

--[[Sync]]--
RegisterNetEvent("Fleeca:UpdateDoors")
AddEventHandler("Fleeca:UpdateDoors", function(tab)
	ZYD.Heists = tab
end)

CreateThread(function()
	while true do
		for a,b in pairs(ZYD.Heists) do
			for c,d in pairs(b.Doors) do
				local entity = GetClosestObjectOfType(d.obj[2], 5.0, d.obj[1], false, false, false)
				if entity ~= 0 then
					if d.obj[3] then
						if d.obj[6] then
							FreezeEntityPosition(entity,false)
						end
						if math.floor(d.obj[5]) ~= math.floor(GetEntityHeading(entity)) and not d.obj[6] then
							repeat
								Wait(5)
								if math.floor(GetEntityHeading(entity)) < d.obj[5] then
									SetEntityHeading(entity, GetEntityHeading(entity)+0.6)
								else
									SetEntityHeading(entity, GetEntityHeading(entity)-0.6)
								end
							until math.floor(d.obj[5]) == math.floor(GetEntityHeading(entity))
						end
					else
						FreezeEntityPosition(entity,true)
						if math.floor(d.obj[4]) ~= math.floor(GetEntityHeading(entity)) and not d.obj[6] then
							repeat
								Wait(9)
								if math.floor(GetEntityHeading(entity)) < d.obj[4] then
									SetEntityHeading(entity, GetEntityHeading(entity)+0.6)
								else
									SetEntityHeading(entity, GetEntityHeading(entity)-0.6)
								end
							until math.floor(d.obj[4]) == math.floor(GetEntityHeading(entity))
						end
					end
				end
			end
		end
		Wait(1000)
	end
end)
--[[Functions]]--
RegisterCommand("test1",function()
	TriggerServerEvent("Fleeca:OpenDoors", "Fleeca Bank (Vespucci Blvd.)", "First", GetToken())
end)

RegisterCommand("grab",function()
	Grab()
end)

function Cash()
	RequestModel(`hei_prop_heist_cash_pile`)
	while not HasModelLoaded(`hei_prop_heist_cash_pile`) do
		Wait(10)
	end
	local handle_pile = CreateObject(`hei_prop_heist_cash_pile`, GetEntityCoords(ped), true)

	FreezeEntityPosition(handle_pile, true)
	SetEntityInvincible(handle_pile, true)
	SetEntityNoCollisionEntity(handle_pile, ped)
	SetEntityVisible(handle_pile, false, false)
	AttachEntityToEntity(handle_pile, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)

	local start = GetGameTimer()
	CreateThread(function()
		while GetGameTimer() - start < 37000 do
			Wait(1)
			DisableControlAction(0, 73, true)
			if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
				if not IsEntityVisible(handle_pile) then
					SetEntityVisible(handle_pile, true, false)
				end
			end
			if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
				if IsEntityVisible(handle_pile) then
					TriggerServerEvent("Fleeca:Reward", GetToken())
				end
			end
		end
		DeleteObject(handle_pile)
	end)
end

function Grab()
    local trolly = GetClosestObjectOfType(GetEntityCoords(ped), 1.3, `hei_prop_hei_cash_trolly_01`, false, false, false)
	local trollyCoords, trollyRotation = GetEntityCoords(trolly), GetEntityRotation(trolly)
	while not NetworkHasControlOfEntity(trolly) do
		Wait(5)
		NetworkRequestControlOfEntity(trolly)
	end

    RequestAnimDict("anim@heists@ornate_bank@grab_cash")
    RequestModel(`hei_prop_hei_cash_trolly_03`)
    while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") and not HasModelLoaded(`hei_prop_hei_cash_trolly_03`) do
        Wait(10)
    end
	Cash()

	local _scene = NetworkCreateSynchronisedScene(trollyCoords, trollyRotation, 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(ped, _scene, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(trolly, _scene, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 4.0, -8.0, 1)
	NetworkStartSynchronisedScene(_scene)

	Wait(37000)

	DeleteObject(trolly)
    local handle = CreateObject(`hei_prop_hei_cash_trolly_03`, trollyCoords + vector3(0.0, 0.0, -1.0), true)
    SetEntityRotation(handle, trollyRotation)
	FreezeEntityPosition(handle,true)
    PlaceObjectOnGroundProperly(handle)
end
