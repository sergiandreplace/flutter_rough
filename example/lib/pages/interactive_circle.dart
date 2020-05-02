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
  double bowing;
  double curveFitting;
  double curveTightness;
  double curveStepCount;
  Shape shape;

  DrawConfig drawConfig;

  @override
  void initState() {
    super.initState();
    maxRandomnessOffset = DrawConfig.defaultValues.maxRandomnessOffset;
    roughness = DrawConfig.defaultValues.roughness;
    bowing = DrawConfig.defaultValues.bowing;
    curveFitting = DrawConfig.defaultValues.curveFitting;
    curveTightness = DrawConfig.defaultValues.curveTightness;
    curveStepCount = DrawConfig.defaultValues.curveStepCount;
    shape = Shape.circle;
  }

  updateState({
    double roughness,
    double maxRandomnessOffset,
    double bowing,
    double curveFitting,
    double curveTightness,
    double curveStepCount,
    Shape shape,
  }) {
    setState(() {
      this.roughness = roughness ?? this.roughness;
      this.maxRandomnessOffset = maxRandomnessOffset ?? this.maxRandomnessOffset;
      this.bowing = bowing ?? this.bowing;
      this.curveFitting = curveFitting ?? this.curveFitting;
      this.curveTightness = curveTightness ?? this.curveTightness;
      this.curveStepCount = curveStepCount ?? this.curveStepCount;
      this.shape = shape ?? this.shape;
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
              shape: shape,
              roughness: roughness,
              maxRandomnessOffset: maxRandomnessOffset,
              bowing: bowing,
              curveFitting: curveFitting,
              curveTightness: curveTightness,
              curveStepCount: curveStepCount,
            ),
          ),
        ),
        Container(
          height: 292,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                child: Row(
                  children: <Widget>[
                    Text("shape:"),
                    DropdownButton(
                      value: this.shape,
                      items: <Shape>[Shape.circle, Shape.square].map((Shape value) {
                        return new DropdownMenuItem<Shape>(
                          value: value,
                          child: new Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (value) => updateState(shape: value),
                    )
                  ],
                ),
              ),
              ConfigSlider(
                label: "rougness",
                value: roughness,
                min: 0,
                max: 5,
                steps: 50,
                onChange: (value) => updateState(roughness: value),
              ),
              ConfigSlider(
                label: "maxRandomnessOffset",
                min: 0,
                max: 10,
                steps: 50,
                value: maxRandomnessOffset,
                onChange: (value) => updateState(maxRandomnessOffset: value),
              ),
              ConfigSlider(
                label: "bowing",
                value: bowing,
                min: 0,
                max: 2,
                steps: 50,
                onChange: (value) => updateState(bowing: value),
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
                min: 2,
                max: 10,
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
  final double maxRandomnessOffset;
  final double bowing;
  final double curveFitting;
  final double curveTightness;
  final double curveStepCount;
  final Shape shape;

  const CircleCanvas({
    Key key,
    this.shape,
    this.roughness,
    this.maxRandomnessOffset,
    this.bowing,
    this.curveFitting,
    this.curveTightness,
    this.curveStepCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(double.infinity),
      painter: CirclePainter(
        this.shape,
        this.roughness,
        this.maxRandomnessOffset,
        this.bowing,
        this.curveFitting,
        this.curveTightness,
        this.curveStepCount,
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double roughness;
  final double maxRandomnessOffset;
  final double bowing;
  final double curveFitting;
  final double curveTightness;
  final double curveStepCount;
  final Shape shape;
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
    this.shape,
    this.roughness,
    this.maxRandomnessOffset,
    this.bowing,
    this.curveFitting,
    this.curveTightness,
    this.curveStepCount,
  );

  @override
  void paint(Canvas canvas, Size size) {
    DrawConfig drawConfig = DrawConfig.build(
      roughness: roughness,
      maxRandomnessOffset: maxRandomnessOffset,
      bowing: bowing,
      curveFitting: curveFitting,
      curveTightness: curveTightness,
      curveStepCount: curveStepCount,
    );
    Generator generator = Generator(drawConfig, ZigZagFiller(FillerConfig().copyWith(drawConfig: drawConfig)));
    Drawable figure;
    double s = min(size.width, size.height);
    switch (shape) {
      case Shape.circle:
        figure = generator.circle(size.width / 2, size.height / 2, s * 0.8);
        break;
      case Shape.square:
        figure = generator.rectangle(s * 0.1, s * 0.1, s * 0.8, s * 0.8);
        break;
    }
    Rough().draw(canvas, figure, pathPaint, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum Shape { circle, square }
