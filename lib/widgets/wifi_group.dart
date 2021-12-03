import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/button_check.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class WifiGroup extends StatefulWidget {
  final Map device;

  WifiGroup(this.device);

  @override
  _WifiGroupState createState() => _WifiGroupState();
}

class _WifiGroupState extends State<WifiGroup> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          ConfigCustom.globalPadding, 0, ConfigCustom.globalPadding, 0),
      child: Container(
        height: ConfigCustom.heightBoxScan,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ConfigCustom.borderRadius4),
          color: widget.device[ConfigCustom.sharedPointWifi] == ConfigCustom.yes
              ? ConfigCustom.colorWhite.withOpacity(0.3)
              : ConfigCustom.colorErrorLight.withOpacity(0.3),
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
                    Ionicons.ios_wifi,
                    size: 31,
                    color: widget.device[ConfigCustom.sharedPointWifi] ==
                            ConfigCustom.yes
                        ? ConfigCustom.colorWhite
                        : ConfigCustom.colorErrorLight,
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 0, 5.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextCustom('Wifi',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color:
                                widget.device[ConfigCustom.sharedPointWifi] ==
                                        ConfigCustom.yes
                                    ? ConfigCustom.colorWhite
                                    : ConfigCustom.colorErrorLight),
                        SizedBox(
                          height: 3,
                        ),
                        TextCustom(
                          widget.device[ConfigCustom.sharedPointWifi] ==
                                  ConfigCustom.yes
                              ? 'Wifi working'
                              : 'Wifi not working',
                          fontSize: 13,
                          color: widget.device[ConfigCustom.sharedPointWifi] ==
                                  ConfigCustom.yes
                              ? ConfigCustom.colorWhite
                              : ConfigCustom.colorErrorLight,
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: ConfigCustom.globalPadding),
                  child: Center(
                    child: widget.device[ConfigCustom.sharedPointWifi] ==
                            ConfigCustom.yes
                        ? ButtonCheck('yes')
                        : ButtonCheck('no'),
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
