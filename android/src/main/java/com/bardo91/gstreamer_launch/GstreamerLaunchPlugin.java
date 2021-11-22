package com.bardo91.gstreamer_launch;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** GstreamerLaunchPlugin */
public class GstreamerLaunchPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  
  static {
      System.loadLibrary("gstreamer_launch_android_native");
  }

  public native int Jniint();


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "gstreamer_launch");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Gst.init(Version.BASELINE, "GstreamerLaunchPlugin", "");  // See to initialize once. Nevertheless, it is done internally but is more elegant.

    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE + ". GStreamer version " + String.valueOf(Jniint()));
    }else if (call.method.equals("android_gst_parse_launch")) {
      String cmd = call.argument("cmd");
    }else if (call.method.equals("android_gst_element_set_state")) {
      int id = call.argument("id");
      int state = call.argument("state");
    }else if (call.method.equals("android_gst_get_app_sink_by_name")) {

    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

}
