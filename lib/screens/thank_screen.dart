import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/button_icon_os.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'dart:io' show Platform;

import '../widgets/loading.dart';

class ThankScreen extends StatefulWidget {
  static const routeName = '/thank';

  @override
  _ThankScreenState createState() => _ThankScreenState();
}

class _ThankScreenState extends State<ThankScreen> {
  bool _isLoading = false;
  String transactionCode = '';
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Future _rateApp() async {
    if (Platform.isAndroid) {
      StoreRedirect.redirect();
    } else if (Platform.isIOS) {
      StoreRedirect.redirect(iOSAppId: '1525501556');
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
      transactionCode = prefs.getString(ConfigCustom.transactionCodeLockScan);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double widthWidget =
        MediaQuery.of(context).size.width - ConfigCustom.globalPadding * 4;

    PreferredSize appBar = Functions.getAppbarScanner(
        context,
        TextCustom(
          '',
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      _drawerKey.currentState.openDrawer();
    });
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _drawerKey,
        appBar: transactionCode.isEmpty ? appBar : null,
        drawer: DrawerCustom(),
        body: _isLoading
            ? Loading()
            : GestureClickOutside(
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: Container(
                          width: widthWidget,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: width,
                                  child: Image.asset(
                                    'assets/app/com_thanks_text.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SpaceCustom(),
                                SpaceCustom(),
                                SizedBox(
                                  width: width,
                                  child: Image.asset(
                                    'assets/app/com_thanks.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SpaceCustom(),
                                SpaceCustom(),
                                Center(
                                    child: Container(
                                        width: width,
                                        child: ButtonWithIconOS(
                                          Platform.isIOS
                                              ? 'assets/app/com_apple.png'
                                              : 'assets/app/com_google_play.png',
                                          'Please rate us on',
                                          Platform.isIOS
                                              ? 'APPLE STORE'
                                              : 'GOOGLE PLAY',
                                          onTap: () {
                                            _rateApp();
                                          },
                                        ))),
                                SpaceCustom(),
                                transactionCode.isEmpty
                                    ? Center(
                                        child: Container(
                                          width: width,
                                          child: ButtonCustom(
                                            'Scan Again',
                                            backgroundColor: Colors.transparent,
                                            color: ConfigCustom.colorWhite,
                                            colorOutline:
                                                ConfigCustom.colorWhite,
                                            onTap: () {
                                              Navigator.of(context)
                                                  .pushNamedAndRemoveUntil(
                                                      AskingProScreen.routeName,
                                                      (Route<dynamic> route) =>
                                                          false);
                                            },
                                          ),
                                        ),
                                      )
                                    : Center(),
                                SpaceCustom(),
                                SpaceCustom(),
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
    );
  }
}
