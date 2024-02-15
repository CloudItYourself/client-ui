import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/bloc/vm_installation_bloc.dart';
import 'package:ciy_client/widgets/view/installation_status.dart';
import 'package:ciy_client/widgets/view/run_vm_button.dart';
import 'package:ciy_client/widgets/view/vm_parameters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnifiedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<VMInstallationBloc>(
            create: (context) => VMInstallationBloc(),
          ),
          BlocProvider<VMRunBloc>(create: ((context) => VMRunBloc())),
        ],
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 380,
                  child: Column(children: [
                    VmSettingsMenu(),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InstallationStatusWidget(),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    width: 380,
                    child: Column(children: [
                      SizedBox(width: 380, height: 200, child: Placeholder()),
                      RunVMButton(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
