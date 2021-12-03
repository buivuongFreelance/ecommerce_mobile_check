import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class ButtonSmallCustom extends StatefulWidget {
  final String message;
  final Function onTap;
  final Color color;

  ButtonSmallCustom(
    this.message, {
    Key key,
    @required this.onTap,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  _ButtonSmallCustomState createState() => _ButtonSmallCustomState();
}

class _ButtonSmallCustomState extends State<ButtonSmallCustom> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.onTap,
      padding: const EdgeInsets.all(0.0),
      child: Ink(
        decoration: BoxDecoration(
          color: ConfigCustom.colorWhite,
          borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
        ),
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
          ),
          constraints: BoxConstraints(minHeight: ConfigCustom.heightWidget),
          alignment: Alignment.center,
          child: TextCustom(
            widget.message.toUpperCase(),
            textAlign: TextAlign.center,
            letterSpacing: ConfigCustom.letterSpacing,
            fontWeight: FontWeight.w600,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
