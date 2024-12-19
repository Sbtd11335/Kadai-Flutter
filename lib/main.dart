import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

final githubToken = StateProvider((_) => "");
final repositoryName = StateProvider((_) => "");
final search = StateProvider((_) => false);

void main() {
  runApp(const ProviderScope(child: MyApp()));
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
      home: const ProviderScope(child: App()),
    );
  }
}