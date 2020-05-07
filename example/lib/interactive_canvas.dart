import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

class DiscreteProperty {
  final String name;
  final String label;
  final double max;
  final double min;
  final int steps;
  final double value;

  DiscreteProperty({this.name, this.label, this.min, this.max, this.steps, this.value});

  static List<DiscreteProperty> drawConfigProperties = [
    DiscreteProperty(name: 'seed', label: 'Seed', min: 0, max: 50, steps: 50),
    DiscreteProperty(name: 'roughness', label: 'Rougness', min: 0, max: 5, steps: 50),
    DiscreteProperty(name: 'curveFitting', label: 'curveFitting', min: 0, max: 5, steps: 50),
    DiscreteProperty(name: 'curveTightness', label: 'curveTightness', min: 0, max: 1, steps: 100),
    DiscreteProperty(name: 'curveStepCount', label: 'curveStepCount', min: 1, max: 20, steps: 190),
    DiscreteProperty(name: 'bowing', label: 'Bowing', min: 0, max: 20, steps: 400),
    DiscreteProperty(name: 'maxRandomnessOffset', label: 'maxRandomnessOffset', min: 0, max: 20, steps: 50),
  ];

  static List<DiscreteProperty> fillerConfigProperties = [
    DiscreteProperty(name: 'fillWeight', label: 'fillWeight', min: 0, max: 50, steps: 500),
    DiscreteProperty(name: 'hachureAngle', label: 'hachureAngle', min: 0, max: 360, steps: 360),
    DiscreteProperty(name: 'hachureGap', label: 'hachureGap', min: 0, max: 50, steps: 500),
    DiscreteProperty(name: 'dashOffset', label: 'dashOffset', min: 0, max: 50, steps: 500),
    DiscreteProperty(name: 'dashGap', label: 'dashGap', min: 0, max: 50, steps: 500),
    DiscreteProperty(name: 'zigzagOffset', label: 'zigzagOffset', min: 0, max: 50, steps: 500),
  ];
}

Map<String, Filler Function(FillerConfig)> _fillers = <String, Filler Function(FillerConfig)>{
  'NoFiller': (fillerConfig) => NoFiller(fillerConfig),
  'HachureFiller': (fillerConfig) => HachureFiller(fillerConfig),
  'ZigZagFiller': (fillerConfig) => ZigZagFiller(fillerConfig),
  'HatchFiller': (fillerConfig) => HatchFiller(fillerConfig),
  'DotFiller': (fillerConfig) => DotFiller(fillerConfig),
  'DashedFiller': (fillerConfig) => DashedFiller(fillerConfig),
  'SolidFiller': (fillerConfig) => SolidFiller(fillerConfig),
};

typedef PainterBuilder = InteractivePainter Function(DrawConfig);

class InteractiveExamplePage extends StatelessWidget {
  final String title;
  final InteractiveExample example;

  const InteractiveExamplePage({Key key, this.title, this.example}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: InteractiveBody(
        example: example,
      ),
    );
  }
}

class InteractiveBody extends StatefulWidget {
  final InteractiveExample example;

  const InteractiveBody({Key key, this.example}) : super(key: key);

  @override
  _InteractiveBodyState createState() => _InteractiveBodyState();
}

