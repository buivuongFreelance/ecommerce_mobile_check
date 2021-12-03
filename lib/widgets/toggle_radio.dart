import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class ToggleRadio extends StatefulWidget {
  final String value;
  final String activeValue;
  final String title;
  final Function onToggle;

  ToggleRadio({
    Key key,
    @required this.value,
    @required this.activeValue,
    this.title,
    this.onToggle,
  }) : super(key: key);

  @override
  _ToggleRadioState createState() => _ToggleRadioState();
}

class _ToggleRadioState extends State<ToggleRadio>
    with AutomaticKeepAliveClientMixin<ToggleRadio> {
  int current;

  @override
  void initState() {
    if (widget.value == widget.activeValue)
      current = 0;
    else
      current = 1;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;
    if (widget.value == widget.activeValue)
      current = 0;
    else
      current = 1;

    return InkWell(
      onTap: () {
        widget.onToggle(widget.value);
      },
      child: Container(
          width: width - ConfigCustom.globalPadding * 4,
          height: 40.0,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              color: widget.activeValue == widget.value
                  ? ConfigCustom.colorWhite
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(ConfigCustom.borderRadius)),
          child: Center(
            child: TextCustom(
              widget.title,
              color: widget.activeValue == widget.value
                  ? ConfigCustom.colorPrimary
                  : ConfigCustom.colorWhite,
              textAlign: TextAlign.left,
              fontWeight: FontWeight.w600,
            ),
          )),
    );
  }
}
