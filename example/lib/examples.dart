import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

import 'interactive_canvas.dart';

class FlutterLogoExample extends InteractiveExample {
  Paint stroke = Paint()
    ..strokeWidth = 2
    ..isAntiAlias = true
    ..color = Colors.blueAccent
    ..strokeCap = StrokeCap.square
    ..style = PaintingStyle.stroke;

  Paint fillPaint = Paint()
    ..strokeWidth = 1
    ..isAntiAlias = true
    ..color = Colors.lightBlueAccent
    ..style = PaintingStyle.stroke;

  @override
  void paintRough(canvas, size, drawConfig, Filler filler) {
    Generator gen = Generator(drawConfig, filler);
    double logoWidth = 165;
    double logoHeight = 201;
    double widthScale = (size.width) / (logoWidth);
    double heightScale = (size.height) / (logoHeight);
    double scale = min(widthScale, heightScale);
    double translateX = (size.width - logoWidth * scale) / 2;
    double translateY = (size.height - logoHeight * scale) / 2;

    canvas
      ..translate(translateX, translateY)
      ..scale(scale)
      ..drawRough(gen.polygon([PointD(37, 128), PointD(9, 101), PointD(100, 10), PointD(156, 10)]), stroke, fillPaint)
      ..translate(-4, -4)
      ..drawRough(gen.polygon([PointD(156, 94), PointD(100, 94), PointD(50, 141), PointD(79, 170)]), stroke, fillPaint)
      ..translate(6, 6)
      ..drawRough(gen.polygon([PointD(79, 170), PointD(100, 191), PointD(156, 191), PointD(107, 142)]), stroke, fillPaint);
  }
}

class ArcExample extends InteractiveExample {
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

  @override
  void paintRough(Canvas canvas, Size size, DrawConfig drawConfig, Filler filler) {
    Generator generator = Generator(drawConfig, filler);
    double s = min(size.width, size.height);
    Drawable figure = generator.arc(size.width / 2, size.height / 2, s * 0.8, s * 0.8, pi * 0.2, pi * 1.8, true);
    canvas.drawRough(figure, pathPaint, fillPaint);
  }
}

class CircleExample extends InteractiveExample {
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

  @override
  void paintRough(Canvas canvas, Size size, DrawConfig drawConfig, Filler filler) {
    Generator generator = Generator(drawConfig, filler);
    double s = min(size.width, size.height);
    Drawable figure = generator.circle(size.width / 2, size.height / 2, s * 0.8);
    canvas.drawRough(figure, pathPaint, fillPaint);
  }
}

class RectangleExample extends InteractiveExample {
  final Paint pathPaint = Paint()
    ..color = Colors.lightGreen.withOpacity(0.8)
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.square
    ..strokeWidth = 5;
  final Paint fillPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 1;

  @override
  void paintRough(Canvas canvas, Size size, DrawConfig drawConfig, Filler filler) {
    Generator generator = Generator(drawConfig, filler);

    Drawable figure = generator.rectangle(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6);
    canvas.drawRough(figure, pathPaint, fillPaint);
  }
}
