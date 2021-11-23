

cmake_minimum_required(VERSION 3.10)

add_library(gstreamer_launch_android_native SHARED gstreamer_launch_android_native.cpp)

find_library( log-lib log )

target_link_libraries( gstreamer_launch_android_native PRIVATE ${log-lib} )

set(ARCH_ABI x86)
if(${ANDROID_ABI} STREQUAL "armeabi-v7a")
    set(ARCH_ABI armv7)
elseif(${ANDROID_ABI} STREQUAL "arm64-v8a")
    set(ARCH_ABI arm64)
elseif(${ANDROID_ABI} STREQUAL "x86")
    set(ARCH_ABI x86)
elseif(${ANDROID_ABI} STREQUAL "x86_64")
    set(ARCH_ABI x86_64)
else()
    message(FATAL_ERROR "Unknown architecture")
endif()

set(GSTREAMER_ANDROID_ROOT C:/gstreamer-1.0-android-universal-1.18.5)
set(GSTREAMER_ANDROID_ROOT_INCLUDE ${GSTREAMER_ANDROID_ROOT}/${ARCH_ABI}/include)
set(GSTREAMER_ANDROID_INCLUDE_DIRS  ${GSTREAMER_ANDROID_ROOT_INCLUDE}/gstreamer-1.0
                                    ${GSTREAMER_ANDROID_ROOT_INCLUDE}/glib-2.0
                                    ${GSTREAMER_ANDROID_ROOT}/${ARCH_ABI}/lib/glib-2.0/include)

target_include_directories(gstreamer_launch_android_native PUBLIC ${GSTREAMER_ANDROID_INCLUDE_DIRS})



set(GSTREAMER_ANDROID_LIB_DIR ${GSTREAMER_ANDROID_ROOT}/${ARCH_ABI}/lib)

set(GSTREAMER_STATIC_LIBRARIES  ${GSTREAMER_ANDROID_LIB_DIR}/libgstreamer-1.0.a
                                ${GSTREAMER_ANDROID_LIB_DIR}/libgstbase-1.0.a
                                ${GSTREAMER_ANDROID_LIB_DIR}/libgmodule-2.0.a
                                ${GSTREAMER_ANDROID_LIB_DIR}/libgobject-2.0.a
                                ${GSTREAMER_ANDROID_LIB_DIR}/libglib-2.0.a
                                ${GSTREAMER_ANDROID_LIB_DIR}/libgio-2.0.a
                                ${GSTREAMER_ANDROID_LIB_DIR}/libffi.a
                                ${GSTREAMER_ANDROID_LIB_DIR}/libintl.a
                                ${GSTREAMER_ANDROID_LIB_DIR}/libiconv.a)

target_link_libraries(gstreamer_launch_android_native PUBLIC  ${GSTREAMER_STATIC_LIBRARIES})