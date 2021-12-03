import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/scanner_basic_screen.dart';
import 'package:dingtoimc/widgets/background_image.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/imei_validator.dart';
import 'package:dingtoimc/widgets/input_imei.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

import 'location_checking_screen.dart';

class ImeiFormScreen extends StatefulWidget {
  static const routeName = '/imei-form-screen';
  @override
  _ImeiFormScreenState createState() => _ImeiFormScreenState();
}

class _ImeiFormScreenState extends State<ImeiFormScreen> {
  String imei = '';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  FocusNode focusImei;
  bool errorImei = false;
  String _errorMessage = '';
  String mode = ConfigCustom.defaultMode;

  @override
  void dispose() {
    if (focusImei != null) {
      focusImei.dispose();
    }
    super.dispose();
  }

  static Future<bool> confirmImei(
      context, text, String textYes, String textNo, callbackYes, callbackNo) {
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isDismissible: true,
            builder: (BuildContext bc) {
              return Stack(alignment: Alignment.topCenter, children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 22),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: ConfigCustom.globalPadding,
                      left: ConfigCustom.globalPadding,
                      right: ConfigCustom.globalPadding,
                    ),
                    decoration: BoxDecoration(
                      gradient: ConfigCustom.colorBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ConfigCustom.borderRadius2),
                      ),
                    ),
                    height: 230,
                    child: Center(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          text,
                          SpaceCustom(),
                          SpaceCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new FlatButton(
                                onPressed: callbackNo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ConfigCustom.borderRadius),
                                ),
                                padding: const EdgeInsets.all(0.0),
                                child: Ink(
                                  width: width / 2.5,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ConfigCustom.colorWhite,
                                        width: 1),
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        ConfigCustom.borderRadius),
                                  ),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: 120, minHeight: 40.0),
                                    alignment: Alignment.center,
                                    child: TextCustom(
                                      textNo.toUpperCase(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              new FlatButton(
                                onPressed: callbackYes,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ConfigCustom.borderRadius),
                                ),
                                padding: const EdgeInsets.all(0.0),
                                child: Ink(
                                  width: width / 2.5,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ConfigCustom.colorWhite,
                                        width: 1),
                                    color: ConfigCustom.colorWhite,
                                    borderRadius: BorderRadius.circular(
                                        ConfigCustom.borderRadius),
                                  ),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: 120, minHeight: 40.0),
                                    alignment: Alignment.center,
                                    child: TextCustom(
                                      textYes.toUpperCase(),
                                      color: ConfigCustom.colorPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.info,
                        color: ConfigCustom.colorPrimary2, size: 30),
                    backgroundColor: ConfigCustom.colorPrimary,
                  ),
                )
              ]);
            }) ??
        false;
  }

  void checkImei() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    confirmImei(
        context,
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'By clicking YES, you agree to cross check your IMEI ',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              color: ConfigCustom.colorWhite,
              fontFamily: 'AvenirNext',
              fontSize: 20,
            ),
            children: <TextSpan>[
              TextSpan(
                  text: imei,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ConfigCustom.colorSecondary)),
              TextSpan(
                text: ' against Blacklisted registry.',
              ),
            ],
          ),
        ),
        'Yes',
        'No', () async {
      if (mode != ConfigCustom.defaultMode) {
        await prefs.setString(ConfigCustom.sharedBacklist, ConfigCustom.yes);
      }
      await prefs.setString(ConfigCustom.sharedImei, imei);
      Functions.goToRoute(context, LocationCheckingScreen.routeName);
    }, () async {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = true;
      });
      try {
        if (mode == ConfigCustom.defaultMode) {
          await User.removeWallet(
              context, prefs.getDouble(ConfigCustom.authPricePro));
          await prefs.setString(ConfigCustom.sharedBacklist, ConfigCustom.no);
          await prefs.setString(
              ConfigCustom.sharedBlacklistStatus, 'Not Verified');
          await prefs.setString(
              ConfigCustom.sharedBlacklistType, ConfigCustom.notVerified);
          Functions.goToRoute(context, ScannerBasicScreen.routeName);
        } else {
          Functions.goToRoute(context, AskingProScreen.routeName);
        }
      } catch (error) {
        if (error == ConfigCustom.notFoundInternet) {
          Functions.confirmAlertConnectivity(context, () {});
        } else {
          Functions.confirmSomethingError(
              context, 'Oops. Something Wrong. Please Try again.', () {});
        }
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future _submit() async {
    String customMode = await Functions.getModeType(context);
    if (customMode == ConfigCustom.defaultMode) {
      if (_formKey.currentState.validate()) {
        confirmImei(
            context,
            TextCustom(
              'Please make sure your IMEI is correct ?',
              fontSize: 20,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            'Confirm',
            'Change', () {
          Navigator.of(context).pop();
          checkImei();
        }, () {
          Navigator.of(context).pop();
          focusImei.requestFocus();
        });
      }
    } else {
      checkImei();
    }
  }

  Future _init() async {
    setState(() {
      _isLoading = true;
    });
    String customMode = await Functions.getModeType(context);
    if (customMode == ConfigCustom.defaultMode) {
      focusImei = FocusNode();
      if (!await User.auth(context)) return;
      await User.checkUserIsScanning(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(ConfigCustom.sharedBacklist, ConfigCustom.yes);
    } else {
      String customImei = '';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (customMode == ConfigCustom.transactionCodeLockScan) {
        Map obj = await Device.transactionListCompare(
            context, prefs.getString(ConfigCustom.transactionCodeLockScan));
        customImei = obj['myScan']['imei'];
      } else {
        customImei = prefs.getString(ConfigCustom.sharedImei);
      }
      setState(() {
        imei = customImei;
      });
    }

    setState(() {
      _isLoading = false;
      mode = customMode;
    });
  }

  Widget widgetMain() {
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
              'Check Blacklist',
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
    return BackgroundImage(
      child: _isLoading
          ? Loading()
          : Scaffold(
              appBar: appBar,
              backgroundColor: Colors.transparent,
              key: _drawerKey,
              drawer: DrawerScan(),
              body: GestureClickOutside(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(
                        left: ConfigCustom.globalPadding,
                        right: ConfigCustom.globalPadding,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Container(
                            //   width: width / 4,
                            //   child: Image.asset('assets/app/com_imei.png'),
                            // ),
                            SpaceCustom(),
                            SpaceCustom(),
                            TextCustom(
                              'Please enter your imei to start blacklist validation',
                              letterSpacing: ConfigCustom.letterSpacing2,
                              color: ConfigCustom.colorWhite,
                              fontSize: 20,
                              textAlign: TextAlign.center,
                            ),
                            SpaceCustom(),
                            InputImei(
                              prefixIcon: SizedBox(
                                  width: 30,
                                  child:
                                      Image.asset('assets/app/com_imei.png')),
                              textInputType: TextInputType.number,
                              focusNode: focusImei,
                              hint: 'Your IMEI',
                              onChanged: (String value) {
                                imei = value;
                              },
                              validator: (value) {
                                if (Functions.isEmpty(value)) {
                                  setState(() {
                                    errorImei = true;
                                    _errorMessage = 'IMEI is required';
                                  });
                                  return '';
                                } else {
                                  try {
                                    ImeiValidator imei = ImeiValidator(value);
                                    if (!imei.isValid) {
                                      setState(() {
                                        errorImei = true;
                                        _errorMessage = 'IMEI validate failed!';
                                      });
                                      return '';
                                    } else {
                                      setState(() {
                                        errorImei = false;
                                      });
                                      return null;
                                    }
                                  } catch (err) {
                                    setState(() {
                                      errorImei = true;
                                      _errorMessage =
                                          'Something wrong. Please try again...';
                                    });
                                    return '';
                                  }
                                }
                              },
                            ),
                            !errorImei
                                ? Center()
                                : TextCustom(
                                    _errorMessage,
                                    letterSpacing: ConfigCustom.letterSpacing2,
                                    color: ConfigCustom.colorError,
                                  ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            InkWell(
                              onTap: () {
                                Functions.readMoreInfo(
                                    context,
                                    "HOW TO FIND MY IMEI NUMBER?",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          "1. Open Phone app on your phone.",
                                          fontSize: 13,
                                        ),
                                        TextCustom(
                                          "2. Dial \"*#06#\" on your keypad.",
                                          fontSize: 13,
                                        ),
                                        TextCustom(
                                          "3. A box will automatically pop up that displays several numbers, including the IMEI.",
                                          fontSize: 13,
                                        ),
                                        SizedBox(height: 10),
                                        TextCustom(
                                          "OR:",
                                          fontSize: 13,
                                        ),
                                        SizedBox(height: 10),
                                        TextCustom(
                                          "1. Open the Settings app on your phone.",
                                          fontSize: 13,
                                        ),
                                        Platform.isIOS
                                            ? TextCustom(
                                                "2. Tap \"General => About\".",
                                                fontSize: 13,
                                              )
                                            : TextCustom(
                                                "2. Tap \"About Phone\".",
                                                fontSize: 13,
                                              ),
                                        TextCustom(
                                          "3. Scroll down and you'll find the number listed under \"IMEI\".",
                                          fontSize: 13,
                                        ),
                                      ],
                                    ));
                              },
                              child: Row(children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    SimpleLineIcons.question,
                                    color: ConfigCustom.colorPrimary2,
                                    size: 22,
                                  ),
                                ),
                                TextCustom(
                                  "How to find my IMEI number ?",
                                  fontStyle: FontStyle.italic,
                                  color: ConfigCustom.colorPrimary2,
                                )
                              ]),
                            ),
                            SpaceCustom(),
                            InkWell(
                              onTap: () {
                                Functions.readMoreInfo(
                                    context,
                                    "WHAT IS THE IMEI?",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          "IMEI stands for International Mobile Equipment Identity.",
                                          fontSize: 13,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextCustom(
                                          "By using this unique IMEI Number you may get to know such data as: the network and country from which your device originally comes from, warranty informationdate of purchase,carrier information, system version,device specification and more details information. (https://www.imei.info/)",
                                          fontSize: 12,
                                          maxLines: 20,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextCustom(
                                          "Let's check IMEI and make sure that your phone is not blacklisted!",
                                          fontSize: 13,
                                        ),
                                      ],
                                    ));
                              },
                              child: Row(children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    SimpleLineIcons.question,
                                    color: ConfigCustom.colorPrimary2,
                                    size: 22,
                                  ),
                                ),
                                TextCustom(
                                  "What is the IMEI ?",
                                  fontStyle: FontStyle.italic,
                                  color: ConfigCustom.colorPrimary2,
                                )
                              ]),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            Container(
                              width: width / 2,
                              child: ButtonCustom(
                                'Start',
                                onTap: () {
                                  _submit();
                                },
                              ),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Widget widgetButton() {
    double width = MediaQuery.of(context).size.width;
    if (mode == ConfigCustom.defaultMode) {
      return Container(
        width: width / 2,
        child: ButtonCustom(
          'Start',
          onTap: () {
            _submit();
          },
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new FlatButton(
            onPressed: () {
              Functions.goToRoute(context, AskingProScreen.routeName);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
            ),
            padding: const EdgeInsets.all(0.0),
            child: Ink(
              width: width / 2.5,
              decoration: BoxDecoration(
                border: Border.all(color: ConfigCustom.colorWhite, width: 1),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 120, minHeight: 40.0),
                alignment: Alignment.center,
                child: TextCustom(
                  "CANCEL",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          new FlatButton(
            onPressed: () {
              _submit();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
            ),
            padding: const EdgeInsets.all(0.0),
            child: Ink(
              width: width / 2.5,
              decoration: BoxDecoration(
                border: Border.all(color: ConfigCustom.colorWhite, width: 1),
                color: ConfigCustom.colorWhite,
                borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 120, minHeight: 40.0),
                alignment: Alignment.center,
                child: TextCustom(
                  "CONFIRM",
                  color: ConfigCustom.colorPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget widgetConfirm() {
    PreferredSize appBar = Functions.getAppbarScanner(
      context,
      Expanded(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextCustom(
              'Check Blacklist',
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
    return BackgroundImage(
      child: _isLoading
          ? Loading()
          : Scaffold(
              appBar: appBar,
              backgroundColor: Colors.transparent,
              key: _drawerKey,
              drawer: DrawerScan(),
              body: GestureClickOutside(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(
                        left: ConfigCustom.globalPadding,
                        right: ConfigCustom.globalPadding,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Container(
                            //   width: width / 4,
                            //   child: Image.asset('assets/app/com_imei.png'),
                            // ),
                            SpaceCustom(),
                            SpaceCustom(),
                            TextCustom(
                              'Your Imei Is',
                              letterSpacing: ConfigCustom.letterSpacing2,
                              fontSize: 20,
                              textAlign: TextAlign.center,
                            ),
                            SpaceCustom(),
                            TextCustom(
                              imei,
                              color: ConfigCustom.colorSuccess,
                              letterSpacing: ConfigCustom.letterSpacing2,
                              fontSize: 20,
                              textAlign: TextAlign.center,
                            ),
                            SpaceCustom(),
                            TextCustom(
                              'Please make sure your IMEI is correct.',
                              letterSpacing: ConfigCustom.letterSpacing2,
                              color: ConfigCustom.colorWhite,
                              fontSize: 20,
                              textAlign: TextAlign.center,
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            InkWell(
                              onTap: () {
                                Functions.readMoreInfo(
                                    context,
                                    "HOW TO FIND MY IMEI NUMBER?",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          "1. Open Phone app on your phone.",
                                          fontSize: 13,
                                        ),
                                        TextCustom(
                                          "2. Dial \"*#06#\" on your keypad.",
                                          fontSize: 13,
                                        ),
                                        TextCustom(
                                          "3. A box will automatically pop up that displays several numbers, including the IMEI.",
                                          fontSize: 13,
                                        ),
                                        SizedBox(height: 10),
                                        TextCustom(
                                          "OR:",
                                          fontSize: 13,
                                        ),
                                        SizedBox(height: 10),
                                        TextCustom(
                                          "1. Open the Settings app on your phone.",
                                          fontSize: 13,
                                        ),
                                        Platform.isIOS
                                            ? TextCustom(
                                                "2. Tap \"General => About\".",
                                                fontSize: 13,
                                              )
                                            : TextCustom(
                                                "2. Tap \"About Phone\".",
                                                fontSize: 13,
                                              ),
                                        TextCustom(
                                          "3. Scroll down and you'll find the number listed under \"IMEI\".",
                                          fontSize: 13,
                                        ),
                                      ],
                                    ));
                              },
                              child: Row(children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    SimpleLineIcons.question,
                                    color: ConfigCustom.colorPrimary2,
                                    size: 22,
                                  ),
                                ),
                                TextCustom(
                                  "How to find my IMEI number ?",
                                  fontStyle: FontStyle.italic,
                                  color: ConfigCustom.colorPrimary2,
                                )
                              ]),
                            ),
                            SpaceCustom(),
                            InkWell(
                              onTap: () {
                                Functions.readMoreInfo(
                                    context,
                                    "WHAT IS THE IMEI?",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          "IMEI stands for International Mobile Equipment Identity.",
                                          fontSize: 13,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextCustom(
                                          "By using this unique IMEI Number you may get to know such data as: the network and country from which your device originally comes from, warranty informationdate of purchase,carrier information, system version,device specification and more details information. (https://www.imei.info/)",
                                          fontSize: 12,
                                          maxLines: 20,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextCustom(
                                          "Let's check IMEI and make sure that your phone is not blacklisted!",
                                          fontSize: 13,
                                        ),
                                      ],
                                    ));
                              },
                              child: Row(children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    SimpleLineIcons.question,
                                    color: ConfigCustom.colorPrimary2,
                                    size: 22,
                                  ),
                                ),
                                TextCustom(
                                  "What is the IMEI ?",
                                  fontStyle: FontStyle.italic,
                                  color: ConfigCustom.colorPrimary2,
                                )
                              ]),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            widgetButton(),
                            SpaceCustom(),
                            SpaceCustom(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = widgetMain();
    if (mode != ConfigCustom.defaultMode) {
      widget = widgetConfirm();
    }
    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: widget,
    );
  }
}
