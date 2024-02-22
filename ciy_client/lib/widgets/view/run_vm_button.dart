import 'package:ciy_client/widgets/bloc/additional_settings_bloc.dart';
import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/bloc/login_bloc.dart';
import 'package:ciy_client/widgets/bloc/vm_installation_bloc.dart';
import 'package:ciy_client/widgets/events/additional_settings_events.dart';
import 'package:ciy_client/widgets/events/vm_running_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RunVMButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final vmRunState = context.watch<VMRunBloc>().state;
      final vmInstallState = context.watch<VMInstallationBloc>().state;
      final additionalSettingsState =
          context.watch<AdditionalSettingsBloc>().state;
      final loginState = context.watch<LoginBloc>().state;

      String buttonText = "Run";
      bool enabled =
          vmInstallState.backendInstalled == InstallationStatus.success &&
              vmInstallState.virtualizationInstalled ==
                  InstallationStatus.success &&
              vmInstallState.vmInstalled == InstallationStatus.success &&
              loginState.loggedIn == LoginEnum.loggedIn;

      VMRuntimeEvent? event;
      AdditionalSettingsEvent? extraEvent;

      if (vmRunState.running == RunningState.running) {
        buttonText = "Terminate";

        extraEvent = SelfManagerEvent(false);
        event = VMTerminateRequest();
      } else if (vmRunState.running == RunningState.inProgress) {
        buttonText = "Initializing";
        enabled = false;
      } else if (vmRunState.running == RunningState.terminating) {
        buttonText = "Terminating";
        enabled = false;
      } else {
        event = VMStartEvent();
      }
      if (enabled &&
          vmRunState.running == RunningState.notRunning &&
          additionalSettingsState.selfManaged == true &&
          loginState.loggedIn == LoginEnum.loggedIn) {
        enabled = false;
        context.read<VMRunBloc>().add(VMStartEvent());
      }
      return Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 60.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: enabled
                          ? () {
                              context.read<VMRunBloc>().add(event!);
                              if (extraEvent != null) {
                                context
                                    .read<AdditionalSettingsBloc>()
                                    .add(extraEvent);
                              }
                            }
                          : null,
                      child: Text(buttonText)),
                )),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 35.0),
                child: SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      Text("CPU: ${vmRunState.vmCpuUsed.toStringAsFixed(4)}%"),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                            "Memory: ${vmRunState.vmRamUsed.toStringAsFixed(4)} GB"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
