import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'weak_classifier.dart';

class Stage {
  double threshold;
  List<WeakClassifier> weakClassifiers;

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
}

extension Stages on List<Stage> {
  static Future<List<Stage>> load() async {
    final json = await rootBundle.loadString('packages/haarcascade/assets/stages.json');
    final stages = jsonDecode(json);
    return List<Stage>.from(stages.map((x) => Stage.fromMap(x)));
  }
}