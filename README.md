# gstreamer_launch

A plugin to use gstreamer in your desktop applications (and possibly in mobiles in the future).

## OS Compatibility:
  * Linux   ❌
  * Windows ✅
  * OSx     ❌
  * Android ❌
  * IOs     ❌

## Getting Started

For windows GStreamer download and install both **runtime** and **development** installer. Link: https://gstreamer.freedesktop.org/download/
Add the binaries folder to system PATH. Current implementation does not bundle DLLs with the plugin, thus it is necessary to install the runtime in every computer. 

For linux, install it from repositories. [Not working yet...]

## Funtionalities:

| Functionality | Status  |
|---|---|
| Create pipelines with gst_launch            |✅|
| Create custom pipelines                     |❌|
| Interface appsink                           |✅|
| Interface appsource                         |❌|
| Ready to use widgets to show streams        |❌|
| Ready to use controller to sink streams     |❌|

* Wrapped methods:
  * native_gst_parse_launch
  * native_gst_element_set_state
  * native_gst_get_app_sink_by_name
  * native_gst_pull_sample
  * native_gst_sample_release
  * native_gst_sample_width
  * native_gst_sample_height
  * native_gst_sample_format
  * native_gst_sample_buffer


## Future

* Improve CMakeLists to search properly in both windows and linux the dependencies.
* Allow to access pads of sinks and sources to get/set the raw data in dart code.