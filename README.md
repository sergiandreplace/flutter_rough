![Pub Version](https://img.shields.io/pub/v/rough?label=latest%20version) ![GitHub Release Date](https://img.shields.io/github/release-date/sergiandreplace/flutter_rough)  [![Codemagic build status](https://api.codemagic.io/apps/5eb08350b412c5001ac53791/5eb08350b412c5001ac53790/status_badge.svg)](https://codemagic.io/apps/5eb08350b412c5001ac53791/5eb08350b412c5001ac53790/latest_build) ![GitHub](https://img.shields.io/github/license/sergiandreplace/flutter_rough)

# Rough

Rough is a library that allows you draw in a sketchy, hand-drawn-like style. It's a direct port of [Rough.js](https://roughjs.com/).

## Installation

In the `dependencies:` section of your `pubspec.yaml`, add the following line:

```yaml
dependencies:
  rough: <latest_version>
```
## Basic usage

Right now only drawing via canvas is supported. This is a basic documentation in case you want to play around with Rough. I can't ensure non-breaking changes of the librayr interface.

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

Both `DrawConfig` and `FillerConfig` will use default values for anything not specfied.
