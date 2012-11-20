TRANIX = {
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
	data = {
		ico = "/assets/dataIco.png",
		sprite = "/assets/data.png",
		nodes = {
			{48,21,0} --techinally a dataout just for colour
		}
		--data will be hardcoded and will not have a source
	}
}
--ico = path to the icon file (any size, perferably 16x16)
--sprite = path to the larger image file (any size, perferably 48x48)
--source = path to the source of the tronic (see wiki)
--nodes = list of nodes located on the tronic {x relative, y relative, node enum, node description} (nodes are 6x6)
--enums for nodes:
--0: data out
--1: data in
--2: flow in
--3: flow out