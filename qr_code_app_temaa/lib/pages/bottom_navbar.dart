import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qr_code_app_temaa/pages/barcodeScannerPage.dart';
import 'package:qr_code_app_temaa/pages/qrCodeScanner.dart';

class MyBottomNav extends StatefulWidget {
  const MyBottomNav({super.key});

  @override
  State<MyBottomNav> createState() => _MyBottomNavState();
}

class _MyBottomNavState extends State<MyBottomNav> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const BarCodeScanner(),
    const QrCodePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              boxShadow: [BoxShadow(blurRadius: 15, color: Colors.black54)]),
          child: BottomNavigationBar(
            showUnselectedLabels: false,
            backgroundColor: HexColor('#00008B').withOpacity(0.6),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: SizedBox(
                      height: 35,
                      width: 35,
                      child: Image.asset(
                        'lib/assets/reader1.png',
                      )),
                  label: 'Barkod Okuyucu'),
              const BottomNavigationBarItem(
                activeIcon: Icon(
                  Icons.qr_code_2_outlined,
                  size: 30,
                ),
                icon: Icon(
                  Icons.qr_code,
                  size: 30,
                  color: Colors.grey,
                ),
                label: 'Qr Kod',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
