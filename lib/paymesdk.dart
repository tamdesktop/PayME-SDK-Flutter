import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PaymeSdkLanguage { VN, EN }

enum PaymeSdkEnv { PRODUCTION, SANDBOX, DEV }

class PaymeSdkConfig {
  final String appToken;
  final String publicKey;
  final String privateKey;
  final String secretKey;
  final Color primaryColor;
  final Color secondaryColor;
  final PaymeSdkLanguage language;
  final PaymeSdkEnv env;

  PaymeSdkConfig({
    @required this.appToken,
    @required this.publicKey,
    @required this.privateKey,
    @required this.secretKey,
    this.primaryColor = const Color(0xff75255b),
    this.secondaryColor = const Color(0xff9d455f),
    this.language = PaymeSdkLanguage.VN,
    this.env = PaymeSdkEnv.SANDBOX,
  });
}

class Paymesdk {
  static const MethodChannel _channel = const MethodChannel('paymesdk');

  static Future<String> login(
      String userId, String phone, PaymeSdkConfig config) async {
    final args = {
      'user_id': userId,
      'phone': phone,
      'app_token': config.appToken,
      'public_key': config.publicKey,
      'private_key': config.privateKey,
      'secret_key': config.secretKey,
      'primary_color': _hexFromColor(config.primaryColor),
      'secondary_color': _hexFromColor(config.secondaryColor),
      'language': _enumValue(config.language),
      'env': _enumValue(config.env),
    };
    final String version = await _channel.invokeMethod('login', args);
    return version;
  }

  static Future<dynamic> getAccountInfo() {
    return _channel.invokeMethod('getAccountInfo');
  }

  static Future<dynamic> openWallet() {
    return _channel.invokeMethod('openWallet');
  }

  static Future<dynamic> deposit(int amount, {bool closeDepositResult = true}) {
    final args = {
      'amount': amount,
      'close_deposit_result': closeDepositResult,
    };
    return _channel.invokeMethod('deposit', args);
  }

  static Future<dynamic> getSupportedServices() {
    return _channel.invokeMethod('getSupportedServices');
  }
}

String _hexFromColor(Color color) {
  return '#${color.value.toRadixString(16).substring(2, 8)}';
}

String _enumValue(dynamic e) {
  return e.toString().split('.').last;
}
