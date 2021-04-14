import 'package:detect_face_example/pages/detect_face_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detect Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DetectFacePage(),
    );
  }
}

