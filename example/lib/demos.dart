import 'package:RoughExample/pages/flutter_logo.dart';
import 'package:flutter/material.dart';

class Demo {
  final String name;
  final String description;
  final Function launcher;
  final Widget icon;

  Demo(this.name, this.description, this.launcher, this.icon);
}

final List<Demo> demos = [
  Demo("Flutter logo", "A simple Flutter logo drawn using Rough", (context) => FlutterLogoPage(), FlutterLogo()),
];
