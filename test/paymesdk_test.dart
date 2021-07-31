import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paymesdk/paymesdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('paymesdk');

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
    expect(await Paymesdk.platformVersion, '42');
  });
}
