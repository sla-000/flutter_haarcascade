import 'package:equatable/equatable.dart';

class FaceDetails extends Equatable {
  const FaceDetails({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  @override
  List<Object?> get props => [x, y, width, height];
}
