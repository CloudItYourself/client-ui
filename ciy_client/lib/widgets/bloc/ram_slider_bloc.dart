import 'dart:math';

import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/events/vm_settings_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class RamChangedEvent extends VMSettingsEvent {
  const RamChangedEvent(this.newValue);
  final int newValue;
}

final class RAMValuesState extends Equatable{
  final int? minRam;
  final int? maxRam;
  final int? increment;
  final int? currentRam;

  RAMValuesState(this.minRam, this.maxRam, this.increment, this.currentRam);

  @override
  List<Object?> get props => [minRam, maxRam, increment, currentRam];

}

class RAMValuesBloc extends Bloc<VMSettingsEvent, RAMValuesState> {
  RAMValuesBloc()
      : super(RAMValuesState(min(3, VMCharacteristics().maxRam!),
            VMCharacteristics().maxRam!, 1, VMCharacteristics().vmRam)) {
    on<RamChangedEvent>((event, emit) {
      var newState = RAMValuesState(
        state.minRam,
        state.maxRam,
        state.increment,
        event.newValue, // Updated value
      );
      VMCharacteristics().updateRAM(event.newValue);
      emit(newState);
    });
  }
}
