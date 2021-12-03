import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class ButtonCustomBlue extends StatefulWidget {
  final String message;
  final Function onTap;

  ButtonCustomBlue(
    this.message, {
    Key key,
    @required this.onTap,
  }) : super(key: key);

  @override
  _ButtonCustomBlueState createState() => _ButtonCustomBlueState();
}

class _ButtonCustomBlueState extends State<ButtonCustomBlue> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.onTap,
      padding: const EdgeInsets.all(0.0),
      child: Ink(
        decoration: BoxDecoration(
          color: ConfigCustom.colorPrimary,
          borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
        ),
        child: Container(
          constraints: BoxConstraints(minHeight: ConfigCustom.heightWidget),
          alignment: Alignment.center,
          child: TextCustom(
            widget.message.toUpperCase(),
            textAlign: TextAlign.center,
            letterSpacing: ConfigCustom.letterSpacing,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
