#include "include/gstreamer_launch/gstreamer_launch_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

#include <gst/gst.h>

// dartImageCallback receives a pointer to buffer, width, height, and a format as string
typedef int (*dartImageCallback)(uint8_t *, int, int, const char *);

namespace {
  class GstreamerLaunchPlugin : public flutter::Plugin {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    GstreamerLaunchPlugin();

    virtual ~GstreamerLaunchPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void GstreamerLaunchPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows * registrar) {
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                          registrar->messenger(), "gstreamer_launch",
                          &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<GstreamerLaunchPlugin>();

    channel->SetMethodCallHandler( [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  GstreamerLaunchPlugin::GstreamerLaunchPlugin() {}

  GstreamerLaunchPlugin::~GstreamerLaunchPlugin() {}

  void GstreamerLaunchPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                               std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name().compare("getPlatformVersion") == 0) {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater())
        version_stream << "10+";
      else if (IsWindows8OrGreater())
        version_stream << "8";
      else if (IsWindows7OrGreater())
        version_stream << "7";
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else {
      result->NotImplemented();
    }
  }

} // namespace

//---------------------------------------------------------------------------------------------------------------------
void GstreamerLaunchPluginRegisterWithRegistrar( FlutterDesktopPluginRegistrarRef registrar) {
  GstreamerLaunchPlugin::RegisterWithRegistrar( flutter::PluginRegistrarManager::GetInstance() ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport) 
void *native_gst_parse_launch(char *str) {
  if (!gst_is_initialized())
    gst_init(0, 0);

  GstElement *pipe = gst_parse_launch(str, nullptr);
  return (void *)pipe;
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport) 
void native_gst_element_set_state(void *_pipe, int _state) {
  if (_state < 0 || _state > 4)
  {
    std::cout << "Error, gst states are within 0 and 4. https://gstreamer.freedesktop.org/documentation/gstreamer/gstelement.html?gi-language=c#GstState" << std::endl;
    return;
  }

  GstElement *pipe = reinterpret_cast<GstElement *>(_pipe);
  gst_element_set_state(pipe, static_cast<GstState>(_state));
}

extern "C" __declspec(dllexport) 
void* native_gst_get_app_sink_by_name(void *_pipe, char *str) {
  GstElement *pipe = reinterpret_cast<GstElement *>(_pipe);
  GstElement *sink = gst_bin_get_by_name(GST_BIN(pipe), str);
  std::cout << "Found sink with name " << str << " " << sink << ". Connecting to callback." << gst_element_get_name(sink) << std::endl;
  return sink;
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport) 
void * native_gst_pull_sample(void *_sink) {
  GstElement *sink = reinterpret_cast<GstElement *>(_sink);
  GstSample *sample;
  g_signal_emit_by_name(sink, "pull-sample", &sample);
  return sample; 
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport) 
void native_gst_sample_release(void *_sample) {
  GstSample *sample = reinterpret_cast<GstSample *>(_sample);
  gst_sample_unref(sample);
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport) 
int native_gst_sample_width(void *_sample) {
  GstSample *sample = reinterpret_cast<GstSample *>(_sample);
  auto caps = gst_sample_get_caps(sample);
  auto structure = gst_caps_get_structure(caps, 0);

  gint width;
  gst_structure_get_int(structure, "width", &width);
  return width; 
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport) 
int native_gst_sample_height(void *_sample) {
  GstSample *sample = reinterpret_cast<GstSample *>(_sample);
  auto caps = gst_sample_get_caps(sample);
  auto structure = gst_caps_get_structure(caps, 0);

  gint height;
  gst_structure_get_int(structure, "height", &height);
  return height; 
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport) 
uint8_t * native_gst_sample_buffer(void *_sample) {
  GstSample *sample = reinterpret_cast<GstSample *>(_sample);
  auto caps = gst_sample_get_caps(sample);
  auto structure = gst_caps_get_structure(caps, 0);

  // Get video name
  const gchar *gname = gst_structure_get_name(structure);
  if (!gname)
    return nullptr;
  std::string name(gname);

  std::cout << "Name channel " << name  << std::endl;
  // Get buffer of sample  --> https://github.com/opencv/opencv/blob/17234f82d025e3bbfbf611089637e5aa2038e7b8/modules/videoio/src/cap_gstreamer.cpp#L453
  GstBuffer *buffer = gst_sample_get_buffer(sample);
  GstMapInfo mapInfo;
  gst_buffer_map(buffer, &mapInfo, GST_MAP_READ);

  if (name == "video/x-raw") { // We do not support compressed formats by now.
    // const char *gFormat = gst_structure_get_string(structure, "format");
    return mapInfo.data; 
  }
  return nullptr;
}
