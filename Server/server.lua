---@diagnostic disable: param-type-mismatch
ZYD.TokenLoaded = {}
ZYD.Cooldown = true
ZYD.Police = {
	["Count"] = 0,
	["CD"] = false,
}
ValidateToken = function(token)
	local s = os.time()
	local fraudScore = 0
	if token[1] ~= string.sub(ZYD.TokenLoaded[source],string.sub(s,9,9),string.sub(s,9,9)) then
		if tostring(string.sub(s,9,9)-1) == string.sub(token[2],9,9) or string.sub(s,9,9)-1 == -1 then
			if string.sub(s,9,9)-1 == 0 then
				if token[1] ~= "" then
					fraudScore = fraudScore+1
				end
			elseif string.sub(s,9,9)-1 == -1 then
				if token[1] ~= string.sub(ZYD.TokenLoaded[source],9,9) then
					fraudScore = fraudScore+1
				end
			else
				if token[1] ~= string.sub(ZYD.TokenLoaded[source],string.sub(s,9,9)-1,string.sub(s,9,9)-1) then
					fraudScore = fraudScore+1
				end
			end
		elseif string.sub(s,9,9) == 0 and string.sub(token[2],9,9) == 9 then
			if token[1] ~= string.sub(ZYD.TokenLoaded[source],9,9) then
				fraudScore = fraudScore+1
			end
		else
			fraudScore = fraudScore+1
		end
	end
	if s-token[2] > 3 then
		fraudScore = fraudScore+1
	end
	if token[4] ~= string.sub("2944",token[3],token[3]) then
		fraudScore = fraudScore+1
	end
	if fraudScore ~= 0 then
		return false
	else
		return true
	end
end

--[[EVENTS]]--
RegisterNetEvent("Fleeca:GetToken")
AddEventHandler("Fleeca:GetToken", function()
	if ZYD.TokenLoaded[source] == nil then
		ZYD.TokenLoaded[source] = GetPlayerToken(source,0)
		TriggerClientEvent("Fleeca:GetToken", source, ZYD.TokenLoaded[source])
	end
end)


RegisterNetEvent("Fleeca:OpenDoors")
AddEventHandler("Fleeca:OpenDoors", function(main,doors,token)
	if ValidateToken(token) then
		if doors == "First" then
			StartCooldown()
			for _,b in pairs(ZYD.Heists[main].Loot) do
				local handle = CreateObject(`hei_prop_hei_cash_trolly_01`, b[1].x, b[1].y, b[1].z-0.5, true, true, false)
				SetEntityHeading(handle,b[2]+180.0)
				FreezeEntityPosition(handle,true)
			end
			-- TODO: notify police
		end
		ZYD.Heists[main].Doors[doors].obj[3] = true
		TriggerClientEvent("Fleeca:UpdateDoors", -1, ZYD.Heists)
	end
end)

RegisterNetEvent("Fleeca:Reward")
AddEventHandler("Fleeca:Reward", function(token)
	if ValidateToken(token) then
		local xPlayer = ESX.GetPlayerFromId(source)
		for _,b in pairs(ZYD.Config.Rewards) do
			if b.chances >= math.random(1,100) then
				if b.type == "item" then
					xPlayer.addInventoryItem(b.item, math.random(b.count[1],b.count[2]))
				else
					xPlayer.addAccountMoney(b.account, math.random(b.count[1],b.count[2]))
				end
			end
		end
	end
end)

ESX.RegisterServerCallback("Fleeca:HasItem", function(source,cb,item,remove)
	local xPlayer = ESX.GetPlayerFromId(source)
	local has = (xPlayer.getInventoryItem(item).count > 0)
	if has and remove then
		xPlayer.removeInventoryItem(item, 1)
	end
	cb(has)
end)

ESX.RegisterServerCallback("Fleeca:Cooldown", function(source,cb)
	cb(ZYD.Cooldown)
end)

ESX.RegisterServerCallback("Fleeca:PoliceCount", function(source,cb)
	local count = CountPolice()
	cb(count)
	Wait(30000)
	if ZYD.Police["CD"] then ZYD.Police["CD"] = false end
end)

--[[Functions]]--
function StartCooldown()
	CreateThread(function()
		ZYD.Cooldown = false
		Wait(ZYD.Config.Cooldown*1000)
		ZYD.Cooldown = true
		for _,b in pairs(GetAllObjects()) do
			Wait(0)
			if GetEntityModel(b) == `hei_prop_hei_cash_trolly_01` or GetEntityModel(b) == `hei_prop_hei_cash_trolly_03` then
				DeleteEntity(b)
			end
		end
	end)
end

function CountPolice()
	if not ZYD.Police["CD"] then
		ZYD.Police["CD"] = true
		ZYD.Police["Count"] = 0
		for i=0, (GetNumPlayerIndices()-1) do 
			if ESX.GetPlayerFromId(GetPlayerFromIndex(i)).getJob().name == "police" then ZYD.Police["Count"] = ZYD.Police["Count"]+1 end
		end
	end
	return ZYD.Police["Count"]
end
