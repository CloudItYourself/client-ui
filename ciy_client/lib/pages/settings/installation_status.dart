import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class InstallationStatusPage extends StatefulWidget {
  @override
  State<InstallationStatusPage> createState() => _InstallationStatusPageState();
}

class _InstallationStatusPageState extends State<InstallationStatusPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          DirectoryPicker()
        ]),
      ),
    );
  }
}


class DirectoryPicker extends StatefulWidget {
  @override
  State<DirectoryPicker> createState() => _DirectoryPickerState();
}

class _DirectoryPickerState extends State<DirectoryPicker> {
  String? _directoryPath;

  Future<void> _pickDirectory() async {
    try {
      // Pick a directory using the file picker
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        // Update the state with the picked directory path
        setState(() {
          _directoryPath = result;
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 500,
          child: TextField(
            controller: TextEditingController(text: _directoryPath ?? ''),
            enabled: false, // Disable editing of the text field
            decoration: InputDecoration(
              labelText: 'VM directory',
              hintText: 'No directory selected yet',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ElevatedButton(
            onPressed: _pickDirectory,
            child: Text('Browse'),
          ),
        ),
      ],
    );
  }
}

class QemuInstalled extends StatefulWidget {
  @override
  State<QemuInstalled> createState() => _QemuInstalledState();
}

class _QemuInstalledState extends State<QemuInstalled> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          DirectoryPicker()
        ]),
      ),
    );
  }
}
