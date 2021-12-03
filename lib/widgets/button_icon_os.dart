import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class ButtonWithIconOS extends StatefulWidget {
  final String message;
  final String icon;
  final String store;
  final Function onTap;

  ButtonWithIconOS(
    this.icon,
    this.message,
    this.store, {
    Key key,
    @required this.onTap,
  }) : super(key: key);

  @override
  _ButtonWithIconState createState() => _ButtonWithIconState();
}

class _ButtonWithIconState extends State<ButtonWithIconOS> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return FlatButton(
      onPressed: widget.onTap,
      padding: const EdgeInsets.all(0.0),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ConfigCustom.borderRadius * 2),
        ),
        child: Container(
            padding: const EdgeInsets.fromLTRB(
              30.0,
              10.0,
              30.0,
              10.0,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 30,
                  child: Image.asset(
                    widget.icon,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  width: width / 2.4,
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextCustom(
                          widget.message,
                          color: ConfigCustom.colorText,
                          fontWeight: FontWeight.bold,
                        ),
                        TextCustom(
                          widget.store,
                          fontSize: 20,
                          color: ConfigCustom.colorText,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                        ),
                      ]),
                ),
              ],
            )),
      ),
    );
  }
}
