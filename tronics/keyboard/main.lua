box = ...

function sense(b,k,x,y)
	if not keyboardgui:check(x,y) then
		grabInput = false
		drawInput = {drawInput[1] or "",160,17,{255,255,255},true}
	else
	focus()
	end
end

function focus(b)
	grabInput = true
	drawInput = {drawInput[1] or "",160,17,{255,255,255}}
end

function cancel(b)
	TRANIX.keyboard.funload(box) --haha
end

function save(b)
	grabInput = false
	sendData(box.id,1,inputHandler:getInput())
	flowOut(box.id,0)
end

function updatekb(s,k)
	if s:len() > 35 then
		s = "..."..s:sub(s:len()-39,s:len())
	end
	drawInput = {s,160,17,{255,255,255}}
end

inputHandler:setInput()
inputHandler:setKeypressFunction(updatekb)
inputHandler:setEnterCallback(save)
box = TRANIX.keyboard.funload(box) --dont ask
focus()
addDraw(TRANIX.keyboard.gui,151,14,"keyboardgui")
addDraw(TRANIX.keyboard.save,160,32,"savegui")
addDraw(TRANIX.keyboard.cancel,432,32,"cancelgui")
keyboardgui = boxClicks:addBox(160,16,338,16,"keyboardgui")
keyboardgui:setCallback(focus,"occlick") --Overlay Compute CLICK
savegui = boxClicks:addBox(160,32,64,16,"savegui")
savegui:setCallback(save,"occlick")
cancelgui = boxClicks:addBox(432,32,64,16,"cancelgui")
cancelgui:setCallback(cancel,"occlick")
sensor = boxClicks:addBox(0,0,800,600,"sensor")
sensor:setCallback(sense,"occlick")