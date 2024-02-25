import 'package:ciy_client/widgets/bloc/cpu_slider_bloc.dart';
import 'package:ciy_client/widgets/bloc/ram_slider_bloc.dart';
import 'package:ciy_client/widgets/view/cpu_slider.dart';
import 'package:ciy_client/widgets/view/ram_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VmSettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      context.watch<RAMValuesBloc>();
      context.watch<CPUValueBloc>();
      return Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Column(children: [
          CPUSliderWidget(),
          RAMSliderWidget(),
        ]),
      );
    });
  }
}
