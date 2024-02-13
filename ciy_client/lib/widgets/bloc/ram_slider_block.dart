import 'dart:math';

import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/bloc/vm_settings_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class RamChangedEvent extends VMSettingsEvent {
  const RamChangedEvent(this.newValue);
  final int newValue;
}


class RAMValuesState {
  int? minRam;
  int? maxRam;
  int? increment;
  int? currentRam;

  RAMValuesState(
      this.minRam, this.maxRam, this.increment, this.currentRam);
}

class RAMValuesBloc extends Bloc<VMSettingsEvent, RAMValuesState> {
  RAMValuesBloc()
      : super(RAMValuesState(min(2, VMCharacteristics().maxRam!),
            VMCharacteristics().maxRam!, 1, VMCharacteristics().vmRam)) {
    on<RamChangedEvent>((event, emit) {
      state.currentRam = event.newValue;
      emit(state);
    });

    on<PublishSettings>(((event, emit) {
      VMCharacteristics().updateRAM(state.currentRam!);
      emit(state);
    }));
  }
}
