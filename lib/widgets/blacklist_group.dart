import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/button_check.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class BlacklistGroup extends StatefulWidget {
  final Map device;

  BlacklistGroup(this.device);

  @override
  _BlacklistGroupState createState() => _BlacklistGroupState();
}

class _BlacklistGroupState extends State<BlacklistGroup> {
  @override
  Widget build(BuildContext context) {
    Color color;
    Widget buttonChecked = Center();
    if (widget.device[ConfigCustom.sharedBlacklistType] ==
        ConfigCustom.notVerified) {
      color = ConfigCustom.colorVerified;
      buttonChecked = ButtonCheck(ConfigCustom.notVerified);
    } else if (widget.device[ConfigCustom.sharedBlacklistType] ==
        ConfigCustom.error) {
      color = ConfigCustom.colorErrorLight;
      buttonChecked = ButtonCheck('no');
    } else {
      color = ConfigCustom.colorWhite;
      buttonChecked = ButtonCheck('yes');
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
          ConfigCustom.globalPadding, 0, ConfigCustom.globalPadding, 0),
      child: Container(
        height: ConfigCustom.heightBoxScan,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ConfigCustom.borderRadius4),
          color: color.withOpacity(0.3),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: ConfigCustom.heightBoxScan,
                  decoration: BoxDecoration(
                    color: ConfigCustom.colorWhite.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ConfigCustom.borderRadius4),
                      bottomLeft: Radius.circular(ConfigCustom.borderRadius4),
                    ),
                  ),
                  child: Icon(
                    MaterialCommunityIcons.cellphone_erase,
                    size: 33,
                    color: color,
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 0, 5.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextCustom(
                          'Blacklist',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: color,
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        TextCustom(
                          'Status: ${widget.device[ConfigCustom.sharedBlacklistStatus]}',
                          fontSize: 13,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: ConfigCustom.globalPadding),
                  child: Center(
                    child: buttonChecked,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
