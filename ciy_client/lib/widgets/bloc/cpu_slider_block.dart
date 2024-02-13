import 'dart:io';
import 'dart:math';

import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/bloc/vm_settings_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class CPUValueChangeEvent extends VMSettingsEvent {
  const CPUValueChangeEvent(this.newValue);
  final int newValue;
}


class CPUValuesState {
  int? minCores;
  int? maxCores;
  int? increment;
  int? currentCoreCount;

  CPUValuesState(
      this.minCores, this.maxCores, this.increment, this.currentCoreCount);
}

class CPUValueBloc extends Bloc<VMSettingsEvent, CPUValuesState> {
  CPUValueBloc()
      : super(CPUValuesState(min(2, Platform.numberOfProcessors),
            VMCharacteristics().maxCores!, 1, VMCharacteristics().vmCores)) {
    on<CPUValueChangeEvent>((event, emit) {
      state.currentCoreCount = event.newValue;
      emit(state);
    });

    on<PublishSettings>(((event, emit) {
      VMCharacteristics().updateCPU(state.currentCoreCount!);
      emit(state);
    }));
  }
}
