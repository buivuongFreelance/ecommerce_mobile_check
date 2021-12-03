import 'package:dingtoimc/helpers/functions.dart';
import 'package:flutter/material.dart';

class WalkThrough extends StatelessWidget {
  final String textContent;
  final double height;

  WalkThrough({
    Key key,
    @required this.textContent,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SizedBox(
          child: Stack(
        children: <Widget>[
          SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: Functions.isEmpty(height)
                  ? (MediaQuery.of(context).size.height) / 1.7
                  : height / 1.7,
              alignment: Alignment.center,
              child: Image.asset(
                textContent,
                width: 300,
                height: Functions.isEmpty(height)
                    ? (MediaQuery.of(context).size.height) / 2.5
                    : height / 2.5,
              ),
            ),
          ),
        ],
      )),
    );
  }
}
