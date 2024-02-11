import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

class CiyInstaller {
  static const String installationDetailsJsonFileName = "ciy-tooling-locations.json";
  static const String qemuDownloadUrl = 'https://qemu.weilnetz.de/w64/2021/qemu-w64-setup-20211215.exe';
  static const List<String> qemuInstallationProcessTask = ['|' ,'findstr' ,'/c:"qemu"'];
  static const int qemuInstallTimeoutInSeconds = 600;

  static Future<bool> checkIfInstalledProperly(String configFile) async {
    var fileExists = await File(configFile).exists();
    if (!fileExists) {
      return false;
    }
    final fileData = await File(configFile).readAsString();
    final jsonData = jsonDecode(fileData) as Map<String, dynamic>;
    return jsonData.containsKey("STATUS") && jsonData["STATUS"] == "Success";
  }

  static Future<bool> installQemu(String temporaryDirectoryPath) async {
    if (Platform.isWindows) {
        final request = await HttpClient().getUrl(Uri.parse(qemuDownloadUrl));
        final response = await request.close();
        response.pipe(File('$temporaryDirectoryPath/qemu-installer.exe').openWrite());
        var result = await Process.run("runas", ["$temporaryDirectoryPath/qemu-installer.exe", "/S"], runInShell: true);
        if (result.exitCode != 0) {
          return false;
        }

        var qemuFinishedInstalling = false;
        var qemuFoundOnce = false;
        for (var i = 0; i < qemuInstallTimeoutInSeconds / 10 ; ++i) {
          sleep(Duration(seconds:  10)); // Sleep for  10 seconds
          Process process = await Process.start('tasklist', qemuInstallationProcessTask);
          String output = '';
            await for (var data in process.stdout) {
            output += utf8.decode(data);
          }
          if (output.contains("qemu")) {
            qemuFoundOnce = true;
          }
          else if(qemuFoundOnce) {
              qemuFinishedInstalling = true;
              break;
          }
        }
        return qemuFinishedInstalling;

    }
    return true;   
  }

  static void installCiyRequirements(List<dynamic> args) async {
      final token = args[0];

      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
      Directory appDir = await getApplicationDocumentsDirectory();
      String installationJsonFullPath = "${appDir.path}/$installationDetailsJsonFileName";
      var installedProperly = await checkIfInstalledProperly(installationJsonFullPath);
      if (installedProperly) {
        return;
      }
      final Directory temporaryDirectory = await getTemporaryDirectory();
      var qemuInstaller = await installQemu(temporaryDirectory.path);
  }
}
