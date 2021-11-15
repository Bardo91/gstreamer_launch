
import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';

import 'gstreamer_launch.dart';



class GstreamerCustomPainter extends CustomPainter{

  late GstElement _appSink;
  late Timer _timerDraw;
  bool _repaint = false;  
  late ImageData _imageData;

  GstreamerCustomPainter(GstElement appSink){
    _appSink = appSink;
    _timerDraw = Timer.periodic(const Duration(milliseconds: 100), (Timer t){
      GstreamerLaunch.pullSample(_appSink).then((value){
        _imageData = value;
        _repaint = true;
      });
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return _repaint;
  }
}