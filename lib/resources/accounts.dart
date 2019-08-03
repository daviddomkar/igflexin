import 'package:igflexin/model/resource.dart';
import 'package:meta/meta.dart';

class InstagramAccount {
  InstagramAccount({
    this.username,
    this.paused,
    this.status,
    this.profilePictureURL,
  });

  final String username;
  final bool paused;
  final String status;
  final String profilePictureURL;
}

enum InstagramAccountState {
  None,
  Running,
  Paused,
  CheckpointRequired,
  TwoFactorAuthRequired,
  InvalidUser,
  BadPassword,
}

enum AccountsState { None, Some }

class AccountsResource extends Resource<AccountsState, List<InstagramAccount>> {
  AccountsResource({@required AccountsState state, List<InstagramAccount> data})
      : super(state: state, data: data);
}
