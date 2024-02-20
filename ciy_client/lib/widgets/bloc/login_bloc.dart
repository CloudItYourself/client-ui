import 'dart:io';

import 'package:ciy_client/widgets/events/login_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';

final class LoginState extends Equatable {
  final bool? loggedIn;

  LoginState({this.loggedIn});
      
  @override
  List<Object?> get props => [loggedIn];
}

class LoginBloc extends Bloc<LoginEventType, LoginState> {
  static const serverPort = 28253;
  final zitadelIssuer = Uri.parse('https://prod-users-ckvdju.zitadel.cloud');
  final zitadelClientId = '254874946579310600@clients';
  OidcUserManager? userManager;
  late Future<void> initFuture;
  late Future<void>? httpCallbackServer;
  static const callbackUrlScheme = 'ciy-client';//??
  final redirectUri = Uri(scheme: callbackUrlScheme, path: 'http://localhost:$serverPort/login_succes');

  static Future<void> startServer() async {
    var server = await HttpServer.bind("localhost", serverPort);
    await for (var request in server) {
      request.response
        ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
        ..write('Login successful')
        ..close();
    }
  }
  LoginBloc()
      : super(LoginState(loggedIn: false)) {
            httpCallbackServer = startServer();

    userManager = OidcUserManager.lazy(
      discoveryDocumentUri:
          OidcUtils.getOpenIdConfigWellKnownUri(zitadelIssuer),
      clientCredentials: OidcClientAuthentication.none(clientId: zitadelClientId),
      store: OidcDefaultStore(),
      settings: OidcUserManagerSettings(
        redirectUri: redirectUri,
        // the same redirectUri can be used as for post logout too.
        postLogoutRedirectUri: redirectUri,
        scope: ['openid', 'profile', 'email', 'offline_access'],
      ),
    );
    initFuture = userManager!.init();

    on<LoginRequest>(((event, emit) async {
      final user = await userManager!.loginAuthorizationCodeFlow();
      // if (token != null) {
      //   emit(LoginState(loggedIn: true));
      // }
    }));
  }
}
