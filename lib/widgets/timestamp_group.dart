import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class TimestampGroup extends StatefulWidget {
  final Map device;

  TimestampGroup(this.device);

  @override
  _TimestampGroupState createState() => _TimestampGroupState();
}

class _TimestampGroupState extends State<TimestampGroup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: TextCustom(
            Functions.getDateTime(widget.device[ConfigCustom.sharedTimestamp])),
      ),
    );
  }
}
