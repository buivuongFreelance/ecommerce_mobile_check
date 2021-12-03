import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/ask_phone_voice.dart';
import 'package:dingtoimc/screens/auto_phone_voice_screen.dart';
import 'package:dingtoimc/screens/welcome_phone_screen.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AskingPhoneVoiceManualScreen extends StatefulWidget {
  static const routeName = '/ask-phone-voice-manual';

  @override
  _AskingPhoneVoiceManualScreenState createState() =>
      _AskingPhoneVoiceManualScreenState();
}

class _AskingPhoneVoiceManualScreenState
    extends State<AskingPhoneVoiceManualScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool _isLoading = false;

  Future _init() async {
    if (!await User.auth(context)) return;
    await User.checkUserIsScanning(context);
    await Device.checkUserAnonymous(context);
    await Device.checkScannerBasic(context);
  }

  Future _checkAuto() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(ConfigCustom.sharedPhoneType, ConfigCustom.auto);

    Navigator.of(context).pushNamedAndRemoveUntil(
        AutoPhoneVoiceManualScreen.routeName, (Route<dynamic> route) => false);
    setState(() {
      _isLoading = false;
    });
  }

  Future _checkManual() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(ConfigCustom.sharedPhoneType, ConfigCustom.manual);

    Navigator.of(context).pushNamedAndRemoveUntil(
        WelcomePhoneScreen.routeName, (Route<dynamic> route) => false);
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
    double widthOption = (width - ConfigCustom.globalPadding * 3) / 2;
    PreferredSize appBar = Functions.getAppbarMainBack(
        context,
        TextCustom(
          'Check Voice / SMS',
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      _drawerKey.currentState.openDrawer();
    }, () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingPhoneVoiceScreen.routeName, (Route<dynamic> route) => false);
    });

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
                                  TextCustom(
                                    "CHECK VOICE / SMS",
                                    fontSize: 20,
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                  ),
                                  SizedBox(height: 8),
                                  TextCustom(
                                    "Please select option to check",
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 55),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          _checkAuto();
                                        },
                                        child: Container(
                                          width: widthOption,
                                          height: widthOption,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ConfigCustom
                                                          .borderRadius),
                                              color:
                                                  ConfigCustom.colorPrimary2),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              SizedBox(
                                                width: widthOption / 2,
                                                child: Image.asset(
                                                    "assets/app/com_auto_check.png"),
                                              ),
                                              SizedBox(height: 20),
                                              TextCustom(
                                                'AUTO',
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _checkManual();
                                        },
                                        child: Container(
                                          width: widthOption,
                                          height: widthOption,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ConfigCustom
                                                          .borderRadius),
                                              color: ConfigCustom.colorWhite),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              SizedBox(
                                                width: widthOption / 2,
                                                child: Image.asset(
                                                    "assets/app/com_manual_check.png"),
                                              ),
                                              SizedBox(height: 20),
                                              TextCustom(
                                                'MANUAL',
                                                fontWeight: FontWeight.w900,
                                                color:
                                                    ConfigCustom.colorPrimary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
