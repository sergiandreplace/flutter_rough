import 'package:RoughExample/pages/flutter_logo.dart';
import 'package:RoughExample/pages/interactive_circle.dart';
import 'package:RoughExample/pages/interactive_rectangle.dart';
import 'package:flutter/material.dart';

class Demo {
  final String name;
  final String description;
  final Function launcher;
  final Widget icon;

  Demo(this.name, this.description, this.launcher, this.icon);
}

final List<Demo> demos = [
  Demo(
    "Flutter logo",
    "A simple Flutter logo drawn using Rough",
    (context) => FlutterLogoPage(),
    FlutterLogo(),
  ),
  Demo(
    "Interactive circle",
    "A circle drawn with Rough generated with interactive parameters",
    (context) => InteractiveCirclePage(),
    Icon(
      Icons.add_circle,
      size: 36,
    ),
  ),
  Demo(
    "Interactive rectangle",
    "A rectange drawn with Rough generated with interactive parameters",
    (context) => InteractiveRectanglePage(),
    Icon(
      Icons.add_box,
      size: 36,
    ),
  ),
];
