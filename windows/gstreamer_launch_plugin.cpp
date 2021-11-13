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
  void GstreamerLaunchPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar) {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "gstreamer_launch",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<GstreamerLaunchPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  GstreamerLaunchPlugin::GstreamerLaunchPlugin() {}

  GstreamerLaunchPlugin::~GstreamerLaunchPlugin() {}

  void GstreamerLaunchPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name().compare("getPlatformVersion") == 0) {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater()) {
        version_stream << "10+";
      } else if (IsWindows8OrGreater()) {
        version_stream << "8";
      } else if (IsWindows7OrGreater()) {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    } else {
      result->NotImplemented();
    }
  }

}  // namespace

//---------------------------------------------------------------------------------------------------------------------
void GstreamerLaunchPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  GstreamerLaunchPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport)
void *native_gst_parse_launch(char *str) {
  if(!gst_is_initialized())
    gst_init(0,0);
  
  GstElement * pipe = gst_parse_launch(str, nullptr);
  return (void*) pipe;
}

//---------------------------------------------------------------------------------------------------------------------
extern "C" __declspec(dllexport)
void native_gst_element_set_state(void *_pipe, int _state){
  if(_state < 0 || _state > 4){
    std::cout << "Error, gst states are within 0 and 4. https://gstreamer.freedesktop.org/documentation/gstreamer/gstelement.html?gi-language=c#GstState" << std::endl;
    return;
  }

  GstElement *pipe = reinterpret_cast<GstElement*>(_pipe);
  gst_element_set_state(pipe, static_cast<GstState>(_state));
  
}

//---------------------------------------------------------------------------------------------------------------------
static GstFlowReturn newSampleCallback (GstElement *sink, void *_dartCb) {
  GstSample *sample;
  g_signal_emit_by_name (sink, "pull-sample", &sample);
  if (sample) {
    std::cout << "Received new data" << std::endl;
    gst_sample_unref (sample);
    return GST_FLOW_OK;
  }

  return GST_FLOW_ERROR;
}

// typedef void (*GstreamerCallbackVideo)(void);

extern "C" __declspec(dllexport)
void native_gst_signal_connect(void *_pipe, char *str){
  
  GstElement *pipe = reinterpret_cast<GstElement*>(_pipe);
  GstElement *sink = gst_bin_get_by_name(GST_BIN(pipe), str);
  std::cout << "Found sink with name " << str << " " << sink << ". Connecting to callback."<< gst_element_get_name(sink) << std::endl;
  g_object_set (sink, "emit-signals", TRUE);
  g_signal_connect (sink, "new-sample", G_CALLBACK (newSampleCallback), nullptr);
}


