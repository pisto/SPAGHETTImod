#ifndef __CUBE_H__
#define __CUBE_H__

#define _FILE_OFFSET_BITS 64

#ifdef __GNUC__
#define gamma __gamma
#endif

#ifdef WIN32
#define _USE_MATH_DEFINES
#endif
#include <cmath>

#ifdef __GNUC__
#undef gamma
#endif

#include <cstring>
#include <cstdio>
#include <cstdlib>
#include <cctype>
#include <cstdarg>
#include <climits>
#include <cassert>
#include <ctime>
#include <array>
#include <type_traits>
#include <lua.hpp>

namespace spaghetti
{
    extern lua_State *L;
}

template<typename T, size_t len>
struct lua_array : std::array<T, len>
{
    using up = std::array<T, len>;
    using value_type = typename std::conditional<std::is_scalar<T>::value, T, T&>::type;
    using up::up;
    value_type __arrayindex(int i){
        if(i<0 || i>=len) luaL_error(spaghetti::L, "Index %d is out of array bounds (%d)", i, int(len));
        return static_cast<up&>(*this)[i];
    }
    void __arraynewindex(int i, value_type val){
        if(i<0 || i>=len) luaL_error(spaghetti::L, "Index %d is out of array bounds (%d)", i, int(len));
        static_cast<up&>(*this)[i] = val;
    }
    operator T*(){
        return up::data();
    }
    operator const T*() const{
        return up::data();
    }
    ~lua_array(){}
};

#ifdef WIN32
  #define WIN32_LEAN_AND_MEAN
  #ifdef _WIN32_WINNT
  #undef _WIN32_WINNT
  #endif
  #define _WIN32_WINNT 0x0500
  #include "windows.h"
  #ifndef _WINDOWS
    #define _WINDOWS
  #endif
  #ifndef __GNUC__
    #include <eh.h>
    #include <dbghelp.h>
  #endif
#endif

#ifndef STANDALONE
#include <SDL.h>
#include <SDL_opengl.h>
#endif

#include <enet/enet.h>

#include <zlib.h>

#include "tools.h"
#include "geom.h"
#include "ents.h"
#include "command.h"

#include "iengine.h"
#include "igame.h"

#endif

