import 'dart:isolate';
import 'dart:ui';
import 'package:ciy_client/utilities/installer.dart';
import 'package:ciy_client/widgets/events/vm_installation_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum InstallationStatus {
  installing,
  success,
  failed;
}

final class VMInstallationState extends Equatable {
  final InstallationStatus virtualizationInstalled;
  final InstallationStatus backendInstalled;
  final InstallationStatus vmInstalled;

  VMInstallationState(
      this.virtualizationInstalled, this.backendInstalled, this.vmInstalled);

  @override
  List<Object?> get props =>
      [virtualizationInstalled, backendInstalled, vmInstalled];
}

class VMInstallationBloc extends Bloc<InstallationEvent, VMInstallationState> {
  late Future<Isolate> virtualizationIsolate;
  late Future<Isolate> backendIsolate;
  late Future<Isolate> vmIsolate;

  VMInstallationBloc()
      : super(VMInstallationState(InstallationStatus.installing,
            InstallationStatus.installing, InstallationStatus.installing)) {
    final virtReceivePort = ReceivePort();
    virtReceivePort.listen((message) {
      if (message is bool) {
        add(VirtualizationInstalledFinishedEvent(message));
      } else {
        add(VirtualizationInstalledFinishedEvent(false));
        throw Exception("Error! isolate sent invalid message!");
      }
      virtReceivePort.close();
    });

    virtualizationIsolate = Isolate.spawn(CiyInstaller.installVirtualization,
        [RootIsolateToken.instance!, virtReceivePort.sendPort]);

    final backendReceivePort = ReceivePort();
    backendReceivePort.listen((message) {
      if (message is bool) {
        add(BackendInstallationFinishedEvent(message));
      } else {
        add(BackendInstallationFinishedEvent(false));
        throw Exception("Error! isolate sent invalid message!");
      }
      backendReceivePort.close();
    });

    backendIsolate = Isolate.spawn(
        CiyInstaller.installBackend, [RootIsolateToken.instance!, backendReceivePort.sendPort]);
    
    final vmReceivePort = ReceivePort();
    vmReceivePort.listen((message) {
      if (message is bool) {
        add(VMInstallationFinishedEvent(message));
      } else {
        add(VMInstallationFinishedEvent(false));
        throw Exception("Error! isolate sent invalid message!");
      }
      vmReceivePort.close();
    });
    
    vmIsolate =
        Isolate.spawn(CiyInstaller.installVM, [RootIsolateToken.instance!, vmReceivePort.sendPort]);

    on<VirtualizationInstalledFinishedEvent>((event, emit) {
      var newState = VMInstallationState(
          event.status ? InstallationStatus.success : InstallationStatus.failed,
          state.backendInstalled,
          state.vmInstalled);
      emit(newState);
    });
    on<VMInstallationFinishedEvent>((event, emit) {
      var newState = VMInstallationState(
          state.virtualizationInstalled,
          state.backendInstalled,
          event.status
              ? InstallationStatus.success
              : InstallationStatus.failed);
      emit(newState);
    });
    on<BackendInstallationFinishedEvent>((event, emit) {
      var newState = VMInstallationState(
          state.virtualizationInstalled,
          event.status ? InstallationStatus.success : InstallationStatus.failed,
          state.vmInstalled);
      emit(newState);
    });
  }
}
