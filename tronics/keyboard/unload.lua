box = ...
if keyboardgui then
	removeDraw("keyboardgui")
	removeDraw("savegui")
	removeDraw("cancelgui")
	boxClicks:removeBox("keyboardgui")
	boxClicks:removeBox("savegui")
	boxClicks:removeBox("cancelgui")
end
