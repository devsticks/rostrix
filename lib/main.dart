import 'package:flutter/material.dart';
import 'screens/roster_home_page.dart';

void main() {
  runApp(const RostremApp());
}

class RostremApp extends StatelessWidget {
  const RostremApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rostrem',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const RosterHomePage(),
    );
  }
}
