/// A class representing the detection of a face in an image.
///
/// The [FaceDetection] class contains the coordinates and dimensions of a
/// detected face within an image.
///
/// Properties:
/// - [x]: The x-coordinate of the top-left corner of the detected face.
/// - [y]: The y-coordinate of the top-left corner of the detected face.
/// - [width]: The width of the detected face.
/// - [height]: The height of the detected face.
class FaceDetection {
  /// The x-coordinate of the detected face.
  /// 
  /// This value represents the horizontal position of the face in the image,
  /// measured in pixels from the left edge of the image.
  final int x;

  /// The y-coordinate of the detected face.
  /// 
  /// This value represents the vertical position of the face in the image,
  /// measured in pixels from the top edge of the image.
  final int y;

  /// The width of the detected face.
  /// 
  /// This value represents the horizontal size of the face in the image,
  /// measured in pixels.
  final int width;

  /// The height of the detected face.
  /// 
  /// This value represents the vertical size of the face in the image,
  /// measured in pixels.
  final int height;

  /// Creates a new [FaceDetection] object with the provided coordinates and dimensions.
  FaceDetection(this.x, this.y, this.width, this.height);
}