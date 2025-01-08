import 'dart:typed_data';

Uint8List convertToGrayscale(Uint8List rgba, int width, int height) {
  final gray = Uint8List(width * height);
  for (int i = 0; i < width * height; i++) {
    final r = rgba[4 * i];
    final g = rgba[4 * i + 1];
    final b = rgba[4 * i + 2];
    // Simple luminance approximation
    gray[i] = ((0.299 * r) + (0.587 * g) + (0.114 * b)).round();
  }
  return gray;
}

List<int> computeIntegralImage(Uint8List gray, int width, int height) {
  final integral = List<int>.filled(width * height, 0);

  for (int y = 0; y < height; y++) {
    int rowSum = 0;
    for (int x = 0; x < width; x++) {
      rowSum += gray[y * width + x];
      // integral[y, x] = rowSum + integral[y-1, x] (if y > 0)
      integral[y * width + x] = rowSum + (y > 0 ? integral[(y - 1) * width + x] : 0);
    }
  }
  return integral;
}