box = ...
grabInput = false
if keyboardgui then
	removeDraw("keyboardgui")
	removeDraw("savegui")
	removeDraw("cancelgui")
	boxClicks:removeBox("keyboardgui")
	boxClicks:removeBox("savegui")
	boxClicks:removeBox("cancelgui")
	boxClicks:removeBox("sensor")
	drawInput = {}
end
return box
