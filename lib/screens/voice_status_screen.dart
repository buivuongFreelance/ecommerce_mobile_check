import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/ask_phone_voice.dart';
import 'package:dingtoimc/screens/auto_phone_voice_screen.dart';
import 'package:dingtoimc/screens/imei_form_screen.dart';
import 'package:dingtoimc/screens/sim_checking_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/button_custom_arrow.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/gestures.dart';

class VoiceStatusScreen extends StatefulWidget {
  static const routeName = '/voice_status_screen';

  @override
  _VoiceStatusScreenState createState() => _VoiceStatusScreenState();
}

class _VoiceStatusScreenState extends State<VoiceStatusScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String imei = '';
  Map obj;
  bool _isLoading = false;
  bool _isBlacklist = false;

  Future skip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        ConfigCustom.sharedVoiceInbound, ConfigCustom.notVerified);
    await prefs.setString(
        ConfigCustom.sharedVoiceOutbound, ConfigCustom.notVerified);
    await prefs.setString(
        ConfigCustom.sharedTextInbound, ConfigCustom.notVerified);
    await prefs.setString(
        ConfigCustom.sharedTextOutbound, ConfigCustom.notVerified);
    await prefs.setInt(ConfigCustom.sharedStep, 3);

    Functions.goToRoute(context, ImeiFormScreen.routeName);
  }

  Widget widgetError(width, appBar) {
    String title = 'Unable to check';
    Widget message = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            'You must allow Dingtoi access to check Voice and SMS functions. Please click on ',
        style: TextStyle(
          fontWeight: FontWeight.w300,
          color: ConfigCustom.colorWhite,
          fontFamily: 'AvenirNext',
          fontSize: 16,
        ),
        children: <TextSpan>[
          TextSpan(
              text: 'Open Settings',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  AppSettings.openAppSettings();
                },
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ConfigCustom.colorPrimary2)),
          TextSpan(
            text: ' and go to enable phone permission for Dingtoi.',
          ),
        ],
      ),
    );

    if (obj[ConfigCustom.sharedSim] == ConfigCustom.isNotReady) {
      title = 'You must insert sim';
      message = RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'You must insert sim to check Voice and SMS functions !!!',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            color: ConfigCustom.colorWhite,
            fontFamily: 'AvenirNext',
            fontSize: 16,
          ),
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
                          onTap: () {
                            skip();
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
                                SimCheckingScreen.routeName,
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

  Widget widgetBlacklist(width, appBar) {
    String title = 'Your Device is Blacklisted';
    String message = 'Your device is Blacklisted so you cannot call or SMS !!!';

    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: Scaffold(
        appBar: appBar,
        backgroundColor: Colors.transparent,
        key: _drawerKey,
        drawer: DrawerCustom(),
        body: Container(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TimerCustom(
                widget: false,
              ),
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
              Container(
                width: width / 1.2,
                child: TextCustom(
                  message,
                  textAlign: TextAlign.center,
                ),
              ),
              SpaceCustom(),
              SpaceCustom(),
              SpaceCustom(),
              SpaceCustom(),
              Container(
                width: width / 2,
                child: ButtonCustomArrow(
                  'Check Blacklist',
                  onTap: () {
                    skip();
                  },
                  colorOutline: ConfigCustom.colorWhite,
                  color: ConfigCustom.colorWhite,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
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
    await Device.checkUserAnonymous(context);
    Map _obj = await Device.checkSim(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedBlacklistType)) {
      if (prefs.get(ConfigCustom.sharedBlacklistType) == ConfigCustom.error) {
        setState(() {
          _isBlacklist = true;
        });
      }
    }

    if (!_isBlacklist) {
      if (_obj[ConfigCustom.sharedSim] != ConfigCustom.isNotReady &&
          _obj[ConfigCustom.sharedSim] != ConfigCustom.isPermanent) {
        Functions.goToRoute(context, AutoPhoneVoiceManualScreen.routeName);
      } else {
        await prefs.setString(ConfigCustom.sharedVoiceInbound, ConfigCustom.no);
        await prefs.setString(
            ConfigCustom.sharedVoiceOutbound, ConfigCustom.no);
        await prefs.setString(ConfigCustom.sharedTextInbound, ConfigCustom.no);
        await prefs.setString(ConfigCustom.sharedTextOutbound, ConfigCustom.no);
      }
    } else {
      await prefs.setString(ConfigCustom.sharedVoiceInbound, ConfigCustom.no);
      await prefs.setString(ConfigCustom.sharedVoiceOutbound, ConfigCustom.no);
      await prefs.setString(ConfigCustom.sharedTextInbound, ConfigCustom.no);
      await prefs.setString(ConfigCustom.sharedTextOutbound, ConfigCustom.no);
    }

    setState(() {
      _isLoading = false;
      obj = _obj;
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
    PreferredSize appBar = Functions.getAppbarMainBack(
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
    }, () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingPhoneVoiceScreen.routeName, (Route<dynamic> route) => false);
    });

    Widget widget;
    if (_isLoading) {
      widget = Loading();
    } else {
      if (_isBlacklist) {
        widget = widgetBlacklist(width, appBar);
      } else {
        if (obj[ConfigCustom.sharedSim] == ConfigCustom.isNotReady ||
            obj[ConfigCustom.sharedSim] == ConfigCustom.isPermanent) {
          widget = widgetError(width, appBar);
        } else {
          widget = Center();
        }
      }
    }

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: widget,
    );
  }
}
