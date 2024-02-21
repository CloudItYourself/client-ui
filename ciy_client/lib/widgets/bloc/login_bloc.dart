import 'package:ciy_client/auth_lib/desktop_authorization_code.dart';
import 'package:ciy_client/auth_lib/desktop_oauth2.dart';
import 'package:ciy_client/widgets/events/login_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LoginEnum { notLoggingIn, loggedIn, inProgress }

final class LoginState extends Equatable {
  final LoginEnum? loggedIn;
  final String? accessToken;
  LoginState({this.loggedIn, this.accessToken});

  @override
  List<Object?> get props => [loggedIn, accessToken];
}

class LoginBloc extends Bloc<LoginEventType, LoginState> {
  LoginBloc()
      : super(LoginState(loggedIn: LoginEnum.notLoggingIn, accessToken: '')) {
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

    on<LoginRequest>(((event, emit) async {
      emit(LoginState(accessToken: '', loggedIn: LoginEnum.inProgress));

      await desktopOAuth2.oauthorizeCode(desktopAuthCodeFlow).then((token) {
        if (token != null && token.isNotEmpty) {
          var newState = LoginState(
              accessToken: token['access_token'], loggedIn: LoginEnum.loggedIn);
          emit(newState);
        } else {
          emit(LoginState(accessToken: '', loggedIn: LoginEnum.notLoggingIn));
        }
      });
    }));
    on<LogoutRequest>(((event, emit) async {
      var newState = LoginState(accessToken: '', loggedIn: LoginEnum.notLoggingIn);
      emit(newState);
    }));
  }
}
