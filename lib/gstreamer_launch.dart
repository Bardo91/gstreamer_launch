import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';

class GstElement {
  GstElement({required this.nativePtr});

  Pointer<Void> nativePtr;
}

typedef NativeGstLaunchFunction = Pointer<Void> Function(Pointer<Utf8> x);
typedef GstreamerCallbackVideo = Void Function(void);

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

  static Future<GstElement> nativeGstParseLaunch(String cmd) async {
    var nativeLib = _getDynamicLibraryGst();
    var gstLaunch = nativeLib.lookupFunction<NativeGstLaunchFunction,
        NativeGstLaunchFunction>("native_gst_parse_launch");

    var nativeCmd = cmd.toNativeUtf8();

    //return GstElement(gstElem: elem);
    return GstElement(nativePtr: gstLaunch(nativeCmd));
  }

  static Future<void> nativeGstSetElementstate( GstElement element, int state) async {
    var nativeLib = _getDynamicLibraryGst();
    var gstSetElementState = nativeLib.lookupFunction<
        Void Function(Pointer<Void>, Int16),
        void Function(Pointer<Void>, int)>("native_gst_element_set_state");

    gstSetElementState(element.nativePtr, state);
  }

  
  static void testFn(){
    print("testing callbacks as ptr");
  }

  static Future<void> nativeGstSignalConnect( GstElement element, String sinkname) async {
    var nativeLib = _getDynamicLibraryGst();
    var gstSignalConnect = nativeLib.lookupFunction<
        Void Function(Pointer<Void>, Pointer<Utf8>),
        void Function(Pointer<Void>, Pointer<Utf8>)>("native_gst_signal_connect");
    
    gstSignalConnect(element.nativePtr, sinkname.toNativeUtf8());
  }
}
