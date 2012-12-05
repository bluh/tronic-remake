box = ...

function focus(b)
end

function cancel(b)
end

function save(b)
print("SEND STRONG")
sendData(box.id,1,"STRoNG")
flowOut(box.id,0)
end

--TODO: switch out keyboard if there is one
addDraw(TRANIX.keyboard.gui,151,14,"keyboardgui")
addDraw(TRANIX.keyboard.save,160,32,"savegui")
addDraw(TRANIX.keyboard.cancel,432,32,"cancelgui")
keyboardgui = boxClicks:addBox(160,16,338,16,"keyboardgui")
keyboardgui:setCallback(focus,"occlick") --Overlay Compute CLICK
savegui = boxClicks:addBox(160,32,32,16,"savegui")
savegui:setCallback(save,"occlick")