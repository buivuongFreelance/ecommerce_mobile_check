import 'package:dingtoimc/helpers/config.dart';
import 'package:flutter/material.dart';

class ButtonTransparent extends StatefulWidget {
  final String text;
  final Function onTap;

  ButtonTransparent(this.text, this.onTap);

  @override
  _ButtonTransparentState createState() => _ButtonTransparentState();
}

class _ButtonTransparentState extends State<ButtonTransparent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ConfigCustom.heightButton,
      child: FlatButton(
        onPressed: () {
          this.widget.onTap();
        },
        shape: RoundedRectangleBorder(
            //borderRadius: BorderRadius.circular(35.5),
            ),
        textColor: Colors.black,
        padding: const EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
            color: ConfigCustom.colorSecondary.withOpacity(0.2),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              minHeight: ConfigCustom.heightButton,
            ),
            alignment: Alignment.center,
            child: Text(
              this.widget.text.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: ConfigCustom.letterSpacing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
