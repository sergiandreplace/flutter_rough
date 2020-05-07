import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../examples.dart';
import '../interactive_canvas.dart';

class ArcExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive arc demo')),
      body: InteractiveBody(
        example: ArcExample(),
      ),
    );
  }
}

class FlutterLogoExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Flutter Logo')),
      body: InteractiveBody(
        example: FlutterLogoExample(),
      ),
    );
  }
}

class CircleExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive circle demo')),
      body: InteractiveBody(
        example: CircleExample(),
      ),
    );
  }
}

class RectangleExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InteractiveExamplePage(title: 'Interactive Rough Rectangle', example: RectangleExample());
  }
}
