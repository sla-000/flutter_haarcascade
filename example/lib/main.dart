import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:haarcascade/haarcascade.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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

      // 3) Decode the image using Flutter's codec to get a ui.Image
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image uiImage = frameInfo.image;

      // 4) Convert the ui.Image to raw RGBA bytes (ui.ImageByteFormat.rawRgba)
      final ByteData? rgbaData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rgbaData == null) {
        print('Failed to get raw RGBA bytes from the image.');
        return;
      }
      final Uint8List rgbaBytes = rgbaData.buffer.asUint8List();

      // 5) Run the Haarcascade detection
      final detections = cascade.detect(
        image: rgbaBytes,
        imageWidth: uiImage.width,
        imageHeight: uiImage.height,
        minScale: 1.0,
        maxScale: 3.0,
        scaleStep: 1.2,
        stepSize: 2,
      );

      // 6) Store the detections in state to display or debug
      setState(() {
        _detections = detections;
      });

      // Print results
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
    // Optionally display your detections in the UI
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection Example')),
      body: Center(
        child: _detections == null
            ? const Text('Detecting faces...')
            : (_detections!.isEmpty
                ? const Text('No faces detected.')
                : Text('Detected ${_detections!.length} face(s).')),
      ),
    );
  }
}
