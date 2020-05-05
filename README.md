[![Pub](https://img.shields.io/pub/v/rough?label=latest%20version)](https://pub.dev/packages/rough)
[![GitHub Release Date](https://img.shields.io/github/release-date/sergiandreplace/flutter_rough)](https://pub.dev/packages/rough)
[![GitHub](https://img.shields.io/github/license/sergiandreplace/flutter_rough)](https://github.com/sergiandreplace/flutter_rough/blob/master/LICENSE)

# Rough

Rough is a library that allows you draw in a sketchy, hand-drawn-like style. It's a direct port of [Rough.js](https://roughjs.com/).

## Installation

In the `dependencies:` section of your `pubspec.yaml`, add the following line:

```yaml
dependencies:
  rough: <latest_version>
```
## Basic usage

Right now only drawing via canvas is supported. This is a basic documentation in case you want to play around with Rough. I can't ensure non-breaking changes of the library interface.

To draw a figure you have to:

1. Create a `DrawConfig` object to determine how your drawing will look.
2. Create a `Filler` to be used when drawing objects (you have to provide a configuration for the filling and a `DrawConfig` for the filling path).
3. Create a `Generator` object using the created `DrawConfig` and `Filler`. This will define a drawing/filling style.
4. Invoke the drawing method from the `Generator` to create a `Drawable`.
5. Paint the `Drawable` in the canvas using the `Rough.draw` method.

Here an example on how to draw a rectangle:

```dart
    //Create a `DrawConfig` object.
    DrawConfig myDrawConfig = DrawConfig.build(
      roughness: 3,
      curveStepCount: 14,
      maxRandomnessOffset: 3,
    );

    //Create a `Filler` (we reuse the drawConfig in this case).
    Filler myFiller = ZigZagFiller(
        FillerConfig(
          hachureGap: 8,
          hachureAngle: -20,
          drawConfig: myDrawConfig,
        ),
    );

    //3Create a `Generator` with the created `DrawConfig` and `Filler`
    Generator generator = Generator(
      myDrawConfig,
      myFiller,
    );

    //4. Build a circle `Drawable`.
    Drawable figure = generator.circle(200, 200, 320);

    //5. Paint the `Drawable` in the canvas.
    Rough().draw(canvas, figure, pathPaint, fillPaint);
```

And this is the result:

![Result](https://raw.githubusercontent.com/sergiandreplace/flutter_rough/master/screenshots/circle.png)

Both `DrawConfig` and `FillerConfig` will use default values for anything not specified.

## Samples

Some screenshots of the example app:


![Example 1](https://raw.githubusercontent.com/sergiandreplace/flutter_rough/master/screenshots/example_app_1.jpg)
![Example 2](https://raw.githubusercontent.com/sergiandreplace/flutter_rough/master/screenshots/example_app_2.jpg)
![Example 3](https://raw.githubusercontent.com/sergiandreplace/flutter_rough/master/screenshots/example_app_3.jpg)
![Example 4](https://raw.githubusercontent.com/sergiandreplace/flutter_rough/master/screenshots/example_app_4.jpg)
