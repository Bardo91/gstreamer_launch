cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "gstreamer_launch")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "gstreamer_launch_plugin")

add_library(${PLUGIN_NAME} SHARED
  "gstreamer_launch_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/")

# find_package(GStreamer REQUIRED)

# target_link_libraries(${PLUGIN_NAME} PRIVATE ${GSTREAMER_LIBRARIES})
# target_include_directories(${PLUGIN_NAME} PRIVATE ${GSTREAMER_INCLUDE_DIRS})

set(GSTREAMER_INCLUDE_DIRS  "C:/gstreamer/1.0/msvc_x86_64/include" 
                            "C:/gstreamer/1.0/msvc_x86_64/include/gstreamer-1.0"
                            "C:/gstreamer/1.0/msvc_x86_64/include/glib-2.0"
                            "C:/gstreamer/1.0/msvc_x86_64/lib/glib-2.0/include"
                            "C:/gstreamer/1.0/msvc_x86_64/include/"
                            "C:/gstreamer/1.0/msvc_x86_64/include/"
                            "C:/gstreamer/1.0/msvc_x86_64/include/")

file(
        GLOB_RECURSE
        GSTREAMER_LIBRARIES
        "C:/gstreamer/1.0/msvc_x86_64/lib/*dll.a"
)


target_link_libraries(${PLUGIN_NAME} PRIVATE ${GSTREAMER_LIBRARIES})
target_include_directories(${PLUGIN_NAME} PRIVATE ${GSTREAMER_INCLUDE_DIRS})


# List of absolute paths to libraries that should be bundled with the plugin
set(gstreamer_launch_bundled_libraries
  # ${GSTREAMER_LIBRARIES}
  ""
  PARENT_SCOPE
)
