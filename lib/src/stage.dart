import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'weak_classifier.dart';

class Stage {
  final double threshold;
  final List<WeakClassifier> weakClassifiers;

  Stage({
    required this.threshold,
    required this.weakClassifiers,
  });

  factory Stage.fromMap(Map<String, dynamic> map) => Stage(
    threshold: map["threshold"]?.toDouble(),
    weakClassifiers: List<WeakClassifier>.from(map["weak_classifiers"].map((x) => WeakClassifier.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "threshold": threshold,
    "weak_classifiers": List<dynamic>.from(weakClassifiers.map((x) => x.toMap())),
  };

  /// Evaluates one Stage for the given window position (x,y) & scale.
  /// Returns true if the sum of all weak classifiers >= stage.threshold.
  bool evaluate(
    List<int> integral,
    int imgWidth,
    int imgHeight,
    int x,
    int y,
    double scale,
  ) {
    double stageSum = weakClassifiers.evaluate(
      integral, 
      imgWidth, 
      imgHeight, 
      x, 
      y, 
      scale
    );

    return (stageSum >= threshold);
  }
}

extension Stages on List<Stage> {
  static Future<List<Stage>> load() async {
    final json = await rootBundle.loadString('packages/haarcascade/assets/stages.json');
    final stages = jsonDecode(json);
    return List<Stage>.from(stages.map((x) => Stage.fromMap(x)));
  }
}