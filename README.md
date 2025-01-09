# haarcascade

A Dart package for detecting objects in images using Haarcascade and OpenCV.

## Features

- Detect faces in images

## Getting started

To use this package, add `haarcascade` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

```yaml
dependencies:
  haarcascade: ^0.0.1
```

Then import the package in your Dart code.

```dart
import 'package:haarcascade/haarcascade.dart';
```

## Usage

Here is an example of how to use the package to detect faces in an image.

```dart
// 1) Load the Haar Cascade data
final cascade = await Haarcascade.load();

// 2) Load the image
final image = File('path/to/image.jpg');

// 3) Detect faces
final faces = await cascade.detect(image);
```

