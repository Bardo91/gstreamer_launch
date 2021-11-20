## 0.1.2-dev.1

* OS Compatibility:
  * Linux   ❌
  * Windows ✅
  * OSx     ❌
  * Android ❌
  * IOs     ❌

# Funtionalities:

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