class _InteractiveBodyState extends State<InteractiveBody> with TickerProviderStateMixin {
  Map<String, double> drawConfigValues = HashMap<String, double>();
  Map<String, double> fillerConfigValues = HashMap<String, double>();
  String fillerType;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    drawConfigValues['maxRandomnessOffset'] = DrawConfig.defaultValues.roughness;
    drawConfigValues['bowing'] = DrawConfig.defaultValues.roughness;
    drawConfigValues['roughness'] = DrawConfig.defaultValues.roughness;
    drawConfigValues['curveFitting'] = DrawConfig.defaultValues.curveFitting;
    drawConfigValues['curveTightness'] = DrawConfig.defaultValues.curveTightness;
    drawConfigValues['curveStepCount'] = DrawConfig.defaultValues.curveStepCount;
    drawConfigValues['seed'] = DrawConfig.defaultValues.seed.toDouble();
    fillerConfigValues['fillWeight'] = FillerConfig.defaultConfig.fillWeight;
    fillerConfigValues['hachureAngle'] = FillerConfig.defaultConfig.hachureAngle;
    fillerConfigValues['hachureGap'] = FillerConfig.defaultConfig.hachureGap;
    fillerConfigValues['dashOffset'] = FillerConfig.defaultConfig.dashOffset;
    fillerConfigValues['dashGap'] = FillerConfig.defaultConfig.dashGap;
    fillerConfigValues['zigzagOffset'] = FillerConfig.defaultConfig.zigzagOffset;
    fillerType = _fillers.keys.elementAt(0);
    _tabController = TabController(
      length: 3,
      initialIndex: 0,
      vsync: this,
    );
  }

  void updateDrawingConfig({
    String property,
    double value,
  }) {
    setState(() {
      drawConfigValues[property] = value;
    });
  }

  void updateFillerConfig({
    String property,
    double value,
  }) {
    setState(() {
      fillerConfigValues[property] = value;
    });
  }

  void updateFillerType({String value}) {
    setState(() {
      fillerType = value;
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
              drawConfigValues: drawConfigValues,
              fillerConfigValues: fillerConfigValues,
              fillerType: fillerType,
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
                children: DiscreteProperty.drawConfigProperties
                    .map(
                      (property) => PropertySlider(
                        label: property.label,
                        value: drawConfigValues[property.name],
                        min: property.min,
                        max: property.max,
                        steps: property.steps,
                        onChange: (value) => updateDrawingConfig(property: property.name, value: value),
                      ),
                    )
                    .toList(),
              ),
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButton<String>(
                      value: fillerType,
                      isExpanded: false,
                      onChanged: (value) {
                        updateFillerType(value: value);
                      },
                      underline: Container(),
                      items: _fillers.keys
                          .map((fillerKey) => DropdownMenuItem<String>(
                                value: fillerKey,
                                child: Text(fillerKey),
                              ))
                          .toList(),
                    ),
                  ),
                  ...DiscreteProperty.fillerConfigProperties
                      .map(
                        (property) => PropertySlider(
                          label: property.label,
                          value: fillerConfigValues[property.name],
                          min: property.min,
                          max: property.max,
                          steps: property.steps,
                          onChange: (value) => updateFillerConfig(property: property.name, value: value),
                        ),
                      )
                      .toList()
                ],
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

class InteractiveCanvas extends StatelessWidget {
  final InteractiveExample example;
  final Map<String, double> drawConfigValues;
  final Map<String, double> fillerConfigValues;
  final String fillerType;

  const InteractiveCanvas({
    Key key,
    this.example,
    this.drawConfigValues,
    this.fillerConfigValues,
    this.fillerType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DrawConfig drawConfig = DrawConfig.build(
        maxRandomnessOffset: drawConfigValues['maxRandomnessOffset'],
        bowing: drawConfigValues['bowing'],
        roughness: drawConfigValues['roughness'],
        curveFitting: drawConfigValues['curveFitting'],
        curveTightness: drawConfigValues['curveTightness'],
        curveStepCount: drawConfigValues['curveStepCount'],
        seed: drawConfigValues['seed'].floor());
    FillerConfig fillerConfig = FillerConfig.build(
      fillWeight: fillerConfigValues['fillWeight'],
      hachureAngle: fillerConfigValues['hachureAngle'],
      hachureGap: fillerConfigValues['hachureGap'],
      dashOffset: fillerConfigValues['dashOffset'],
      dashGap: fillerConfigValues['dashGap'],
      zigzagOffset: fillerConfigValues['zigzagOffset'],
      drawConfig: drawConfig,
    );
    Filler filler = _fillers[fillerType].call(fillerConfig);
    return CustomPaint(
      size: Size.square(double.infinity),
      painter: InteractivePainter(drawConfig, filler, example),
    );
  }
}

class InteractivePainter extends CustomPainter {
  final DrawConfig drawConfig;
  final Filler filler;
  final InteractiveExample interactiveExample;

  InteractivePainter(this.drawConfig, this.filler, this.interactiveExample);

  @override
  paint(Canvas canvas, Size size) {
    drawConfig.randomizer.reset();
    interactiveExample.paintRough(canvas, size, drawConfig, filler);
  }

  @override
  bool shouldRepaint(InteractivePainter oldDelegate) {
    return oldDelegate.drawConfig != drawConfig;
  }
}

abstract class InteractiveExample {
  void paintRough(Canvas canvas, Size size, DrawConfig drawConfig, Filler filler);
}
