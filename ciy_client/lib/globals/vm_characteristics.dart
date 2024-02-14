import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_info/system_info.dart';

class VMCharacteristics {
  static final VMCharacteristics _singleton = VMCharacteristics._internal();
  int? maxCores;
  int? maxRam;

  int? vmCores;
  int? vmRam;

  String? clusterUrl;
  
  factory VMCharacteristics() {
    return _singleton;
  }

  VMCharacteristics._internal() {
    SharedPreferences.getInstance().then((value) {
      vmCores = value.getInt("VmCores");
      vmRam = value.getInt("VmRam");
      clusterUrl = value.getString("ClusterURL");
    });
    maxCores = Platform.numberOfProcessors;
    maxRam = (SysInfo.getTotalPhysicalMemory() / pow(2, 30)).ceil();

  }

  void updateCPU(int cpuCount) {
      SharedPreferences.getInstance().then((value) async {
        await value.setInt("VmCores", cpuCount);
      });
      vmCores = cpuCount;
  }

  void updateRAM(int ramCount) {
      SharedPreferences.getInstance().then((value) async {
        await value.setInt("VmRam", ramCount);
      });
      vmRam = ramCount;
  }

  void updateClusterURL(String clusterUrl) {
      SharedPreferences.getInstance().then((value) async {
        await value.setString("ClusterURL", clusterUrl);
      });
      this.clusterUrl = clusterUrl;
  }
}
