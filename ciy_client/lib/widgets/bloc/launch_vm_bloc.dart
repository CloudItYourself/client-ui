import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/utilities/installer.dart';
import 'package:ciy_client/utilities/process_utils.dart';
import 'package:path/path.dart' as path;
import 'package:auto_exit_process/auto_exit_process.dart' as aep;

import 'package:ciy_client/widgets/events/vm_running_events.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RunningState { notRunning, inProgress, running }

final class CurrentVMState extends Equatable {
  final RunningState running;

  CurrentVMState({required this.running});

  @override
  List<Object?> get props => [running];


  static void runVM(List<dynamic> args) async {
    final token = args[0];
    SendPort sendPort = args[1];
    ReceivePort recvPort = ReceivePort();
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    final appHomeDir = path.dirname(Platform.script.toFilePath());

    sendPort.send(recvPort.sendPort);

    try {
      if (Platform.isWindows) {
        var backendExecutor =
            '$appHomeDir/${CiyInstaller.dataDir}/${CiyInstaller.backendFileNameWindows}';
        if (await File(backendExecutor).exists()) {
          sendPort.send(true);
          var result = await aep.Process.start(backendExecutor, [],
              environment: {
                "MONGO_URI":
                    "mongodb+srv://ronen:r43oy63x@tpc-dev-db.gbm30mu.mongodb.net/"
              },
              isAutoExit: true);

          recvPort.listen((message) {
            if (Platform.isWindows){
              killWindowsChildProcesses();
            }
          });
          await result.exitCode;
        }
      }
    } on Exception {
      //TODO: log me
    }

    sendPort.send(false);
  }
}

class VMRunBloc extends Bloc<VMRuntimeEvent, CurrentVMState> {
  Isolate? runningVMIsolate;
  ReceivePort? readCommunicationPort;
  SendPort? writeCommunicationPort;

  VMRunBloc() : super(CurrentVMState(running: RunningState.notRunning)) {
    on<VMStartEvent>((event, emit) async {
      prepareVMParametersFile();
      runVM();
      emit(CurrentVMState(running: RunningState.inProgress));
    });

    on<VMRunningEvent>((event, emit) {
      emit(CurrentVMState(running: RunningState.running));
    });

    on<VMTerminateRequest>((event, emit) {
      killVM();
    });

    on<VMStopEvent>((event, emit) {
      emit(CurrentVMState(running: RunningState.notRunning));
    });
  }

  void prepareVMParametersFile() async {
    var vmParams = VMCharacteristics();
    var vmJsonRepresentation = <String, String>{};
    if (Platform.isWindows) {
      final appHomeDir = path.dirname(Platform.script.toFilePath());
      var vmLocation =
          '$appHomeDir/${CiyInstaller.dataDir}/${CiyInstaller.vmFileNameWindows}';

      vmJsonRepresentation["server_url"] =
          'https://cluster-access.${vmParams.clusterUrl!}';
      vmJsonRepresentation["cpu_limit"] = vmParams.vmCores!.toString();
      vmJsonRepresentation["memory_limit"] =
          (vmParams.vmRam! * 1024).toString();
      vmJsonRepresentation["qemu_installation_location"] =
          CiyInstaller.qemuInstalledPathWindows;
      vmJsonRepresentation["vm_image_location"] =
          vmLocation.replaceAll("/", "\\");
      Map<String, String> envVars = Platform.environment;
      String configFilePath =
          "${envVars['UserProfile']!}/.ciy-worker-manager/config.json";

      final configFile = File(configFilePath);
      await configFile.create(recursive: true);
      await configFile.writeAsString(jsonEncode(vmJsonRepresentation));
    }
  }

  void runVM() async {
    readCommunicationPort = ReceivePort();
    readCommunicationPort!.listen((message) {
      if (message is bool) {
        if (message == true) {
          add(VMRunningEvent());
        } else {
          killVM();
        }
      } else {
        writeCommunicationPort = message;
      }
    });
    runningVMIsolate = await Isolate.spawn(CurrentVMState.runVM,
        [RootIsolateToken.instance!, readCommunicationPort!.sendPort]);
  }

  void killVM() {
    if (runningVMIsolate != null) {
      writeCommunicationPort!.send(true);
      readCommunicationPort!.close();
    }
    readCommunicationPort = null;
    runningVMIsolate = null;
    add(VMStopEvent());
  }
}
