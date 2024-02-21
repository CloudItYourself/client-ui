import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/bloc/login_bloc.dart';
import 'package:ciy_client/widgets/events/login_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final loggedIn = context.watch<LoginBloc>().state.loggedIn!;
      final vmRunState = context.watch<VMRunBloc>().state;

      Widget? buttonChild;
      var vmRunning = vmRunState.running != RunningState.notRunning;

      switch (loggedIn) {
        case LoginEnum.inProgress:
          buttonChild = LoadingAnimationWidget.threeArchedCircle(
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 20,
          );
        case LoginEnum.notLoggingIn:
          buttonChild = Text("Login");
        case LoginEnum.loggedIn:
          buttonChild = Text("Logout");
      }
      return ElevatedButton(
          onPressed: vmRunning
              ? null
              : loggedIn == LoginEnum.loggedIn
                  ? () {
                      context.read<LoginBloc>().add(LogoutRequest());
                    }
                  : () {
                      context.read<LoginBloc>().add(LoginRequest());
                    },
          child: buttonChild);
    });
  }
}
