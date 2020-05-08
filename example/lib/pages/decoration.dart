import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

class DecorationExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('RoughDecorator example')),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: const RoughDecoration(
                    shape: BoxShape.rectangle,
                    roughDrawDecoration: RoughDrawDecoration(
                      width: 10,
                      color: Colors.orange,
                      gradient: SweepGradient(
                        colors: [Colors.greenAccent, Colors.purpleAccent, Colors.greenAccent],
                      ),
                    ),
                  ),
                  child: Container(
                    color: Colors.red.withOpacity(0.0),
                    child: const Text(
                      'BoxDecorator\ndel amor\ninfinito\nsin igual',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    gradient: SweepGradient(
                      colors: [Colors.greenAccent, Colors.purpleAccent, Colors.greenAccent],
//                      begin: Alignment.topCenter,
//                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    color: Colors.white.withOpacity(0.0),
                    child: const Text(
                      'BoxDecorator\ndel amor\ninfinito\nsin igual',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
