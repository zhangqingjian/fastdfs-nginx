--[[ 
	�������Ŀ¼������ͼ�ߴ硢�ü����ͽ������ã�ƥ���Ž�������ͼ����
	1.sizes={'350x350'} ����֤�ȱ���ͼ
	2.sizes={'300x300_'}�ȱ���ͼ
	3.sizes={'250x250!'}�ǵȱ���ͼ���������Ĳ�����ͼ��ȱ�㣺����Ȼ�仯��	
	4.sizes={'50x50^'}�ü���֤�ȱ���ͼ ��ȱ�㣺�ü���ͼƬ��һ���֣�	
	5.sizes={'100x100>'}ֻ��С���Ŵ�		
	6.sizes={'140x140$'}���ƿ�ȣ�ֻ��С���Ŵ�(������ҳ��ͼƬ�����ֻ���ʱ)	Ŀǰ����GraphicsMagick����汾��֧��
	
 @ !
]]


-- д���ļ�
local function writefile(filename, info)
    local wfile=io.open(filename, "w") --д���ļ�(w����)
    assert(wfile)  --��ʱ��֤�Ƿ����		
    wfile:write(info)  --д�봫�������
    wfile:close()  --���ý�����ǵùر�
end

-- ���·���Ƿ�Ŀ¼
local function is_dir(sPath)
    if type(sPath) ~= "string" then return false end
    local response = os.execute( "cd " .. sPath )
    if response == 0 then
        return true
    end
    return false
end
--��ȡͼƬ�Ŀ�͸�
local function getImageSize(path)
	--print("getImageSize path",path)
    --��ȡ�ļ���С��ͼƬ���
    dpi = {}
    if path then
        -- --Ҫ�Ȱ�װhttps://github.com/keplerproject/luafilesystem/
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
      --Ҫ�Ȱ�װhttps://github.com/yufei6808/limage
	     --�ô���nginx��lua����Cд��limage.so�Ŀӣ�ĿǰֻҪ�����õ�limage.so��������ڸô���
	    --��fastdfs.lua�вŲ������attempt to call global 'image_size' (a nil value)�Ĵ��󣬷�����ִ�д����һ����ִ�У����ǣ��ڶ��ξ͵��ò�����
		  -- local lim   = require('limage')
           --����ʹ��local width,height=lim.limage_size(path)��仰��limΪbooleanֵ��ֻ�ܵ���ȫ�ֵ�image_size������
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

-- ����ļ��Ƿ����
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

--�������ͼ�Ѿ������ˣ���ֱ�ӷ��ش��ڵ�����ͼ
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
---gravity center -extent ����ȥ���ڵ׺Ͱױ�
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
--ȥ����չ��
local function stripextension(filename)
    local idx = filename:match(".+()%.%w+$")
    if (idx) then
        return filename:sub(1, idx - 1)
    else
        return filename
    end
end

--��ȡ��չ��
local function getExtension(filename)
    return filename:match(".+%.(%w+)$")
end

 
 
