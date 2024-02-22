import 'dart:io';

import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/events/additional_settings_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

final class AdditionalSettingsState extends Equatable {
  final bool? selfManaged;
  final bool? runOnStartup;
  final bool? startInTray;

  AdditionalSettingsState(
      this.selfManaged, this.runOnStartup, this.startInTray);

  @override
  List<Object?> get props => [selfManaged, runOnStartup, startInTray];
}

class AdditionalSettingsBloc
    extends Bloc<AdditionalSettingsEvent, AdditionalSettingsState> {
      bool isLaunchOnStartupInitialized = false;
  AdditionalSettingsBloc()
      : super(AdditionalSettingsState(
            VMCharacteristics().selfManaged ?? false,
            VMCharacteristics().runOnStartup ?? true,
            VMCharacteristics().startInTray ?? true)) {
              
    on<SelfManagerEvent>((event, emit) {
      var newState = AdditionalSettingsState(
        event.status,
        state.runOnStartup,
        state.startInTray,
      );
      VMCharacteristics().updateSelfManaged(event.status);
      emit(newState);
    });

    on<RunOnStartupEvent>(((event, emit) async {
      var newState = AdditionalSettingsState(
        state.selfManaged,
        event.status,
        state.startInTray,
      );
      if (!isLaunchOnStartupInitialized) {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          launchAtStartup.setup(
            appName: packageInfo.appName,
            appPath: Platform.resolvedExecutable,
          );
      }
    

      event.status ? await launchAtStartup.enable() : launchAtStartup.disable();
      VMCharacteristics().updateRunOnStartup(event.status);
      emit(newState);
    }));

    on<StartInTrayEvent>(((event, emit) {
      var newState = AdditionalSettingsState(
        state.selfManaged,
        state.runOnStartup,
        event.status,
      );
      VMCharacteristics().updateStartInTray(event.status);
      emit(newState);
    }));
  }
}
