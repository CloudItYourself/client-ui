import 'package:ciy_client/widgets/view/installation_status.dart';
import 'package:ciy_client/widgets/view/vm_parameters.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: 380,
      child: Column(children: [
        VmSettingsMenu(),
        Padding(
          padding: const EdgeInsets.only(left:120.0, top: 50.0),
          child: InstallationStatusWidget(),
        ),
      ]),
    ));
  }
}
