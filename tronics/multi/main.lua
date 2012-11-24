box = ...
t = tonumber(getData(box.id,2)) or 0
a = tonumber(getData(box.id,3)) or 0
sendData(box.id,4,t*a)
flowOut(box.id,1)