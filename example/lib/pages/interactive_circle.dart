import 'dart:math';

import 'package:RoughExample/config_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

class InteractiveCirclePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Interactive circle demo")),
      body: InteractiveBody(),
    );
  }
}

class InteractiveBody extends StatefulWidget {
  @override
  _InteractiveBodyState createState() => _InteractiveBodyState();
}

class _InteractiveBodyState extends State<InteractiveBody> {
  double roughness;
  double maxRandomnessOffset;

  DrawConfig drawConfig;

  @override
  void initState() {
    super.initState();
    drawConfig = buildConfig();
    maxRandomnessOffset = drawConfig.maxRandomnessOffset;
    roughness = drawConfig.roughness;
  }

  buildConfig() => DrawConfig().copyWith(
        roughness: roughness,
        maxRandomnessOffset: maxRandomnessOffset,
      );

  updateState({double roughness, double maxRandomnessOffset}) {
    setState(() {
      this.roughness = roughness ?? this.roughness;
      this.maxRandomnessOffset = maxRandomnessOffset ?? this.maxRandomnessOffset;
      this.drawConfig = buildConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: CircleCanvas(
            drawConfig: buildConfig(),
          ),
        ),
        ConfigSlider(
          label: "rougness",
          min: 0,
          max: 5,
          steps: 50,
          onChange: (value) {
            if (value != roughness) updateState(roughness: value);
          },
        ),
        ConfigSlider(
          label: "maxRandomnessOffset",
          min: 0,
          max: 50,
          steps: 50,
          onChange: (value) {
            if (value != maxRandomnessOffset) updateState(maxRandomnessOffset: value);
          },
        ),
      ],
    );
  }
}

class CircleCanvas extends StatelessWidget {
  final DrawConfig drawConfig;

  const CircleCanvas({Key key, this.drawConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(drawConfig),
    );
  }
}

class CirclePainter extends CustomPainter {
  final DrawConfig drawConfig;
  final Paint pathPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 2;
  final Paint fillPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 1;

  CirclePainter(this.drawConfig);

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("size: ${size.width} x ${size.height}");
    Generator generator = Generator(drawConfig, ZigZagFiller(FillerConfig().copyWith(drawConfig: drawConfig)));
    Drawable circle = generator.circle(size.width / 2, size.height / 2, min(size.height, size.width) * 0.8);
    Rough().draw(canvas, circle, pathPaint, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
