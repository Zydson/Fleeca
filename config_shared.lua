ESX = exports["es_extended"]:getSharedObject()
ZYD = {
	Config = {
		Cooldown = 3600, -- Seconds
		RequiredCops = 0,
		Rewards = { --  Types: item, money | Count: {min,max} | Chances: 1-100
			{type = "money", account = "black_money", count = {1000,5000}, chances = 100}
		}
	},

	Heists = {
		["Fleeca Bank (Vespucci Blvd.)"] = {
			Loot = {
				{vector3(146.671082, -1049.883545, 28.825514), 87.81},
				{vector3(149.451538, -1051.175781, 28.826668),161.95},
				{vector3(150.540024, -1048.417114, 28.832388),301.55}
			},
			Doors = {
				["First"] = {
					obj = {2121050683, vector3(148.026611, -1044.363892, 29.506931), false, 249.8, 160.0, false}, -- Doors hash, coords, state, deafult heading, opened heading, collision
					hack = {
						["Type"] = "drill",
						["Notifications"] = {
							["Help"] = "Naciśnij ~INPUT_CONTEXT~ aby zacząć wiercić",
							["Success"] = "Udało ci się przewiercić drzwi",
							["Failure"] = "Wiertło się przegrzało i pękło",
						},
						["Coords"] = vector3(146.97480773926, -1045.1481933594, 29.36802482605),
						["Heading"] = 251.3,
						["ItemRequired"] = "drill",
						["RemoveItem"] = true,
						["Animation"] = {"anim@heists@fleeca_bank@drilling","drill_straight_idle",2}, -- Lib, anim, flag
					}
				},
				["Second"] = {
					obj = {-1591004109, vector3(150.291321, -1047.629028, 29.666298), false, 160.0, 160.0, true},
					hack = {
						["Type"] = "keypad",
						["Notifications"] = {
							["Help"] = "Naciśnij ~INPUT_CONTEXT~ aby rozpocząć hackowanie",
							["Success"] = "Udało ci się zhackować keypad'a",
							["Failure"] = "Hack nieudany, spróbuj ponownie",
						},
						["Coords"] = vector3(148.87586975098, -1046.0334472656, 29.346282958984),
						["Heading"] = 157.5,
						["ItemRequired"] = "accesscard",
						["RemoveItem"] = true,
						["Animation"] = {"anim@heists@keycard@","enter",0},
					}
				}
			}
		}
	}
}
