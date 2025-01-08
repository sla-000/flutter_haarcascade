import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:haarcascade/haarcascade.dart';
import 'package:image/image.dart' as img;

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
  Uint8List? _grayscaleImageBytes;

  @override
  void initState() {
    super.initState();
    _runFaceDetection();
  }

  Future<void> _runFaceDetection() async {
    try {
      // 1) Load the Haar Cascade data (Stages.load() -> Haarcascade)
      final cascade = await Haarcascade.load();

      // 2) Load the image bytes from assets
      final ByteData data = await rootBundle.load('assets/example.jpg');
      final Uint8List imageBytes = data.buffer.asUint8List();

      // 3) Decode the image using the 'image' package
      final img.Image? decodedImg = img.decodeImage(imageBytes);

      if (decodedImg == null) {
        throw Exception('Could not decode image');
      }

      // 4) Convert to grayscale
      final img.Image grayscaleImg = img.grayscale(decodedImg);

      // 5) Re-encode the grayscale image to display in a Flutter Image widget
      final Uint8List grayscaleBytes = Uint8List.fromList(
        img.encodeJpg(grayscaleImg),
      );

      // 6) Run the Haarcascade detection (on the original imageBytes or grayscaleBytes)
      //    Here we do it on the original for simplicity:
      final detections = cascade.detect(image: imageBytes);

      // Update state: store detections and the grayscale image
      setState(() {
        _detections = detections;
        _grayscaleImageBytes = grayscaleBytes;
      });

      // Print results for debugging
      for (final detection in detections) {
        print('Detected face at x=${detection.x}, '
            'y=${detection.y}, '
            'w=${detection.width}, '
            'h=${detection.height}.');
      }
    } catch (e, stack) {
      print('Error running face detection: $e');
      print(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display the grayscale image and the face detection results
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection Example (Grayscale)')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_grayscaleImageBytes != null)
                Image.memory(
                  _grayscaleImageBytes!,
                  fit: BoxFit.contain,
                )
              else
                const Text('Loading grayscale image...'),

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
