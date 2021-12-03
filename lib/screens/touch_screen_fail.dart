import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/ask_phone_voice.dart';
import 'package:dingtoimc/screens/scanner_basic_screen.dart';
import 'package:dingtoimc/widgets/button_small.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TouchScreenFail extends StatefulWidget {
  static const routeName = '/touch_screen_fail';

  @override
  _TouchScreenFailState createState() => _TouchScreenFailState();
}

class _TouchScreenFailState extends State<TouchScreenFail> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Future init() async {
    if (!await User.auth(context)) return;
    await User.checkUserIsScanning(context);
    await Device.checkUserAnonymous(context);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _saveTouchScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(ConfigCustom.sharedPointTouchScreen, ConfigCustom.no);
    if (prefs.getString(ConfigCustom.sharedUserPay) == ConfigCustom.userFree) {
      Functions.goToRoute(context, ScannerBasicScreen.routeName);
    } else {
      await prefs.setInt(ConfigCustom.sharedStep, 2);
      Functions.goToRoute(context, AskingPhoneVoiceScreen.routeName);
    }
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
                'Check General',
                maxLines: 1,
                fontWeight: FontWeight.w900,
                textAlign: TextAlign.center,
                fontSize: 16,
                letterSpacing: ConfigCustom.letterSpacing2,
              ),
              TimerCustom(
                widget: true,
                inverse: true,
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
      child: Container(
        decoration: BoxDecoration(
          gradient: ConfigCustom.colorBgError,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: _drawerKey,
          drawer: DrawerScan(),
          primary: true,
          appBar: appBar,
          body: Container(
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      decoration: new BoxDecoration(
                        gradient: ConfigCustom.colorBgCircleOutline,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: new BoxDecoration(
                        color: ConfigCustom.colorWhite,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: ConfigCustom.globalPadding / 2),
                      child: Icon(
                        Foundation.alert,
                        color: ConfigCustom.colorError,
                        size: 60,
                      ),
                    ),
                  ],
                ),
                SpaceCustom(),
                SpaceCustom(),
                Container(
                  width: width / 1.2,
                  child: TextCustom(
                    'Touch Screen Verification Failed',
                    fontSize: 20,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SpaceCustom(),
                Container(
                  width: width / 1.2,
                  child: TextCustom(
                    'Touchscreen Failed. But you still can continue to scan your phone.',
                    textAlign: TextAlign.center,
                  ),
                ),
                SpaceCustom(),
                SpaceCustom(),
                SpaceCustom(),
                SpaceCustom(),
                ButtonSmallCustom(
                  'Next',
                  onTap: () {
                    _saveTouchScreen();
                  },
                  color: ConfigCustom.colorError,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
