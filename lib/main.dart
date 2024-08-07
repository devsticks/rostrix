import 'package:flutter/material.dart';
import 'screens/roster_home_page.dart';

void main() {
  runApp(const RostrixApp());
}

class RostrixApp extends StatelessWidget {
  const RostrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rostrix',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const RosterHomePage(),
    );
  }
}
