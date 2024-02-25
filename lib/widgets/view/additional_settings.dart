import 'package:ciy_client/widgets/bloc/additional_settings_bloc.dart';
import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/events/additional_settings_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdditionalSettigsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final vmRunState = context.watch<VMRunBloc>().state;
      final additionalSettingsState =
          context.watch<AdditionalSettingsBloc>().state;
      var selfManagedEnabled = vmRunState.running == RunningState.notRunning;

      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 300,
          child: Column(
            children: [
              CheckboxListTile(
                  title: Text("Self managed"),
                  value: additionalSettingsState.selfManaged,
                  onChanged: selfManagedEnabled
                      ? (value) {
                          context
                              .read<AdditionalSettingsBloc>()
                              .add(SelfManagerEvent(value!));
                        }
                      : null),
              CheckboxListTile(
                title: Text("Run on startup"),
                value: additionalSettingsState.runOnStartup,
                onChanged: (value) {
                  context
                      .read<AdditionalSettingsBloc>()
                      .add(RunOnStartupEvent(value!));
                },
              ),
              CheckboxListTile(
                title: Text("Start minimized"),
                value: additionalSettingsState.startInTray,
                onChanged: (value) {
                  context
                      .read<AdditionalSettingsBloc>()
                      .add(StartInTrayEvent(value!));
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
