---@diagnostic disable: param-type-mismatch
ZYD.TokenLoaded = {}
ZYD.LastHeist = 0

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
			ZYD.LastHeist = os.time()
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
		for a,b in pairs(ZYD.Config.Rewards) do
			if b.chances <= math.random(1,100) then
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
	cb(ZYD.LastHeist+ZYD.Config.Cooldown-os.time()<=0)
end)