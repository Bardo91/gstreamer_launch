//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <gstreamer_launch/gstreamer_launch_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) gstreamer_launch_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "GstreamerLaunchPlugin");
  gstreamer_launch_plugin_register_with_registrar(gstreamer_launch_registrar);
}
