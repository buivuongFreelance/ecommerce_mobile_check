import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class CheckboxButton extends StatefulWidget {
  final Function onChecked;
  final String message;
  final Widget widget;
  final String value;

  CheckboxButton({
    Key key,
    this.onChecked,
    this.message,
    this.widget,
    this.value,
  }) : super(key: key);
  @override
  _CheckboxButtonState createState() => _CheckboxButtonState();
}

class _CheckboxButtonState extends State<CheckboxButton> {
  String _current = ConfigCustom.no;

  @override
  void initState() {
    if (_current != widget.value) {
      setState(() {
        _current = widget.value;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    _current = widget.value;

    return InkWell(
      onTap: () {
        String c =
            _current == ConfigCustom.yes ? ConfigCustom.no : ConfigCustom.yes;
        setState(() {
          _current = c;
        });
        widget.onChecked(c);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Functions.isEmpty(widget.widget) ? Center() : widget.widget,
          Container(
            width: width / 2.5,
            child: TextCustom(widget.message,
                minFontSize: 20,
                letterSpacing: ConfigCustom.letterSpacing2,
                fontWeight: FontWeight.w900,
                maxLines: 1),
          ),
          /*_current == ConfigCustom.yes
              ? Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 24.0,
                    ),
                  ))
              : Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),*/
        ],
      ),
    );
  }
}
