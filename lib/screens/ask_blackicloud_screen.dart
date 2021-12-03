import 'dart:io';

import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/ask_phone_voice.dart';
import 'package:dingtoimc/screens/imei_form_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/checkbox_button.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AskingBlacklistIcloudScreen extends StatefulWidget {
  static const routeName = '/ask-blacklist-icloud';

  @override
  _AskingBlacklistIcloudScreenState createState() =>
      _AskingBlacklistIcloudScreenState();
}

class _AskingBlacklistIcloudScreenState
    extends State<AskingBlacklistIcloudScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String blacklist = ConfigCustom.no;

  Future _init() async {
    if (!await User.auth(context)) return;
    await User.checkUserIsScanning(context);

    String _blacklist = ConfigCustom.yes;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedBacklist)) {
      _blacklist = prefs.get(ConfigCustom.sharedBacklist);
    }

    setState(() {
      blacklist = _blacklist;
    });
  }

  Future _next() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(ConfigCustom.sharedBacklist, blacklist);
    if (blacklist == ConfigCustom.yes)
      Navigator.of(context).pushNamedAndRemoveUntil(
          ImeiFormScreen.routeName, (Route<dynamic> route) => false);
    else {
      await prefs.setInt(ConfigCustom.sharedStep, 3);
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingPhoneVoiceScreen.routeName, (Route<dynamic> route) => false);
    }
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
        TextCustom(
          'Check Blacklist',
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      _drawerKey.currentState.openDrawer();
    });

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: Container(
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
                Container(
                  child: Center(
                    child: Container(
                      width: width - ConfigCustom.globalPadding * 3,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            TimerCustom(
                              widget: false,
                            ),
                            TextCustom(
                              "Please select options to check",
                              fontSize: 20,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 55),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: CheckboxButton(
                                    message: "BLACKLIST",
                                    onChecked: (str) {
                                      setState(() {
                                        blacklist = str;
                                      });
                                    },
                                    value: blacklist,
                                    widget: Container(
                                      width: width / 4,
                                      padding: EdgeInsets.only(right: 10),
                                      child: Platform.isAndroid
                                          ? Image.asset(
                                              'assets/app/com_blacklist.png',
                                              fit: BoxFit.contain,
                                            )
                                          : Center(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 50),
                            Container(
                              width: width / 2,
                              child: ButtonCustom(
                                'NEXT',
                                onTap: () {
                                  _next();
                                },
                              ),
                            ),
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
