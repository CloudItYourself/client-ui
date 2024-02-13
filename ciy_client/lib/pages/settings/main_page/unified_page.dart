import 'package:ciy_client/widgets/cluster_url.dart';
import 'package:ciy_client/widgets/cpu_slider.dart';
import 'package:ciy_client/widgets/installation_status.dart';
import 'package:ciy_client/widgets/ram_slider.dart';
import 'package:ciy_client/widgets/vm_parameters.dart';
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
            ClusterURLWidget(),
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
