#ifndef _LIMAGE_LIB__
#define _LIMAGE_LIB__

#include <lua.h>

#ifdef __cplusplus
extern "C" {
#endif


int luaopen_limage(lua_State* L);
/*
	local width,height=image_size("/user/test.jpg")
	if width and height then
		
	end
*/

#ifdef __cplusplus
}
#endif

#endif