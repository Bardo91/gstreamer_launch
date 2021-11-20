import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gstreamer_launch/GstreamerCustomPainter.dart';
import 'package:gstreamer_launch/gstreamer_launch.dart';
import 'package:image/image.dart' as img_pack;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  late GstElement _gstPipeServer;
  late GstElement _gstPipeClient;
  late Future<GstElement> _appsink;
  bool isInit = false;
  late ValueNotifier<int> _notifier;
  late Timer _timerNotifier;

  Image image = Image.network(
      "https://www.mozilla.org/media/img/structured-data/logo-firefox-nightly.2ae024a36eed.png");

  @override
  void initState() {
    super.initState();
    initPlatformState();

  _notifier = ValueNotifier<int>(0);
  _timerNotifier = Timer.periodic(const Duration(milliseconds: 30), (Timer t) { _notifier.value++;});

  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await GstreamerLaunch.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              Center(
                child: Text('Running on: $_platformVersion\n'),
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            String cmd = "";
                            if (Platform.isLinux) {
                              cmd =
                                  "v4l2src ! videoconvert ! video/x-raw,format=YUY2,width=640,height=480,framerate=30/1 ! jpegenc ! rtpjpegpay ! udpsink host=0.0.0.0 port=5000";
                            } else if (Platform.isWindows) {
                              cmd =
                                  "ksvideosrc ! videoconvert ! video/x-raw,format=YUY2,width=640,height=480,framerate=30/1 ! jpegenc ! rtpjpegpay ! udpsink host=127.0.0.1 port=5000";
                            } else {
                              return;
                            }
                            GstreamerLaunch.parseLaunch(cmd).then((value) {
                              _gstPipeServer = value;
                              GstreamerLaunch.setElementState(
                                  _gstPipeServer, 4);
                            });
                          },
                          child: const Text("Start Server"))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            GstreamerLaunch.setElementState(_gstPipeServer, 1);
                          },
                          child: const Text("Stop Server")))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            String cmd = "";
                            if (Platform.isLinux) {
                              cmd =
                                  "udpsrc address=0.0.0.0 port=5000 ! application/x-rtp,media=video,payload=26,clock-rate=90000,encoding-name=JPEG,framerate=30/1 ! rtpjpegdepay ! jpegdec ! videoconvert ! video/x-raw,format=RGBA ! xvimagesink";
                            } else if (Platform.isWindows) {
                              cmd =
                                  "udpsrc address=127.0.0.1 port=5000 ! application/x-rtp,media=video,payload=26,clock-rate=90000,encoding-name=JPEG,framerate=30/1 ! rtpjpegdepay ! jpegdec ! videoconvert ! video/x-raw,format=RGBA ! appsink name=appsink";
                            } else {
                              return;
                            }
                            GstreamerLaunch.parseLaunch(cmd).then((value) {
                              _gstPipeClient = value;
                              GstreamerLaunch.setElementState(
                                  _gstPipeClient, 4);
                            });
                            isInit = true;
                            setState(() {});
                          },
                          child: const Text("Start Client"))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            GstreamerLaunch.setElementState(_gstPipeClient, 1);
                          },
                          child: const Text("Stop Client")))
                ],
              ),
              Container(
                child: LayoutBuilder(
                  builder: (_, constraints) => Container(
                    width: 666,
                    height: 666,
                    child: isInit
                        ? CustomPaint(
                            painter: GstreamerCustomPainter(
                                GstreamerLaunch.getAppSinkByName(
                                    _gstPipeClient, "appsink"), _notifier))
                        : Container(child: image, )
                  ),
                ),
              )
            ],
          )),
    );
  }
}
