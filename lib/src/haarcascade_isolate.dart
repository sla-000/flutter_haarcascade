part of 'package:haarcascade/haarcascade.dart';

class _Haarcascade {
  static cv.CascadeClassifier? _classifier;

  static void init(String filePath) {
    _classifier = cv.CascadeClassifier.fromFile(filePath);
  }

  static Map<String, dynamic> detect({
    required Uint8List data,
    required int rows,
    required int cols,
    required int sensorOrientation,
    required bool isFrontLens,
    required double screenWidth,
    required double screenHeight,
    double scaleFactor = 1.1,
    int minNeighbors = 3,
    (int, int) minSize = (0, 0),
    (int, int) maxSize = (0, 0),
  }) {
    assert(
      _classifier != null,
      'Haarcascade classifier is not loaded. Call Haarcascade.init() first.',
    );

    var cvImage = cv.Mat.fromList(rows, cols, cv.MatType.CV_8UC1, data);

    if (cvImage.isEmpty) {
      throw const FormatException("Can't convert image to OpenCV Mat");
    }

    cvImage = switch (sensorOrientation) {
      0 => cvImage,
      90 => cvImage.rotate(cv.ROTATE_90_COUNTERCLOCKWISE), // back
      180 => cvImage.rotate(cv.ROTATE_180),
      270 => cvImage.rotate(cv.ROTATE_90_CLOCKWISE), // front
      _ => throw Exception(
        'Unsupported rotation degrees: '
        '$sensorOrientation',
      ),
    };

    late int imageWidth;
    late int imageHeight;

    imageWidth = switch (sensorOrientation) {
      0 => cols,
      90 => rows,
      180 => cols,
      270 => rows,
      _ => throw Exception(
        'Unsupported rotation degrees: '
        '$sensorOrientation',
      ),
    };

    imageHeight = switch (sensorOrientation) {
      0 => rows,
      90 => cols,
      180 => rows,
      270 => cols,
      _ => throw Exception(
        'Unsupported rotation degrees: '
        '$sensorOrientation',
      ),
    };

    cvImage = isFrontLens ? cv.flip(cvImage, 0) : cv.flip(cvImage, -1);

    final faces = _classifier!.detectMultiScale(
      cvImage,
      scaleFactor: scaleFactor,
      minNeighbors: minNeighbors,
      minSize: minSize,
      maxSize: maxSize,
    );

    final faceDetails = faces
        .map(
          (face) => FaceDetails(
            x: _normalize(
              face.x.toDouble(),
              imageWidth.toDouble(),
              screenWidth,
            ),
            y: _normalize(
              face.y.toDouble(),
              imageHeight.toDouble(),
              screenHeight,
            ),
            width: _normalize(
              face.width.toDouble(),
              imageWidth.toDouble(),
              screenWidth,
            ),
            height: _normalize(
              face.height.toDouble(),
              imageHeight.toDouble(),
              screenHeight,
            ),
          ),
        )
        .toList();

    //cv2.imencode(".jpg", img, [cv2.IMWRITE_JPEG_QUALITY, 90])
    final (isOk, previewImage) = cv.imencode('.jpg', cvImage);
    if (!isOk) {
      throw const FormatException("Can't encode preview image to JPG format");
    }

    return {'faceDetails': faceDetails, 'previewImage': previewImage.toList()};
  }
}

double _normalize(double val, double oldMax, double newMax) {
  return val / oldMax * newMax;
}

class HaarcascadeIsolate {
  late final Isolate _isolate;
  late final SendPort _sendPort;
  final ReceivePort _receivePort = ReceivePort();

  HaarcascadeIsolate._();

  /// Инициализирует и запускает изолят
  static Future<HaarcascadeIsolate> create() async {
    final faceDetector = await rootBundle.load(
      'packages/haarcascade/assets/haarcascade_frontalface_default.xml',
    );
    final temp = await getTemporaryDirectory();
    final xmlPath = '${temp.path}/haarcascade_frontalface_default.xml';
    await File(xmlPath).writeAsBytes(faceDetector.buffer.asUint8List());

    final instance = HaarcascadeIsolate._();
    final completer = Completer<void>();

    final initialMessage = {
      'port': instance._receivePort.sendPort,
      'path': xmlPath,
    };

    instance._isolate = await Isolate.spawn(_isolateEntryPoint, initialMessage);

    instance._receivePort.listen((message) {
      if (message is SendPort) {
        instance._sendPort = message;
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
      // Здесь можно обрабатывать другие сообщения от изолята, если потребуется
    });

    await completer.future;
    return instance;
  }

  Future<(List<FaceDetails> detectedFaces, Uint8List previewImage)> detect(
    Uint8List data, {
    required int rows,
    required int cols,
    required int sensorOrientation,
    required bool isFrontLens,
    required double screenWidth,
    required double screenHeight,
    double scaleFactor = 1.1,
    int minNeighbors = 3,
    (int, int) minSize = (0, 0),
    (int, int) maxSize = (0, 0),
  }) {
    final completer =
        Completer<(List<FaceDetails> detectedFaces, Uint8List previewImage)>();
    final responsePort = ReceivePort();

    _sendPort.send({
      'command': 'detect',
      'port': responsePort.sendPort,
      'data': {
        'image_data': data,
        'rows': rows,
        'cols': cols,
        'sensorOrientation': sensorOrientation,
        'isFrontLens': isFrontLens,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'scale_factor': scaleFactor,
        'min_neighbors': minNeighbors,
        'min_size': minSize,
        'max_size': maxSize,
      },
    });

    responsePort.listen((message) {
      if (message is Map) {
        final faces = message['faceDetails'] as List<FaceDetails>;
        final previewImage = message['previewImage'] as List<int>;
        final result = (faces, Uint8List.fromList(previewImage));
        completer.complete(result);
      } else {
        completer.completeError(
          Exception("Failed to detect faces or invalid message type"),
        );
      }
      responsePort.close();
    });

    return completer.future;
  }

  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }
}

void _isolateEntryPoint(Map<String, dynamic> initialMessage) {
  final mainSendPort = initialMessage['port'] as SendPort;
  final xmlPath = initialMessage['path'] as String;

  final isolateReceivePort = ReceivePort();
  mainSendPort.send(isolateReceivePort.sendPort);

  _Haarcascade.init(xmlPath);

  isolateReceivePort.listen((message) {
    if (message is Map<String, dynamic> && message['command'] == 'detect') {
      final SendPort responsePort = message['port'];
      final params = message['data'];

      final result = _Haarcascade.detect(
        data: params['image_data'],
        rows: params['rows'],
        cols: params['cols'],
        sensorOrientation: params['sensorOrientation'],
        isFrontLens: params['isFrontLens'],
        screenWidth: params['screenWidth'],
        screenHeight: params['screenHeight'],
        scaleFactor: params['scale_factor'],
        minNeighbors: params['min_neighbors'],
        minSize: params['min_size'],
        maxSize: params['max_size'],
      );

      responsePort.send(result);
    }
  });
}
