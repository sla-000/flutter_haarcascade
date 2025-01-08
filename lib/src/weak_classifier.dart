import 'rectangle_feature.dart';

class WeakClassifier {
  List<RectangleFeature> features;
  double threshold;
  double leafX;
  double leafY;

  WeakClassifier({
    required this.features,
    required this.threshold,
    required this.leafX,
    required this.leafY,
  });

  factory WeakClassifier.fromMap(Map<String, dynamic> map) => WeakClassifier(
    features: List<RectangleFeature>.from(map["features"].map((x) => RectangleFeature.fromMap(x))),
    threshold: map["threshold"]?.toDouble(),
    leafX: map["leaf_x"]?.toDouble(),
    leafY: map["leaf_y"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "features": List<dynamic>.from(features.map((x) => x.toMap())),
    "threshold": threshold,
    "leaf_x": leafX,
    "leaf_y": leafY,
  };

  /// Computes the sum of the rectangle features for one WeakClassifier,
  /// then compares against `wc.threshold` to pick `wc.leafX` or `wc.leafY`.
  double evaluate(
    List<int> integral,
    int imgWidth,
    int imgHeight,
    int originX,
    int originY,
    double scale,
  ) {
    double featureSum = 0.0;

    // Sum up all rectangle features
    for (final rectFeature in features) {
      featureSum += rectFeature.sum(
        integral, 
        imgWidth, 
        imgHeight, 
        originX, 
        originY, 
        scale
      );
    }

    // Compare featureSum to threshold
    if (featureSum < threshold) {
      return leafX; // e.g. negative or positive vote
    } else {
      return leafY;
    }
  }
}