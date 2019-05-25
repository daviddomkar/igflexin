import 'package:igflexin/core/resource.dart';
import 'package:meta/meta.dart';

class User {}

enum UserState {
  None,
  Unauthenticated,
  Authenticated,
}

class UserResource extends Resource<UserState, User> {
  UserResource({@required UserState state, User data})
      : super(state: state, data: data);
}
