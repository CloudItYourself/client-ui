import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:tar/tar.dart';

class CiyInstaller {
  static const String qemuDownloadUrl =
      'https://qemu.weilnetz.de/w64/2021/qemu-w64-setup-20211215.exe';

  static const String backendDownloadUrl =
      'https://gitlab.com/api/v4/projects/54080196/packages/generic/ciy-client-runner/1.0.0/ciy-runner-1.0.0-win-amd64.tgz';

  static const String vmDownloadUrl =
      'https://gitlab.com/api/v4/projects/54080196/packages/generic/ciy-client-runner/1.0.0/ciy-vm-1.0.0-amd64.tgz';

  static const int qemuInstallTimeoutInSeconds = 600;

  static const String backendFileNameWindows = "external_controller.exe";
  static const String vmFileNameWindows = "ciy.qcow2";
  static const String qemuInstalledPathWindows =
      "C:\\Program Files\\qemu\\qemu-system-x86_64.exe";

  static const String dataDir = "data";

  static Future<bool> installQemu(String temporaryDirectoryPath) async {
    if (Platform.isWindows) {
      final request = await HttpClient().getUrl(Uri.parse(qemuDownloadUrl));
      final response = await request.close();
      Stream<List<int>> inputStream = response;
      RandomAccessFile outputFile =
          await File('$temporaryDirectoryPath/ciy-vm-runner.exe')
              .open(mode: FileMode.write);
      await inputStream.listen((data) {
        outputFile.writeFromSync(data);
      }).asFuture();

      // Close the file after writing
      await outputFile.close();

      var result = await Process.run(
          "$temporaryDirectoryPath/ciy-vm-runner.exe", ["/S"],
          runInShell: true);
      await File('$temporaryDirectoryPath/ciy-vm-runner.exe').delete();
      return result.exitCode == 0;
    }
    return true;
  }

  static void installVirtualization(List<dynamic> args) async {
    final token = args[0];
    SendPort sendPort = args[1];
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    try {
      if (await File(qemuInstalledPathWindows).exists()) {
        sendPort.send(true);
        return;
      }

      final Directory temporaryDirectory = await getTemporaryDirectory();
      var qemuInstalled = await installQemu(temporaryDirectory.path);
      sendPort
          .send(qemuInstalled && await File(qemuInstalledPathWindows).exists());
    } on Exception {
      sendPort.send(false);
    }
  }

  static Future<void> extractTarGz(File tarGz, Directory target) async {
  final input = tarGz.openRead().transform(gzip.decoder);

  await TarReader.forEach(input, (entry) async {
    final destination =
        path.joinAll([target.path, ...path.posix.split(entry.name)]);

    final f = File(destination);
    await f.create(recursive: true);
    await entry.contents.pipe(f.openWrite());
  });
}

  static void installBackend(List<dynamic> args) async {
    final token = args[0];
    SendPort sendPort = args[1];
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    final appHomeDir = path.dirname(Platform.script.toFilePath());

    try {
      if (Platform.isWindows) {
        if (await File('$appHomeDir/$dataDir/$backendFileNameWindows')
            .exists()) {
          sendPort.send(true);
          return;
        }

        final Directory temporaryDirectory =
            await getTemporaryDirectory();

        final request =
            await HttpClient().getUrl(Uri.parse(backendDownloadUrl));
        request.headers.add("PRIVATE-TOKEN", "glpat-3zqVQwKxwU_Qsvc_8fw8");
        final response = await request.close();
        Stream<List<int>> inputStream = response;
        RandomAccessFile outputFile = await File(
                '${temporaryDirectory.path}/$backendFileNameWindows.tgz')
            .open(mode: FileMode.write);
        await inputStream.listen((data) {
          outputFile.writeFromSync(data);
        }).asFuture();
        
        // Close the file after writing
        await outputFile.close();
        await extractTarGz(File(outputFile.path), Directory('$appHomeDir/$dataDir'));
  
        await File(outputFile.path).delete();
        sendPort.send(await File('$appHomeDir/$dataDir/$backendFileNameWindows').exists());
      }
    } on Exception {
      // do nothing.. (will send false);
    }
    return sendPort.send(false);
  }

  static void installVM(List<dynamic> args) async {
    final token = args[0];
    SendPort sendPort = args[1];
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    final appHomeDir = path.dirname(Platform.script.toFilePath());

    try {
      if (Platform.isWindows) {
        if (await File('$appHomeDir/$dataDir/$vmFileNameWindows')
            .exists()) {
          sendPort.send(true);
          return;
        }

        final Directory temporaryDirectory =
            await getTemporaryDirectory();

        final request =
            await HttpClient().getUrl(Uri.parse(vmDownloadUrl));
        request.headers.add("PRIVATE-TOKEN", "glpat-3zqVQwKxwU_Qsvc_8fw8");
        final response = await request.close();
        Stream<List<int>> inputStream = response;
        RandomAccessFile outputFile = await File(
                '${temporaryDirectory.path}/$vmFileNameWindows.tgz')
            .open(mode: FileMode.write);
        await inputStream.listen((data) {
          outputFile.writeFromSync(data);
        }).asFuture();
        
        // Close the file after writing
        await outputFile.close();
        await extractTarGz(File(outputFile.path), Directory('$appHomeDir/$dataDir'));
  
        await File(outputFile.path).delete();
        sendPort.send(await File('$appHomeDir/$dataDir/$vmFileNameWindows').exists());
      }
    } on Exception {
      // do nothing.. (will send false);
    }
    return sendPort.send(false);
  }
}
