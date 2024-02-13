import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/view/cpu_slider.dart';
import 'package:ciy_client/widgets/view/ram_slider.dart';
import 'package:flutter/material.dart';

class VmSettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CPUSliderWidget(),
      RAMSliderWidget(),
      Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
                  onPressed: () {
                    //VMCharacteristics().saveParameters();
                  },
                  child: Icon(
                    Icons.check,
                    size: 13,
                  ))),
    ]);
  }
}
