import 'package:meta/meta.dart';

class Resource<S, D> {
  Resource({@required this.state, this.data});

  final S state;
  final D data;
}
