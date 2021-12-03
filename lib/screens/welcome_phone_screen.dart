import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/ask_phone_manual_screen.dart';
import 'package:dingtoimc/screens/login_screen.dart';
import 'package:dingtoimc/screens/phone_form_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:dingtoimc/widgets/walkthrough.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePhoneScreen extends StatefulWidget {
  static const routeName = '/welcome_phone_screen';
  @override
  _WelcomePhoneScreenState createState() => _WelcomePhoneScreenState();
}

class _WelcomePhoneScreenState extends State<WelcomePhoneScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool _isLoading = false;

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool checkIsPhoneTransactionScan =
        await Device.checkIsPhoneTransactionScan(context);
    if (checkIsPhoneTransactionScan) {
      Functions.goToRoute(context, LoginScreen.routeName);
    }
    if (!await User.auth(context)) return;
    setState(() {
      _isLoading = true;
    });

    await User.checkUserIsScanning(context);
    await Device.checkUserAnonymous(context);
    await Device.checkScannerBasic(context);

    await prefs.setString(ConfigCustom.sharedVoiceInbound, ConfigCustom.no);
    await prefs.setString(ConfigCustom.sharedVoiceOutbound, ConfigCustom.no);
    await prefs.setString(ConfigCustom.sharedTextInbound, ConfigCustom.no);
    await prefs.setString(ConfigCustom.sharedTextOutbound, ConfigCustom.no);
    setState(() {
      _isLoading = false;
    });
  }

  int currentIndexPage = 0;
  int pageLength;

  var titles = [
    'Voice Inbound',
    'Voice Outbound',
    'SMS Inbound',
    'SMS Outbound',
  ];

  var subTitles = [
    'Voice Inbound is what your phone receives for incoming calls.',
    'Voice Outbound is what your phone made outcoming calls.',
    'SMS Inbound is what your phone receives for incoming SMS.',
    'SMS Outbound is what your phone made outcoming SMS.',
  ];

  @override
  void initState() {
    init();
    currentIndexPage = 0;
    pageLength = 4;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _next() async {
    Functions.goToRoute(context, PhoneFormScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    PreferredSize appBar = Functions.getAppbarMainBack(
        context,
        Expanded(
          flex: 1,
          child: Image.asset(
            'assets/app/com_logo_white.png',
          ),
        ), () {
      _drawerKey.currentState.openDrawer();
    }, () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingPhoneVoiceManualScreen.routeName,
          (Route<dynamic> route) => false);
    });

    var height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: _isLoading
          ? Loading()
          : Container(
              color: ConfigCustom.colorPrimary,
              child: Scaffold(
                  key: _drawerKey,
                  backgroundColor: Colors.transparent,
                  appBar: appBar,
                  drawer: DrawerScan(),
                  body: Stack(
                    children: <Widget>[
                      TimerCustom(
                        widget: false,
                      ),
                      Container(
                        color: ConfigCustom.colorWhite,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: PageView(
                          children: <Widget>[
                            WalkThrough(
                                textContent:
                                    'assets/app/com_walkthrough_phone_1.png',
                                height: height * 0.7),
                            WalkThrough(
                              textContent:
                                  'assets/app/com_walkthrough_phone_2.png',
                              height: height * 0.7,
                            ),
                            WalkThrough(
                              textContent:
                                  'assets/app/com_walkthrough_phone_3.png',
                              height: height * 0.7,
                            ),
                            WalkThrough(
                              textContent:
                                  'assets/app/com_walkthrough_phone_4.png',
                              height: height * 0.7,
                            ),
                          ],
                          onPageChanged: (value) {
                            setState(() => currentIndexPage = value);
                          },
                        ),
                      ),
                      Positioned(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        top: height * 0.42,
                        child: Align(
                          alignment: Alignment.center,
                          child: new DotsIndicator(
                            dotsCount: 4,
                            position:
                                double.tryParse(currentIndexPage.toString()),
                            decorator: DotsDecorator(
                              color: ConfigCustom.colorGreyWarm,
                              activeColor: ConfigCustom.colorPrimary,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        width: MediaQuery.of(context).size.width,
                        top: MediaQuery.of(context).size.height * 0.43,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 20),
                              TextCustom(
                                titles[currentIndexPage],
                                fontSize: 20,
                                color: ConfigCustom.colorPrimary,
                              ),
                              SizedBox(height: 10),
                              Center(
                                child: TextCustom(
                                  subTitles[currentIndexPage],
                                  fontSize: 18,
                                  color: ConfigCustom.colorSteel,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: ButtonCustom(
                            'Skip To Check',
                            onTap: () {
                              _next();
                            },
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
    );
  }
}
