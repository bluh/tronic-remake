boxCopy = {
	id = nil,
	properties = {},
	dimensions = {},
	callback = {},
	main = (function(self)
		self.dimensions = {self.properties[1],self.properties[2],(self.properties[1] + self.properties[3]),(self.properties[2] + self.properties[4])}
	end),
	check = (function(self,x,y)
		return ((x > self.properties[1] and x < self.dimensions[3]) and (y > self.properties[2] and y < self.dimensions[4]))
	end),
	getArea = (function(self)
		return self.properties[3]*self.properties[4]
	end),
	getXY = (function(self)
		return self.properties[1],self.properties[2],self.properties[3],self.properties[4]
	end),
	setCallback = (function(self,callb,kind)
		self.callback[kind] = callb
	end)
}

boxClicks = {
	boxes = {},
	paused = {},
	activated = true,
	newBoxId = (function(self)
		local i = 0
		repeat i = i + 1
		until not self:boxExists(i)
		return i
	end),
	boxExists = (function(self,id)
		return self.boxes[id] ~= nil
	end),
	addBox = (function(self,x,y,sizex,sizey,id)
		id = (id or self:newBoxId())
		assert((sizex > 0 and sizey > 0),"invalid box properties")
		assert(not self.boxes[id],"duplicate ID: "..id)
		self.boxes[id] = setmetatable({id = id,properties={x,y,sizex,sizey},callback = {}},{__index=boxCopy})
		self.boxes[id]:main()
		return self.boxes[id]
	end),
	updateBox = (function(self,id,x,y,sizex,sizey)
		if not sizex and not sizey then
			self.boxes[id].properties = {x,y,self.boxes[id].properties[3],self.boxes[id].properties[4]}
		else
			self.boxes[id].properties = {x,y,sizex,sizey}
		end
		self.boxes[id]:main()
	end),
	removeBox = (function(self,id)
		if self.boxes[id] then
			self.boxes[id] = nil
		end
	end),
	toggleActivated = (function(self,act)
		if type(act) == "boolean" then
			self.activated = act
		else
			self.activated = not self.activated
		end
	end),
	getBoxFromXY = (function(self,x,y)
		local ret = {}
		for _,b in pairs(self.boxes) do
			if b:check(x,y) then
				ret[b.id] = b
			end
		end
		return ret
	end),
	getBoxFromId = (function(self,id)
		return self.boxes[id]
	end),
	sendCallbacks = (function(self,x,y,kind)
		for _,a in pairs(self.boxes) do
			if a:check(x,y) then
				--if kind ~= "move" then print(kind,x,y,b.id) end
				if a.callback[kind] and self.paused[kind] == nil then return a.callback[kind](a,kind,x,y) end
			end
		end
	end),
	pauseCallback = (function(self,back)
		if self.paused[back] == "paused" then
			self.paused[back] = nil
		else
			self.paused[back] = "paused" --don't u judge me
		end
	end)
}
