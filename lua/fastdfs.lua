--[[ 
	配置项，对目录、缩略图尺寸、裁剪类型进行配置，匹配后才进行缩略图处理
	1.sizes={'350x350'} 填充后保证等比缩图
	2.sizes={'300x300_'}等比缩图
	3.sizes={'250x250!'}非等比缩图，按给定的参数缩图（缺点：长宽比会变化）	
	4.sizes={'50x50^'}裁剪后保证等比缩图 （缺点：裁剪了图片的一部分）	
	5.sizes={'100x100>'}只缩小不放大		
	6.sizes={'140x140$'}限制宽度，只缩小不放大(比如网页版图片用于手机版时)	目前测试GraphicsMagick这个版本不支持
	
 @ !
]]


-- 写入文件
local function writefile(filename, info)
    local wfile=io.open(filename, "w") --写入文件(w覆盖)
    assert(wfile)  --打开时验证是否出错		
    wfile:write(info)  --写入传入的内容
    wfile:close()  --调用结束后记得关闭
end

-- 检测路径是否目录
local function is_dir(sPath)
    if type(sPath) ~= "string" then return false end
    local response = os.execute( "cd " .. sPath )
    if response == 0 then
        return true
    end
    return false
end
--获取图片的宽和高
local function getImageSize(path)
	--print("getImageSize path",path)
    --读取文件大小和图片宽高
    dpi = {}
    if path then
        -- --要先安装https://github.com/keplerproject/luafilesystem/
        -- local lfs   = require('lfs')
        -- --local filepath="./ed724426a341d666369a244a2e8c54ad.jpg"

        -- local res=lfs.attributes(path)
		
		-- for k,v in pairs(res) do
		-- print("KEY="..k,"value="..v)
		-- end
        -- local size = res["size"]
        -- if size ~=  nil and tonumber(size) >= 0 then
            -- reslimage["size"] = size
        -- end	 		
      --要先安装https://github.com/yufei6808/limage
	     --该处是nginx的lua加载C写的limage.so的坑，目前只要将调用的limage.so的引入放在该处，
	    --在fastdfs.lua中才不会出现attempt to call global 'image_size' (a nil value)的错误，否则是执行代码第一次能执行，但是，第二次就调用不了了
		  -- local lim   = require('limage')
           --不能使用local width,height=lim.limage_size(path)这句话，lim为boolean值，只能调用全局的image_size函数。
		local width,height=image_size(path)
        if width and height then
			--print("width=",width)
			--print("height=",height)
             --reslimage["dpi"] = width.."x"..height
			dpi[1]=width
			dpi[2]=height
        end 
    end
    return dpi
end

-- 检测文件是否存在
local file_exists = function(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end
--/group1/M00/00/00/CgcXPlwOPFmEKxzaAAAAAORd3Es082.jpg
local originalUri = ngx.var.uri
--/data/fdfs/data/00/00/CgcXPlwOPFmEKxzaAAAAAORd3Es082.jpg?x-oss-process=image/resize,m_fill,w_90,h_80
local originalFile = ngx.var.file;
--print("originalUri=",originalUri)
--print("originalFile=",originalFile)
local index = string.find(originalFile, "?");  
if index then 
    originalFile = string.sub(originalFile, 0, index-1)
	--print("originalFile=",originalFile)
end
--local originalFile =ngx.var.uri
local uri_args = ngx.req.get_uri_args()
local ossStyle=uri_args["x-oss-process"]
--print("ossStyle=",ossStyle)

if ossStyle==nil then
ngx.exit(400)
end
local width=nil;
local w_width = string.match(ossStyle, "w_[0-9]+")
if w_width ~=nil then
    width=string.sub(w_width ,#"w_"+1,#w_width)
end
--print("w_width=",w_width)
--print("width=",width)
local height=nil
local h_height = string.match(ossStyle, "h_[0-9]+")
if h_height ~=nil then
     height=string.sub(h_height ,#"h_"+1,#h_height )
end
--print("h_height =",h_height )
if width ==nil and height==nil then
  ngx.exit(400)
end
if file_exists(originalFile)==false then
   return ngx.exit(404)
end
local dpiArray=getImageSize(originalFile)
if next(dpiArray) ~= nil and #dpiArray>1 then
	--print("dpi width=",dpiArray[1])
	--print("dpi height=",dpiArray[2])
	if dpiArray[1] ~= nil and dpiArray[2] ~=nil then
		if width==nil then
				width=dpiArray[1]/dpiArray[2]*height
		else
			if height==nil then
				height=width*dpiArray[2]/dpiArray[1]
			end
		end
	end 
	
end		
local area=width.."x"..height
--print("area=",area)
local newFile=originalFile.."_"..area..".jpg"
local newUrl=originalUri.."_"..area..".jpg"

--print("newFile=",newFile)
--print("newUrl=",newUrl)

--如果缩略图已经存在了，则直接返回存在的缩略图
if file_exists(newFile) then
   return ngx.exec(newUrl)
end
--print("newUrl=",newUrl)
-- check original file
if not file_exists(originalFile) then
    local fileid = string.sub(originalUri, 2);
    -- main
    local fastdfs = require('restyfastdfs')
    local fdfs = fastdfs:new()
    fdfs:set_tracker("10.7.23.62", 22122)
    fdfs:set_timeout(1000)
    fdfs:set_tracker_keepalive(0, 100)
    fdfs:set_storage_keepalive(0, 100)
    local data = fdfs:do_download(fileid)
    if data then
       -- check image dir
        if not is_dir(ngx.var.image_dir) then
            os.execute("mkdir -p " .. ngx.var.image_dir)
        end
        writefile(originalFile, data)
    end
end
---gravity center -extent 是能去掉黑底和白边
-- refer https://yq.aliyun.com/ziliao/589489
--print("gm do ","======")
local cmd = "gm convert " .. originalFile  .. " -thumbnail " .. area .."".. " -auto-orient -gravity NorthWest -extent   " .. area;
cmd = cmd .. " -quality 75"
cmd = cmd .. " +profile \"*\" " .. newFile;
os.execute(cmd);

if file_exists(newFile) then
   return ngx.exec(newUrl)
else
   return ngx.exit(404)
end
--去除扩展名
local function stripextension(filename)
    local idx = filename:match(".+()%.%w+$")
    if (idx) then
        return filename:sub(1, idx - 1)
    else
        return filename
    end
end

--获取扩展名
local function getExtension(filename)
    return filename:match(".+%.(%w+)$")
end

 
 
