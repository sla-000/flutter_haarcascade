import 'dart:typed_data';

import 'package:haarcascade/src/face_detection.dart';
import 'package:haarcascade/src/stage.dart';

class Haarcascade {
  final List<Stage> _stages;

  Haarcascade(this._stages);

  static Future<Haarcascade> load() async {
    final stages = await Stages.load();
    return Haarcascade(stages);
  }

  /// Runs a basic Viola-Jones detection using the loaded stages.
  /// [image] is your integral image for the grayscale input.
  /// [imageWidth], [imageHeight] is the image size.
  /// [minScale], [maxScale], [scaleStep] define the scanning scales.
  /// [stepSize] defines how many pixels to shift the window each iteration.
  List<FaceDetection> detect({
    required Uint8List image,
    required int imageWidth,
    required int imageHeight,
    double minScale = 1.0,
    double maxScale = 4.0,
    double scaleStep = 1.2,
    int stepSize = 2,
  }) {
    const baseWindowSize = 24; // as stated, the cascade window is always 24x24
    final detections = <FaceDetection>[];

    double currentScale = minScale;

    final gray = Uint8List(imageWidth * imageHeight);
    for (int i = 0; i < imageWidth * imageHeight; i++) {
      final r = image[4 * i];
      final g = image[4 * i + 1];
      final b = image[4 * i + 2];
      // Simple luminance approximation
      gray[i] = ((0.299 * r) + (0.587 * g) + (0.114 * b)).round();
    }

    final integral = List<int>.filled(imageWidth * imageHeight, 0);

    for (int y = 0; y < imageHeight; y++) {
      int rowSum = 0;
      for (int x = 0; x < imageWidth; x++) {
        rowSum += gray[y * imageWidth + x];
        // integral[y, x] = rowSum + integral[y-1, x] (if y > 0)
        integral[y * imageWidth + x] = rowSum + (y > 0 ? integral[(y - 1) * imageWidth + x] : 0);
      }
    }

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