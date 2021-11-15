import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';

class GstElement {
  GstElement({required this.nativePtr});

  Pointer<Void> nativePtr;
}

typedef NativeGstLaunchFunction = Pointer<Void> Function(Pointer<Utf8> x);
typedef GstreamerCallbackVideo = Void Function(void);

typedef DartImageCallbackPrototypeNative = Int32 Function(Pointer<Uint8>, Int32, Int32, Pointer<Utf8>);
typedef DartImageCallbackPrototype = int Function(Pointer<Uint8>, int, int, Pointer<Utf8>);

class ImageData{
    late int width;
    late int height;
    late Pointer<Uint8> buffer;

    ImageData(this.width, this.height, this.buffer);
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
    var nativeLib = _getDynamicLibraryGst();
    var gstLaunch = nativeLib.lookupFunction<NativeGstLaunchFunction,
        NativeGstLaunchFunction>("native_gst_parse_launch");

    var nativeCmd = cmd.toNativeUtf8();

    //return GstElement(gstElem: elem);
    return GstElement(nativePtr: gstLaunch(nativeCmd));
  }

  static Future<void> setElementState( GstElement element, int state) async {
    var nativeLib = _getDynamicLibraryGst();
    var gstSetElementState = nativeLib.lookupFunction<
        Void Function(Pointer<Void>, Int16),
        void Function(Pointer<Void>, int)>("native_gst_element_set_state");

    gstSetElementState(element.nativePtr, state);
  }

  static Future<GstElement> getAppSinkByName(GstElement element, String sinkname) async {
    var nativeLib = _getDynamicLibraryGst();
    var gstSignalConnect = nativeLib.lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>),
        Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>)>("native_gst_get_app_sink_by_name");
    
    return GstElement(nativePtr: gstSignalConnect(element.nativePtr, sinkname.toNativeUtf8()));
  }

  static Future<ImageData> pullSample( GstElement _appSink) async {
    var nativeLib = _getDynamicLibraryGst();

    var pullSampleFn = nativeLib.lookupFunction<    Pointer<Void> Function(Pointer<Void>), 
                                                    Pointer<Void> Function(Pointer<Void>)>("native_gst_pull_sample");
    var sampleWidthFn = nativeLib.lookupFunction<   Int32 Function(Pointer<Void>), 
                                                    int Function(Pointer<Void>)>("native_gst_sample_width");
    var sampleHeightFn = nativeLib.lookupFunction<  Int32 Function(Pointer<Void>), 
                                                    int Function(Pointer<Void>)>("native_gst_sample_height");
    var sampleBufferFn = nativeLib.lookupFunction<  Pointer<Uint8> Function(Pointer<Void>), 
                                                    Pointer<Uint8> Function(Pointer<Void>)>("native_gst_sample_buffer");
    
    Pointer<Void> sample = pullSampleFn(_appSink.nativePtr);
    ImageData data = ImageData(sampleWidthFn(sample), sampleHeightFn(sample), sampleBufferFn(sample));

    return data;
  }



}
