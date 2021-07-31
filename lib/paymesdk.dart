
import 'dart:async';

import 'package:flutter/services.dart';

class Paymesdk {
  static const MethodChannel _channel =
      const MethodChannel('paymesdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
