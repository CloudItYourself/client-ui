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
import 'package:http/http.dart' as http;
import 'package:mutex/mutex.dart';

enum RunningState { notRunning, inProgress, running}

enum RequestType { execute, terminate }

enum ResponseStatus { sucesss, failure }

class PeriodicVMStatus {
  bool vmConnected;
  final double vmCpuUsed;
  final double vmRamUsed;
  PeriodicVMStatus(this.vmConnected, this.vmCpuUsed, this.vmRamUsed);
  Map<String, dynamic> toJson() => {
        'vmConnected': vmConnected,
        'vmCpuUsed': vmCpuUsed,
        'vmRamUsed': vmRamUsed,
      };
  factory PeriodicVMStatus.fromJson(Map<String, dynamic> json) {
    return PeriodicVMStatus(
      json['vmConnected'],
      json['vmCpuUsed'].toDouble(),
      json['vmRamUsed'].toDouble(),
    );
  }
}

class VMIsolate {
  RunningState currentState = RunningState.notRunning;
  SendPort sendPort;
  ReceivePort recvPort;
  Process? vmProcess;
  final mutex = Mutex();
  late final String backendExecutorPath;

  VMIsolate({required this.sendPort, required this.recvPort}) {
    final appHomeDir = path.dirname(Platform.script.toFilePath());
    recvPort.listen(handleRequests);
    backendExecutorPath =
        '$appHomeDir/${CiyInstaller.dataDir}/${CiyInstaller.backendFileNameWindows}';
  }

  Future<void> publishPeriodicRequests() async {
    while (true) {
      await Future.delayed(Duration(seconds: 5));
      if (currentState != RunningState.notRunning) {
        try {
          final response = await http
              .get(Uri.parse("http://localhost:28253/api/v1/vm_metrics"));
          if (response.statusCode == 200) {
            var responseBody = jsonDecode(response.body);
            var vmCpuUsed = responseBody["vm_cpu_utilization"] /
                responseBody["vm_cpu_allocated"];
            var vmMemoryUsed = responseBody["vm_memory_used"] /
                responseBody["vm_memory_available"];
            currentState = RunningState.running;
            sendPort.send(jsonEncode(PeriodicVMStatus(true, vmCpuUsed, vmMemoryUsed).toJson()));
          } else {
            if (currentState == RunningState.running) {
              currentState = RunningState.notRunning;
            }
            sendPort.send(jsonEncode(PeriodicVMStatus(false, 0.0, 0.0).toJson()));
          }
        } on Exception {
          sendPort.send(jsonEncode(PeriodicVMStatus(false, 0.0, 0.0).toJson()));
        }
      }
    }
  }

  void handleRequests(dynamic message) async {
    if (message == RequestType.execute) {
      if (currentState == RunningState.running ||
          currentState == RunningState.inProgress) {
        sendPort.send(ResponseStatus.sucesss);
      } else {
        if (vmProcess != null) {
          sendPort.send(ResponseStatus.sucesss);
        } else {
          vmProcess = await aep.Process.start(backendExecutorPath, [],
              mode: ProcessStartMode
                  .inheritStdio, // this is incredibly important, DO NOT CHANGE
              isAutoExit: true);
          sendPort.send(ResponseStatus.sucesss);
          currentState = RunningState.inProgress;
        }
      }
    } else {
      if (currentState == RunningState.running ||
          currentState == RunningState.inProgress) {
        if (vmProcess != null) {
          await killWindowsChildProcesses();
          vmProcess!.kill();
          vmProcess = null;
        }
        currentState = RunningState.notRunning;
        sendPort.send(ResponseStatus.sucesss);
      } else {
        sendPort.send(ResponseStatus.sucesss);
      }
    }
  }
}

final class CurrentVMState extends Equatable {
  final RunningState running;
  final double vmCpuUsed;
  final double vmRamUsed;

  CurrentVMState(
      {required this.running,
      required this.vmCpuUsed,
      required this.vmRamUsed});

  @override
  List<Object?> get props => [running, vmCpuUsed, vmRamUsed];

  static void runVMIsolate(List<dynamic> args) async {
    final token = args[0];
    SendPort sendPort = args[1];
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    ReceivePort recvPort = ReceivePort();
    sendPort.send(recvPort.sendPort);
    var vmIsolate = VMIsolate(sendPort: sendPort, recvPort: recvPort);
    await vmIsolate.publishPeriodicRequests();
  }
}

class VMRunBloc extends Bloc<VMRuntimeEvent, CurrentVMState> {
  Future<Isolate>? runningVMIsolate;
  late ReceivePort readCommunicationPort;
  SendPort? writeCommunicationPort;

  PeriodicVMStatus? lastStatus;
  ResponseStatus? latestResponse;

  VMRunBloc()
      : super(CurrentVMState(
            running: RunningState.notRunning, vmCpuUsed: 0.0, vmRamUsed: 0.0)) {
    readCommunicationPort = ReceivePort();
    readCommunicationPort.listen(handleMessages);
    runningVMIsolate = Isolate.spawn(CurrentVMState.runVMIsolate,
        [RootIsolateToken.instance!, readCommunicationPort.sendPort]);

    on<VMStartEvent>((event, emit) async {
      runVM();
    });

    on<VMRunningEvent>((event, emit) {
      emit(CurrentVMState(
          running: RunningState.running,
          vmCpuUsed: lastStatus!.vmCpuUsed,
          vmRamUsed: lastStatus!.vmRamUsed));
    });

    on<VMTerminateRequest>((event, emit) {
      killVM();
    });

    on<VMStopEvent>((event, emit) {
      lastStatus = null;
      emit(CurrentVMState(
          running: RunningState.notRunning, vmCpuUsed: 0.0, vmRamUsed: 0.0));
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
    while (writeCommunicationPort == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    if (state.running == RunningState.notRunning &&
        (lastStatus == null || lastStatus!.vmConnected == false)) {
      lastStatus = null;
      prepareVMParametersFile();
      writeCommunicationPort!.send(RequestType.execute);
      latestResponse = null;
      while (latestResponse == null) {
        await Future.delayed(Duration(milliseconds: 20));
      }
      if (latestResponse == ResponseStatus.sucesss) {
        emit(CurrentVMState(
            running: RunningState.inProgress, vmCpuUsed: 0.0, vmRamUsed: 0.0));
      } else {
        // TODO: log me
      }
    }
  }

  void killVM() async {
    while (writeCommunicationPort == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    if (state.running != RunningState.notRunning) {
      lastStatus = null;
      writeCommunicationPort!.send(RequestType.terminate);
      latestResponse = null;
      while (latestResponse == null) {
        await Future.delayed(Duration(milliseconds: 20));
      }
      if (latestResponse == ResponseStatus.sucesss) {
        emit(CurrentVMState(
            running: RunningState.notRunning, vmCpuUsed: 0.0, vmRamUsed: 0.0));
      } else {
        // TODO: log me
      }
    }
  }

  void handleMessages(dynamic message) {
    if (message is SendPort) {
      writeCommunicationPort = message;
    } else if (message is ResponseStatus) {
      latestResponse = message;
    } else if (message is String) {
      lastStatus = PeriodicVMStatus.fromJson(jsonDecode(message));
      if (lastStatus!.vmConnected == false &&
          state.running == RunningState.running) {
        add(VMTerminateRequest());
      }
      if (lastStatus!.vmConnected && state.running != RunningState.notRunning) {
        add(VMRunningEvent());
      }
    }
  }
}
