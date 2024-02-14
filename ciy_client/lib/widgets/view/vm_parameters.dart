import 'package:ciy_client/widgets/bloc/cluster_url_bloc.dart';
import 'package:ciy_client/widgets/bloc/cpu_slider_bloc.dart';
import 'package:ciy_client/widgets/bloc/ram_slider_bloc.dart';
import 'package:ciy_client/widgets/events/vm_settings_events.dart';
import 'package:ciy_client/widgets/view/cluster_url.dart';
import 'package:ciy_client/widgets/view/cpu_slider.dart';
import 'package:ciy_client/widgets/view/ram_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VmSettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CPUValueBloc>(
          create: (context) => CPUValueBloc(),
        ),
        BlocProvider<RAMValuesBloc>(
          create: (context) => RAMValuesBloc(),
        ),
        BlocProvider<CurrentURLBloc>(
          create: (context) => CurrentURLBloc(),
        ),
      ],
      child: Column(children: [
        CPUSliderWidget(),
        RAMSliderWidget(),
        Padding(
          padding: const EdgeInsets.only(left:22.0),
          child: ClusterURLWidget(),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: Builder(builder: (context) {
              return ElevatedButton(
                  onPressed: () {
                    context.read<CPUValueBloc>().add(PublishSettings());
                    context.read<RAMValuesBloc>().add(PublishSettings());
                    context.read<CurrentURLBloc>().add(PublishSettings());
                  },
                  child: Icon(
                    Icons.check,
                    size: 15,
                  ));
            })),
      ]),
    );
  }
}
