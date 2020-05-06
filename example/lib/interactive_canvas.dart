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
  final InteractiveExample example;
  final List<DiscreteProperty> properties;

  const InteractiveBody({Key key, this.example, this.properties}) : super(key: key);

  @override
  _InteractiveBodyState createState() => _InteractiveBodyState();
}

class _InteractiveBodyState extends State<InteractiveBody> with TickerProviderStateMixin {
  Map<String, double> propertyValues = HashMap<String, double>();
  TabController _tabController;

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
    _tabController = TabController(
      length: 3,
      initialIndex: 0,
      vsync: this,
    );
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
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Card(
            child: InteractiveCanvas(
              example: widget.example,
              propertyValues: propertyValues,
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: <Widget>[
            ConfigTab(label: 'Draw', iconData: Icons.border_color),
            ConfigTab(label: 'Filler', iconData: Icons.format_color_fill),
            ConfigTab(label: 'Shape', iconData: Icons.format_shapes),
          ],
          onTap: (index) => setState(() => _tabController.index = index),
        ),
        Container(
          height: 200,
          child: IndexedStack(
            sizing: StackFit.expand,
            index: _tabController.index,
            children: <Widget>[
              ListView(
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
              Container(
                child: const Center(
                  child: Text('ehllo'),
                ),
              ),
              Container(
                child: const Center(
                  child: Text('ehllo'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ConfigTab extends StatelessWidget {
  final String label;
  final IconData iconData;

  const ConfigTab({Key key, this.label, this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(iconData, size: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
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
        ),
      ],
    );
  }
}

typedef OnConfigChange = void Function(double);

class InteractiveCanvas extends StatefulWidget {
  final InteractiveExample example;
  final Map<String, double> propertyValues;

  const InteractiveCanvas({
    Key key,
    this.example,
    this.propertyValues,
  }) : super(key: key);

  @override
  _InteractiveCanvasState createState() => _InteractiveCanvasState();
}

class _InteractiveCanvasState extends State<InteractiveCanvas> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DrawConfig drawConfig = DrawConfig.build(
        maxRandomnessOffset: widget.propertyValues['maxRandomnessOffset'],
        bowing: widget.propertyValues['bowing'],
        roughness: widget.propertyValues['roughness'],
        curveFitting: widget.propertyValues['curveFitting'],
        curveTightness: widget.propertyValues['curveTightness'],
        curveStepCount: widget.propertyValues['curveStepCount'],
        seed: widget.propertyValues['seed'].floor());
    return CustomPaint(
      size: Size.square(double.infinity),
      painter: InteractivePainter(drawConfig, widget.example),
    );
  }
}

class InteractivePainter extends CustomPainter {
  final DrawConfig drawConfig;
  final InteractiveExample interactiveExample;

  InteractivePainter(this.drawConfig, this.interactiveExample);

  @override
  paint(Canvas canvas, Size size) {
    interactiveExample.paintRough(canvas, size, drawConfig);
  }

  @override
  bool shouldRepaint(InteractivePainter oldDelegate) {
    return oldDelegate.drawConfig != drawConfig;
  }
}

abstract class InteractiveExample {
  void paintRough(Canvas canvas, Size size, DrawConfig drawConfig);
}
