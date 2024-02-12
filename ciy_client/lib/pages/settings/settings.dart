import 'dart:io';
import 'dart:math';
import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:flutter/material.dart';
import 'package:ciy_client/utilities/divisions_slider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ← Add this.
    return Card(
      color: theme.colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CPUSlider(),
            RAMSlider(),
          ],
        ),
      ),
    );
  }
}

class CPUSlider extends StatefulWidget {
  @override
  State<CPUSlider> createState() => _CPUSliderState();
}

class _CPUSliderState extends State<CPUSlider> {
  final String header = "VM Core count";
  int? minCores;
  int? maxCores;
  SpecificDivisionsSlider? slider;
  final int increment = 1;

  _CPUSliderState() {
    maxCores = VMCharacteristics().maxCores;
    minCores = min(2, Platform.numberOfProcessors);
    slider = SpecificDivisionsSlider(header, minCores!, maxCores!, increment, notifiable: updateCPU);
  }
  void updateCPU(int value) {
    VMCharacteristics().vmCores = value;
  }

  @override
  Widget build(BuildContext context) {
    return slider!;
  }
}


class RAMSlider extends StatefulWidget {
  @override
  State<RAMSlider> createState() => _RAMSliderState();
}

class _RAMSliderState extends State<RAMSlider> {
  final String header = "VM Memory (GB)";
  int? minRam;
  int? maxRam;
  SpecificDivisionsSlider? slider;
  final int increment = 1;

  _RAMSliderState() {
    maxRam = VMCharacteristics().maxRam;
    minRam = min(2, maxRam!);
    slider = SpecificDivisionsSlider(header, minRam!, maxRam!, increment, notifiable: updateMemory);
  }

  void updateMemory(int value) {
    VMCharacteristics().vmRam = value;
  }
  @override
  Widget build(BuildContext context) {
    return slider!;
  }
}
