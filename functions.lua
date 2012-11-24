function addDraw(dr,x,y,id) --this is used for an overlay, not for grid things
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

function drawNodes(id,rx,ry,k,par)
	local tot = 0
	tronics.nodes[id] = {}
	for _,p in ipairs(TRANIX[k].nodes) do
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
			box.properties.parent = par
		end
		tot = tot + 1
	end
end

function removeNodes(id)
	for i,_ in pairs(tronics.nodes[id]) do
		boxClicks:removeBox(id.."!"..i)
		for _,w in pairs(getAssocWires(id.."!"..i)) do
			removeWire(w[1].id..">"..w[2].id)
		end
	end
	tronics.nodes[id] = nil
end

function hideNodes(id)
	for i,_ in pairs(tronics.nodes[id]) do
		boxClicks:removeBox(id.."!"..i)
	end
	tronics.nodes[id] = nil
end

function outputData(b,k,x,y)
	print(b.id,tronics.dats[b.id])
end

function finalTron(b,k,x,y)
	if idrag == 0 then
		newid = kdrag.."~"..tronics.id + 1
		tronics.id = tronics.id + 1
	else
		newid = idrag
	end
	idrag = 0
	x,y = x - (mdrag:getWidth()/2) - screenx,y - (mdrag:getHeight()/2) - screeny
	x,y = x - ((x + 8) % 16),y - ((y + 8) % 16)
	tronics.acts[newid] = boxClicks:addBox(x,y,mdrag:getWidth(),mdrag:getHeight(),newid)
	tronics.acts[newid].properties["id"] = kdrag
	tronics.acts[newid]:setCallback(dragTron,"click")
	tronics.acts[newid]:setCallback(remTron,"rclick")
	tronics.acts[newid]:setCallback(outputData,"mclick")
	drawNodes(newid,x,y,kdrag,tronics.acts[newid])
	hideNodes("temp")
	mode = "ON"
	boxClicks:removeBox("mDrag")
end

function remTron(b,k,x,y)
	tronics.acts[b.id] = nil
	boxClicks:removeBox(b.id)
	removeNodes(b.id)
end

function dragTron(b,k,x,y)
	if not boxClicks:boxExists("mDrag") then 
		idrag = b.id
		mode = "DRAG"
		hideNodes(b.id)
		kdrag = b.properties.id
		mdrag = love.graphics.newImage(TRANIX[kdrag].sprite)
		boxClicks:removeBox(b.id)
		boxClicks:addBox(x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2),mdrag:getWidth(),mdrag:getHeight(),"mDrag"):setCallback(finalTron,"orelease")
		tronics.acts[b.id] = nil
	end
end

function newTron(b,k,x,y)
	if not boxClicks:boxExists("mDrag") then 
		mode = "DRAG"
		kdrag = b.id
		mdrag = love.graphics.newImage(TRANIX[b.id].sprite)
		boxClicks:addBox(x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2),mdrag:getWidth(),mdrag:getHeight(),"mDrag"):setCallback(finalTron,"orelease")
	end
end

function stopCompute(b,k,x,y)
	draw["go"] = {love.graphics.newImage("/assets/go.png"),draw["go"][2],draw["go"][3]}
	boxClicks:removeBox("stop")
	boxClicks:addBox(16,16,32,32,"go"):setCallback(startCompute,"click")
	mode = "ON"
end

function startCompute(b,k,x,y)
	draw["go"] = {love.graphics.newImage("/assets/stop.png"),draw["go"][2],draw["go"][3]}
	boxClicks:removeBox("go")
	boxClicks:addBox(16,16,32,32,"stop"):setCallback(stopCompute,"cclick")
	for i,a in pairs(tronics.acts) do
		if TRANIX[a.properties.id].preload then
			TRANIX[a.properties.id].fpreload(a)
		end
	end
	mode = "COMPUTE"
end

function flowOut(id,node)
	wire = getAssocWires(id.."!"..node)
	if #wire > 1 then
		error("more than one flowout node connected to "..id.."!"..node.." node!")
	end
	if #wire == 0 or mode ~= "COMPUTE" then
		print("end of line")
		return true
	end
	if wire[1][1].id == id.."!"..node then
		ntron = wire[1][2].properties.parent
	else
		ntron = wire[1][1].properties.parent
	end
	TRANIX[ntron.properties.id].fsource(ntron)
end

function getData(id,node)
	wire = getAssocWires(id.."!"..node)
	if #wire > 1 then
		error("more than one datain node connected to "..id.."!"..node.." node!")
	end
	if #wire == 0 then
		print("1")
		return 1
	end
	if wire[1][1].id == id.."!"..node then
		ntron = wire[1][2].properties.parent
	else
		ntron = wire[1][1].properties.parent
	end
	print(tronics.dats[ntron.id] or 0)
	return (tronics.dats[ntron.id] or 0)
end

function sendData(id,node,data)
	wire = getAssocWires(id.."!"..node)
	print(id.."!"..node,data,#wire)
	if #wire > 1 then
		error("more than one data node connected to "..id.."!"..node.." node!")
	end
	if #wire == 0 then
		return false
	end
	if wire[1][1].id == id.."!"..node then
		ntron = wire[1][2].properties.parent
	else
		ntron = wire[1][1].properties.parent
	end
	print(ntron.id)
	tronics.dats[ntron.id] = data
end
