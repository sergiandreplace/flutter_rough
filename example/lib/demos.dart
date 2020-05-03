import 'package:RoughExample/pages/flutter_logo.dart';
import 'package:RoughExample/pages/interactive_arc.dart';
import 'package:RoughExample/pages/interactive_circle.dart';
import 'package:RoughExample/pages/interactive_rectangle.dart';
import 'package:flutter/material.dart';

class Demo {
  final String name;
  final String description;
  final WidgetBuilder launcher;
  final Widget icon;

  Demo(this.name, this.description, this.launcher, this.icon);
}

final List<Demo> demos = [
  Demo(
    'Flutter logo',
    'A simple Flutter logo drawn using Rough',
    (context) => FlutterLogoPage(),
    const FlutterLogo(),
  ),
  Demo(
    'Interactive circle',
    'A circle drawn with Rough generated with interactive parameters',
    (context) => InteractiveCirclePage(),
    const Icon(
      Icons.add_circle,
      size: 36,
    ),
  ),
  Demo(
    'Interactive rectangle',
    'A rectange drawn with Rough generated with interactive parameters',
    (context) => InteractiveRectanglePage(),
    const Icon(
      Icons.add_box,
      size: 36,
    ),
  ),
  Demo(
    'Interactive arc',
    'An arc drawn with Rough generated with interactive parameters',
    (context) => InteractiveArcPage(),
    const Icon(
      Icons.pie_chart_outlined,
      size: 36,
    ),
  ),
];
