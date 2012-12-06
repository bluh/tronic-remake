--[[some project I started a while ago wow it can work with minitrons cool]]--

inputHandler = {
	value = "",
	caps = false,
	shift = false,
	max = 0,
	kpfunction = nil,
	setInput = (function(self,talue)
		self.value = tostring(talue or "")
	end),
	setKeypressFunction = (function(self,gfun)
		self.kpfunction = gfun
	end),
	setEnterCallback = (function(self,gfun)
		self.ecall = gfun
	end),
	control = (function(self)
		love.keyboard.setKeyRepeat(310,10)
	end),
	getInput = (function(self)
		return self.value -- or error("Unable to get input!")
	end),
	setMax = (function(self,x)
		if type(x) == "number" then
			self.max = x
		else
			error("bad arugment #1 to 'setMax' (number expected, got "..type(x)..")")
		end
	end),
	keyDown = (function(self,k)
		if k == "rshift" or k == "lshift" then
			self.shift = true
			k = ""
		elseif k == "capslock" then
			self.caps = (not self.caps) or false
			k = ""
		elseif k == "return" then
			k = ""
			if self.ecall then
				self.ecall()
			end
			return self.value
		elseif k == "backspace" then
			self.value = self.value:sub(0,self.value:len()-1) or ""
			k = ""
		else
			if self.shift then
				if k == "1" then k = "!"
				elseif k == "2" then k = "@"
				elseif k == "3" then k = "#" --fuck it I'm having optimizations soon
				elseif k == "4" then k = "$"
				elseif k == "5" then k = "%"
				elseif k == "6" then k = "^"
				elseif k == "7" then k = "&"
				elseif k == "8" then k = "*"
				elseif k == "9" then k = "("
				elseif k == "0" then k = ")"
				elseif k == "-" then k = "_"
				elseif k == "=" then k = "+"
				elseif k == "[" then k = "{"
				elseif k == "]" then k = "}"
				elseif k == ";" then k = ":" 
				elseif k == "\'" then k = "\""
				elseif k == "," then k = "<"
				elseif k == "." then k = ">"
				elseif k == "/" then k = "?"
				elseif k == "`" then k = "~"
				elseif k == "\\" then k = "|"
				else k = k:upper()
				end
			end
			if self.caps then
				k = k:upper()
			end
			if k:len() > 1 then k = "" end
		end
		if (not ((self.value:len() + 1) > self.max)) or self.max == 0 then
			self.value = self.value..""..k
		end
		if self.kpfunction then
			self.kpfunction(self.value,k)
		end
		return (self.value),k
	end),
	keyUp = (function(self,k)
		if k == "rshift" or k == "lshift" then
			self.shift = false
		end
	end),
	quickSet = (function(self,up,down)
		if type(up) ~= "function" or type(down) ~= "function" then
			error("Given arguements were not the correct type! (function expected, got "..type(up).." and "..type(down))
		else
		--probably some shit would have gone here who even knows
		end
	end)
}