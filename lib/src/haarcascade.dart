import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:haarcascade/src/face_detection.dart';
import 'package:haarcascade/src/stage.dart';

class Haarcascade {
  final List<Stage> _stages;

  Haarcascade(this._stages);

  static Future<Haarcascade> load() async {
    final stages = await Stages.load();
    return Haarcascade(stages);
  }

  List<int> _computeIntegralImage(img.Image grayImage) {
    final width = grayImage.width;
    final height = grayImage.height;

    // Each element: integral[y*width + x]
    final integral = List<int>.filled(width * height, 0);

    for (int y = 0; y < height; y++) {
      int rowSum = 0;
      for (int x = 0; x < width; x++) {
        // If grayImage is indeed grayscale, the pixel's R=G=B, so just take the red channel
        final pixel = grayImage.getPixel(x, y);
        // 0xFF & pixel gives us the alpha, so shift or mask as needed:
        final intensity = pixel.b;

        rowSum += intensity.floor();
        final above = (y > 0) ? integral[(y - 1) * width + x] : 0;
        integral[y * width + x] = rowSum + above;
      }
    }

    return integral;
  }

  /// Runs a basic Viola-Jones detection using the loaded stages.
  /// [image] is your integral image for the grayscale input.
  /// [minScale], [maxScale], [scaleStep] define the scanning scales.
  /// [stepSize] defines how many pixels to shift the window each iteration.
  List<FaceDetection> detect({
    required Uint8List image,
    double minScale = 1.0,
    double maxScale = 4.0,
    double scaleStep = 1.2,
    int stepSize = 2,
  }) {
    const baseWindowSize = 24; // as stated, the cascade window is always 24x24
    final List<FaceDetection> detections = [];

    // Decode to an image object
    final imageData = img.decodeImage(image);

    if (imageData == null) {
      print('Failed to decode image');
      return detections;
    }

    // Convert to grayscale using the built-in method
    final grayImage = img.grayscale(imageData);
    final imageWidth = grayImage.width;
    final imageHeight = grayImage.height;

    final integral = _computeIntegralImage(grayImage);

    double currentScale = minScale;
    while (currentScale <= maxScale) {
      final windowSize = (baseWindowSize * currentScale).round();
      // If scaled window is larger than the image, break early.
      if (windowSize > imageWidth || windowSize > imageHeight) {
        break;
      }

      for (int y = 0; y <= imageHeight - windowSize; y += stepSize) {
        for (int x = 0; x <= imageWidth - windowSize; x += stepSize) {
          bool passedAll = true;

          // Evaluate each stage in order.
          for (final stage in _stages) {
            if (!stage.evaluate(integral, imageWidth, imageHeight, x, y, currentScale)) {
              passedAll = false;
              break;
            }
          }

          // If all stages pass, record detection.
          if (passedAll) {
            detections.add(FaceDetection(x, y, windowSize, windowSize));
          }
        }
      }

      currentScale *= scaleStep;
    }

    return detections;
  }
}