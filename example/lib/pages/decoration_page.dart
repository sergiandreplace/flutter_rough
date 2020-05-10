import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

class DecorationExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('RoughDecorator example')),
        body: Container(
          width: double.infinity,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            children: <Widget>[
              const NiceBox(),
              const SizedBox(height: 32),
              const HighlightedText(),
              const SizedBox(height: 32),
              const CircledIcon(),
              const SizedBox(height: 32),
              const SecretText(),
            ],
          ),
        ));
  }
}

class NiceBox extends StatelessWidget {
  const NiceBox({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(
            width: 4,
            color: Colors.orange,
          ),
          filler: DotFiller(FillerConfig.build(hachureGap: 15, fillWeight: 10)),
          fillStyle: RoughDrawingStyle(
            width: 2,
            color: Colors.blue[100],
          )),
      child: const Text(
        'BoxDecorator\ndecorating\na nice\nbox with text',
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: RoughBoxDecoration(
        shape: RoughBoxShape.rectangle,
        filler: ZigZagFiller(FillerConfig.defaultConfig.copyWith(hachureGap: 6, hachureAngle: 110)),
        fillStyle: RoughDrawingStyle(color: Colors.yellow[600], width: 6),
      ),
      child: const Text(
        'Text remarked with a highlighter',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CircledIcon extends StatelessWidget {
  const CircledIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: RoughBoxDecoration(
        shape: RoughBoxShape.circle,
        drawConfig: DrawConfig.build(
          roughness: 2,
          curveTightness: 0.1,
          curveFitting: 1,
          curveStepCount: 6,
        ),
        filler: SolidFiller(FillerConfig.defaultConfig),
        borderStyle: RoughDrawingStyle(
          color: Colors.lightGreen,
          width: 6,
        ),
      ),
      child: Icon(Icons.format_paint),
    );
  }
}

class SecretText extends StatelessWidget {
  const SecretText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 18),
        text: 'This text has a ',
        children: <InlineSpan>[
          WidgetSpan(
              child: Container(
            decoration: RoughBoxDecoration(
                shape: RoughBoxShape.rectangle,
                drawConfig: DrawConfig.build(),
                filler: HatchFiller(FillerConfig.build(
                  hachureAngle: 20,
                  hachureGap: 5,
                  drawConfig: DrawConfig.build(roughness: 3),
                )),
                fillStyle: RoughDrawingStyle(
                  color: Colors.brown,
                  width: 2,
                )),
            child: Text(
              'secret text',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          )),
          const TextSpan(text: ' that you can not read'),
        ],
      ),
    );
  }
}
