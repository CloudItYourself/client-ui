import 'dart:io';
import 'dart:math';

import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/divisions_slider.dart';
import 'package:flutter/material.dart';

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
