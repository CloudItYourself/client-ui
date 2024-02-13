import 'dart:math';

import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/widgets/divisions_slider.dart';
import 'package:flutter/material.dart';
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
