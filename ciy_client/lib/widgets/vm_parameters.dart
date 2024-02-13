import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/cpu_slider.dart';
import 'package:ciy_client/widgets/ram_slider.dart';
import 'package:flutter/material.dart';

class VmSettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CPUSlider(),
      RAMSlider(),
      Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
                  onPressed: () {
                    VMCharacteristics().saveParameters();
                  },
                  child: Icon(
                    Icons.check,
                    size: 13,
                  ))),
    ]);
  }
}
