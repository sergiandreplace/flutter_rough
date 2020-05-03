import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

class DiscreteProperty {
  final String name;
  final String label;
  final double max;
  final double min;
  final int steps;

  DiscreteProperty({this.name, this.label, this.min, this.max, this.steps});
}

typedef PainterBuilder = InteractivePainter Function(DrawConfig);

class InteractiveBody extends StatefulWidget {
  final PainterBuilder painterBuilder;
  final List<DiscreteProperty> properties;

  const InteractiveBody({Key key, this.painterBuilder, this.properties}) : super(key: key);

  @override
  _InteractiveBodyState createState() => _InteractiveBodyState();
}

class _InteractiveBodyState extends State<InteractiveBody> {
  Map<String, double> propertyValues = HashMap<String, double>();
  DrawConfig drawConfig;

  @override
  void initState() {
    super.initState();
    propertyValues['maxRandomnessOffset'] = DrawConfig.defaultValues.roughness;
    propertyValues['bowing'] = DrawConfig.defaultValues.roughness;
    propertyValues['roughness'] = DrawConfig.defaultValues.roughness;
    propertyValues['curveFitting'] = DrawConfig.defaultValues.curveFitting;
    propertyValues['curveTightness'] = DrawConfig.defaultValues.curveTightness;
    propertyValues['curveStepCount'] = DrawConfig.defaultValues.curveStepCount;
    propertyValues['seed'] = DrawConfig.defaultValues.seed.toDouble();
  }

  void updateState({
    String property,
    double value,
  }) {
    setState(() {
      propertyValues[property] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    DrawConfig drawConfig = DrawConfig.build(
        maxRandomnessOffset: propertyValues['maxRandomnessOffset'],
        bowing: propertyValues['bowing'],
        roughness: propertyValues['roughness'],
        curveFitting: propertyValues['curveFitting'],
        curveTightness: propertyValues['curveTightness'],
        curveStepCount: propertyValues['curveStepCount'],
        seed: propertyValues['seed'].floor());
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Card(
            child: InteractiveCanvas(
              painter: widget.painterBuilder(drawConfig),
            ),
          ),
        ),
        Container(
          height: 200,
          child: ListView(
            children: widget.properties
                .map(
                  (property) => PropertySlider(
                    label: property.label,
                    value: propertyValues[property.name],
                    min: property.min,
                    max: property.max,
                    steps: property.steps,
                    onChange: (value) => updateState(property: property.name, value: value),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}

class PropertySlider extends StatefulWidget {
  final String label;
  final double min;
  final double max;
  final int steps;
  final OnConfigChange onChange;
  final double value;

  const PropertySlider({Key key, this.value, this.label, this.min = 0, this.max = 0, this.steps = 10, this.onChange}) : super(key: key);

  @override
  _PropertySliderState createState() => _PropertySliderState();
}

class _PropertySliderState extends State<PropertySlider> {
  double configValue;

  @override
  void initState() {
    super.initState();
    configValue = widget.value;
  }

  void onConfigValueChange(double value) {
    if (configValue != value) {
      setState(() {
        configValue = value;
      });
      widget.onChange(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text('${widget.label}: ${configValue.toStringAsFixed(1)}'),
        ),
        Expanded(
          child: Slider(
            value: configValue,
            divisions: widget.steps,
            min: widget.min,
            max: widget.max,
            onChanged: onConfigValueChange,
          ),
        )
      ],
    );
  }
}

typedef OnConfigChange = void Function(double);

class InteractiveCanvas extends StatelessWidget {
  final InteractivePainter painter;

  const InteractiveCanvas({
    Key key,
    this.painter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(double.infinity),
      painter: painter,
    );
  }
}

abstract class InteractivePainter extends CustomPainter {
  final DrawConfig drawConfig;

  InteractivePainter(this.drawConfig);

  @override
  paint(Canvas canvas, Size size) {
    paintRough(canvas, size);
  }

  void paintRough(Canvas canvas, Size size);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
