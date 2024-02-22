import 'package:ciy_client/auth_lib/desktop_authorization_code.dart';
import 'package:ciy_client/auth_lib/desktop_oauth2.dart';
import 'package:ciy_client/widgets/events/login_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum LoginEnum { notLoggingIn, loggedIn, inProgress }

final class LoginState extends Equatable {
  final LoginEnum? loggedIn;
  final String? accessToken;
  final DateTime? expiresIn;

  LoginState({this.loggedIn, this.accessToken, this.expiresIn});

  @override
  List<Object?> get props => [loggedIn, accessToken];
}

class LoginBloc extends Bloc<LoginEventType, LoginState> {
  final _storage = const FlutterSecureStorage();

  LoginBloc() : super(LoginState(loggedIn: LoginEnum.notLoggingIn)) {
    DesktopOAuth2 desktopOAuth2 = DesktopOAuth2();
    DesktopAuthorizationCodeFlow desktopAuthCodeFlow =
        DesktopAuthorizationCodeFlow();
    desktopAuthCodeFlow.authState = 'xcoivjuywkdkhvusuye3kch';
    desktopAuthCodeFlow.authorizationUrl =
        'https://dev-k1hhibazdyt8o3em.us.auth0.com/authorize';
    desktopAuthCodeFlow.clientId = 'pZVAw5C39J89hYyU9E8KxifqIBc1e5xm';
    desktopAuthCodeFlow.localPort = 9298;
    desktopAuthCodeFlow.pkce = true;
    desktopAuthCodeFlow.redirectUri = 'http://localhost:9298/code';
    desktopAuthCodeFlow.scopes = ['openid'];
    desktopAuthCodeFlow.tokenUrl =
        'https://dev-k1hhibazdyt8o3em.us.auth0.com/oauth/token';

    Future.delayed(Duration(seconds: 0)).then((value) async {
      String? loggedInString = await _storage.read(key: "loggedIn");
      String? token = await _storage.read(key: "token");
      String? tokenExpiration = await _storage.read(key: "tokenExpiration");
      if (loggedInString != null && loggedInString == "true") {
        DateTime dateTime = DateTime.parse(tokenExpiration!).toUtc();
        if (DateTime.now().toUtc().isBefore(dateTime)) {
          emit(LoginState(
              accessToken: token,
              loggedIn: LoginEnum.loggedIn,
              expiresIn: dateTime));
        }
      }
    });

    on<LoginRequest>(((event, emit) async {
      emit(LoginState(accessToken: '', loggedIn: LoginEnum.inProgress));

      await desktopOAuth2
          .oauthorizeCode(desktopAuthCodeFlow)
          .then((token) async {
        if (token != null && token.isNotEmpty) {
          var tokenExpiration = DateTime.now()
              .toUtc()
              .add(Duration(seconds: token["expires_in"]));

          var newState = LoginState(
              accessToken: token['access_token'],
              loggedIn: LoginEnum.loggedIn,
              expiresIn: tokenExpiration);

          await _storage.write(key: "loggedIn", value: "true");
          await _storage.write(key: "token", value: token['access_token']);
          await _storage.write(
              key: "tokenExpiration", value: tokenExpiration.toString());

          emit(newState);
        } else {
          emit(LoginState(accessToken: '', loggedIn: LoginEnum.notLoggingIn));
        }
      });
    }));
    on<LogoutRequest>(((event, emit) async {
      var newState =
          LoginState(accessToken: '', loggedIn: LoginEnum.notLoggingIn);
      await _storage.write(key: "loggedIn", value: "false");
      await _storage.write(key: "token", value: '');
      await _storage.write(key: "tokenExpiration", value: '');

      emit(newState);
    }));
  }
}
