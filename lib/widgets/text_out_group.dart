import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/button_check.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class TextOutGroup extends StatefulWidget {
  final Map device;

  TextOutGroup(this.device);

  @override
  _TextOutGroupState createState() => _TextOutGroupState();
}

class _TextOutGroupState extends State<TextOutGroup> {
  @override
  Widget build(BuildContext context) {
    String desc = '';
    Color color;
    if (widget.device[ConfigCustom.sharedTextOutbound] == ConfigCustom.yes) {
      desc = 'Outbound working';
      color = ConfigCustom.colorWhite;
    } else if (widget.device[ConfigCustom.sharedTextOutbound] ==
        ConfigCustom.no) {
      desc = 'Outbound not working';
      color = ConfigCustom.colorErrorLight;
    } else {
      desc = 'Outbound not verified';
      color = ConfigCustom.colorVerified;
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
                    MaterialCommunityIcons.message_text,
                    size: 31,
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
                          'SMS Outbound',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: color,
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        TextCustom(
                          desc,
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
                    child: ButtonCheck(
                      widget.device[ConfigCustom.sharedTextOutbound],
                    ),
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
