box = ...
t = tonumber(getData(box.id,2)) or 0
a = tonumber(getData(box.id,3)) or 1 --just output t if there is no a
if a == 0 then
	print("flow end because tried to divide by 0")
	return false
end
sendData(box.id,4,t/a)
flowOut(box.id,1)