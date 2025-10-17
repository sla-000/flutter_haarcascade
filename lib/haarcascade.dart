library haarcascade;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:path_provider/path_provider.dart';

part 'src/face_detection.dart';
part 'src/haarcascade.dart';
part 'src/haarcascade_isolate.dart';
