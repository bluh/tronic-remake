mode = "OFF"
mousex,mousey = 0,0
mdrag = nil
draw = {}
tronics = {
	id = 0,
	acts = {},
	dats = {},
	wires = {}
}

function addDraw(dr,x,y,id)
	if id then
		draw[id] = {dr,x,y}
	else
		table.insert(draw,{dr,x,y})
	end
end

function finalTron(b,k,x,y)
	local newid = b.id.."~"..tronics.id + 1
	tronics.id = tronics.id + 1
	x,y = x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2)
	x,y = x - (x % 5),y - (y % 5)
	tronics.acts[newid] = boxClicks:addBox(x,y,mdrag:getWidth(),mdrag:getHeight(),newid)
	addDraw(mdrag,x,y,newid)
	boxClicks:removeBox("mDrag")
	mode = "ON"
end

function newTron(b,k,x,y)
	mode = "DRAG"
	mdrag = love.graphics.newImage(TRANIX[b.id].sprite)
	boxClicks:addBox(x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2),mdrag:getWidth(),mdrag:getHeight(),"mDrag"):setCallback(finalTron,"release")
end

function love.load()
	mode = "LOADING"
	loadBC = love.filesystem.load("/boxClicks/init.lua") or error("could not find boxClicks library! try reinstalling")
	loadTC = love.filesystem.load("/tronics/tronicslist.lua") or error("could not find tronics list! try reinstalling")
	loadBC() --why
	loadTC()
	local d = 20
	for i,x in pairs(TRANIX) do --draw icons
		d = d + 20
		x.icon = love.graphics.newImage(x.ico)
		addDraw(x.icon,d,540,i)
		boxClicks:addBox(d,540,x.icon:getWidth(),x.icon:getHeight(),i):setCallback(newTron,"click")
	end
	mode = "ON"
end

function love.mousepressed(x,y)
	boxClicks:sendCallbacks(x,y,"click")
end

function love.mousereleased(x,y)
	boxClicks:sendCallbacks(x,y,"release")
end

function love.draw()
	if mode ~= "OFF" and mode ~= "LOADING" then
		mousex,mousey = love.mouse.getX(),love.mouse.getY()
		boxClicks:sendCallbacks(mousex,mousey,"move")
		for i,x in pairs(draw) do
			love.graphics.draw(x[1],x[2],x[3])
		end
		if mode == "DRAG" then
			love.graphics.draw(mdrag,mousex - (mdrag:getWidth()/2),mousey - (mdrag:getHeight()/2))
			boxClicks:updateBox("mDrag",mousex - (mdrag:getWidth()/2),mousey - (mdrag:getHeight()/2))
		end
	end
end