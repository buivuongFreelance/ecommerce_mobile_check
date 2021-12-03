import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class ButtonReadmore extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color color;
  final Color colorOutline;
  final Function onTap;
  final double fontSize;
  final double borderRadius;

  ButtonReadmore(
    this.message, {
    Key key,
    @required this.onTap,
    this.backgroundColor,
    this.color,
    this.colorOutline,
    this.fontSize = 12,
    this.borderRadius = 0,
  }) : super(key: key);

  @override
  _ButtonReadmoreState createState() => _ButtonReadmoreState();
}

class _ButtonReadmoreState extends State<ButtonReadmore> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.onTap,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius > 0
            ? widget.borderRadius
            : ConfigCustom.borderRadius),
        side: !Functions.isEmpty(widget.colorOutline)
            ? BorderSide(
                color: widget.colorOutline,
              )
            : BorderSide.none,
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: Functions.isEmpty(widget.backgroundColor)
              ? ConfigCustom.colorPrimary2
              : widget.backgroundColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(ConfigCustom.borderRadius / 2),
            topLeft: Radius.circular(widget.borderRadius > 0
                ? widget.borderRadius
                : ConfigCustom.borderRadius2),
          ),
        ),
        child: Container(
          constraints: BoxConstraints(minHeight: ConfigCustom.heightWidget),
          // alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextCustom(
                widget.message.toUpperCase(),
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w900,
                fontSize: widget.fontSize,
                color: Functions.isEmpty(widget.color)
                    ? ConfigCustom.colorWhite
                    : widget.color,
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.info_outline,
                  color: ConfigCustom.colorWhite,
                  size: 19,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
