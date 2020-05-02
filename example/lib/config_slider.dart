import 'package:flutter/material.dart';

class ConfigSlider extends StatefulWidget {
  final String label;
  final double min;
  final double max;
  final int steps;
  final OnConfigChange onChange;

  const ConfigSlider({Key key, this.label, this.min = 0, this.max = 0, this.steps = 10, this.onChange}) : super(key: key);

  @override
  _ConfigSliderState createState() => _ConfigSliderState();
}

class _ConfigSliderState extends State<ConfigSlider> {
  double configValue = 0;

  onConfigValueChange(double value) {
    setState(() {
      configValue = value;
    });
    widget.onChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text("${widget.label}: ${configValue.toStringAsFixed(1)}"),
        Slider(
          value: configValue,
          divisions: widget.steps,
          min: widget.min,
          max: widget.max,
          onChanged: (value) => onConfigValueChange(value),
        )
      ],
    );
  }
}

typedef OnConfigChange = void Function(double);
