import 'package:RoughExample/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(FlutterRoughDemo());

class FlutterRoughDemo extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Rough Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(),
    );
  }
}
