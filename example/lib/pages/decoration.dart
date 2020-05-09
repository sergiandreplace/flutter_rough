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
              Container(
                decoration: RoughDecoration(
                    shape: BoxShape.rectangle,
                    borderStyle: RoughDrawStyle(
                      width: 4,
                      color: Colors.orange,
                    ),
                    filler: DotFiller(FillerConfig.build(hachureGap: 15, fillWeight: 10)),
                    fillStyle: RoughDrawStyle(
                      width: 2,
                      color: Colors.blue[100],
                    )),
                child: const Text(
                  'BoxDecorator\ndecorating\na nice\nbox with text',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: RoughDecoration(
                  shape: BoxShape.rectangle,
                  filler: ZigZagFiller(FillerConfig.defaultConfig.copyWith(hachureGap: 6, hachureAngle: 110)),
                  fillStyle: RoughDrawStyle(color: Colors.yellow[600], width: 6),
                ),
                child: const Text(
                  'Text remarked with a highlighter',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: RoughDecoration(
                  shape: BoxShape.circle,
                  drawConfig: DrawConfig.build(
                    roughness: 2,
                    curveTightness: 0.2,
                    curveFitting: 0.5,
                    curveStepCount: 8,
                  ),
                  borderStyle: RoughDrawStyle(color: Colors.lightGreen, width: 6),
                ),
                child: Icon(Icons.format_paint),
              ),
              const SizedBox(height: 32),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  text: 'This text has a ',
                  children: <InlineSpan>[
                    WidgetSpan(
                        child: Container(
                      decoration: RoughDecoration(
                          shape: BoxShape.rectangle,
                          drawConfig: DrawConfig.build(),
                          filler: HatchFiller(FillerConfig.build(
                            hachureAngle: 20,
                            hachureGap: 5,
                            drawConfig: DrawConfig.build(roughness: 3),
                          )),
                          fillStyle: RoughDrawStyle(
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
              ),
            ],
          ),
        ));
  }
}
