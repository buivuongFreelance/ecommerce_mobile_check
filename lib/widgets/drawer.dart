import 'dart:async';
import 'dart:io';

import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/contact_screen.dart';
import 'package:dingtoimc/screens/history_scan_screen.dart';
import 'package:dingtoimc/screens/privacy_screen.dart';
import 'package:dingtoimc/screens/qr_scan_screen.dart';
import 'package:dingtoimc/screens/wallet_screen.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerCustom extends StatefulWidget {
  @override
  _DrawerCustomState createState() => _DrawerCustomState();
}

class _DrawerCustomState extends State<DrawerCustom> {
  bool _isLoading = false;
  String email = '';
  String mode = ConfigCustom.defaultMode;
  String transactionCode = '';

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    try {
      if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
        await User.logoutLocked(context);
        Functions.goToRoute(context, WelcomeScreen.routeName);
      } else {
        await User.logout(context);
      }
    } catch (error) {
      _isLoading = false;
    }
  }

  Future startTimer() async {
    Timer.periodic(new Duration(seconds: 1), (time) {});
  }

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customMode = await Functions.getModeType(context);
    if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
      transactionCode = prefs.getString(ConfigCustom.transactionCodeLockScan);
    }
    if (!Functions.isEmpty(prefs.get(ConfigCustom.authEmail))) {
      setState(() {
        email = EmailValidator.validate(prefs.get(ConfigCustom.authEmail))
            ? prefs.get(ConfigCustom.authEmail)
            : '';
        mode = customMode;
      });
    }
  }

  Future goToRoute(String route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(ConfigCustom.authScan)) {
      Navigator.of(context).pop();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pop();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return _isLoading
        ? Loading()
        : Container(
            width: width * 0.75,
            height: height,
            child: Drawer(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, ConfigCustom.globalPadding * 2,
                    0, ConfigCustom.globalPadding * 2),
                decoration: BoxDecoration(
                  gradient: ConfigCustom.colorBgBlendBottom,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {},
                                child: SizedBox(
                                  width: width / 5.5,
                                  child: Image.asset(
                                      'assets/app/com_logo_short.jpg'),
                                ),
                              ),
                              SpaceCustom(),
                              TextCustom(
                                email,
                              ),
                              SpaceCustom(),
                            ],
                          ),
                        ),
                        SpaceCustom(),
                        InkWell(
                          onTap: () {
                            goToRoute(AskingProScreen.routeName);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color:
                                    ConfigCustom.colorWhite.withOpacity(0.1)),
                            padding: EdgeInsets.fromLTRB(
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5,
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5),
                            child: Row(
                              children: <Widget>[
                                Icon(SimpleLineIcons.home,
                                    color: ConfigCustom.colorWhite, size: 15),
                                SizedBox(
                                  width: ConfigCustom.globalPadding / 2,
                                ),
                                TextCustom(
                                  'HOME',
                                  fontSize: 13,
                                  letterSpacing: ConfigCustom.letterSpacing,
                                ),
                              ],
                            ),
                          ),
                        ),
                        transactionCode.isNotEmpty
                            ? Center()
                            : InkWell(
                                onTap: () {
                                  goToRoute(QrScanScreen.routeName);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      ConfigCustom.globalPadding,
                                      ConfigCustom.globalPadding / 1.5,
                                      ConfigCustom.globalPadding,
                                      ConfigCustom.globalPadding / 1.5),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                          Platform.isIOS
                                              ? Ionicons.ios_qr_scanner
                                              : Ionicons.md_qr_scanner,
                                          color: ConfigCustom.colorWhite,
                                          size: 18),
                                      SizedBox(
                                        width: ConfigCustom.globalPadding / 2,
                                      ),
                                      TextCustom(
                                        'QR SCAN DEVICE',
                                        fontSize: 13,
                                        letterSpacing:
                                            ConfigCustom.letterSpacing,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        transactionCode.isNotEmpty
                            ? Center()
                            : InkWell(
                                onTap: () {
                                  goToRoute(WalletScreen.routeName);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      ConfigCustom.globalPadding,
                                      ConfigCustom.globalPadding / 1.5,
                                      ConfigCustom.globalPadding,
                                      ConfigCustom.globalPadding / 1.5),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(SimpleLineIcons.wallet,
                                          color: ConfigCustom.colorWhite,
                                          size: 15),
                                      SizedBox(
                                        width: ConfigCustom.globalPadding / 2,
                                      ),
                                      TextCustom(
                                        'YOUR WALLET',
                                        fontSize: 13,
                                        letterSpacing:
                                            ConfigCustom.letterSpacing,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        transactionCode.isNotEmpty
                            ? Center()
                            : InkWell(
                                onTap: () {
                                  goToRoute(HistoryScanScreen.routeName);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      ConfigCustom.globalPadding,
                                      ConfigCustom.globalPadding / 1.5,
                                      ConfigCustom.globalPadding,
                                      ConfigCustom.globalPadding / 1.5),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(SimpleLineIcons.clock,
                                          color: ConfigCustom.colorWhite,
                                          size: 15),
                                      SizedBox(
                                        width: ConfigCustom.globalPadding / 2,
                                      ),
                                      TextCustom(
                                        'SCAN HISTORY',
                                        fontSize: 13,
                                        letterSpacing:
                                            ConfigCustom.letterSpacing,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        transactionCode.isNotEmpty
                            ? Center()
                            : InkWell(
                                onTap: () {
                                  Functions.confirmOkModel(context,
                                      'Notifications is developing !', () {});
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      ConfigCustom.globalPadding,
                                      ConfigCustom.globalPadding / 1.5,
                                      ConfigCustom.globalPadding,
                                      ConfigCustom.globalPadding / 1.5),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(SimpleLineIcons.bell,
                                          color: ConfigCustom.colorWhite,
                                          size: 16),
                                      SizedBox(
                                        width: ConfigCustom.globalPadding / 2,
                                      ),
                                      TextCustom(
                                        'NOTIFICATIONS',
                                        fontSize: 13,
                                        letterSpacing:
                                            ConfigCustom.letterSpacing,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        InkWell(
                          onTap: () {
                            goToRoute(ContactScreen.routeName);
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5,
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5),
                            child: Row(
                              children: <Widget>[
                                Icon(SimpleLineIcons.phone,
                                    color: ConfigCustom.colorWhite, size: 15),
                                SizedBox(
                                  width: ConfigCustom.globalPadding / 2,
                                ),
                                TextCustom(
                                  'CONTACT',
                                  fontSize: 13,
                                  letterSpacing: ConfigCustom.letterSpacing,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            goToRoute(PrivacyScreen.routeName);
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5,
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5),
                            child: Row(
                              children: <Widget>[
                                Icon(SimpleLineIcons.diamond,
                                    color: ConfigCustom.colorWhite, size: 15),
                                SizedBox(
                                  width: ConfigCustom.globalPadding / 2,
                                ),
                                TextCustom(
                                  'PRIVACY POLICY',
                                  fontSize: 13,
                                  letterSpacing: ConfigCustom.letterSpacing,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Functions.confirmYesNo(
                                context, 'Do you want to log out ?', () {
                              logout();
                            }, false);
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5,
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5),
                            child: Row(
                              children: <Widget>[
                                Icon(SimpleLineIcons.lock_open,
                                    color: ConfigCustom.colorWhite, size: 15),
                                SizedBox(
                                  width: ConfigCustom.globalPadding / 2,
                                ),
                                TextCustom(
                                  'SIGN OUT',
                                  fontSize: 13,
                                  letterSpacing: ConfigCustom.letterSpacing,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
