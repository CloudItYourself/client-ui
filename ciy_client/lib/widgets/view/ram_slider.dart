import 'package:ciy_client/widgets/view/divisions_slider.dart';
import 'package:flutter/material.dart';
import 'package:ciy_client/widgets/bloc/ram_slider_block.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RAMSliderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => RAMValuesBloc(),
        child: Builder(builder: (context) {
          return SpecificDivisionsSlider<RamChangedEvent, RAMValuesBloc>(
              "Memory (GB)",
              context.select((RAMValuesBloc bloc) => bloc.state.minRam!),
              context.select((RAMValuesBloc bloc) => bloc.state.maxRam!),
              context.select((RAMValuesBloc bloc) => bloc.state.increment!),
              RamChangedEvent.new,
              context.select((RAMValuesBloc bloc) => bloc.state.currentRam!));
        }));
  }
}
