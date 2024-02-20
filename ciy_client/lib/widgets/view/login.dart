import 'package:ciy_client/widgets/bloc/login_bloc.dart';
import 'package:ciy_client/widgets/events/login_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final loggedIn = context.watch<LoginBloc>().state.loggedIn!;
      var buttonText = loggedIn ? "Logout" : "Login";
      return ElevatedButton(
          onPressed: loggedIn
              ? () {
                  context.read<LoginBloc>().add(LogoutRequest());
                }
              : () {
                  context.read<LoginBloc>().add(LoginRequest());
                },
          child: Text(buttonText));
    });
  }
}
