import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

import 'gstreamer_launch.dart';

import 'package:image/image.dart' as img_pack;

class GstreamerCustomPainter extends CustomPainter {
  late GstElement _appSink;
  late Timer _timerDraw;
  bool _repaint = false;
  late ui.Image _image;

  GstreamerCustomPainter(Future<GstElement> appSink, notifier): super(repaint: notifier) {
    appSink.then((value) {
      _appSink = value;
      _timerDraw = Timer.periodic(const Duration(milliseconds: 30), (Timer t) {
        GstreamerLaunch.pullSample(_appSink).then((_imageData) {
          img_pack.Image img =
              img_pack.Image(_imageData.width, _imageData.height);
          for (var y = 0; y < _imageData.height; y++) {
            for (var x = 0; x < _imageData.width; x++) {
              int idx = (y * _imageData.width + x) * 3;
              var pixel = _imageData.buffer.elementAt(idx);
              int r = pixel.elementAt(0).value;
              int g = pixel.elementAt(1).value;
              int b = pixel.elementAt(2).value;
              img.setPixelRgba(x, y, r, g, b, 255);
            }
          }
          ui.decodeImageFromPixels(img.getBytes(), _imageData.width,
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
