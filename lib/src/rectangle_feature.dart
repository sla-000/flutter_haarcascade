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

  double sum(
    List<int> integral,
    int imgWidth,
    int imgHeight,
    int originX,
    int originY,
    double scale,
  ) {
    final rx = (originX + x * scale).round();
    final ry = (originY + y * scale).round();
    final rw = (width * scale).round();
    final rh = (height * scale).round();

    // bottom-right corner
    final x2 = (rx + rw - 1).clamp(0, imgWidth - 1);
    final y2 = (ry + rh - 1).clamp(0, imgHeight - 1);
    // top-left corner (subtract 1 for inclusion-exclusion)
    final x1 = (rx - 1).clamp(-1, imgWidth - 1);
    final y1 = (ry - 1).clamp(-1, imgHeight - 1);

    final A = (x1 >= 0 && y1 >= 0) ? integral[y1 * imgWidth + x1] : 0;
    final B = (y1 >= 0) ? integral[y1 * imgWidth + x2] : 0;
    final C = (x1 >= 0) ? integral[y2 * imgWidth + x1] : 0;
    final D = integral[y2 * imgWidth + x2];

    return (D + A - B - C) * weight;
  }
}

extension RectangleFeatures on List<RectangleFeature> {
  double sum(
    List<int> integral,
    int imgWidth,
    int imgHeight,
    int originX,
    int originY,
    double scale,
  ) {
    double sum = 0.0;
    for (final rectFeature in this) {
      sum += rectFeature.sum(
        integral, 
        imgWidth, 
        imgHeight, 
        originX, 
        originY, 
        scale
      );
    }
    return sum;
  }
}