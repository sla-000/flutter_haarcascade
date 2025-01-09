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
      _imageBytes = data.buffer.asUint8List();

      final temp = await getTemporaryDirectory();
      final file = await File('${temp.path}/example.jpg').create();
      await file.writeAsBytes(_imageBytes!);

      // 6) Run the Haarcascade detection (on the original imageBytes or grayscaleBytes)
      //    Here we do it on the original for simplicity:
      final detections = cascade.detect(file);

      // Update state: store detections and the grayscale image
      setState(() {
        _detections = detections;
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
              if (_imageBytes != null)
                Image.memory(
                  _imageBytes!,
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
