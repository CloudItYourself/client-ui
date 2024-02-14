import 'package:ciy_client/widgets/view/installation_status.dart';
import 'package:ciy_client/widgets/view/vm_parameters.dart';
import 'package:flutter/material.dart';

class UnifiedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 400,
          child: Column(children: [
            VmSettingsMenu(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InstallationStatusWidget(),
            ),
          ]),
        ),
      ),
    );
  }
}