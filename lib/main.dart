import 'package:flutter/material.dart';
import 'auth_screen.dart';

void main() {
  runApp(const BuildingExpenseApp());
}

class BuildingExpenseApp extends StatelessWidget {
  const BuildingExpenseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Building Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthScreen(),
    );
  }
}
