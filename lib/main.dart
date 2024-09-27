import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp(),
      ),
    );

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  late QRViewController controller;
  bool isFlashOn = false;
  bool isFrontCamera = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scan"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: isFlashOn ? const Icon(Icons.flash_on) : const Icon(Icons.flash_off),
            onPressed: toggleFlash,
          ),
          IconButton(
            icon: isFrontCamera
                ? const Icon(Icons.camera_front)
                : const Icon(Icons.camera_rear),
            onPressed: flipCamera,
          )
        ],
      ),
      body: Column(
        children:[
          Expanded(
            flex: 5,
            child: Center(
              child: QRView(
                key: qrKey,
                overlay: QrScannerOverlayShape(
                  borderRadius: 10,
                  borderColor: Colors.red,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: 'Scan result: ',
                  style: const TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: qrText,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (qrText.isNotEmpty) {
                            launchURL(qrText);
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code!; // Access the scan result properly
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void pauseCamera() {
    controller.pauseCamera();
  }

  void resumeCamera() {
    controller.resumeCamera();
  }

  void flipCamera() {
    controller.flipCamera();
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
  }

  void toggleFlash() {
    controller.toggleFlash();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  void launchURL(String url) async {
   
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url'; // Fallback to add http if missing
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url'); // Log the error
    }
  }
}
