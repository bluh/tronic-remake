mode = "OFF"
screenx,screeny = 0,0
mousex,mousey = 0,0
--dragging vars
mdrag = nil
idrag = 0
kdrag = ""
--wire vars
wire = {}
lastdt = 0
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
	love.filesystem.load("/inputHandler/init.lua")()
	local d = 24
	for _,t in pairs(TRANIXORDER) do --time to start fucking colouring these icons, kids
		x = TRANIX[t]
		x.icon = love.graphics.newImage(x.ico)
		x.image = love.graphics.newImage(x.sprite)
		addDraw(x.icon,d,545,t)
		boxClicks:addBox(d,545,x.icon:getWidth(),x.icon:getHeight(),t):setCallback(newTron,"oclick")
		if x.source then
			x.fsource = love.filesystem.load(x.source)
		end
		if x.preload then
			x.fpreload = love.filesystem.load(x.preload)
		end
		if x.unload then
			x.funload = love.filesystem.load(x.unload)
		end
		d = d + x.icon:getWidth()
	end
	addDraw(love.graphics.newImage("/assets/go.png"),16,16,"go")
	boxClicks:addBox(16,16,32,32,"go"):setCallback(startCompute,"oclick")
	mode = "ON"
end

function love.mousepressed(x,y,k)
	ax,ay = x - screenx,y - screeny
	if k == "l" then
		if mode ~= "WIRE" then
			if mode ~= "COMPUTE" then
				boxClicks:sendCallbacks(x,y,"oclick") --oclick = overlay click
				boxClicks:sendCallbacks(ax,ay,"click")
			else
				boxClicks:sendCallbacks(x,y,"occlick")
				boxClicks:sendCallbacks(ax,ay,"cclick")
			end
		else
			boxClicks:sendCallbacks(ax,ay,"wclick")
		end
	elseif k == "r" then
		if mode ~= "WIRE" then
			if mode ~= "COMPUTE" then
				--boxClicks:sendCallbacks(x,y,"orclick")
				boxClicks:sendCallbacks(ax,ay,"rclick")
			else
				boxClicks:sendCallbacks(x,y,"occlick")
				boxClicks:sendCallbacks(ax,ay,"cclick")
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
	ax,ay = x - screenx,y - screeny
	boxClicks:sendCallbacks(ax,ay,"release")
	boxClicks:sendCallbacks(x,y,"orelease")
end

function love.keypressed(k)
	if k == "up" then
		screeny = screeny + 16
	elseif k == "down" then
		screeny = screeny - 16
	elseif k == "right" then
		screenx = screenx - 16
	elseif k == "left" then
		screenx = screenx + 16
	elseif k == " " then
		screenx,screeny = 0,0
	end
end

function love.draw(dt)
	if mode ~= "OFF" and mode ~= "LOADING" then
		mousex,mousey = love.mouse.getX() + screenx,love.mouse.getY() + screeny
		amousex,amousey = love.mouse.getX(),love.mouse.getY()
		boxClicks:sendCallbacks(mousex,mousey,"move")
		love.graphics.draw(TRANIX.background,0,0) --must be called first
		--draw overlay
		for _,x in pairs(draw) do
			love.graphics.draw(x[1],x[2],x[3])
		end
		love.graphics.setColor(0,0,0)
		love.graphics.print("{"..screenx..","..screeny.."}",600,16,0,1.5,1.5)
		--draw trons
		love.graphics.setColor(255,255,255)
		for i,t in pairs(tronics.acts) do
			tx,ty = t:getXY()
			love.graphics.draw(TRANIX[t.properties.id].image,tx + screenx,ty + screeny)
		end
		--draw wires
		for i,w in pairs(tronics.wires) do
			if not pointOnWire(i,amousex - screenx,amousey - screeny) then
				if w.activated then --leftover from wire highlighting which I'll get back to someday
					love.graphics.setColor(0,0,0)
					print(w.activated)
				else
					love.graphics.setColor(w[3])
				end
			else
				love.graphics.setColor(math.min(255,w[3][1] + 80),math.min(255,w[3][2] + 80),math.min(255,w[3][3] + 80))
			end
			b1 = boxClicks:getBoxFromId(w[1].id)
			b2 = boxClicks:getBoxFromId(w[2].id)
			if b1 and b2 then
				sx,sy = b1:getXY()
				ex,ey = b2:getXY()
				love.graphics.line(sx + screenx + 3,sy + screeny + 3,ex + screenx + 3,ey + screeny + 3)
			end
		end
		--draw nodes
		food = boxClicks:getBoxFromXY(amousex - screenx,amousey - screeny)
		for i,a in pairs(tronics.nodes) do
			for t,n in pairs(a) do
				if not food[i.."!"..t] then
					love.graphics.setColor(n[3][1],n[3][2],n[3][3])
				else
					love.graphics.setColor(math.min(255,n[3][1]+80),math.min(255,n[3][2]+80),math.min(255,n[3][3]+80))
				end
				love.graphics.rectangle("fill",n[1] + screenx,n[2] + screeny,6,6) 
			end
		end
		--draw wire
		if mode == "WIRE" then
			love.graphics.setColor(math.min(255,wire[4][1] + 40),math.min(255,wire[4][2] + 40),math.min(255,wire[4][3] + 40))
			love.graphics.line(wire[1] + screenx,wire[2] + screeny,amousex,amousey)
		end
		love.graphics.setColor(255,255,255)
		--draw dragged item
		if mode == "DRAG" then
			drawNodes("temp",amousex - (mdrag:getWidth()/2) - screenx,amousey - (mdrag:getHeight()/2) - screeny,kdrag)
			love.graphics.draw(mdrag,amousex - (mdrag:getWidth()/2),amousey - (mdrag:getHeight()/2))
			boxClicks:updateBox("mDrag",amousex - (mdrag:getWidth()/2),amousey - (mdrag:getHeight()/2))
		end
	end
end