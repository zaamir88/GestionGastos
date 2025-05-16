import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ControlGastosApp());
}

class ControlGastosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomeScreen(),
    );
  }
}
