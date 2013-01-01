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
	queue = {},
	callbacking = false,
	activated = true,
	id = 0,
	newBoxId = (function(self)
		self.id = self.id + 1
		return self.id
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
			dprint("box "..id.." added")
			return self.boxes[id]
		--adding while in callback loop doesn't seem to error so we won't make an exception for now
	end),
	updateBox = (function(self,id,x,y,sizex,sizey)
		dprint("box "..id.." update")
		if not self:boxExists(id) then error("could not update box with box "..id.." (box does not exist)") end
		if not sizex and not sizey then
			self.boxes[id].properties = {x,y,self.boxes[id].properties[3],self.boxes[id].properties[4]}
		else
			self.boxes[id].properties = {x,y,sizex,sizey}
		end
		self.boxes[id]:main()
		return self.boxes[id]
	end),
	removeBox = (function(self,id)
		if self.boxes[id] then
			if not callbacking then
				dprint("box "..id.." removed")
				self.boxes[id] = nil
			else
				dprint("tried to remove box "..id.." durring callbacks, adding to queue")
				table.insert(self.queue,{"remove",id})
			end
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
		callbacking = true
		for _,a in pairs(self.boxes) do
			if a:check(x,y) then
				if a.callback[kind] and self.paused[kind] == nil then
					dprint(a.id)
					a.callback[kind](a,kind,x,y)
				end
			end
		end
		callbacking = false
		for _,b in pairs(self.queue) do
			if b[1] == "remove" then
				dprint("queue tries to remove "..b[2])
				self:removeBox(b[2])
			end
		end
		self.queue = {}
	end),
	pauseCallback = (function(self,back)
		if self.paused[back] == "paused" then
			self.paused[back] = nil
		else
			self.paused[back] = "paused" --don't u judge me
		end
	end)
}
