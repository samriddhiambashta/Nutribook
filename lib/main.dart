import 'package:calorie_check/home_screen.dart';
import 'package:flutter/material.dart';
import 'health.dart';

void main() => runApp(Nutribook());

class Nutribook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
