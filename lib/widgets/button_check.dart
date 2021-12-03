import 'package:dingtoimc/helpers/config.dart';
import 'package:flutter/material.dart';

class ButtonCheck extends StatefulWidget {
  final String type;

  ButtonCheck(
    this.type, {
    Key key,
  }) : super(key: key);

  @override
  _ButtonCheckState createState() => _ButtonCheckState();
}

class _ButtonCheckState extends State<ButtonCheck> {
  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    if (widget.type == 'yes' || widget.type == ConfigCustom.yes) {
      color = ConfigCustom.colorSuccess1;
      icon = Icons.check;
    } else if (widget.type == 'no' || widget.type == ConfigCustom.no) {
      color = ConfigCustom.colorErrorLight;
      icon = Icons.clear;
    } else {
      color = ConfigCustom.colorVerified;
      icon = Icons.warning;
    }

    return ClipOval(
      child: Material(
        color: color,
        child: Ink(
          child: SizedBox(
              width: 20,
              height: 20,
              child: Icon(
                icon,
                size: 15,
                color: ConfigCustom.colorWhite,
              )),
        ),
      ),
    );
  }
}
