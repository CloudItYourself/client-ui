import 'package:ciy_client/widgets/bloc/vm_installation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class InstallationStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VMInstallationBloc, VMInstallationState>(
      builder: (context, state) {
    var children = <Widget>[];
    context.select((VMInstallationBloc bloc) {
      switch (bloc.state.virtualizationInstalled) {
        case InstallationStatus.installing:
          children.add(Row(
            children: [
              Text("Virtualization "),
              LoadingAnimationWidget.threeArchedCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ],
          ));
        case InstallationStatus.success:
          children.add(Row(
            children: [
              Text("Virtualization "),
              Icon(Icons.check),
            ],
          ));
        case InstallationStatus.failed:
          children.add(Row(
            children: [
              Text("Virtualization "),
              Icon(Icons.error),
            ],
          ));
      }

      switch (bloc.state.backendInstalled) {
        case InstallationStatus.installing:
          children.add(Row(
            children: [
              Text("Backend        "),
              LoadingAnimationWidget.threeArchedCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ],
          ));
        case InstallationStatus.success:
          children.add(Row(
            children: [
              Text("Backend        "),
              Icon(Icons.check),
            ],
          ));
        case InstallationStatus.failed:
          children.add(Row(
            children: [
              Text("Backend        "),
              Icon(Icons.error),
            ],
          ));
      }
      switch (bloc.state.vmInstalled) {
        case InstallationStatus.installing:
          children.add(Row(
            children: [
              Text("VM                "),
              LoadingAnimationWidget.threeArchedCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ],
          ));
        case InstallationStatus.success:
          children.add(Row(
            children: [
              Text("VM                "),
              Icon(Icons.check),
            ],
          ));
        case InstallationStatus.failed:
          children.add(Row(
            children: [
              Text("VM                "),
              Icon(Icons.error),
            ],
          ));
      }
    });

    return Align(
        alignment: Alignment.centerLeft, child: Column(children: children)); 
         });
  }
}
