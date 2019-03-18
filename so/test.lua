local originalFile="./1.jpg"
local lim=require "limage"
print(type(lim))
  

 local function getImageSize(path)
	dpi = {}
	local width,height=image_size(path)
	if width and height then
		print("width=",width)
		print("height=",height)
		dpi[1]=width
		dpi[2]=height
	end
	return dpi
end
 
local dpiArray=getImageSize(originalFile)
if next(dpiArray) ~= nil and #dpiArray>1 then
	print("dpi width=",dpiArray[1])
 	print("dpi height=",dpiArray[2])
  
end

