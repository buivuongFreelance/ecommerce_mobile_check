import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Notify extends StatefulWidget {
  final String message;
  final String type;
  final Function onTap;

  Notify({
    this.message = '',
    this.type = 'success',
    this.onTap,
  });

  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    IconData lineIcons = SimpleLineIcons.check;
    Color color = ConfigCustom.colorSuccess;
    if (widget.type == 'error') {
      lineIcons = Icons.error;
      color = ConfigCustom.colorErrorLight;
    }

    return Container(
        padding: EdgeInsets.only(
          right: ConfigCustom.globalPadding,
          left: ConfigCustom.globalPadding,
        ),
        decoration: new BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (!Functions.isEmpty(widget.onTap)) widget.onTap();
              },
              child: Container(
                  padding: EdgeInsets.only(
                    top: ConfigCustom.globalPadding,
                    bottom: ConfigCustom.globalPadding,
                  ),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    SimpleLineIcons.close,
                    color: ConfigCustom.colorWhite,
                  )),
            ),
            SpaceCustom(),
            RawMaterialButton(
              onPressed: () {},
              elevation: 0.0,
              fillColor: ConfigCustom.colorWhite,
              child: Icon(
                lineIcons,
                size: 50,
                color: color,
              ),
              padding: EdgeInsets.all(ConfigCustom.globalPadding / 2),
              shape: CircleBorder(),
            ),
            SpaceCustom(),
            TextCustom(
              widget.message,
              color: ConfigCustom.colorWhite,
              fontSize: 20,
              textAlign: TextAlign.center,
            ),
            SpaceCustom(),
            SpaceCustom(),
            ButtonCustom(
              'OK',
              backgroundColor: ConfigCustom.colorWhite,
              color: ConfigCustom.colorPrimary,
              onTap: () {
                Navigator.pop(context);
                if (!Functions.isEmpty(widget.onTap)) widget.onTap();
              },
            ),
            SpaceCustom(),
            SpaceCustom(),
          ],
        ));
  }
}
