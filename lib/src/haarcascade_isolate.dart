part of 'package:haarcascade/haarcascade.dart';

class _Haarcascade {
  static cv.CascadeClassifier? _classifier;

  static void init(String filePath) {
    _classifier = cv.CascadeClassifier.fromFile(filePath);
  }

  static List<FaceDetection> detect({
    required List<int> data,
    required int rows,
    required int cols,
    double scaleFactor = 1.1,
    int minNeighbors = 3,
    (int, int) minSize = (0, 0),
    (int, int) maxSize = (0, 0),
  }) {
    assert(
      _classifier != null,
      'Haarcascade classifier is not loaded. Call Haarcascade.init() first.',
    );

    final mat = cv.Mat.fromList(rows, cols, cv.MatType.CV_8UC1, data);

    final faces = _classifier!.detectMultiScale(
      mat,
      scaleFactor: scaleFactor,
      minNeighbors: minNeighbors,
      minSize: minSize,
      maxSize: maxSize,
    );

    List<FaceDetection> detections = [];
    for (final face in faces) {
      detections.add(FaceDetection._(face.x, face.y, face.width, face.height));
    }
    return detections;
  }
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

  Future<List<FaceDetection>> detect(
    List<int> data, {
    required int rows,
    required int cols,
    double scaleFactor = 1.1,
    int minNeighbors = 3,
    (int, int) minSize = (0, 0),
    (int, int) maxSize = (0, 0),
  }) {
    final completer = Completer<List<FaceDetection>>();
    final responsePort = ReceivePort();

    _sendPort.send({
      'command': 'detect',
      'port': responsePort.sendPort,
      'data': {
        'image_data': data,
        'rows': rows,
        'cols': cols,
        'scale_factor': scaleFactor,
        'min_neighbors': minNeighbors,
        'min_size': minSize,
        'max_size': maxSize,
      },
    });

    responsePort.listen((message) {
      if (message is List) {
        final detections = message.cast<FaceDetection>().toList();
        completer.complete(detections);
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
        scaleFactor: params['scale_factor'],
        minNeighbors: params['min_neighbors'],
        minSize: params['min_size'],
        maxSize: params['max_size'],
      );

      responsePort.send(result);
    }
  });
}
