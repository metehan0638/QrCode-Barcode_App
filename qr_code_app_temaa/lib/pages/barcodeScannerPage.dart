// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class BarCodeScanner extends StatefulWidget {
  const BarCodeScanner({super.key});

  @override
  State<BarCodeScanner> createState() => _BarCodeScannerState();
}

class _BarCodeScannerState extends State<BarCodeScanner> {
  String? gelenBarkodNum;
  String? gelenProductName;
  String? gelenPrice;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  bool isProductRegistered = false;
  var unknownProduct = 'Ürün Kayıtlı değil';
  var unknownProductPrice = 'Fiyat Bilgisi Kayıtlı değil';
  String scanBarcode = 'Okunamadı';
  late String scanBarcodeResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor('#00008B'),
        body: Builder(builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
                alignment: Alignment.center,
                child: Flex(direction: Axis.vertical, children: <Widget>[
                  const SizedBox(
                    height: 25.0,
                  ),
                  myAppBar(context),
                  const SizedBox(
                    height: 45.0,
                  ),
                  barkodIcon(),
                  const SizedBox(
                    height: 75,
                  ),
                  _buildButton(),
                  const SizedBox(
                    height: 10,
                  ),
                ])),
          );
        }));
  }

  Future<void> scanBarcodeNormal() async {
    try {
      scanBarcodeResponse = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'İptal', true, ScanMode.BARCODE);
      debugPrint('$scanBarcodeResponse ilk okunan code');
    } on PlatformException {
      scanBarcodeResponse = 'Barcode okunamadı';
    }

    if (!mounted) return;

    setState(() {
      scanBarcode = scanBarcodeResponse;
      _verileriGetir();
    });
  }

  _buildFirmaContainer(String leading, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(
          leading,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        const SizedBox(
          width: 15,
        ),
        Expanded(child: Text(trailing))
      ],
    );
  }

  _verileriEkle() async {
    await firestore.collection('products').doc(scanBarcode).set({
      'productName': productNameController.text,
      'barkodNum': scanBarcode,
      'price': productPriceController.text
    });
  }

  Future _verileriGetir() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(scanBarcode)
        .get()
        .then((gelenVeri) {
      setState(() {
        try {
          setState(() {
            gelenBarkodNum = gelenVeri.data()?['barkodNum'];
            gelenProductName = gelenVeri.data()?['productName'];
            gelenPrice = gelenVeri.data()?['price'];
            debugPrint(gelenProductName.toString());
            isProductRegistered = true;
          });
        } catch (e) {
          debugPrint('e hata');
        }
        if (gelenBarkodNum == scanBarcode) {
          debugPrint('$gelenBarkodNum gelen');
          debugPrint('$scanBarcode okunan');
          kayitliAlertDialog();
        } else {
          debugPrint(gelenBarkodNum);
          debugPrint(scanBarcode);
          newProductAlertDialog();
        }
      });
    });
  }

  Future kayitliAlertDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tamam'))
          ],
          title: const Center(child: Text('Ürün Bilgileri')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 35,
                ),
                _buildFirmaContainer('Ürün İsmi', gelenProductName.toString()),
                const SizedBox(
                  height: 35,
                ),
                _buildFirmaContainer(
                    'Barkod Numarası', gelenBarkodNum.toString()),
                const SizedBox(
                  height: 35,
                ),
                _buildFirmaContainer('Fiyat', '$gelenPrice ₺'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future newProductAlertDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _verileriEkle();
                                    });

                                    productNameController.clear();
                                    productPriceController.clear();
                                    Navigator.pop(context);
                                    const snackBar = SnackBar(
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.green,
                                      content: Text(
                                        'Veri Başarıyla Eklenmiştir',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  },
                                  child: const Text('Kaydet'))
                            ],
                            title: const Center(child: Text('Ürün Ekle')),
                            content: SizedBox(
                              height: 180,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          hintText: 'Ürün İsmi Giriniz'),
                                      controller: productNameController,
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          hintText: 'Ürün Fiyatını Giriniz'),
                                      controller: productPriceController,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(
                          top: 8.0, bottom: 8, left: 25, right: 25),
                      child: Text('Ürünü Sisteme Ekle'),
                    )),
              ),
            )
          ],
          title: const Center(child: Text('Ürün Bilgileri')),
          content: SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  _buildFirmaContainer('Ürün İsmi', unknownProduct),
                  const SizedBox(
                    height: 25,
                  ),
                  _buildFirmaContainer('Barkod Numarası', scanBarcode),
                  const SizedBox(
                    height: 25,
                  ),
                  _buildFirmaContainer('Fiyat', unknownProductPrice),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget myAppBar(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.transparent,
        height: 85,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            'Barkod Tarayıcı',
            style: GoogleFonts.mPlus1(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget barkodIcon() {
    return SizedBox(
      height: 200,
      width: 200,
      child: Image.asset('lib/assets/reader_icons.png'),
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: HexColor('#00b7eb'),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            side: BorderSide(width: 2, color: Colors.blue.shade200)),
        onPressed: () {
          scanBarcodeNormal();
        },
        child: Padding(
          padding:
              const EdgeInsets.only(top: 14.0, bottom: 14, left: 48, right: 48),
          child: Text(
            'Barkod Okut',
            style: GoogleFonts.mPlus1(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ));
  }
}
