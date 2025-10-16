part of 'package:haarcascade/haarcascade.dart';

/// A class that provides functionality for loading and using Haar Cascade classifiers
/// for face detection.
///
/// The `Haarcascade` class allows you to use Haar Cascade classifiers to detect faces
///
/// Example usage:
/// ```dart
/// // Load the Haarcascade
/// final haarcascade = await Haarcascade.load();
///
/// // Detect faces in an image
/// final faces = haarcascade.detect(imageFile);
/// ```
///
/// Methods:
/// - `load()`: Loads the Haarcascade XML file from the assets and returns a `Future<Haarcascade>` object.
/// - `detect()`: Detects faces in the given image file and returns a list of `FaceDetection` objects.
class Haarcascade {
  static cv.CascadeClassifier? _classifier;

  /// Loads the Haarcascade XML file from the assets, saves it to a temporary
  /// directory, and then loads it into a CascadeClassifier.
  ///
  /// This method performs the following steps:
  /// 1. Loads the Haarcascade XML file from the assets.
  /// 2. Saves the XML file to a temporary directory.
  /// 3. Loads the XML file from the temporary directory into a CascadeClassifier.
  ///
  /// Throws an [Exception] if there is an error during the loading or saving process.
  static Future<void> init() async {
    // Load XML from assets
    final faceDetector = await rootBundle.load(
      'packages/haarcascade/assets/haarcascade_frontalface_default.xml',
    );
    final temp = await getTemporaryDirectory();

    // Save XML to temporary directory
    final file = await File(
      '${temp.path}/haarcascade_frontalface_default.xml',
    ).create();
    await file.writeAsBytes(faceDetector.buffer.asUint8List());

    // Load XML from temporary directory
    _classifier = cv.CascadeClassifier.fromFile(file.path);
  }

  /// Detects faces in the given image file.
  ///
  /// This method uses the Haar Cascade classifier to detect faces in the provided image.
  ///
  /// [image] is the image file in which faces need to be detected.
  ///
  /// Optional parameters:
  /// - [grayscale] (default: false): If using a grayscale image, set this to true.
  /// - [scaleFactor] (default: 1.1): Specifies how much the image size is reduced at each image scale.
  /// - [minNeighbors] (default: 3): Specifies how many neighbors each candidate rectangle should have to retain it.
  /// - [minSize] (default: (0, 0)): Minimum possible object size. Objects smaller than that are ignored.
  /// - [maxSize] (default: (0, 0)): Maximum possible object size. Objects larger than that are ignored.
  ///
  /// Returns a list of [FaceDetection] objects, each representing a detected face with its position and size.
  static List<FaceDetection> detect(
    cv.Mat data, {
    required int rows,
    required int cols,
    bool grayscale = false,
    double scaleFactor = 1.1,
    int minNeighbors = 3,
    (int, int) minSize = (0, 0),
    (int, int) maxSize = (0, 0),
  }) {
    // Check if the classifier is loaded
    assert(
      _classifier != null,
      'Haarcascade classifier is not loaded. Call Haarcascade.init() first.',
    );

    // Detect faces
    final faces = _classifier!.detectMultiScale(
      data,
      scaleFactor: scaleFactor,
      minNeighbors: minNeighbors,
      minSize: minSize,
      maxSize: maxSize,
    );

    List<FaceDetection> detections = [];
    for (final face in faces) {
      detections.add(FaceDetection._(face.x, face.y, face.width, face.height));
    }

    return detections;
  }
}
