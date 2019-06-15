import 'package:igflexin/core/resource.dart';
import 'package:meta/meta.dart';

class AuthError {}

enum AuthInfoState { None, Pending, Success, Error }

class AuthInfoResource extends Resource<AuthInfoState, AuthError> {
  AuthInfoResource({@required AuthInfoState state, AuthError data})
      : super(state: state, data: data);
}
