import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:haarcascade/haarcascade.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection (Grayscale)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FaceDetectionPage(),
    );
  }
}

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  List<FaceDetection>? _detections;
  Uint8List? _imageBytes;
  int? _imageWidth;
  int? _imageHeight;

  Future<void> _runFaceDetection() async {
    // 1) Load the Haar Cascade data
    final cascade = await Haarcascade.load();

    // 2) Load the image bytes from assets
    final ByteData data = await rootBundle.load('assets/example.jpg');
    _imageBytes = data.buffer.asUint8List();

    // 3) Decode the image so we get the width and height
    final decoded = await decodeImageFromList(_imageBytes!);
    _imageWidth = decoded.width;
    _imageHeight = decoded.height;

    // 4) Save the image bytes to a temporary file
    final temp = await getTemporaryDirectory();
    final file = await File('${temp.path}/example.jpg').create();
    await file.writeAsBytes(_imageBytes!);

    // 5) Run face detection on the image file
    _detections = cascade.detect(file);

    // 6) Update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Display the image and the face detection results
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection Example (Grayscale)')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageBytes == null)
                const Text('Loading image...')
              else
                // We use a FittedBox + SizedBox + Stack so the drawn boxes
                // line up with the displayed image.
                FittedBox(
                  child: SizedBox(
                    width: _imageWidth?.toDouble() ?? 100,
                    height: _imageHeight?.toDouble() ?? 100,
                    child: Stack(
                      children: [
                        // Our base image
                        Image.memory(
                          _imageBytes!,
                          fit: BoxFit.fill,
                        ),

                        // Draw bounding boxes on top of the image
                        if (_detections != null && _detections!.isNotEmpty)
                          CustomPaint(
                            painter: FacePainter(_detections!),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (_detections == null)
                const Text('Detecting faces...')
              else if (_detections!.isEmpty)
                const Text('No faces detected.')
              else
                Text('Detected ${_detections!.length} face(s).'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runFaceDetection,
        tooltip: 'Run Face Detection',
        child: const Icon(Icons.search),
      ),
    );
  }
}

/// A simple [CustomPainter] to draw bounding boxes for face detections.
class FacePainter extends CustomPainter {
  final List<FaceDetection> detections;

  FacePainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    // Define the paint for our rectangle
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw each detection as a rectangle
    for (final detection in detections) {
      canvas.drawRect(
        Rect.fromLTWH(
          detection.x.toDouble(),
          detection.y.toDouble(),
          detection.width.toDouble(),
          detection.height.toDouble(),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    // Repaint if the list of detections changes
    return oldDelegate.detections != detections;
  }
}
