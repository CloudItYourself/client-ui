import 'package:flutter/material.dart';

class InstallationStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Row(
              children: [
                Text("Virtualization "),
                Icon(Icons.check),
              ],
            ),
            Row(
              children: [
                Text("Backend        "),
                Icon(Icons.error),
              ],
            ),
            Row(
              children: [
                Text("VM                "),
                Icon(Icons.check),
              ],
            )
          ],
        ));
  }
}
