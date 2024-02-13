import 'package:flutter/material.dart';

class ClusterURLWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 250,
        child: TextField(
          controller: TextEditingController(text: ''),
          decoration: InputDecoration(
            labelText: 'Cluster URL',
            hintText: 'examle.cloud-iy.com',
          ),
        ),
      ),
    );
  }
}
