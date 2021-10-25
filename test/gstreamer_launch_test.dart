import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gstreamer_launch/gstreamer_launch.dart';

void main() {
  const MethodChannel channel = MethodChannel('gstreamer_launch');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await GstreamerLaunch.platformVersion, '42');
  });
}
