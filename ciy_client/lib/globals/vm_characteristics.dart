import 'dart:io';
import 'dart:math';

import 'package:system_info/system_info.dart';

class VMCharacteristics {
  static final VMCharacteristics _singleton = VMCharacteristics._internal();
  int? maxCores;
  int? maxRam;

  int? vmCores;
  int? vmRam;

  factory VMCharacteristics() {
    return _singleton;
  }

  VMCharacteristics._internal() {
    maxCores = Platform.numberOfProcessors;
    maxRam = (SysInfo.getTotalPhysicalMemory() / pow(2, 30)).ceil();
  }
}
