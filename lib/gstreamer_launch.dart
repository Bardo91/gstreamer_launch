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

class GstreamerLaunch {
  static const MethodChannel _channel = MethodChannel('gstreamer_launch');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<GstElement> nativeGstParseLaunch(String cmd) async {
    var nativeLib = _getDynamicLibraryGst();
    var gstLaunch = nativeLib.lookupFunction<NativeGstLaunchFunction,
        NativeGstLaunchFunction>("native_gst_parse_launch");

    var nativeCmd = cmd.toNativeUtf8();

    //return GstElement(gstElem: elem);
    return GstElement(nativePtr: gstLaunch(nativeCmd));
  }

  static DynamicLibrary _getDynamicLibraryGst() {
    final DynamicLibrary nativeEdgeDetection = Platform.isLinux
        ? DynamicLibrary.open("libgstreamer_launch_plugin.so")
        : DynamicLibrary.process();
    return nativeEdgeDetection;
  }
}
