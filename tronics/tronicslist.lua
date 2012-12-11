TRANIXORDER = {
"data",
"rbutton",
"keyboard",
"add",
"subtract",
"multi",
"division",
}
TRANIX = {
	background = love.graphics.newImage("/assets/background.png"),
	add = {
		ico = "/assets/addIco.png",
		sprite = "/assets/add.png",
		source = "/tronics/add/main.lua",
		nodes = {
			{-6,21,2},
			{48,21,3},
			{12,-6,1},
			{30,-6,1},
			{21,48,0}
		}
	},
	subtract = {
		ico = "/assets/subtractIco.png",
		sprite = "/assets/subtract.png",
		source = "/tronics/subtract/main.lua",
		nodes = {
			{-6,21,2},
			{48,21,3},
			{12,-6,1},
			{30,-6,1},
			{21,48,0}
		}
	},
	multi = {
		ico = "/assets/multiIco.png",
		sprite = "/assets/multi.png",
		source = "/tronics/multi/main.lua",
		nodes = {
			{-6,21,2},
			{48,21,3},
			{12,-6,1},
			{30,-6,1},
			{21,48,0}
		}
	},
	division = {
		ico = "/assets/divisionIco.png",
		sprite = "/assets/division.png",
		source = "/tronics/division/main.lua",
		nodes = {
			{-6,21,2},
			{48,21,3},
			{12,-6,1},
			{30,-6,1},
			{21,48,0}
		}
	},
	rbutton = {
		ico = "/assets/rbuttonIco.png",
		sprite = "/assets/rbutton.png",
		source = "/tronics/rbutton/main.lua",
		preload = "/tronics/rbutton/preload.lua",
		nodes = {
			{48,21,3}
		}
	},
	keyboard = {
		ico = "/assets/keyboardIco.png",
		sprite = "/assets/keyboard.png",
		source = "/tronics/keyboard/main.lua",
		preload = "/tronics/keyboard/preload.lua",
		unload = "/tronics/keyboard/unload.lua",
		nodes = {
			{54,-6,3},
			{70,-6,0}
		},
		gui = love.graphics.newImage("/assets/keyboardGUI.png"),
		cancel = love.graphics.newImage("/assets/cancel.png"),
		save = love.graphics.newImage("/assets/save.png")
	},
	data = {
		ico = "/assets/dataIco.png",
		sprite = "/assets/data.png",
		nodes = {
			{48,21,4} --let's just use 4 for data and never talk about it ever again
		}
		--data will be hardcoded and will not have a source
	}
}
--tranixorder = the order in which tronics are displayed at the bottom (add your tronic here in the order you want it)
--ico = path to the icon file (any size, perferably 16x16)
--sprite = path to the larger image file (any size, perferably 48x48)
--source = path to the source of the tronic (see wiki)
--nodes = list of nodes located on the tronic {x relative, y relative, node enum, node description} (nodes are 6x6)
--enums for nodes:
--0: data out
--1: data in
--2: flow in
--3: flow out
--friendly reminder that you can add any assets to this list that you want and they'll be available in the scope of the functions