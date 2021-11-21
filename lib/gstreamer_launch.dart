import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';

class GstElement {
  GstElement();

  Pointer<Void> nativePtr = Pointer<Void>.fromAddress(0);
  int androidId = 0;
}

typedef NativeGstLaunchFunction = Pointer<Void> Function(Pointer<Utf8> x);
typedef GstreamerCallbackVideo = Void Function(void);

typedef DartImageCallbackPrototypeNative = Int32 Function(
    Pointer<Uint8>, Int32, Int32, Pointer<Utf8>);
typedef DartImageCallbackPrototype = int Function(
    Pointer<Uint8>, int, int, Pointer<Utf8>);

class ImageData {
  late int width;
  late int height;
  late Pointer<Uint8> buffer;
  late String format;

  ImageData(this.width, this.height, this.buffer, this.format);
}

class GstreamerLaunch {
  static const MethodChannel _channel = MethodChannel('gstreamer_launch');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static DynamicLibrary _getDynamicLibraryGst() {
    final DynamicLibrary nativeEdgeDetection = Platform.isWindows
        ? DynamicLibrary.open("gstreamer_launch_plugin.dll")
        : DynamicLibrary.process();
    return nativeEdgeDetection;
  }

  static Future<GstElement> parseLaunch(String cmd) async {
    if (Platform.isAndroid) {
      int ?pipeId = await _channel.invokeMethod('android_gst_parse_launch');
      GstElement element = GstElement();
      element.androidId = pipeId!;
      return element;
    }

    var nativeLib = _getDynamicLibraryGst();
    var gstLaunch = nativeLib.lookupFunction<NativeGstLaunchFunction,
        NativeGstLaunchFunction>("native_gst_parse_launch");

    var nativeCmd = cmd.toNativeUtf8();

    GstElement element = GstElement();
    element.nativePtr = gstLaunch(nativeCmd);
    return element;
  }

  static Future<void> setElementState(GstElement element, int state) async {
    if (Platform.isAndroid) {
      await _channel
          .invokeMethod('android_gst_element_set_state', [element, state]);
      return;
    }

    var nativeLib = _getDynamicLibraryGst();
    var gstSetElementState = nativeLib.lookupFunction<
        Void Function(Pointer<Void>, Int16),
        void Function(Pointer<Void>, int)>("native_gst_element_set_state");

    gstSetElementState(element.nativePtr, state);
  }

  static Future<GstElement> getAppSinkByName(
      GstElement element, String sinkname) async {
    if (Platform.isAndroid) {
      var sink = await _channel.invokeMethod(
          'android_gst_get_app_sink_by_name', [element, sinkname]);
      return sink;
    }

    var nativeLib = _getDynamicLibraryGst();
    var gstSignalConnect = nativeLib.lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>),
        Pointer<Void> Function(
            Pointer<Void>, Pointer<Utf8>)>("native_gst_get_app_sink_by_name");

    GstElement sink = GstElement();
    sink.nativePtr = gstSignalConnect(element.nativePtr, sinkname.toNativeUtf8());
    return sink;
  }

  static Future<ImageData> pullSample(GstElement _appSink) async {
    var nativeLib = _getDynamicLibraryGst();

    var pullSampleFn = nativeLib.lookupFunction<
        Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)>("native_gst_pull_sample");
    var sampleWidthFn = nativeLib.lookupFunction<Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)>("native_gst_sample_width");
    var sampleHeightFn = nativeLib.lookupFunction<Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)>("native_gst_sample_height");
    var sampleBufferFn = nativeLib.lookupFunction<
        Pointer<Uint8> Function(Pointer<Void>),
        Pointer<Uint8> Function(Pointer<Void>)>("native_gst_sample_buffer");
    var sampleFormatFn = nativeLib.lookupFunction<
        Pointer<Utf8> Function(Pointer<Void>),
        Pointer<Utf8> Function(Pointer<Void>)>("native_gst_sample_format");

    Pointer<Void> sample = pullSampleFn(_appSink.nativePtr);
    ImageData data = ImageData(sampleWidthFn(sample), sampleHeightFn(sample),
        sampleBufferFn(sample), sampleFormatFn(sample).toDartString());

    return data;
  }
}
