import 'package:flutter/material.dart';
import 'package:kadai/api/Github.dart';

import 'app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark().copyWith(
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 20, color: Colors.white),
      )
    );
    final lightTheme = ThemeData.light().copyWith(
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 20, color: Colors.black)
      )
    );

    return MaterialApp(
      title: "kadai",
      darkTheme: darkTheme,
      theme: lightTheme,
      home: const App(),
    );
  }
}
