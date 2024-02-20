import 'dart:math';

import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/events/additional_settings_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    on<RunOnStartupEvent>(((event, emit) {
      var newState = AdditionalSettingsState(
        state.selfManaged,
        event.status,
        state.startInTray,
      );
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
