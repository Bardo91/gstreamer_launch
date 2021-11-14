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
                            GstreamerLaunch.nativeGstParseLaunch(cmd)
                                .then((value) {
                              _gstPipeServer = value;
                              GstreamerLaunch.nativeGstSetElementstate(
                                  _gstPipeServer, 4);
                            });
                          },
                          child: const Text("Start Server"))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            GstreamerLaunch.nativeGstSetElementstate(
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
                            GstreamerLaunch.nativeGstParseLaunch(cmd).then((value) {
                              _gstPipeClient = value;
                              GstreamerLaunch.nativeGstSetElementstate(
                                  _gstPipeClient, 4);
                            });
                          },
                          child: const Text("Start Client"))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            GstreamerLaunch.nativeGstSetElementstate(
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
                        GstreamerLaunch.pullSampleAndRunCallback(value, (Pointer<Uint8> _data, int _width, int _height, Pointer<Utf8> _format){
                                          Image.memory(_data.asTypedList(_width*_height*3), width:   _width.toDouble(), height: _height.toDouble());
                                          return 1;  
                                        });
                        });
                  },
                  child: const Text("Retrieve node"),
                ),
              )
            ],
          )),
    );
  }
}
