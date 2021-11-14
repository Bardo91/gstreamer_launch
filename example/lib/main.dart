import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gstreamer_launch/gstreamer_launch.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

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
  Image image = Image.network("https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png");

  @override
  void initState() {
    super.initState();
    initPlatformState();
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
                            if(Platform.isLinux){
                              cmd = "v4l2src ! videoconvert ! video/x-raw,format=YUY2,width=640,height=480,framerate=30/1 ! jpegenc ! rtpjpegpay ! udpsink host=0.0.0.0 port=5000";
                            }else if(Platform.isWindows){
                              cmd = "ksvideosrc ! videoconvert ! video/x-raw,format=YUY2,width=640,height=480,framerate=30/1 ! jpegenc ! rtpjpegpay ! udpsink host=127.0.0.1 port=5000";
                            }else{
                              return;
                            }
                            GstreamerLaunch.parseLaunch(cmd)
                                .then((value) {
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
                            GstreamerLaunch.setElementState(
                                _gstPipeServer, 1);
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
                            if(Platform.isLinux){
                              cmd = "udpsrc address=0.0.0.0 port=5000 ! application/x-rtp,media=video,payload=26,clock-rate=90000,encoding-name=JPEG,framerate=30/1 ! rtpjpegdepay ! jpegdec ! videoconvert ! xvimagesink";
                            }else if(Platform.isWindows){
                              cmd = "udpsrc address=127.0.0.1 port=5000 ! application/x-rtp,media=video,payload=26,clock-rate=90000,encoding-name=JPEG,framerate=30/1 ! rtpjpegdepay ! jpegdec ! videoconvert ! appsink name=appsink";
                            }else{
                              return;
                            }
                            GstreamerLaunch.parseLaunch(cmd).then((value) {
                              _gstPipeClient = value;
                              GstreamerLaunch.setElementState(
                                  _gstPipeClient, 4);
                            });
                          },
                          child: const Text("Start Client"))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            GstreamerLaunch.setElementState(
                                _gstPipeClient, 1);
                          },
                          child: const Text("Stop Client")))
                ],
              ),
              Container(
                child:  ElevatedButton(
                  onPressed: (){
                    var appsink = GstreamerLaunch.getAppSinkByName(_gstPipeClient, "appsink");
                    appsink.then((value){
                        GstreamerLaunch.pullSample(value).then((bytes){
                            //image = Image.memory(bytes);
                            setState(() {
                              
                            });
                          });
                        });
                  },
                  child: const Text("Retrieve node"),
                ),
              ),
                Container(
child: image,)
            ],
          )),
    );
  }
}
