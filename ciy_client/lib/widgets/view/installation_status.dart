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
        var virtualizationText = Text("Virtualization ");
        Widget? virtualizationChild;
        switch (bloc.state.virtualizationInstalled) {
          case InstallationStatus.installing:
            virtualizationChild = LoadingAnimationWidget.threeArchedCircle(
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            );
          case InstallationStatus.success:
            virtualizationChild = Icon(Icons.check);
          case InstallationStatus.failed:
            virtualizationChild = Icon(Icons.error);
        }

        var backendInstalledText = Text("Backend        ");
        Widget? backendInstalledChild;

        switch (bloc.state.backendInstalled) {
          case InstallationStatus.installing:
            backendInstalledChild = LoadingAnimationWidget.threeArchedCircle(
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            );
          case InstallationStatus.success:
            backendInstalledChild = Icon(Icons.check);
          case InstallationStatus.failed:
            backendInstalledChild = Icon(Icons.error);
        }

        var vmInstallingText = Text("VM                ");
        Widget? vmInstallingChild;

        switch (bloc.state.vmInstalled) {
          case InstallationStatus.installing:
            vmInstallingChild = LoadingAnimationWidget.threeArchedCircle(
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            );
          case InstallationStatus.success:
            vmInstallingChild = Icon(Icons.check);
          case InstallationStatus.failed:
            vmInstallingChild = Icon(Icons.error);
        }
        children.add(Padding(
          padding: const EdgeInsets.only(top:8.0),
          child: Row(children: [
            virtualizationText,
            Padding(
              padding: const EdgeInsets.only(left:20.0),
              child: virtualizationChild,
            ),
          ]),
        ));

        children.add(Padding(
          padding: const EdgeInsets.only(top:8.0),
          child: Row(children: [
            backendInstalledText,
            Padding(
              padding: const EdgeInsets.only(left:20.0),
              child: backendInstalledChild,
            ),
          ]),
        ));

        children.add(Padding(
          padding: EdgeInsets.only(top:8.0),
          child: Row(children: [
            vmInstallingText,
            Padding(
              padding: const EdgeInsets.only(left:20.0),
              child: vmInstallingChild,
            ),
          ]),
        ));
      });
      return Align(
          alignment: Alignment.centerLeft, child: Column(children: children));
    });
  }
}
