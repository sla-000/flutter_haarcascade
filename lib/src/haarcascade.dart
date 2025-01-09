import 'dart:io';

import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv_dart.dart';
import 'package:path_provider/path_provider.dart';

import 'face_detection.dart';

class Haarcascade {
  final CascadeClassifier _classifier;

  Haarcascade(this._classifier);

  static Future<Haarcascade> load() async {
    // Load XML from assets
    final faceDetector = await rootBundle.load('packages/haarcascade/assets/haarcascade_frontalface_default.xml');
    final temp = await getTemporaryDirectory();
  
    // Save XML to temporary directory
    final file = await File('${temp.path}/haarcascade_frontalface_default.xml').create();
    await file.writeAsBytes(faceDetector.buffer.asUint8List());

    // Load XML from temporary directory
    final classifier = CascadeClassifier.fromFile(file.path);

    // Return Haarcascade object
    return Haarcascade(classifier);
  }

  /// Runs a basic Viola-Jones detection using the loaded stages.
  /// [image] is the input image file.
  List<FaceDetection> detect(
    File image, {
    bool grayscale = false,
    double scaleFactor = 1.1,
    int minNeighbors = 3,
    (int, int) minSize = (0, 0),
    (int, int) maxSize = (0, 0),
  }) {
    final img = imread(image.path, flags: grayscale ? IMREAD_GRAYSCALE : IMREAD_COLOR);

    // Detect faces
    final faces = _classifier.detectMultiScale(img,
      scaleFactor: scaleFactor,
      minNeighbors: minNeighbors,
      minSize: minSize,
      maxSize: maxSize,
    );

    List<FaceDetection> detections = [];
    for (final face in faces) {
      detections.add(FaceDetection(face.x, face.y, face.width, face.height));
    }

    return detections;
  }
}