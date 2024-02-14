import 'dart:io';
import 'dart:math';

import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/events/vm_settings_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class CPUValueChangeEvent extends VMSettingsEvent {
  const CPUValueChangeEvent(this.newValue);
  final int newValue;
}

final class CPUValuesState extends Equatable {
  final int? minCores;
  final int? maxCores;
  final int? increment;
  final int? currentCoreCount;

  CPUValuesState(
      this.minCores, this.maxCores, this.increment, this.currentCoreCount);
      
  @override
  List<Object?> get props => [minCores, maxCores, increment, currentCoreCount];
}

class CPUValueBloc extends Bloc<VMSettingsEvent, CPUValuesState> {
  CPUValueBloc()
      : super(CPUValuesState(min(2, Platform.numberOfProcessors),
            VMCharacteristics().maxCores!, 1, VMCharacteristics().vmCores)) {

    on<PublishSettings>(((event, emit) {
      VMCharacteristics().updateCPU(state.currentCoreCount!);
    }));

    on<CPUValueChangeEvent>((event, emit) {
      var newState = CPUValuesState(
        state.minCores,
        state.maxCores,
        state.increment,
        event.newValue, // Updated value
      );
      emit(newState);
    });
  }
}
