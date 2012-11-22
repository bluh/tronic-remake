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

function getWire(to,from)
	if not tronics.wires[to..">"..from] then
		if not tronics.wires[from..">"..to] then
			return false
		else
			return tronics.wires[from..">"..to]
		end
	else
		return tronics.wires[to..">"..from]
	end
end

function getAssocWires(id)
	local ret = {}
	for i,w in pairs(tronics.wires) do
		if i:match(id) then
			table.insert(ret,w)
		end
	end
	return ret
end

function pointOnWire(id,x,y)
	local sx,sy,fx,fy = 0,0,0,0
	if boxClicks:boxExists(tronics.wires[id][1].id) and boxClicks:boxExists(tronics.wires[id][2].id) then
		sx,sy = boxClicks:getBoxFromId(tronics.wires[id][1].id):getXY()
		fx,fy = boxClicks:getBoxFromId(tronics.wires[id][2].id):getXY()
		firstx,lastx = math.min(sx,fx),math.max(sx,fx)
		sx,sy,fx,fy = sx + 3,sy + 3,fx + 3,fy + 3
		m = -(sy-fy)/(sx-fx)
		rx,ry = -(sx-x),sy-y
		if x > firstx - 5 and x < lastx + 5 and ry > m*rx - (math.ceil(math.abs(m)) + 8) and ry < m*rx + (math.ceil(math.abs(m)) + 8) then
			return true
		end
	end
	return false
end

function removeWire(id)
	tronics.wires[id] = nil
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
		if #getAssocWires(wire[5].id) > 0 then
			return false
		end
	elseif wire[3] == 1 then
		if b.properties.kind ~= 4 then return false end
		c = {67,251,29}
		if #getAssocWires(wire[5].id) > 0 then
			return false
		end
	elseif wire[3] == 2 then
		if b.properties.kind ~= 3 then return false end
		c = {179,1,1}
		if #getAssocWires(b.id) > 0 then
			return false
		end
	elseif wire[3] == 3 then
		if b.properties.kind ~= 2 then return false end
		if #getAssocWires(wire[5].id) > 0 then
			return false
		end
		c = {179,1,1}
	elseif wire[3] == 4 then
		if b.properties.kind == 1 then
			c = {67,251,29}
		elseif b.properties ~= 0 then
			c = {18,14,253}
		else
			return false
		end
		if #getAssocWires(b.id) > 0 then
			return false
		end
	end
	if tronics.wires[b.id..">"..wire[5].id] then
		removeWire(b.id..">"..wire[5].id)
		mode = "ON"
		return false
	elseif tronics.wires[wire[5].id..">"..b.id] then
		removeWire(wire[5].id..">"..b.id)
		mode = "ON"
		return true
	else
		tronics.wires[wire[5].id..">"..b.id] = {wire[5],b,c}
		mode = "ON"
		return true
	end
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
	x,y = x - ((x + 8) % 16),y - ((y + 8) % 16)
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
	assert((love.filesystem.load("/boxClicks/init.lua")() == nil),"could not find boxClicks library! try reinstalling")
	loadTC = love.filesystem.load("/tronics/tronicslist.lua") or error("could not find tronics list! try reinstalling")
	loadTC() --WHY w-w
	local d = 8
	for i,x in pairs(TRANIX) do --time to start fucking colouring these icons, kids
		d = d + 16
		x.icon = love.graphics.newImage(x.ico)
		addDraw(x.icon,d,545,i)
		boxClicks:addBox(d,545,x.icon:getWidth(),x.icon:getHeight(),i):setCallback(newTron,"click")
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
			for i,_ in pairs(tronics.wires) do
				if pointOnWire(i,x,y) then
					removeWire(i)
				end
			end
		end
	end
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