package com.bardo91.gstreamer_launch;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import org.freedesktop.gstreamer.Version;
import org.freedesktop.gstreamer.Pipeline;
import org.freedesktop.gstreamer.Gst;
import org.freedesktop.gstreamer.Element;
import org.freedesktop.gstreamer.State;

import java.util.HashMap;

/** GstreamerLaunchPlugin */
public class GstreamerLaunchPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private HashMap<Integer, Element> elements = new HashMap<Integer, Element>();
  private int id = 0;


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "gstreamer_launch");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Gst.init(Version.BASELINE, "GstreamerLaunchPlugin", "");  // See to initialize once. Nevertheless, it is done internally but is more elegant.

    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE + ". GStreamer version " + Version.BASELINE);
    }else if (call.method.equals("android_gst_parse_launch")) {
      System.out.println(call.arguments);
      String cmd = call.argument("cmd");
      elements.put(id, androidGstParseLaunch(cmd));
      result.success(id);
      id++;
    }else if (call.method.equals("android_gst_element_set_state")) {
      int id = call.argument("id");
      int state = call.argument("state");
      result.success(androidGstElementSetState(elements.get(id), state));
    }else if (call.method.equals("android_gst_get_app_sink_by_name")) {

    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public Pipeline androidGstParseLaunch(String _cmd){
    return (Pipeline) Gst.parseLaunch(_cmd);
  }

  public int androidGstElementSetState(Element _element, int _state){
    Pipeline pipe = (Pipeline) _element;
    switch(_state){
    case 0:
      return 0;
    case 1:
      return pipe.stop().intValue();
    case 2:
      return pipe.ready().intValue();
    case 3:
      return pipe.pause().intValue();
    case 4:
      return pipe.play().intValue();
    }
    return -1;
  }

}
