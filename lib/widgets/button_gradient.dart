import 'package:dingtoimc/helpers/config.dart';
import 'package:flutter/material.dart';

class ButtonGradient extends StatelessWidget {
  final String message;
  final double width;
  final Function onPressed;

  ButtonGradient(this.message, this.width, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40.0,
      child: FlatButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(),
        textColor: Colors.white,
        padding: const EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
            color: ConfigCustom.colorPrimary,
            //borderRadius: BorderRadius.circular(35.5),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 200, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              message.toUpperCase(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
