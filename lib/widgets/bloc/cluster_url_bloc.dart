import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/events/vm_settings_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class ClusterUrlEvent extends VMSettingsEvent {
  const ClusterUrlEvent(this.newValue);
  final String newValue;
}

final class CurrentUrlState extends Equatable {
  final String? currentUrl;

  CurrentUrlState({this.currentUrl});

  @override
  List<Object?> get props => [currentUrl];
}

class CurrentURLBloc extends Bloc<VMSettingsEvent, CurrentUrlState> {
  CurrentURLBloc()
      : super(CurrentUrlState(currentUrl: VMCharacteristics().clusterUrl)) {
    on<ClusterUrlEvent>((event, emit) {
      var newState = CurrentUrlState(
        currentUrl: event.newValue, // Updated value
      );
      VMCharacteristics().updateClusterURL(state.currentUrl!);
      emit(newState);
    });
  }
}
