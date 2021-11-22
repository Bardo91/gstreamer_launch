

cmake_minimum_required(VERSION 3.10)

add_library(gstreamer_launch_android_native SHARED gstreamer_launch_android_native.cpp)

find_library( log-lib log )

target_link_libraries( gstreamer_launch_android_native PRIVATE ${log-lib} )


set(GSTREAMER_ANDROID_INCLUDE_DIRS C:/gstreamer-1.0-android-universal-1.18.5/armv7/include/gstreamer-1.0/gst)

target_include_directories(gstreamer_launch_android_native PRIVATE ${GSTREAMER_ANDROID_INCLUDE_DIRS})