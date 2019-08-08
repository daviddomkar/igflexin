import 'package:igflexin/model/resource.dart';
import 'package:meta/meta.dart';

class InstagramAccount {
  InstagramAccount({
    this.id,
    this.username,
    this.paused,
    this.status,
    this.profilePictureURL,
  });

  final String id;
  final String username;
  final bool paused;
  final String status;
  final String profilePictureURL;
}

enum InstagramAccountState {
  None,
  Running,
  CheckpointRequired,
  TwoFactorAuthRequired,
  InvalidUser,
  BadPassword,
  LimitReached,
  UnknownError,
}

getInstagramAccountStateFromString(String state) {
  switch (state) {
    case 'running':
      return InstagramAccountState.Running;
    case 'checkpoint-required':
      return InstagramAccountState.CheckpointRequired;
    case 'two-factor-required':
      return InstagramAccountState.TwoFactorAuthRequired;
    case 'invalid-user':
      return InstagramAccountState.InvalidUser;
    case 'bad-password':
      return InstagramAccountState.BadPassword;
    case 'limit-reached':
      return InstagramAccountState.LimitReached;
    case 'error':
      return InstagramAccountState.UnknownError;
    default:
      return InstagramAccountState.None;
  }
}

// ignore: missing_return
String getPrettyStringFromAccountState(InstagramAccountState state) {
  switch (state) {
    case InstagramAccountState.None:
      return 'Unknown';
    case InstagramAccountState.Running:
      return 'Running';
    case InstagramAccountState.CheckpointRequired:
      return 'Security code required';
    case InstagramAccountState.TwoFactorAuthRequired:
      return 'Two factor authentication required';
    case InstagramAccountState.InvalidUser:
      return 'Username does not exist';
    case InstagramAccountState.BadPassword:
      return 'Bad password';
    case InstagramAccountState.LimitReached:
      return 'Account limit reached';
    case InstagramAccountState.UnknownError:
      return 'Unknown error';
  }
}

enum AccountsState { None, Some }

class AccountsResource extends Resource<AccountsState, List<InstagramAccount>> {
  AccountsResource({@required AccountsState state, List<InstagramAccount> data})
      : super(state: state, data: data);
}
