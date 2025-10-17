part of 'package:haarcascade/haarcascade.dart';

// Код вашего класса Haarcascade, немного измененный для работы в изоляте.
// ВАЖНО: Функции, которые будут выполняться в изоляте, должны быть
// либо статическими, либо функциями верхнего уровня.
class _Haarcascade {
  static cv.CascadeClassifier? _classifier;

  static Future<void> init() async {
    final faceDetector = await rootBundle.load(
      'packages/haarcascade/assets/haarcascade_frontalface_default.xml',
    );
    final temp = await getTemporaryDirectory();
    final file = await File(
      '${temp.path}/haarcascade_frontalface_default.xml',
    ).create();
    await file.writeAsBytes(faceDetector.buffer.asUint8List());
    _classifier = cv.CascadeClassifier.fromFile(file.path);
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

/// Класс-обертка для управления изолятом Haarcascade
class HaarcascadeIsolate {
  late final Isolate _isolate;
  late final SendPort _sendPort;
  final ReceivePort _receivePort = ReceivePort();

  // Приватный конструктор
  HaarcascadeIsolate._();

  /// Инициализирует и запускает изолят
  static Future<HaarcascadeIsolate> create() async {
    final instance = HaarcascadeIsolate._();
    final completer = Completer<void>();

    instance._isolate = await Isolate.spawn(
      _isolateEntryPoint,
      instance._receivePort.sendPort,
    );

    instance._receivePort.listen((message) {
      if (message is SendPort) {
        instance._sendPort = message;
        completer.complete();
      }
      // Здесь можно обрабатывать другие сообщения от изолята, если потребуется
    });

    await completer.future;
    return instance;
  }

  /// Отправляет данные изображения в изолят для детекции лиц
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
      if (message is List<FaceDetection>) {
        completer.complete(message);
      } else {
        completer.completeError(Exception("Failed to detect faces"));
      }
      responsePort.close();
    });

    return completer.future;
  }

  /// Останавливает изолят
  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }
}

/// Точка входа для нового изолята
Future<void> _isolateEntryPoint(SendPort mainSendPort) async {
  final isolateReceivePort = ReceivePort();
  mainSendPort.send(isolateReceivePort.sendPort);

  // Инициализируем Haarcascade один раз при старте изолята
  await _Haarcascade.init();
  mainSendPort.send('initialized');

  await for (final message in isolateReceivePort) {
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
  }
}
