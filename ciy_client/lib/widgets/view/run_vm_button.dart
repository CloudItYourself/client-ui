import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/events/vm_running_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RunVMButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VMRunBloc, CurrentVMState>(builder: (context, state) {
      String buttonText = "Run";
      bool enabled = true;
      VMRuntimeEvent? event;

      context.select((VMRunBloc bloc) {
        if (bloc.state.running == RunningState.running) {
          buttonText = "Terminate";
          event = VMTerminateRequest();
        } else if (bloc.state.running == RunningState.inProgress) {
          buttonText = "Initializing";
          enabled = false;
        } else {
          event = VMStartEvent();
        }
      });

      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: enabled
                  ? () {
                      context.read<VMRunBloc>().add(event!);
                    }
                  : null,
              child: Text(buttonText)));
    });
  }
}
