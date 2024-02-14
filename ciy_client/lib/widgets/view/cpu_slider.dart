import 'package:ciy_client/widgets/bloc/cpu_slider_bloc.dart';
import 'package:ciy_client/widgets/view/divisions_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CPUSliderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpecificDivisionsSlider<CPUValueChangeEvent, CPUValueBloc>(
        "Cores",
        context.select((CPUValueBloc bloc) => bloc.state.minCores!),
        context.select((CPUValueBloc bloc) => bloc.state.maxCores!),
        context.select((CPUValueBloc bloc) => bloc.state.increment!),
        CPUValueChangeEvent.new,
        context.select((CPUValueBloc bloc) => bloc.state.currentCoreCount!));
  }
}
