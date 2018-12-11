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

-- 检测文件是否存在
local file_exists = function(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

local area = nil
local newFile=nil
local newUrl=nil
--/group1/M00/00/00/CgcXPlwOPFmEKxzaAAAAAORd3Es082.jpg
local originalUri = ngx.var.uri
--/data/fdfs/data/00/00/CgcXPlwOPFmEKxzaAAAAAORd3Es082.jpg?x-oss-process=image/resize,m_fill,w_90,h_80
local originalFile = ngx.var.file;
print("originalUri=",originalUri)
print("originalFile=",originalFile)
local index = string.find(originalFile, "?");  
if index then 
    originalFile = string.sub(originalFile, 0, index-1);  
	print("originalFile=",originalFile)
end
--local originalFile =ngx.var.uri
local uri_args = ngx.req.get_uri_args()
 
local ossStyle=uri_args["x-oss-process"];
 
print("ossStyle=",ossStyle)

local w_width = string.match(ossStyle, "w_[0-9]+")
print("w_width=",w_width)
print("a=",#w_width)
local width=string.sub(w_width ,#"w_"+1,#w_width)
print("width=",width)

local h_height = string.match(ossStyle, "h_[0-9]+")
print("h_height =",h_height )
print("a=",#h_height )
local height=string.sub(h_height ,#"h_"+1,#h_height )
print("height=",height)

local area=width.."x"..height
print("area=",area)
newFile=originalFile.."_"..area..".jpg"
newUrl=originalUri.."_"..area..".jpg"
print("newUrl=",newUrl)
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
local command = "gm convert " .. originalFile  .. " -thumbnail " .. area .. " -auto-orient -gravity center -extent   " .. area .. " " .. newFile;
os.execute(command);

if file_exists(newFile) then
   --ngx.req.set_uri(newUrl, true);  
	print("last2 newFile=",newUrl)
   return ngx.exec(newUrl)
else
   return ngx.exit(404)
end