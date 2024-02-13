import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/bloc/cpu_slider_block.dart';
import 'package:ciy_client/widgets/bloc/ram_slider_block.dart';
import 'package:ciy_client/widgets/view/cpu_slider.dart';
import 'package:ciy_client/widgets/view/ram_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VmSettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      BlocProvider(
          create: (context) => CPUValueBloc(), child: CPUSliderWidget()),
      BlocProvider(
          create: (context) => RAMValuesBloc(), child: RAMSliderWidget()),
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
