import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpecificDivisionsSlider<EventClass extends Object, BlocType extends Bloc>
    extends StatefulWidget {
  final String sliderHeader;
  final int min;
  final int max;
  final int step;
  final EventClass Function(int) creator;
  final int? initialValue;

  SpecificDivisionsSlider(
      this.sliderHeader, this.min, this.max, this.step, this.creator,
      this.initialValue);

  @override
  _SpecificDivisionsSliderState createState() =>
      _SpecificDivisionsSliderState<EventClass, BlocType>();
}

class _SpecificDivisionsSliderState<EventClass extends Object,
    BlocType extends Bloc> extends State<SpecificDivisionsSlider> {

  
  int _sliderValue = -1;

  int _mapValueToCustomDivision(int value) {
    List<int> customDivisions = List<int>.generate(
      ((widget.max - widget.min) / widget.step)
          .ceil(), // Calculates the length of the list based on the step size
      (index) =>
          widget.min +
          index *
              widget
                  .step, // Generator function that calculates the value for each element
    );
    customDivisions.add(widget.max);
    int index = customDivisions.indexWhere((element) => element >= value);
    if (index == -1) {
      return customDivisions.last;
    } else {
      return customDivisions[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sliderValue == -1) {
      if (widget.initialValue != null) {
        _sliderValue = widget.initialValue!;
      }
    }
    if (_sliderValue < widget.min) {
      _sliderValue = widget.min;
    }
    return Column(
      children: <Widget>[
        Text(
            '${widget.sliderHeader}: ${_mapValueToCustomDivision(_sliderValue)}'),
        Slider(
          value: _sliderValue.toDouble(),
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          divisions: ((widget.max - widget.min) / widget.step)
              .truncate(), // Total number of divisions including custom ones
          label: _mapValueToCustomDivision(_sliderValue).toString(),
          onChanged: (double value) {
            setState(() {
              _sliderValue = value.toInt();
              BlocProvider.of<BlocType>(context).add(widget.creator(_sliderValue));
            });
          },
        ),
      ],
    );
  }
}
