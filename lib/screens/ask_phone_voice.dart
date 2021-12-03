import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/sim_checking_screen.dart';
import 'package:dingtoimc/widgets/button_custom_arrow.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AskingPhoneVoiceScreen extends StatefulWidget {
  static const routeName = '/ask-phone-voice';

  @override
  _AskingPhoneVoiceScreenState createState() => _AskingPhoneVoiceScreenState();
}

class _AskingPhoneVoiceScreenState extends State<AskingPhoneVoiceScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String voice = ConfigCustom.yes;
  String text = ConfigCustom.yes;
  bool _isLoading = false;

  Future _init() async {
    if (!await User.auth(context)) return;
    await User.checkUserIsScanning(context);
    await Device.checkUserAnonymous(context);

    String _voice = ConfigCustom.yes;
    String _text = ConfigCustom.yes;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedVoice)) {
      _voice = prefs.get(ConfigCustom.sharedVoice);
    }
    if (prefs.containsKey(ConfigCustom.sharedText)) {
      _text = prefs.get(ConfigCustom.sharedText);
    }

    setState(() {
      voice = _voice;
      text = _text;
    });
  }

  Future _next() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(ConfigCustom.sharedVoice, ConfigCustom.yes);
    await prefs.setString(ConfigCustom.sharedText, ConfigCustom.yes);

    Functions.goToRoute(context, SimCheckingScreen.routeName);

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
        ), () {
      _drawerKey.currentState.openDrawer();
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
                            width: width - ConfigCustom.globalPadding * 3,
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  TextCustom(
                                    "Dingtoi will now check your hardware for Voice and SMS functions",
                                    fontSize: 20,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 55),
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 20, bottom: 20),
                                    decoration: BoxDecoration(
                                        color: ConfigCustom.colorWhite
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            ConfigCustom.borderRadius / 2)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: width / 4,
                                          padding: EdgeInsets.only(right: 10),
                                          child: RawMaterialButton(
                                            onPressed: () {},
                                            elevation: 0.0,
                                            fillColor:
                                                ConfigCustom.colorPrimary2,
                                            child: Icon(
                                              SimpleLineIcons.phone,
                                              color: ConfigCustom.colorWhite,
                                              size: 30.0,
                                            ),
                                            padding: EdgeInsets.all(
                                                ConfigCustom.globalPadding /
                                                    1.8),
                                            shape: CircleBorder(),
                                          ),
                                        ),
                                        Container(
                                          child: TextCustom(
                                            "VOICE",
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 20, bottom: 20),
                                    decoration: BoxDecoration(
                                        color: ConfigCustom.colorWhite
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            ConfigCustom.borderRadius / 2)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: width / 4,
                                          padding: EdgeInsets.only(right: 10),
                                          child: RawMaterialButton(
                                            onPressed: () {},
                                            elevation: 0.0,
                                            fillColor:
                                                ConfigCustom.colorPrimary2,
                                            child: Icon(
                                              MaterialCommunityIcons
                                                  .message_text,
                                              color: ConfigCustom.colorWhite,
                                              size: 30.0,
                                            ),
                                            padding: EdgeInsets.all(
                                                ConfigCustom.globalPadding /
                                                    1.8),
                                            shape: CircleBorder(),
                                          ),
                                        ),
                                        Container(
                                          child: TextCustom(
                                            "SMS",
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 50),
                                  Container(
                                    width: width / 1.5,
                                    child: ButtonCustomArrow(
                                      'CHECK',
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
