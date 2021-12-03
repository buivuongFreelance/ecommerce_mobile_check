import 'package:flutter/material.dart';

class ButtonGradientLoading extends StatelessWidget {
  final double width;

  ButtonGradientLoading(this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40.0,
      child: FlatButton(
        onPressed: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.5),
        ),
        textColor: Colors.white,
        padding: const EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xFF303A96),
                Color(0xFF242E88),
              ],
            ),
            borderRadius: BorderRadius.circular(35.5),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: width, minHeight: 40.0),
            alignment: Alignment.center,
            child: Center(
              child: Container(
                height: 20,
                width: 20,
                margin: EdgeInsets.all(5),
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
