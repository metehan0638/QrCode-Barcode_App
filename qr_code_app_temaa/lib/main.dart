import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_app_temaa/firebase_options.dart';
import 'package:qr_code_app_temaa/pages/bottom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  
  
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qr code app',
      home: MyBottomNav(),
    );
  }
}
