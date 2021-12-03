import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/imei_form_screen.dart';
import 'package:dingtoimc/widgets/button_custom_arrow.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AutoPhoneVoiceManualScreen extends StatefulWidget {
  static const routeName = '/auto-phone-voice';

  @override
  _AutoPhoneVoiceManualScreenState createState() =>
      _AutoPhoneVoiceManualScreenState();
}

class _AutoPhoneVoiceManualScreenState
    extends State<AutoPhoneVoiceManualScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool _isLoading = false;
  bool _isPhone = false;
  bool _isText = false;

  Future _init() async {
    setState(() {
      _isLoading = true;
    });
    if (!await User.auth(context)) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(ConfigCustom.sharedVoice)) {
      if (prefs.get(ConfigCustom.sharedVoice) == ConfigCustom.yes) {
        setState(() {
          _isPhone = true;
        });
      }
    }

    if (prefs.containsKey(ConfigCustom.sharedText)) {
      if (prefs.get(ConfigCustom.sharedText) == ConfigCustom.yes) {
        setState(() {
          _isText = true;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future _checkAuto() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(ConfigCustom.sharedVoice)) {
      if (prefs.get(ConfigCustom.sharedVoice) == ConfigCustom.yes) {
        const url = 'tel:0906603187';
        if (await canLaunch(url)) {
          await prefs.setString(
              ConfigCustom.sharedVoiceInbound, ConfigCustom.yes);
          await prefs.setString(
              ConfigCustom.sharedVoiceOutbound, ConfigCustom.yes);
        } else {
          await prefs.setString(
              ConfigCustom.sharedVoiceInbound, ConfigCustom.no);
          await prefs.setString(
              ConfigCustom.sharedVoiceOutbound, ConfigCustom.no);
        }
      }
    }

    if (prefs.containsKey(ConfigCustom.sharedText)) {
      if (prefs.get(ConfigCustom.sharedText) == ConfigCustom.yes) {
        const url = 'sms:0906603187';
        if (await canLaunch(url)) {
          await prefs.setString(
              ConfigCustom.sharedTextInbound, ConfigCustom.yes);
          await prefs.setString(
              ConfigCustom.sharedTextOutbound, ConfigCustom.yes);
        } else {
          await prefs.setString(
              ConfigCustom.sharedTextInbound, ConfigCustom.no);
          await prefs.setString(
              ConfigCustom.sharedTextOutbound, ConfigCustom.no);
        }
      }
    }
    await prefs.setInt(ConfigCustom.sharedStep, 3);

    Functions.goToRoute(context, ImeiFormScreen.routeName);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    PreferredSize appBar = Functions.getAppbarScanner(
      context,
      Expanded(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextCustom(
              'Check Voice / SMS',
              maxLines: 1,
              fontWeight: FontWeight.w900,
              textAlign: TextAlign.center,
              fontSize: 16,
              letterSpacing: ConfigCustom.letterSpacing2,
            ),
            TimerCustom(
              widget: true,
            ),
          ],
        ),
      ),
      () {
        _drawerKey.currentState.openDrawer();
      },
    );

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: _isLoading
          ? Loading()
          : Container(
              decoration: BoxDecoration(
                gradient: ConfigCustom.colorBgBlendBottom,
              ),
              child: Scaffold(
                appBar: appBar,
                backgroundColor: Colors.transparent,
                key: _drawerKey,
                drawer: DrawerScan(),
                body: GestureClickOutside(
                  child: Stack(
                    children: <Widget>[
                      TimerCustom(
                        widget: false,
                      ),
                      Container(
                        child: Center(
                          child: Container(
                            width: width - ConfigCustom.globalPadding * 2,
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  !_isPhone
                                      ? Center()
                                      : Container(
                                          padding: EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                              color: ConfigCustom.colorWhite
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ConfigCustom
                                                              .borderRadius /
                                                          2)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: width / 5.5,
                                                height: width / 5.5,
                                                decoration: BoxDecoration(
                                                  color: ConfigCustom.colorWhite
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        ConfigCustom
                                                            .borderRadius4),
                                                    bottomLeft: Radius.circular(
                                                        ConfigCustom
                                                            .borderRadius4),
                                                  ),
                                                ),
                                                child: Icon(
                                                  MaterialCommunityIcons
                                                      .phone_incoming,
                                                  size: 31,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              TextCustom(
                                                'Voice Inbound',
                                                fontSize: 20,
                                              ),
                                              Icon(
                                                Ionicons.ios_checkmark_circle,
                                                color:
                                                    ConfigCustom.colorSuccess1,
                                                size: 30,
                                              ),
                                            ],
                                          ),
                                        ),
                                  !_isPhone ? Center() : SpaceCustom(),
                                  !_isPhone
                                      ? Center()
                                      : Container(
                                          padding: EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                              color: ConfigCustom.colorWhite
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ConfigCustom
                                                              .borderRadius /
                                                          2)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: width / 5.5,
                                                height: width / 5.5,
                                                decoration: BoxDecoration(
                                                  color: ConfigCustom.colorWhite
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        ConfigCustom
                                                            .borderRadius4),
                                                    bottomLeft: Radius.circular(
                                                        ConfigCustom
                                                            .borderRadius4),
                                                  ),
                                                ),
                                                child: Icon(
                                                  MaterialCommunityIcons
                                                      .phone_outgoing,
                                                  size: 31,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              TextCustom(
                                                'Voice Outbound',
                                                fontSize: 20,
                                              ),
                                              Icon(
                                                Ionicons.ios_checkmark_circle,
                                                color:
                                                    ConfigCustom.colorSuccess1,
                                                size: 30,
                                              ),
                                            ],
                                          ),
                                        ),
                                  !_isPhone ? Center() : SpaceCustom(),
                                  !_isText
                                      ? Center()
                                      : Container(
                                          padding: EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                              color: ConfigCustom.colorWhite
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ConfigCustom
                                                              .borderRadius /
                                                          2)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: width / 5.5,
                                                height: width / 5.5,
                                                decoration: BoxDecoration(
                                                  color: ConfigCustom.colorWhite
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        ConfigCustom
                                                            .borderRadius4),
                                                    bottomLeft: Radius.circular(
                                                        ConfigCustom
                                                            .borderRadius4),
                                                  ),
                                                ),
                                                child: Icon(
                                                  MaterialCommunityIcons
                                                      .message_reply_text,
                                                  size: 31,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              TextCustom(
                                                'SMS Inbound',
                                                fontSize: 20,
                                              ),
                                              Icon(
                                                Ionicons.ios_checkmark_circle,
                                                color:
                                                    ConfigCustom.colorSuccess1,
                                                size: 30,
                                              ),
                                            ],
                                          ),
                                        ),
                                  !_isText ? Center() : SpaceCustom(),
                                  !_isText
                                      ? Center()
                                      : Container(
                                          padding: EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                              color: ConfigCustom.colorWhite
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ConfigCustom
                                                              .borderRadius /
                                                          2)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: width / 5.5,
                                                height: width / 5.5,
                                                decoration: BoxDecoration(
                                                  color: ConfigCustom.colorWhite
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        ConfigCustom
                                                            .borderRadius4),
                                                    bottomLeft: Radius.circular(
                                                        ConfigCustom
                                                            .borderRadius4),
                                                  ),
                                                ),
                                                child: Icon(
                                                  MaterialCommunityIcons
                                                      .message_text,
                                                  size: 31,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              TextCustom(
                                                'SMS Outbound',
                                                fontSize: 20,
                                              ),
                                              Icon(
                                                Ionicons.ios_checkmark_circle,
                                                color:
                                                    ConfigCustom.colorSuccess1,
                                                size: 30,
                                              ),
                                            ],
                                          ),
                                        ),
                                  !_isText ? Center() : SpaceCustom(),
                                  SpaceCustom(),
                                  SpaceCustom(),
                                  ButtonCustomArrow('Check Blacklist',
                                      onTap: () {
                                    _checkAuto();
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
