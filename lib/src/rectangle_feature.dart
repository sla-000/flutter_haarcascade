class RectangleFeature {
  int x;
  int y;
  int width;
  int height;
  double weight;

  RectangleFeature({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.weight,
  });

  factory RectangleFeature.fromMap(Map<String, dynamic> map) => RectangleFeature(
    x: map["x"],
    y: map["y"],
    width: map["width"],
    height: map["height"],
    weight: map["weight"],
  );

  Map<String, dynamic> toMap() => {
    "x": x,
    "y": y,
    "width": width,
    "height": height,
    "weight": weight,
  };
}