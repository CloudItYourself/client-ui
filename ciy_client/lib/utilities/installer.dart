import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

class CiyInstaller {
  static const String installationDetailsJsonFileName =
      "ciy-tooling-locations.json";
  static const String qemuDownloadUrl =
      'https://qemu.weilnetz.de/w64/2021/qemu-w64-setup-20211215.exe';
  static const List<String> qemuInstallationProcessTask = [
    '|',
    'findstr',
    '/c:"qemu"'
  ];
  static const int qemuInstallTimeoutInSeconds = 600;

  static Future<Map<String, dynamic>?> checkIfInstalledProperly(
      String configFile) async {
    var fileExists = await File(configFile).exists();
    if (!fileExists) {
      return null;
    }
    final fileData = await File(configFile).readAsString();
    return jsonDecode(fileData) as Map<String, dynamic>;
  }

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

  static void installCiyRequirements(List<dynamic> args) async {
    final token = args[0];

    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    Directory appDir = await getApplicationDocumentsDirectory();
    String installationJsonFullPath =
        "${appDir.path}/$installationDetailsJsonFileName";
    var insallationStatus =
        await checkIfInstalledProperly(installationJsonFullPath);
    final Directory temporaryDirectory = await getTemporaryDirectory();
    var outputJson = <String, String>{};
    if (insallationStatus != null) {
      outputJson.addAll(insallationStatus.map((key, value) => MapEntry(key, value.toString())));
    }
    if (!outputJson.containsKey("QEMU_INSTALLED") ||
        outputJson["QEMU_INSTALLED"] != "Success") {
      var qemuInstaller = await installQemu(temporaryDirectory.path);
      outputJson["QEMU_INSTALLED"] = qemuInstaller ? "Success" : "Failure";
    }
    await File(installationJsonFullPath).writeAsString(jsonEncode(outputJson));
  }
}
