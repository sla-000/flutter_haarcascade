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
}