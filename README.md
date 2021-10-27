# gstreamer_launch

A plugin to use gstreamer in your desktop applications (and possibly in mobiles in the future).

## Getting Started

For windows GStreamer download and install both **runtime** and **development** installer. Link: https://gstreamer.freedesktop.org/download/
Add the binaries folder to system PATH.

For linux, install it from repositories.

## Future

* Improve CMakeLists to search properly in both windows and linux the dependencies.
* Allow to access pads of sinks and sources to get/set the raw data in dart code.