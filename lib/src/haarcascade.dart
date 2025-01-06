import 'dart:io';

import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

void loadHaarCascade() async {
  final classifier = cv.CascadeClassifier.empty();

  // Load `haarcascade_frontalface_default.xml` from the asset bundle
  final bytes = rootBundle.load('packages/drumline/assets/haarcascade_frontalface_default.xml');

  final temp = await getTemporaryDirectory();

  // Write the bytes to a temporary file
  final file = File('${temp.path}/haarcascade_frontalface_default.xml');
  await file.writeAsBytes((await bytes).buffer.asUint8List());

  // Load the classifier from the file
  classifier.load(file.path);

  // Use the classifier
  final image = cv.imread('path/to/image.jpg');
}