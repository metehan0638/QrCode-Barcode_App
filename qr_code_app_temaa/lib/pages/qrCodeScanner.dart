// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({Key? key}) : super(key: key);

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  late String userName;
  late String userEmail;

  String getResult = '';
  bool isGetResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#00008B'),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
        child: Column(
          children: [
            Expanded(child: myAppBar(context)),
            const SizedBox(
              height: 50.0,
            ),
            Expanded(child: _myQrIcon()),
            const Expanded(
              child: SizedBox(
                height: 50.0,
              ),
            ),
            _myElevatedButton(),
            const SizedBox(
              height: 40.0,
            ),
            isGetResult ? _myRowContainers() : const SizedBox(),
            const SizedBox(
              height: 30.0,
            ),
          ],
        ),
      )),
    );
  }

  void scanQrCode() async {
    userName = AutofillHints.name;
    userEmail = AutofillHints.email;
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);

      if (!mounted) return;

      setState(() {
        getResult = qrCode;
        isGetResult = true;
      });
    } on PlatformException {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Hata !'),
            content: const Text('QR kod okunamadı !'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Tekrar Dene'))
            ],
          );
        },
      );
    }
  }

  static Widget myAppBar(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.transparent,
        height: 55,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            'QR Code Tarayıcı',
            style: GoogleFonts.mPlus1(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _myQrIcon() {
    return const SizedBox(
      height: 200,
      width: 200,
      child: Icon(
        Icons.qr_code_scanner,
        size: 128,
        color: Colors.white,
      ),
    );
  }

  Widget _myElevatedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: HexColor('#00b7eb'),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(width: 2, color: Colors.blue.shade200),
      ),
      onPressed: () {
        scanQrCode();
      },
      child: Padding(
        padding:
            const EdgeInsets.only(top: 14.0, bottom: 14, left: 64, right: 64),
        child: Text(
          'QR Okut',
          style: GoogleFonts.mPlus1(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _myRowContainers() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 65,
            decoration: BoxDecoration(
                color: HexColor('#00b7eb'),
                border: Border.all(color: Colors.blue.shade200, width: 1),
                borderRadius: BorderRadius.circular(16)),
            child: GestureDetector(
              onTap: () {
                _launchUrl();
              },
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        getResult,
                        style: GoogleFonts.mPlus1(
                          decoration: TextDecoration.underline,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          _launchUrl();
                        },
                        icon: const Icon(Icons.launch)),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl() async {
    final url = getResult;
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Tekrar Dene',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
            backgroundColor: Colors.grey.shade300,
            title: const Center(
                child: Text(
              'Hata',
              style: TextStyle(color: Colors.red),
            )),
            content: const SizedBox(
              height: 75,
              child: Center(
                child: Text(
                  'Geçersiz Url Hatası !',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
