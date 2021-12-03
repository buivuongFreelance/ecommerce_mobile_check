import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class ButtonIcon extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color color;
  final Color colorOutline;
  final Function onTap;

  ButtonIcon(
    this.message, {
    Key key,
    @required this.onTap,
    this.backgroundColor,
    this.color,
    this.colorOutline,
  }) : super(key: key);

  @override
  _ButtonIconState createState() => _ButtonIconState();
}

class _ButtonIconState extends State<ButtonIcon> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.onTap,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ConfigCustom.borderRadius / 2),
        side: !Functions.isEmpty(widget.colorOutline)
            ? BorderSide(
                color: widget.colorOutline,
              )
            : BorderSide.none,
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: Functions.isEmpty(widget.backgroundColor)
              ? ConfigCustom.colorPrimary
              : widget.backgroundColor,
          borderRadius: BorderRadius.circular(ConfigCustom.borderRadius / 2),
        ),
        child: Container(
          constraints: BoxConstraints(minHeight: ConfigCustom.heightWidget),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Center(),
              ),
              Expanded(
                flex: 3,
                child: TextCustom(
                  widget.message.toUpperCase(),
                  textAlign: TextAlign.center,
                  letterSpacing: ConfigCustom.letterSpacing,
                  fontWeight: FontWeight.w900,
                  color: Functions.isEmpty(widget.color)
                      ? ConfigCustom.colorWhite
                      : widget.color,
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                    height: 45,
                    child: Icon(
                      Icons.arrow_forward,
                      size: 25,
                      color: Functions.isEmpty(widget.color)
                          ? ConfigCustom.colorWhite
                          : widget.color,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
