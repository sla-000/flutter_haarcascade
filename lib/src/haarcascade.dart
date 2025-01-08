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
  
  /// Computes the integral image (summed-area table) of a grayscale [src] image.
  /// Returns a List<int> in row-major order, where each element is the integral
  /// at that pixel (x, y).
  List<int> _computeIntegralImage(img.Image src) {
    final int width = src.width;
    final int height = src.height;

    // This will hold the integral values. We use `int` here;
    // if your images are large or intensities can be very big,
    // consider using a larger numeric type or BigInt.
    final List<int> integral = List<int>.filled(width * height, 0);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Get the pixel value.
        // If your image is strictly grayscale, the red, green, and blue channels
        // will be the same; here we just use getRed as the intensity.
        final img.Pixel pixel = src.getPixel(x, y);
        final int intensity = pixel.r.toInt();

        // Get left, top, and top-left values safely (0 if out of bounds).
        final int left   = (x > 0) ? integral[(y * width) + (x - 1)] : 0;
        final int top    = (y > 0) ? integral[((y - 1) * width) + x] : 0;
        final int topLeft= (x > 0 && y > 0) ? integral[((y - 1) * width) + (x - 1)] : 0;

        // Apply the summed-area table formula:
        integral[y * width + x] = intensity + left + top - topLeft;
      }
    }

    return integral;
  }

  /// Runs a basic Viola-Jones detection using the loaded stages.
  /// [image] is the input image as a byte array.
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