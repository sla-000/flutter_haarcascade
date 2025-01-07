import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Haarcascade {
  String stageType;
  String featureType;
  int height;
  int width;
  StageParams stageParams;
  FeatureParams featureParams;
  int stageNum;
  List<Stage> stages;
  List<Feature> features;
  String typeId;

  Haarcascade({
    required this.stageType,
    required this.featureType,
    required this.height,
    required this.width,
    required this.stageParams,
    required this.featureParams,
    required this.stageNum,
    required this.stages,
    required this.features,
    required this.typeId,
  });

  factory Haarcascade.fromJson(Map<String, dynamic> json) => Haarcascade(
    stageType: json["stageType"],
    featureType: json["featureType"],
    height: json["height"],
    width: json["width"],
    stageParams: StageParams.fromJson(json["stageParams"]),
    featureParams: FeatureParams.fromJson(json["featureParams"]),
    stageNum: json["stageNum"],
    stages: List<Stage>.from(json["stages"].map((x) => Stage.fromJson(x))),
    features: List<Feature>.from(json["features"].map((x) => Feature.fromJson(x))),
    typeId: json["type_id"],
  );

  Map<String, dynamic> toJson() => {
    "stageType": stageType,
    "featureType": featureType,
    "height": height,
    "width": width,
    "stageParams": stageParams.toJson(),
    "featureParams": featureParams.toJson(),
    "stageNum": stageNum,
    "stages": List<dynamic>.from(stages.map((x) => x.toJson())),
    "features": List<dynamic>.from(features.map((x) => x.toJson())),
    "type_id": typeId,
  };

  static Future<Haarcascade> load() async {
    final json = await rootBundle.loadString('assets/haarcascade_frontalface_default.json');
    return Haarcascade.fromJson(jsonDecode(json));
  }
}

class FeatureParams {
  int maxCatCount;

  FeatureParams({
    required this.maxCatCount,
  });

  factory FeatureParams.fromJson(Map<String, dynamic> json) => FeatureParams(
    maxCatCount: json["maxCatCount"],
  );

  Map<String, dynamic> toJson() => {
    "maxCatCount": maxCatCount,
  };
}

class Feature {
  List<List<int>> rects;

  Feature({
    required this.rects,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    rects: List<List<int>>.from(json["rects"].map((x) => List<int>.from(x.map((x) => x)))),
  );

  Map<String, dynamic> toJson() => {
    "rects": List<dynamic>.from(rects.map((x) => List<dynamic>.from(x.map((x) => x)))),
  };
}

class StageParams {
  int maxWeakCount;

  StageParams({
    required this.maxWeakCount,
  });

  factory StageParams.fromJson(Map<String, dynamic> json) => StageParams(
    maxWeakCount: json["maxWeakCount"],
  );

  Map<String, dynamic> toJson() => {
    "maxWeakCount": maxWeakCount,
  };
}

class Stage {
  int maxWeakCount;
  double stageThreshold;
  List<WeakClassifier> weakClassifiers;

  Stage({
    required this.maxWeakCount,
    required this.stageThreshold,
    required this.weakClassifiers,
  });

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    maxWeakCount: json["maxWeakCount"],
    stageThreshold: json["stageThreshold"]?.toDouble(),
    weakClassifiers: List<WeakClassifier>.from(json["weakClassifiers"].map((x) => WeakClassifier.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "maxWeakCount": maxWeakCount,
    "stageThreshold": stageThreshold,
    "weakClassifiers": List<dynamic>.from(weakClassifiers.map((x) => x.toJson())),
  };
}

class WeakClassifier {
  List<double> internalNodes;
  List<double> leafValues;

  WeakClassifier({
    required this.internalNodes,
    required this.leafValues,
  });

  factory WeakClassifier.fromJson(Map<String, dynamic> json) => WeakClassifier(
    internalNodes: List<double>.from(json["internalNodes"].map((x) => x?.toDouble())),
    leafValues: List<double>.from(json["leafValues"].map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "internalNodes": List<dynamic>.from(internalNodes.map((x) => x)),
    "leafValues": List<dynamic>.from(leafValues.map((x) => x)),
  };
}
