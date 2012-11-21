mode = "OFF"
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

function addDraw(dr,x,y,id)
	if id then
		draw[id] = {dr,x,y}
	else
		table.insert(draw,{dr,x,y})
	end
end

function removeDraw(id)
	if not id then return false end
	draw[id] = nil
end

function beginWire(b,k,x,y)
	mode = "WIRE"
	wire[1],wire[2] = b.properties[1] + 3,b.properties[2] + 3
	wire[3] = b.properties.kind
	wire[4] = b.properties.color
	wire[5] = b
end

function finalWire(b,k,x,y)
	if wire[3] == 0  then
		if b.properties.kind ~= 4 then return false end
		c = {18,14,253}
	elseif wire[3] == 1 then
		if b.properties.kind ~= 4 then return false end
		c = {67,251,29}
	elseif wire[3] == 2 then
		if b.properties.kind ~= 3 then return false end
		c = {179,1,1}
		--make sure that there can be multiple outs to a single in but only one out to one in
	elseif wire[3] == 3 then
		if b.properties.kind ~= 2 then return false end
		c = {179,1,1}
	elseif wire[3] == 4 then
		if b.properties.kind == 1 then
			c = {67,251,29}
		elseif b.properties ~= 0 then
			c = {18,14,253}
		else
		return false
		end
	end
	tronics.wires[wire[5].id..">"..b.id] = {wire[5],b,c}
	mode = "ON"
end

function drawNodes(id,rx,ry,k)
	local tot = 0
	tronics.nodes[id] = {}
	for _,p in pairs(TRANIX[k].nodes) do
		if p[3] == 0 then
			c = {18,14,253}
		elseif p[3] == 1 then
			c = {67,251,29}
		elseif p[3] == 2 then
			c = {251,251,30}
		elseif p[3] == 3 then
			c = {179,1,1}
		elseif p[3] == 4 then
			c = {72,215,254}
		end
		tronics.nodes[id][tot] = {rx + p[1],ry + p[2],c}
		if id ~= "temp" then
			box = boxClicks:addBox(rx + p[1],ry + p[2],6,6,id.."!"..tot)
			box:setCallback(beginWire,"click")
			box:setCallback(finalWire,"wclick")
			box.properties.kind = p[3] --hm
			box.properties.color = c
		end
		tot = tot + 1
	end
end

function hideNodes(id)
	for i,_ in pairs(tronics.nodes[id]) do
		boxClicks:removeBox(id.."!"..i)
	end
	tronics.nodes[id] = nil
end

function finalTron(b,k,x,y)
	if idrag == 0 then
		newid = kdrag.."~"..tronics.id + 1
		tronics.id = tronics.id + 1
	else
		newid = idrag
	end
	idrag = 0
	x,y = x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2)
	x,y = x - (x % 16),y - (y % 16)
	tronics.acts[newid] = boxClicks:addBox(x,y,mdrag:getWidth(),mdrag:getHeight(),newid)
	tronics.acts[newid].properties["id"] = kdrag
	tronics.acts[newid]:setCallback(dragTron,"click")
	tronics.acts[newid]:setCallback(remTron,"rclick")
	addDraw(mdrag,x,y,newid)
	drawNodes(newid,x,y,kdrag)
	hideNodes("temp")
	mode = "ON"
	boxClicks:removeBox("mDrag")
end

function remTron(b,k,x,y)
	tronics.acts[b.id] = nil
	removeDraw(b.id)
	boxClicks:removeBox(b.id)
	hideNodes(b.id)
end

function dragTron(b,k,x,y)
	print(boxClicks:boxExists("mDrag"))
	if not boxClicks:boxExists("mDrag") then 
		idrag = b.id
		mode = "DRAG"
		hideNodes(b.id)
		kdrag = b.properties.id
		mdrag = love.graphics.newImage(TRANIX[kdrag].sprite)
		removeDraw(b.id)
		boxClicks:removeBox(b.id)
		boxClicks:addBox(x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2),mdrag:getWidth(),mdrag:getHeight(),"mDrag"):setCallback(finalTron,"release")
	end
end

function newTron(b,k,x,y)
	if not boxClicks:boxExists("mDrag") then 
		mode = "DRAG"
		kdrag = b.id
		mdrag = love.graphics.newImage(TRANIX[b.id].sprite)
		boxClicks:addBox(x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2),mdrag:getWidth(),mdrag:getHeight(),"mDrag"):setCallback(finalTron,"release")
	end
end

function love.load()
	mode = "LOADING"
	love.graphics.setLine(4,"smooth")
	love.graphics.setIcon(love.graphics.newImage("/assets/icon.png"))
	loadBC = love.filesystem.load("/boxClicks/init.lua") or error("could not find boxClicks library! try reinstalling")
	loadTC = love.filesystem.load("/tronics/tronicslist.lua") or error("could not find tronics list! try reinstalling")
	loadBC() --why
	loadTC() --WHY w-w
	local d = 20
	for i,x in pairs(TRANIX) do --time to start fucking colouring these icons, kids
		d = d + 20
		x.icon = love.graphics.newImage(x.ico)
		addDraw(x.icon,d,540,i)
		boxClicks:addBox(d,540,x.icon:getWidth(),x.icon:getHeight(),i):setCallback(newTron,"click")
	end
	background = love.graphics.newImage("/assets/background.png") --whatever
	mode = "ON"
end

function love.mousepressed(x,y,k)
	if k == "l" then
		if mode ~= "WIRE" then
			boxClicks:sendCallbacks(x,y,"click")
		else
			boxClicks:sendCallbacks(x,y,"wclick")
		end
	else
		if mode ~= "WIRE" then
			boxClicks:sendCallbacks(x,y,"rclick")
		else
			mode = "ON"
			wire = {}
		end
		if mode == "ON" then
			for _,w in pairs(tronics.wires) do
				boxClicks:getBoxFromId(w[1].id):getXY()
			end
		end
	end
end

function love.keypressed(k)
	if k == "t" then
		--boxClicks:pauseCallback("click")
		print("paused")
	end
end

function love.mousereleased(x,y)
	boxClicks:sendCallbacks(x,y,"release")
end

function love.draw()
	if mode ~= "OFF" and mode ~= "LOADING" then
		mousex,mousey = love.mouse.getX(),love.mouse.getY()
		boxClicks:sendCallbacks(mousex,mousey,"move")
		love.graphics.draw(background,0,0) --must be called first
		for _,x in pairs(draw) do
			love.graphics.draw(x[1],x[2],x[3])
		end
		for _,w in pairs(tronics.wires) do
			love.graphics.setColor(w[3])
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
			love.graphics.setColor(wire[4][1],wire[4][2],wire[4][3])
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