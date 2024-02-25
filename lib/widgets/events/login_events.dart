sealed class LoginEventType {}

final class LoginRequest extends LoginEventType {
  LoginRequest();
}

final class LogoutRequest extends LoginEventType {
  LogoutRequest();
}