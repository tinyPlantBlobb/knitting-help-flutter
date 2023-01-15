import 'package:flutter/material.dart';

import 'screens/StartScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'knitting help',
      theme: ThemeData(
        // This is the theme of your application.

        primarySwatch: Colors.green,
      ),
      home: const StartPage(title: 'Knitting help'),
    );
  }
}



