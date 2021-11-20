import 'dart:async';
import 'dart:ffi';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'gstreamer_launch.dart';

class GstreamerCustomPainter extends CustomPainter {
  late GstElement _appSink;
  late Timer _timerDraw;
  bool _repaint = false;
  late ui.Image _image;

  GstreamerCustomPainter(Future<GstElement> appSink, notifier): super(repaint: notifier) {
    appSink.then((value) {
      _appSink = value;
      _timerDraw = Timer.periodic(const Duration(milliseconds: 1), (Timer t) {
        GstreamerLaunch.pullSample(_appSink).then((_imageData) {
          ui.decodeImageFromPixels(_imageData.buffer.asTypedList(_imageData.width*_imageData.height*4), _imageData.width,
              _imageData.height, ui.PixelFormat.rgba8888, (image) {
            _image = image;
            _repaint = true;
          });
        });
      });
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(_image, new Offset(0.0, 0.0), new Paint());
    _repaint = false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return _repaint;
  }
}
