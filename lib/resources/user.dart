import 'package:igflexin/models/resource.dart';
import 'package:meta/meta.dart';

class User {
  User({this.eligibleForFreeTrial, this.userCompleted});

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
