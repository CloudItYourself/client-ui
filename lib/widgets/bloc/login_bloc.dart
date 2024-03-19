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
  final clientId = 'pZVAw5C39J89hYyU9E8KxifqIBc1e5xm';
  Future<void>? reAuthorizeLoopFuture;

  LoginBloc() : super(LoginState(loggedIn: LoginEnum.notLoggingIn)) {
    DesktopOAuth2 desktopOAuth2 = DesktopOAuth2();
    DesktopAuthorizationCodeFlow desktopAuthCodeFlow =
        DesktopAuthorizationCodeFlow();
    desktopAuthCodeFlow.authState = 'xcoivjuywkdkhvusuye3kch';
    desktopAuthCodeFlow.authorizationUrl =
        'https://dev-k1hhibazdyt8o3em.us.auth0.com/authorize';
    desktopAuthCodeFlow.clientId = clientId;
    desktopAuthCodeFlow.localPort = 9298;
    desktopAuthCodeFlow.pkce = true;
    desktopAuthCodeFlow.redirectUri = 'http://localhost:9298/code';
    desktopAuthCodeFlow.scopes = ['offline_access'];
    desktopAuthCodeFlow.tokenUrl =
        'https://dev-k1hhibazdyt8o3em.us.auth0.com/oauth/token';

    Future.delayed(Duration(seconds: 0)).then((value) async {
      String? loggedInString = await _storage.read(key: "loggedIn");
      String? token = await _storage.read(key: "token");
      String? tokenExpiration = await _storage.read(key: "tokenExpiration");
      String? refreshToken = await _storage.read(key: "refresh_token");

      if (loggedInString != null && loggedInString == "true") {
        DateTime dateTime = DateTime.parse(tokenExpiration!).toUtc();
        DateTime currentTime =
            DateTime.now().toUtc().subtract(Duration(hours: 2));
        if (currentTime.isBefore(dateTime)) {
          emit(LoginState(
              accessToken: token,
              loggedIn: LoginEnum.loggedIn,
              expiresIn: dateTime));
        } else if (refreshToken != null) {
          await reAuthorize();
        }
      }
      reAuthorizeLoopFuture = reAuthorizeLoop();
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
              key: "refresh_token", value: token['refresh_token']);
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

  Future<bool> reAuthorize() async {
    DesktopOAuth2 desktopOAuth2 = DesktopOAuth2();
    String? refreshToken = await _storage.read(key: "refresh_token");
    if (refreshToken == null) {
      return false;
    }

    var response = await desktopOAuth2.reAuthorize(
        reAuthUrl: 'https://dev-k1hhibazdyt8o3em.us.auth0.com/oauth/token',
        clientId: clientId,
        refreshToken: refreshToken,
        clientSecret:
            'Uq5903-wmE6rgNfxBiqKReshNen4Vd8iMnYXgM2SDUeSAmTww0SRQBYNl6BWoCPW');
    if (response == null) {
       var newState = LoginState(
        accessToken: '',
        loggedIn: LoginEnum.notLoggingIn,
        expiresIn: null);

        emit(newState);
        return false;
    }

    var tokenExpiration =
        DateTime.now().toUtc().add(Duration(seconds: response["expires_in"]));

    var newState = LoginState(
        accessToken: response['access_token'],
        loggedIn: LoginEnum.loggedIn,
        expiresIn: tokenExpiration);

    emit(newState);

    await _storage.write(key: "loggedIn", value: "true");
    await _storage.write(key: "token", value: response['access_token']);
    await _storage.write(
        key: "tokenExpiration", value: tokenExpiration.toString());

    return true;
  }

  Future<void> reAuthorizeLoop() async {
    while (true) {
      if (state.loggedIn != null && state.loggedIn == LoginEnum.loggedIn) {
        // wait until 2 hours before current expiration and refresh
        DateTime expirationTime =
            DateTime.parse((await _storage.read(key: "tokenExpiration"))!);
        DateTime currentTime = DateTime.now().toUtc();
        if (expirationTime.subtract(Duration(hours: 2)).isBefore(currentTime)) {
          await reAuthorize();
        } else {
          await Future.delayed(Duration(seconds: 30));
        }
      } else {
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }
}
