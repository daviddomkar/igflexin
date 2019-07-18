import 'package:igflexin/model/resource.dart';
import 'package:meta/meta.dart';

class User {
  User({this.email, this.eligibleForFreeTrial, this.userCompleted});

  final String email;
  final bool eligibleForFreeTrial;
  final bool userCompleted;
}

enum UserState {
  None,
  Unauthenticated,
  Authenticated,
}

class UserResource extends Resource<UserState, User> {
  UserResource({@required UserState state, User data}) : super(state: state, data: data);
}
