import 'package:RoughExample/pages/arc_example.dart';
import 'package:RoughExample/pages/circle_example.dart';
import 'package:RoughExample/pages/flutter_logo_example.dart';
import 'package:RoughExample/pages/rectangle_example.dart';
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
    (context) => FlutterLogoExamplePage(),
    const FlutterLogo(),
  ),
  Demo(
    'Interactive circle',
    'A circle drawn with Rough generated with interactive parameters',
    (context) => CircleExamplePage(),
    const Icon(
      Icons.add_circle,
      size: 36,
    ),
  ),
  Demo(
    'Interactive rectangle',
    'A rectange drawn with Rough generated with interactive parameters',
    (context) => RectangleExamplePage(),
    const Icon(
      Icons.add_box,
      size: 36,
    ),
  ),
  Demo(
    'Interactive arc',
    'An arc drawn with Rough generated with interactive parameters',
    (context) => ArcExamplePage(),
    const Icon(
      Icons.pie_chart_outlined,
      size: 36,
    ),
  ),
];
