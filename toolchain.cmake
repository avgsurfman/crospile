#This sucks
message("Toolchain file loaded with path: $ENV{TOOLS}")
message("CMAKE_SYSROOT: ${CMAKE_SYSROOT}")
message("CMAKE_FIND_ROOT_PATH: ${CMAKE_FIND_ROOT_PATH}")


# set from .bashrc
set(tools $ENV{TOOLS})
set(rootfs_dir /home/develop/rootfs/)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_LIBRARY_ARCHITECTURE aarch64-linux-gnu)
set(CMAKE_CROSSCOMPILING 1)


#set(CMAKE_FIND_ROOT_PATH /home/develop/ros2_ws/install)
set(CMAKE_FIND_ROOT_PATH ${rootfs_dir} /home/develop/ros2_ws/install)
set(CMAKE_PREFIX_PATH ${rootfs_dir})
set(CMAKE_SYSROOT ${rootfs_dir})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8-a+crc -mtune=cortex-a72 -ftree-vectorize -O2 -pipe -fomit-frame-pointer")
# if 32 bit -latomic
set(CMAKE_C_FLAGS= "${CMAKE_C_FLAGS} -march=armv8-a+crc -mtune=cortex-a72 -ftree-vectorize -O2 -pipe -fomit-frame-pointer")



## Compiler Binary 
SET(BIN_PREFIX ${tools}/bin/aarch64-linux-gnu)
#SET(BIN_PREFIX ${tools}/bin/aarch64-none-elf)


SET (CMAKE_C_COMPILER ${BIN_PREFIX}-gcc)
SET (CMAKE_CXX_COMPILER ${BIN_PREFIX}-g++ )
SET (CMAKE_LINKER ${BIN_PREFIX}-ld 
            CACHE STRING "Set the cross-compiler tool LD" FORCE)
SET (CMAKE_AR ${BIN_PREFIX}-ar 
            CACHE STRING "Set the cross-compiler tool AR" FORCE)
SET (CMAKE_NM {BIN_PREFIX}-nm 
            CACHE STRING "Set the cross-compiler tool NM" FORCE)
SET (CMAKE_OBJCOPY ${BIN_PREFIX}-objcopy 
            CACHE STRING "Set the cross-compiler tool OBJCOPY" FORCE)
SET (CMAKE_OBJDUMP ${BIN_PREFIX}-objdump 
            CACHE STRING "Set the cross-compiler tool OBJDUMP" FORCE)
SET (CMAKE_RANLIB ${BIN_PREFIX}-ranlib 
            CACHE STRING "Set the cross-compiler tool RANLIB" FORCE)
SET (CMAKE_STRIP ${BIN_PREFIX}-strip 
            CACHE STRING "Set the cross-compiler tool RANLIB" FORCE)

# ABOVE ADDED AS TEST
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)

#Python SOABI
set(PYTHON_SOABI cpython-311m-aarch64-linux-gnu)

file(GLOB rootfs_dirs ${rootfs_dir}/*)


include_directories(
    /home/develop/rootfs/usr/include/
#    /home/develop/rootfs/usr/include/arm-linux-gnueabihf
    /home/develop/rootfs/usr/include/aarch64-linux-gnu
)
