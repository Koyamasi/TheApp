import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 74, 22, 164),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.fromARGB(255, 148, 56, 185),
                Color.fromARGB(150, 148, 56, 185),
                Color.fromARGB(100, 148, 56, 185),
                Color.fromARGB(255, 68, 22, 86)
              ],
            ),
          ),
          child: const Center(
            child: Text('Building management app'),
          ),
        ),
      ),
    ),
  );
}
