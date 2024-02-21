import 'package:ciy_client/widgets/bloc/additional_settings_bloc.dart';
import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/bloc/login_bloc.dart';
import 'package:ciy_client/widgets/bloc/vm_installation_bloc.dart';
import 'package:ciy_client/widgets/view/additional_settings.dart';
import 'package:ciy_client/widgets/view/installation_status.dart';
import 'package:ciy_client/widgets/view/login.dart';
import 'package:ciy_client/widgets/view/run_vm_button.dart';
import 'package:ciy_client/widgets/view/vm_parameters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

class UnifiedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VMInstallationBloc>(
          create: (context) => VMInstallationBloc(),
        ),
        BlocProvider<VMRunBloc>(create: ((context) => VMRunBloc())),
        BlocProvider<AdditionalSettingsBloc>(
            create: ((context) => AdditionalSettingsBloc())),
        BlocProvider<LoginBloc>(create: ((context) => LoginBloc())),
      ],
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kWindowCaptionHeight),
            child: WindowCaption(
                brightness: Theme.of(context).brightness,
                backgroundColor: Theme.of(context).colorScheme.background,
                title: const Text('Cloud IY'))),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 380,
                child: Column(children: [
                  VmSettingsMenu(),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, left: 20.0),
                    child: InstallationStatusWidget(),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 380,
                  child: Column(children: [
                    LoginWidget(),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: SizedBox(
                          width: 380,
                          height: 160,
                          child: AdditionalSettigsWidget()),
                    ),
                    RunVMButton(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
