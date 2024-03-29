#include "include/gstreamer_launch/gstreamer_launch_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <iostream>
#include <chrono>
#include <thread>

#include <gst/gst.h>

#define GSTREAMER_LAUNCH_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), gstreamer_launch_plugin_get_type(), \
                              GstreamerLaunchPlugin))

struct _GstreamerLaunchPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(GstreamerLaunchPlugin, gstreamer_launch_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void gstreamer_launch_plugin_handle_method_call(
    GstreamerLaunchPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void gstreamer_launch_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(gstreamer_launch_plugin_parent_class)->dispose(object);
}

static void gstreamer_launch_plugin_class_init(GstreamerLaunchPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = gstreamer_launch_plugin_dispose;
}

static void gstreamer_launch_plugin_init(GstreamerLaunchPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  GstreamerLaunchPlugin* plugin = GSTREAMER_LAUNCH_PLUGIN(user_data);
  gstreamer_launch_plugin_handle_method_call(plugin, method_call);
}

void gstreamer_launch_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  GstreamerLaunchPlugin* plugin = GSTREAMER_LAUNCH_PLUGIN(
      g_object_new(gstreamer_launch_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "gstreamer_launch",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}


extern "C" __attribute__((visibility("default"))) __attribute__((used))
void *native_gst_parse_launch(char *str) {
  if(!gst_is_initialized())
    gst_init(0,0);
  
  GstElement * pipe = gst_parse_launch(str, nullptr);
  return (void*) pipe;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void native_gst_element_set_state(void *_pipe, int _state){
  if(_state < 0 || _state > 4){
    std::cout << "Error, gst states are within 0 and 4. https://gstreamer.freedesktop.org/documentation/gstreamer/gstelement.html?gi-language=c#GstState" << std::endl;
    return;
  }

  GstElement *pipe = reinterpret_cast<GstElement*>(_pipe);
  gst_element_set_state(pipe, static_cast<GstState>(_state));
  
}