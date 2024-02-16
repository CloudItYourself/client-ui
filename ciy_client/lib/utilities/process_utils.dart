import 'dart:convert';
import 'dart:io';

bool checkIfProcessOwnedByMe(Map<int, int> processMap, int processId) {
  if (processId == pid) {
    return false;
  }

  var currentProcess = processId;
  var currentParent = -1;
  while (true) {
    if (!processMap.containsKey(currentProcess)) {
      return false;
    }
    currentParent = processMap[currentProcess]!;
    if (currentParent == currentProcess) {
      return false;
    }
    if (currentParent == pid) {
      return true;
    }
    currentProcess = currentParent;
  }
}

void killWindowsChildProcesses() async {
  var result = await Process.run('powershell', [
    'Get-WmiObject Win32_Process | Format-Table Name,ProcessId,ParentProcessId -AutoSize'
  ]);

  List<String> lines = LineSplitter.split(result.stdout).toList();
  var processIdToParentId = <int, int>{};
  for (int i = 3; i < lines.length; i++) {
    String line = lines[i];

    List<String> parts = line.trim().split(RegExp(r'\s{2,}'));

    if (parts.length >= 3) {
      int processId = int.tryParse(parts[1]) ?? -1;
      int parentProcessId = int.tryParse(parts[2]) ?? -1;
      if (processId != -1 && parentProcessId != -1) {
        processIdToParentId[processId] = parentProcessId;
      }
    }
  }
  for (int process in processIdToParentId.keys) {
    if (checkIfProcessOwnedByMe(processIdToParentId, process)) {
      Process.killPid(process);
    }
  }
}
