import 'package:RoughExample/interactive_canvas.dart';
import 'package:RoughExample/pages/decoration.dart';
import 'package:flutter/material.dart';

import 'interactive_examples.dart';
import 'pages/example.dart';

abstract class Demo {
  final String name;
  final String description;
  final Widget icon;

  Demo(this.name, this.description, this.icon);

  Widget buildPage(BuildContext context);
}

class InteractiveDemo extends Demo {
  final ExampleBuilder exampleBuilder;

  InteractiveDemo(String name, String description, this.exampleBuilder, Widget icon) : super(name, description, icon);

  @override
  Widget buildPage(BuildContext context) {
    return ExamplePage(title: name, exampleBuilder: exampleBuilder);
  }
}

class NormalDemo extends Demo {
  final WidgetBuilder builder;
  NormalDemo(String name, String description, this.builder, Widget icon) : super(name, description, icon);

  @override
  Widget buildPage(BuildContext context) {
    return builder(context);
  }
}

typedef ExampleBuilder = InteractiveExample Function();

final List<Demo> demos = [
  InteractiveDemo('Flutter logo', 'A simple Flutter logo drawn using Rough', () => FlutterLogoExample(), const FlutterLogo()),
  InteractiveDemo(
    'Interactive circle',
    'A circle drawn with Rough generated with interactive parameters',
    () => CircleExample(),
    const Icon(Icons.add_circle, size: 36),
  ),
  InteractiveDemo(
    'Interactive rectangle',
    'A rectange drawn with Rough generated with interactive parameters',
    () => RectangleExample(),
    const Icon(Icons.add_box, size: 36),
  ),
  InteractiveDemo(
    'Interactive arc',
    'An arc drawn with Rough generated with interactive parameters',
    () => ArcExample(),
    const Icon(Icons.pie_chart_outlined, size: 36),
  ),
  InteractiveDemo(
    'Interactive curve',
    'An curve drawn with Rough generated with interactive parameters',
    () => CurveExample(),
    const Icon(Icons.gesture, size: 36),
  ),
  NormalDemo(
    'Decoration demo',
    'Create decorations with Rough',
    (_) => DecorationExamplePage(),
    const Icon(Icons.format_shapes, size: 36),
  )
];
