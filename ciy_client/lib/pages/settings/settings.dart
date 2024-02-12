import 'dart:io';
import 'dart:math';
import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:flutter/material.dart';
import 'package:ciy_client/utilities/divisions_slider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cpu = CPUSlider();
    var ram = RAMSlider();
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            cpu,
            ram,
            ElevatedButton(
            onPressed: () {
              VMCharacteristics().saveParameters();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.check),
              Text('Save'),]
            )
          )],
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
  final String header = "Cores";
  int? minCores;
  int? maxCores;
  SpecificDivisionsSlider? slider;
  final int increment = 1;

  _CPUSliderState() {
    maxCores = VMCharacteristics().maxCores;
    minCores = min(2, Platform.numberOfProcessors);
    slider = SpecificDivisionsSlider(header, minCores!, maxCores!, increment, notifiable: updateCPU, initialValue: VMCharacteristics().vmCores);
  }

  void updateCPU(int value) {
    VMCharacteristics().tempCores = value;
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
  final String header = "Memory(GB)";
  int? minRam;
  int? maxRam;
  SpecificDivisionsSlider? slider;
  final int increment = 1;

  _RAMSliderState() {
    maxRam = VMCharacteristics().maxRam;
    minRam = min(2, maxRam!);
    slider = SpecificDivisionsSlider(header, minRam!, maxRam!, increment, notifiable: updateMemory, initialValue: VMCharacteristics().vmRam);

  }

  void updateMemory(int value) {
    VMCharacteristics().tempRam = value;
  }

  @override
  Widget build(BuildContext context) {
    return slider!;
  }
}
