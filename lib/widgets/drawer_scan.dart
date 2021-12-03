import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/step_pro_wizard.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerScan extends StatefulWidget {
  @override
  _DrawerScanState createState() => _DrawerScanState();
}

class _DrawerScanState extends State<DrawerScan> {
  bool _isLoading = false;
  String email = '';
  String scanType;
  Map user;
  int step;

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
      await User.logoutLocked(context);
      Functions.goToRoute(context, WelcomeScreen.routeName);
    } else {
      await User.logout(context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future init() async {
    Map _user = await User.checkPreUserIsScanning(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedStep)) {
      setState(() {
        step = prefs.getInt(ConfigCustom.sharedStep);
      });
    }

    String _scanType;
    if (_user.isNotEmpty) {
      _scanType = _user[ConfigCustom.sharedUserPay];
    }

    if (!Functions.isEmpty(prefs.get(ConfigCustom.authEmail))) {
      setState(() {
        email = EmailValidator.validate(prefs.get(ConfigCustom.authEmail))
            ? prefs.get(ConfigCustom.authEmail)
            : '';
        scanType = _scanType;
        user = _user;
      });
    }
  }

  Future scanAgain() async {
    Functions.confirmScanAgain(context);
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

    String strScan = 'Transaction Scan';
    Color bgScan = ConfigCustom.colorPrimary2;
    if (scanType == ConfigCustom.userFree) {
      strScan = 'Basic Scan';
      bgScan = ConfigCustom.colorSecondary;
    } else if (scanType == ConfigCustom.userPro) {
      strScan = 'Pro Scan';
      bgScan = ConfigCustom.colorSecondary;
    }

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
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    ConfigCustom.globalPadding,
                                    ConfigCustom.globalPadding / 3,
                                    ConfigCustom.globalPadding,
                                    ConfigCustom.globalPadding / 3),
                                decoration: BoxDecoration(
                                    color: bgScan,
                                    borderRadius: BorderRadius.circular(
                                        ConfigCustom.borderRadius2)),
                                child: TextCustom(
                                  strScan.toUpperCase(),
                                  color: ConfigCustom.colorPrimary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: ConfigCustom.letterSpacing2,
                                ),
                              ),
                              SpaceCustom(),
                            ],
                          ),
                        ),
                        SpaceCustom(),
                        Functions.isEmpty(step) ? Center() : StepProWizard(),
                        SpaceCustom(),
                        InkWell(
                          onTap: () {
                            scanAgain();
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5,
                                ConfigCustom.globalPadding,
                                ConfigCustom.globalPadding / 1.5),
                            child: Row(
                              children: <Widget>[
                                Icon(SimpleLineIcons.refresh,
                                    color: ConfigCustom.colorWhite, size: 16),
                                SizedBox(
                                  width: ConfigCustom.globalPadding / 2,
                                ),
                                TextCustom(
                                  'SCAN AGAIN',
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
                                context, 'Do you want to log out ?', () async {
                              await logout();
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
                                    color: ConfigCustom.colorWhite, size: 16),
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
