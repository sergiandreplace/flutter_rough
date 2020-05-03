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
  double curveFitting;
  double curveTightness;
  double curveStepCount;

  DrawConfig drawConfig;

  @override
  void initState() {
    super.initState();
    roughness = DrawConfig.defaultValues.roughness;
    curveFitting = DrawConfig.defaultValues.curveFitting;
    curveTightness = DrawConfig.defaultValues.curveTightness;
    curveStepCount = DrawConfig.defaultValues.curveStepCount;
  }

  updateState({
    double roughness,
    double curveFitting,
    double curveTightness,
    double curveStepCount,
  }) {
    setState(() {
      this.roughness = roughness ?? this.roughness;
      this.curveFitting = curveFitting ?? this.curveFitting;
      this.curveTightness = curveTightness ?? this.curveTightness;
      this.curveStepCount = curveStepCount ?? this.curveStepCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Card(
            child: CircleCanvas(
              roughness: roughness,
              curveFitting: curveFitting,
              curveTightness: curveTightness,
              curveStepCount: curveStepCount,
            ),
          ),
        ),
        Container(
          height: 200,
          child: ListView(
            children: <Widget>[
              ConfigSlider(
                label: "roughness",
                value: roughness,
                min: 0,
                max: 2,
                steps: 50,
                onChange: (value) => updateState(roughness: value),
              ),
              ConfigSlider(
                label: "curveFitting",
                value: curveFitting,
                min: 0,
                max: 2,
                onChange: (value) => updateState(curveFitting: value),
              ),
              ConfigSlider(
                label: "curveTightness",
                value: curveTightness,
                min: 0,
                max: 1,
                onChange: (value) => updateState(curveTightness: value),
              ),
              ConfigSlider(
                label: "curveStepCount",
                value: curveStepCount,
                min: 1,
                max: 11,
                steps: 100,
                onChange: (value) => updateState(curveStepCount: value),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CircleCanvas extends StatelessWidget {
  final double roughness;
  final double curveFitting;
  final double curveTightness;
  final double curveStepCount;

  const CircleCanvas({
    Key key,
    this.roughness,
    this.curveFitting,
    this.curveTightness,
    this.curveStepCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(double.infinity),
      painter: CirclePainter(
        this.roughness,
        this.curveFitting,
        this.curveTightness,
        this.curveStepCount,
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double roughness;
  final double curveFitting;
  final double curveTightness;
  final double curveStepCount;
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

  CirclePainter(
    this.roughness,
    this.curveFitting,
    this.curveTightness,
    this.curveStepCount,
  );

  @override
  void paint(Canvas canvas, Size size) {
    DrawConfig drawConfig = DrawConfig.build(
        roughness: roughness, curveFitting: curveFitting, curveTightness: curveTightness, curveStepCount: curveStepCount, seed: 1);
    Generator generator = Generator(drawConfig, NoFiller(FillerConfig().copyWith(drawConfig: drawConfig)));
    double s = min(size.width, size.height);
    Drawable figure = generator.circle(size.width / 2, size.height / 2, s * 0.8);
    Rough().draw(canvas, figure, pathPaint, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum Shape { circle, square }
