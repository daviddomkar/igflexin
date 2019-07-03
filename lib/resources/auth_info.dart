import 'package:igflexin/models/resource.dart';
import 'package:meta/meta.dart';

enum AuthError {
  Unknown, // ERROR_UNKNOWN
  ServiceNotAvailable, // ERROR_API_NOT_AVAILABLE
  Internal, // ERROR_CUSTOM_TOKEN_MISMATCH
  AccountDisabled, // ERROR_USER_DISABLED
  OperationNotAllowed, // ERROR_OPERATION_NOT_ALLOWED
  EmailAlreadyInUse, // ERROR_EMAIL_ALREADY_IN_USE
  InvalidEmail, // ERROR_INVALID_EMAIL
  WrongPassword, // ERROR_WRONG_PASSWORD
  TooManyRequests, // ERROR_TOO_MANY_REQUESTS
  UserNotFound, // ERROR_USER_NOT_FOUND
  AccountExistsWithDifferentCredential, // ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL
  NetworkError, // ERROR_NETWORK_REQUEST_FAILED
}

enum AuthInfoState {
  None,
  Pending,
  Success,
  Error,
}

class AuthInfoResource extends Resource<AuthInfoState, AuthError> {
  AuthInfoResource({@required AuthInfoState state, AuthError data})
      : super(state: state, data: data);
}
