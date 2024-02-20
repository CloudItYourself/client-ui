import 'package:ciy_client/widgets/bloc/additional_settings_bloc.dart';
import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/bloc/vm_installation_bloc.dart';
import 'package:ciy_client/widgets/events/vm_running_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RunVMButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final vmRunState = context.watch<VMRunBloc>().state;
      final vmInstallState = context.watch<VMInstallationBloc>().state;
      final additionalSettingsState = context.watch<AdditionalSettingsBloc>().state;

      String buttonText = "Run";
      bool enabled =
          vmInstallState.backendInstalled == InstallationStatus.success &&
              vmInstallState.virtualizationInstalled ==
                  InstallationStatus.success &&
              vmInstallState.vmInstalled == InstallationStatus.success;
      VMRuntimeEvent? event;
      if (vmRunState.running == RunningState.running) {
        buttonText = "Terminate";
        event = VMTerminateRequest();
      } else if (vmRunState.running == RunningState.inProgress) {
        buttonText = "Initializing";
        enabled = false;
      } else {
        event = VMStartEvent();
      }
      if (enabled  && vmRunState.running == RunningState.notRunning && additionalSettingsState.selfManaged == true) {
        enabled = false;
        context.read<VMRunBloc>().add(VMStartEvent());
      }
      return Padding(
        padding: const EdgeInsets.only(top:60.0),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: enabled
                        ? () {
                            context.read<VMRunBloc>().add(event!);
                          }
                        : null,
                    child: Text(buttonText))),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      Text("CPU: ${vmRunState.vmCpuUsed.toStringAsFixed(4)}%"),
                      Padding(
                        padding: const EdgeInsets.only(left:12.0),
                        child: Text("Memory: ${vmRunState.vmRamUsed.toStringAsFixed(4)} GB"),
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
