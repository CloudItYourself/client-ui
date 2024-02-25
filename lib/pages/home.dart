import 'package:ciy_client/widgets/view/additional_settings.dart';
import 'package:ciy_client/widgets/view/cluster_url.dart';
import 'package:ciy_client/widgets/view/login.dart';
import 'package:ciy_client/widgets/view/run_vm_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: 400,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Row(
              children: [
                ClusterURLWidget(),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: LoginWidget(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: SizedBox(
                width: 380, height: 160, child: AdditionalSettigsWidget()),
          ),
          RunVMButton(),
        ]),
      ),
    ));
  }
}
