
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SpecificDivisionsSlider("XD"),
              SpecificDivisionsSlider("XP"),
              SpecificDivisionsSlider("WTF"),
            ],
          ),
    );
  }
}

class SpecificDivisionsSlider extends StatefulWidget {
  final String sliderHeader;
  SpecificDivisionsSlider(this.sliderHeader);

  @override
  _SpecificDivisionsSliderState createState() => _SpecificDivisionsSliderState();
}

class _SpecificDivisionsSliderState extends State<SpecificDivisionsSlider> {
  double _sliderValue =  0;
  List<double> _customDivisions = [0.5,  1,  2,  3,  4,  5,  10,  15];

  double _mapValueToCustomDivision(double value) {
    int index = _customDivisions.indexWhere((element) => element >= value);
    if (index == -1) {
      return _customDivisions.last;
    } else {
      return _customDivisions[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('${widget.sliderHeader}: ${_mapValueToCustomDivision(_sliderValue)}'),
        Slider(
          value: _sliderValue,
          min:  0,
          max:  15,
          divisions:  15, // Total number of divisions including custom ones
          label: _mapValueToCustomDivision(_sliderValue).toString(),
          onChanged: (double value) {
            setState(() {
              _sliderValue = value;
            });
          },
        ),
      ],
    );
  }
}
