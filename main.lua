mode = "OFF"
mousex,mousey = 0,0
mdrag = nil
idrag = 0
kdrag = ""
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

function removeDraw(id)
	if not id then return false end
	draw[id] = nil
end

--function drawNodes(id,k,x,y)
	--for i,x in pairs(

function finalTron(b,k,x,y)
	if idrag == 0 then
		newid = b.id.."~"..tronics.id + 1
		tronics.id = tronics.id + 1
	else
		newid = idrag
	end
	idrag = 0
	x,y = x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2)
	x,y = x - (x % 16),y - (y % 16)
	tronics.acts[newid] = boxClicks:addBox(x,y,mdrag:getWidth(),mdrag:getHeight(),newid)
	print(kdrag)
	tronics.acts[newid].properties["id"] = kdrag
	tronics.acts[newid]:setCallback(dragTron,"click")
	tronics.acts[newid]:setCallback(remTron,"rclick")
	addDraw(mdrag,x,y,newid)
	boxClicks:removeBox("mDrag")
	mode = "ON"
end

function remTron(b,k,x,y)
	idrag = b.id
	tronics.acts[b.id] = nil
	removeDraw(b.id)
	boxClicks:removeBox(b.id)
	boxClicks:addBox(x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2),mdrag:getWidth(),mdrag:getHeight(),"mDrag"):setCallback(finalTron,"release")
end

function dragTron(b,k,x,y)
	print(boxClicks:boxExists("mDrag"))
	if not boxClicks:boxExists("mDrag") then 
		mode = "DRAG"
		kdrag = b.properties.id
		print(kdrag,b.properties.id)
		mdrag = love.graphics.newImage(TRANIX[kdrag].sprite)
		removeDraw(b.id)
		boxClicks:removeBox(b.id)
		boxClicks:addBox(x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2),mdrag:getWidth(),mdrag:getHeight(),"mDrag"):setCallback(finalTron,"release")
	end
end

function newTron(b,k,x,y)
	print(boxClicks:boxExists("mDrag"))
	if not boxClicks:boxExists("mDrag") then 
		mode = "DRAG"
		kdrag = b.id
		print(b.id,kdrag)
		mdrag = love.graphics.newImage(TRANIX[b.id].sprite)
		boxClicks:addBox(x - (mdrag:getWidth()/2),y - (mdrag:getHeight()/2),mdrag:getWidth(),mdrag:getHeight(),"mDrag"):setCallback(finalTron,"release")
	end
end

function love.load()
	mode = "LOADING"
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
		boxClicks:sendCallbacks(x,y,"click")
	else
		boxClicks:sendCallbacks(x,y,"rclick")
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
		for i,x in pairs(draw) do
			love.graphics.draw(x[1],x[2],x[3])
		end
		if mode == "DRAG" then
			love.graphics.draw(mdrag,mousex - (mdrag:getWidth()/2),mousey - (mdrag:getHeight()/2))
			boxClicks:updateBox("mDrag",mousex - (mdrag:getWidth()/2),mousey - (mdrag:getHeight()/2))
		end
	end
end