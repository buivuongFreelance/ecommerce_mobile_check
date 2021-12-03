import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/location_checking_screen.dart';
import 'package:dingtoimc/screens/scanner_basic_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/button_custom_arrow.dart';
import 'package:dingtoimc/widgets/divider_custom.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/loading_blacklist.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:io' show Platform;

class BlacklistStatusScreen extends StatefulWidget {
  static const routeName = '/blacklist_status_screen';

  @override
  _BlacklistStatusScreenState createState() => _BlacklistStatusScreenState();
}

class _BlacklistStatusScreenState extends State<BlacklistStatusScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String imei = '';
  Map obj;
  Map checkBlacklist;
  bool _isLoading = false;

  Future _goToStep3() async {
    Functions.goToRoute(context, ScannerBasicScreen.routeName);
  }

  Widget widgetErrorServer(width, appBar) {
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: Scaffold(
        appBar: appBar,
        backgroundColor: Colors.transparent,
        key: _drawerKey,
        drawer: DrawerScan(),
        body: Container(
          width: width,
          padding: EdgeInsets.only(
            left: ConfigCustom.globalPadding * 2,
            right: ConfigCustom.globalPadding * 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Image.asset('assets/app/com_status_failed.png'),
                width: width / 2,
              ),
              SpaceCustom(),
              SpaceCustom(),
              Container(
                width: width / 1.2,
                child: TextCustom(
                  'Oops. Server Error',
                  fontSize: 20,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SpaceCustom(),
              Container(
                width: width / 1.2,
                child: TextCustom(
                  'Server Error. Please wait for a few minutes and try again.',
                  textAlign: TextAlign.center,
                ),
              ),
              TextCustom(
                "Then, click RETRY button to check again.",
                textAlign: TextAlign.center,
              ),
              SpaceCustom(),
              SpaceCustom(),
              SpaceCustom(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: width / 3,
                    child: ButtonCustom(
                      'Skip',
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString(
                            ConfigCustom.sharedBlacklistStatus, 'Not Verified');
                        await prefs.setString(ConfigCustom.sharedBlacklistType,
                            ConfigCustom.notVerified);
                        Functions.goToRoute(
                            context, ScannerBasicScreen.routeName);
                      },
                      colorOutline: ConfigCustom.colorWhite,
                      color: ConfigCustom.colorWhite,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: width / 3,
                    child: ButtonCustom(
                      'Retry',
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            LocationCheckingScreen.routeName,
                            (Route<dynamic> route) => false);
                      },
                      color: ConfigCustom.colorPrimary,
                    ),
                  ),
                  SpaceCustom(),
                  SpaceCustom(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget widgetSuccess(width, appBar) {
    return checkBlacklist.isEmpty
        ? Center()
        : Container(
            decoration: BoxDecoration(
              gradient: ConfigCustom.colorBgBlendBottom,
            ),
            child: Scaffold(
              appBar: appBar,
              backgroundColor: Colors.transparent,
              key: _drawerKey,
              drawer: DrawerScan(),
              body: Container(
                width: width,
                padding: EdgeInsets.only(
                  left: ConfigCustom.globalPadding * 2,
                  right: ConfigCustom.globalPadding * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: checkBlacklist['type'] != ConfigCustom.success
                          ? Image.asset('assets/app/com_status_failed.png')
                          : Image.asset('assets/app/com_status_success.png'),
                      width: width / 2,
                    ),
                    SpaceCustom(),
                    SpaceCustom(),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextCustom('IMEI'),
                          TextCustom(obj[ConfigCustom.sharedImei]),
                        ],
                      ),
                    ),
                    DividerCustom(),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextCustom('BLACKLIST STATUS'),
                          TextCustom(
                            checkBlacklist['status'],
                            color:
                                checkBlacklist['type'] != ConfigCustom.success
                                    ? ConfigCustom.colorError
                                    : ConfigCustom.colorSuccess1,
                          ),
                        ],
                      ),
                    ),
                    DividerCustom(),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextCustom('COUNTRY'),
                          // TextCustom(Functions.countryParse(
                          //     obj[ConfigCustom.sharedCountryCode])),
                          TextCustom('CANADA'),
                        ],
                      ),
                    ),
                    SpaceCustom(),
                    SpaceCustom(),
                    SpaceCustom(),
                    SpaceCustom(),
                    Container(
                      width: width,
                      child: ButtonCustomArrow(
                        'Go To Scan Report',
                        onTap: () {
                          _goToStep3();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget widgetError(width, appBar) {
    String title = 'Unable to check';
    Widget message = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            'You must allow Dingtoi access location permission to check blacklist. Please click on ',
        style: TextStyle(
          fontWeight: FontWeight.w300,
          color: ConfigCustom.colorWhite,
          fontFamily: 'AvenirNext',
          height: 1.7,
          fontSize: 16,
        ),
        children: <TextSpan>[
          TextSpan(
              text: 'Open Setting',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Platform.isAndroid
                      ? obj[ConfigCustom.sharedCountryCode] ==
                              ConfigCustom.isDisabled
                          ? AppSettings.openLocationSettings()
                          : AppSettings.openAppSettings()
                      : AppSettings.openLocationSettings();
                },
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ConfigCustom.colorPrimary2)),
          TextSpan(
            text: ' and go to enable location permission for Dingtoi.',
          ),
        ],
      ),
    );

    if (obj[ConfigCustom.sharedCountryCode] == ConfigCustom.isDisabled) {
      title = 'Unable to check';
      message = RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text:
              'You must allow Dingtoi access location permission to check blacklist. Please click on ',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            color: ConfigCustom.colorWhite,
            fontFamily: 'AvenirNext',
            fontSize: 15,
          ),
          children: <TextSpan>[
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    AppSettings.openLocationSettings();
                  },
                text: 'Open Settings.',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ConfigCustom.colorSecondary)),
            TextSpan(
              text: ' and go to enable location permission for Dingtoi.',
            ),
          ],
        ),
      );
    } else if (obj[ConfigCustom.sharedCountryCode] == ConfigCustom.isDisabled) {
      title = 'Unable to check';
      message = RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text:
              'You must allow Dingtoi access location permission to check blacklist. Please click on ',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            color: ConfigCustom.colorWhite,
            fontFamily: 'AvenirNext',
            fontSize: 15,
          ),
          children: <TextSpan>[
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    AppSettings.openLocationSettings();
                  },
                text: 'Open Settings.',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ConfigCustom.colorSecondary)),
            TextSpan(
              text: ' and go to enable location permission for Dingtoi.',
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: Scaffold(
        appBar: appBar,
        backgroundColor: Colors.transparent,
        key: _drawerKey,
        drawer: DrawerScan(),
        body: Container(
          width: width,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Image.asset('assets/app/com_status_failed.png'),
                    width: width / 2,
                  ),
                  SpaceCustom(),
                  SpaceCustom(),
                  Container(
                    width: width / 1.2,
                    child: TextCustom(
                      title,
                      fontSize: 20,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SpaceCustom(),
                  Container(width: width / 1.2, child: message),
                  TextCustom("Then, click RETRY button to check again."),
                  SpaceCustom(),
                  SpaceCustom(),
                  SpaceCustom(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: width / 3,
                        child: ButtonCustom(
                          'Skip',
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString(
                                ConfigCustom.sharedBlacklistStatus,
                                'Not Verified');
                            await prefs.setString(
                                ConfigCustom.sharedBlacklistType,
                                ConfigCustom.notVerified);
                            Functions.goToRoute(
                                context, ScannerBasicScreen.routeName);
                          },
                          colorOutline: ConfigCustom.colorWhite,
                          color: ConfigCustom.colorWhite,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        width: width / 3,
                        child: ButtonCustom(
                          'Retry',
                          onTap: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                LocationCheckingScreen.routeName,
                                (Route<dynamic> route) => false);
                          },
                          color: ConfigCustom.colorPrimary,
                        ),
                      ),
                      SpaceCustom(),
                      SpaceCustom(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _init() async {
    setState(() {
      _isLoading = true;
    });
    if (!await User.auth(context)) return;
    await User.checkUserIsScanning(context);
    Map _obj = await Device.checkImeiCountryCode(context);
    Map _checkBlacklist;

    try {
      if (_obj[ConfigCustom.sharedCountryCode] != ConfigCustom.isReject &&
          _obj[ConfigCustom.sharedCountryCode] != ConfigCustom.isDisabled &&
          _obj[ConfigCustom.sharedCountryCode] != ConfigCustom.isPermanent) {
        _checkBlacklist = await Device.checkBlacklist(
            context,
            _obj[ConfigCustom.sharedImei],
            _obj[ConfigCustom.sharedCountryCode]);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            ConfigCustom.sharedBlacklistStatus, _checkBlacklist['status']);
        await prefs.setString(
            ConfigCustom.sharedBlacklistType, _checkBlacklist['type']);

        if (_checkBlacklist['type'] == ConfigCustom.success) {
          if (prefs.containsKey(ConfigCustom.authPricePro) &&
              prefs.containsKey(ConfigCustom.authIsPay)) {
            if (!prefs.getBool(ConfigCustom.authIsPay)) {
              await User.removeWallet(
                  context, prefs.getDouble(ConfigCustom.authPricePro));
            }
          }
        }
      }
      setState(() {
        obj = _obj;
        _isLoading = false;
        checkBlacklist = _checkBlacklist;
      });
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else if (error == ConfigCustom.errImei) {
        Functions.confirmSomethingError(context, 'IMEI Wrong !!!', () {});
      } else {
        Functions.confirmSomethingError(
            context, 'Oops. Something Wrong. Please Try again.', () {});
      }
      setState(() {
        _isLoading = false;
      });
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
        ), () {
      _drawerKey.currentState.openDrawer();
    });

    Widget widget = widgetErrorServer(width, appBar);
    if (_isLoading) {
      widget = LoadingBlacklist();
    } else if (obj != null) {
      if (obj[ConfigCustom.sharedCountryCode] == ConfigCustom.isReject ||
          obj[ConfigCustom.sharedCountryCode] == ConfigCustom.isDisabled ||
          obj[ConfigCustom.sharedCountryCode] == ConfigCustom.isPermanent) {
        widget = widgetError(width, appBar);
      } else
        widget = widgetSuccess(width, appBar);
    }

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: widget,
    );
  }
}
