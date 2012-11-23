box = ...
t = getData(box.id,2)
a = getData(box.id,3)
if a == 0 then
	return false
end
sendData(box.id,4,t/a)
flowOut(box.id,1)