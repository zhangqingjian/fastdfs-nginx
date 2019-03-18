#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>


int limage_size(lua_State* L)
{
	int x, y, comp;
	FILE* file=NULL;
	const char* filepath=luaL_checkstring(L,1);
	file=fopen(filepath,"rb");
	if(file)
	{
		if(stbi_info_from_file(file,&x,&y,&comp)>0)
		{
			lua_pushnumber(L,(lua_Number)x);
			lua_pushnumber(L,(lua_Number)y);
			fclose(file);
			return 2;
		}
		fclose(file);
	}
	return 0;
}

int luaopen_limage(lua_State* L)
{
	#lua_pushcfunction(L,limage_size);
	#lua_setglobal(L,"image_size");
	 luaL_register(L,libName,mylibs);
	return 1;
}

