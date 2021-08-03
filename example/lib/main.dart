import 'package:flutter/material.dart';
import 'package:paymesdk/paymesdk.dart';

void main() {
  runApp(MyApp());
}

const APP_TOKEN_DEFAULT_SANDBOX =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MTQsImlhdCI6MTYxNDE2NDI3MH0.MmzNL81YTx8XyTu6SczAqZtnCA_ALsn9GHsJGBKJSIk";
const PUBLIC_KEY_DEFAULT_SANDBOX = "-----BEGIN PUBLIC KEY-----\n" +
    "      MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMyTFdiYBiaSIBgqFdxSgzk5LYXKocgT\n" +
    "      MCx/g1gz9k2jadJ1PDohCs7N65+dh/0dTbT8CIvXrrlAgQT1zitpMPECAwEAAQ==\n" +
    "      -----END PUBLIC KEY-----";
const SECRET_KEY_DEFAULT_SANDBOX = "de7bbe6566b0f1c38898b7751b057a94";
const PRIVATE_KEY_DEFAULT_SANDBOX = "-----BEGIN RSA PRIVATE KEY-----\n" +
    "      MIIBOQIBAAJAZCKupmrF4laDA7mzlQoxSYlQApMzY7EtyAvSZhJs1NeW5dyoc0XL\n" +
    "      yM+/Uxuh1bAWgcMLh3/0Tl1J7udJGTWdkQIDAQABAkAjzvM9t7kD84PudR3vEjIF\n" +
    "      5gCiqxkZcWa5vuCCd9xLUEkdxyvcaLWZEqAjCmF0V3tygvg8EVgZvdD0apgngmAB\n" +
    "      AiEAvTF57hIp2hkf7WJnueuZNY4zhxn7QNi3CQlGwrjOqRECIQCHfqO53A5rvxCA\n" +
    "      ILzx7yXHzk6wnMcGnkNu4b5GH8usgQIhAKwv4WbZRRnoD/S+wOSnFfN2DlOBQ/jK\n" +
    "      xBsHRE1oYT3hAiBSfLx8OAXnfogzGLsupqLfgy/QwYFA/DSdWn0V/+FlAQIgEUXd\n" +
    "      A8pNN3/HewlpwTGfoNE8zCupzYQrYZ3ld8XPGeQ=\n" +
    "      -----END RSA PRIVATE KEY-----";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _accountStatus = 'Not Connected. Please LOGIN first';
  bool _connected = false;

  @override
  Widget build(BuildContext context) {
    final sdkArgs = PaymeSdkConfig(
      appToken: APP_TOKEN_DEFAULT_SANDBOX,
      publicKey: PUBLIC_KEY_DEFAULT_SANDBOX,
      privateKey: PRIVATE_KEY_DEFAULT_SANDBOX,
      secretKey: SECRET_KEY_DEFAULT_SANDBOX,
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(_accountStatus),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final status =
                        await Paymesdk.login('10002', '0987654321', sdkArgs);
                    setState(() {
                      _accountStatus = status;
                      _connected = true;
                    });
                    print(status);
                  } catch (e) {
                    print(e);
                    setState(() {
                      _connected = false;
                    });
                  }
                },
                child: Text("1. Login"),
              ),
              ElevatedButton(
                onPressed: _connected
                    ? () async {
                        try {
                          final info = await Paymesdk.getAccountInfo();
                          print(info);
                        } catch (e) {
                          print(e);
                        }
                      }
                    : null,
                child: Text("2. getAccountInfo"),
              ),
              ElevatedButton(
                onPressed: _connected
                    ? () async {
                        try {
                          final info = await Paymesdk.getSupportedServices();
                          print(info);
                        } catch (e) {
                          print(e);
                        }
                      }
                    : null,
                child: Text("3. getSupportedServices"),
              ),
              ElevatedButton(
                onPressed: _connected
                    ? () {
                        Paymesdk.openWallet();
                      }
                    : null,
                child: Text("4. openWallet"),
              ),
              ElevatedButton(
                onPressed: _connected
                    ? () {
                        try {
                          Paymesdk.deposit(10000);
                        } catch (e) {
                          print(e);
                        }
                      }
                    : null,
                child: Text("5. deposit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
