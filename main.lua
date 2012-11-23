mode = "OFF"
screenx,screeny = 0,0
mousex,mousey = 0,0
--dragging vars
mdrag = nil
idrag = 0
kdrag = ""
--wire vars
wire = {}
--
draw = {}
tronics = {
	id = 0,
	acts = {},
	nodes = {},
	dats = {},
	wires = {}
}

function love.load()
	mode = "LOADING"
	love.graphics.setLine(4,"smooth")
	love.graphics.setIcon(love.graphics.newImage("/assets/icon.png"))
	love.filesystem.load("/boxClicks/init.lua")()
	love.filesystem.load("/tronics/tronicslist.lua")()
	love.filesystem.load("/functions.lua")()
	local d = 8
	for i,x in pairs(TRANIX) do --time to start fucking colouring these icons, kids
		d = d + 16
		x.icon = love.graphics.newImage(x.ico)
		addDraw(x.icon,d,545,i)
		boxClicks:addBox(d,545,x.icon:getWidth(),x.icon:getHeight(),i):setCallback(newTron,"click")
		if x.source then
			x.fsource = love.filesystem.load(x.source)
		end
		if x.preload then
			x.fpreload = love.filesystem.load(x.preload)
		end
		if x.unload then
			x.funload = love.filesystem.load(x.unload)
		end
	end
	background = love.graphics.newImage("/assets/background.png") --whatever
	addDraw(love.graphics.newImage("/assets/go.png"),16,16,"go")
	boxClicks:addBox(16,16,32,32,"go"):setCallback(startCompute,"click")
	mode = "ON"
end

function love.mousepressed(x,y,k)
	if k == "l" then
		if mode ~= "WIRE" then
			if mode ~= "COMPUTE" then
				boxClicks:sendCallbacks(x,y,"click")
			else
				boxClicks:sendCallbacks(x,y,"cclick")
			end
		else
			boxClicks:sendCallbacks(x,y,"wclick")
		end
	elseif k == "r" then
		if mode ~= "WIRE" then
			if mode ~= "COMPUTE" then
				boxClicks:sendCallbacks(x,y,"rclick")
			else
				boxClicks:sendCallbacks(x,y,"cclick")
			end
		else
			mode = "ON"
			wire = {}
		end
		if mode == "ON" then
			for i,_ in pairs(tronics.wires) do
				if pointOnWire(i,x,y) then
					removeWire(i)
				end
			end
		end
	elseif k == "m" then
		boxClicks:sendCallbacks(x,y,"mclick")
	end
end

function love.mousereleased(x,y)
	boxClicks:sendCallbacks(x,y,"release")
end

--[[function love.keypressed(k)
	if k == "up" then
		screeny = screeny - 16
	elseif k == "down" then
		screeny = screeny + 16
	elseif k == "right" then
		screenx = screenx + 16
	elseif k == "left" then
		screenx = screenx - 16
	elseif k == " " then
		screenx,screeny = 0,0
	end
end]] --probably gonna make screen scrolling a thing someday

function love.draw()
	if mode ~= "OFF" and mode ~= "LOADING" then
		mousex,mousey = love.mouse.getX(),love.mouse.getY()
		boxClicks:sendCallbacks(mousex,mousey,"move")
		love.graphics.draw(background,0,0) --must be called first
		for _,x in pairs(draw) do
			love.graphics.draw(x[1],x[2],x[3])
		end
		for i,w in pairs(tronics.wires) do
			if not pointOnWire(i,mousex,mousey) then
				love.graphics.setColor(w[3])
			else
				love.graphics.setColor(math.min(255,w[3][1] + 80),math.min(255,w[3][2] + 80),math.min(255,w[3][3] + 80))
			end
			b1 = boxClicks:getBoxFromId(w[1].id)
			b2 = boxClicks:getBoxFromId(w[2].id)
			if b1 and b2 then
				sx,sy = b1:getXY()
				ex,ey = b2:getXY()
				love.graphics.line(sx + 3,sy + 3,ex + 3,ey + 3)
			end
		end
		food = boxClicks:getBoxFromXY(mousex,mousey)
		for i,a in pairs(tronics.nodes) do
			for t,n in pairs(a) do
				if not food[i.."!"..t] then
					love.graphics.setColor(n[3][1],n[3][2],n[3][3])
				else
					love.graphics.setColor(math.min(255,n[3][1]+80),math.min(255,n[3][2]+80),math.min(255,n[3][3]+80))
				end
				love.graphics.rectangle("fill",n[1],n[2],6,6) 
			end
		end
		if mode == "WIRE" then
			love.graphics.setColor(math.min(255,wire[4][1] + 40),math.min(255,wire[4][2] + 40),math.min(255,wire[4][3] + 40))
			love.graphics.line(wire[1],wire[2],mousex,mousey)
		end
		love.graphics.setColor(255,255,255)
		if mode == "DRAG" then
			drawNodes("temp",mousex - (mdrag:getWidth()/2),mousey - (mdrag:getHeight()/2),kdrag)
			love.graphics.draw(mdrag,mousex - (mdrag:getWidth()/2),mousey - (mdrag:getHeight()/2))
			boxClicks:updateBox("mDrag",mousex - (mdrag:getWidth()/2),mousey - (mdrag:getHeight()/2))
		end
	end
end