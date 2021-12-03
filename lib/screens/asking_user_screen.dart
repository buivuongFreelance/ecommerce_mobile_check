import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/touch_screen.dart';
import 'package:dingtoimc/widgets/background_image.dart';
import 'package:dingtoimc/widgets/button_custom_arrow.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/walkthrough.dart';
import 'package:dots_indicator/dots_indicator.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AskingUserScreen extends StatefulWidget {
  static const routeName = '/asking_user_screen';

  @override
  _AskingUserScreenState createState() => _AskingUserScreenState();
}

class _AskingUserScreenState extends State<AskingUserScreen> {
  bool _isLoading = false;
  int currentIndexPage = 0;
  int pageLength;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  String title = '';
  String mode = '';
  List titles = [];
  List subTitles = [];
  Map user;

  Future init() async {
    if (!await User.auth(context)) return;
    try {
      String customMode = await Functions.getModeType(context);
      Map _user = await User.checkPreUserIsScanning(context);
      List _titles = [];
      List _subTitles = [];
      String _title = '';
      int _pageLength = 0;
      String sharedUserPay = _user[ConfigCustom.sharedUserPay];
      if (sharedUserPay == ConfigCustom.userFree) {
        _title = 'Basic Scan';
        _titles = [
          'Remaining Time ${_user[ConfigCustom.authTimerBasic]} : 00',
          'Check Touch Screen',
          'Scan Report',
          'Physical Grading',
          'Summary Report',
        ];
        _subTitles = [
          'You\'ve been given ${_user[ConfigCustom.authTimerBasic]} minutes to complete the scan but it should only take a couple of minutes to scan your phone.',
          'Follow the instructions on the next screen to check the integrity of your touch screen.',
          'You can share your scan report with anyone. It\'s that easy.',
          'The process of assigning a grade from A-D, based on the physical condition of a mobile device.',
          'You can see the overview of your scan results, furthermore you can save it and view again on history.'
        ];
        _pageLength = 5;
      } else if (sharedUserPay == ConfigCustom.userPro ||
          sharedUserPay == ConfigCustom.userTransaction) {
        if (sharedUserPay == ConfigCustom.userPro)
          _title = 'Pro Scan';
        else if (sharedUserPay == ConfigCustom.userTransaction) {
          _title = 'Transaction Scan';
        }
        _titles = [
          'Remaining Time ${_user[ConfigCustom.authTimer]} : 00',
          'Check Touch Screen',
          'Scan Report',
          'Check Voice / SMS',
          'Check Blacklist',
          'Physical Grading',
          'Summary Report',
        ];
        _subTitles = [
          'You\'ve been given ${_user[ConfigCustom.authTimerBasic]} minutes to complete the scan but it should only take a couple of minutes to scan your phone.',
          'Check your screen by swiping your finger across the entire screen.',
          'You can share your scan report with anyone. It\'s that easy.',
          'Check your hardware for Voice and SMS functions',
          'Check Blacklist to determine if a device has been reported lost or stolen.',
          'The process of assigning a grade from A-D, based on the physical condition of a mobile device.',
          'You can see the overview of your scan results, furthermore you can save it and view again on history.'
        ];
        _pageLength = 7;
      }
      setState(() {
        title = _title;
        titles = _titles;
        subTitles = _subTitles;
        pageLength = _pageLength;
        user = _user;
        mode = customMode;
      });
    } catch (error) {}
    currentIndexPage = 0;
  }

  Future scanPhone() async {
    try {
      setState(() {
        _isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (mode == ConfigCustom.transactionOwnerMode ||
          mode == ConfigCustom.transactionCodeLockScan) {
        String date = DateTime.now().toString();
        await prefs.setString(ConfigCustom.timerOnWeb, date);
        await Device.backendTransactionProcess(context, 2, date);
      }
      await prefs.setInt(ConfigCustom.sharedStep, 1);
      await Functions.startTimer(user[ConfigCustom.sharedUserPay]);
      setState(() {
        _isLoading = false;
      });
      Functions.goToRoute(context, TouchScreen.routeName);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget renderPageView() {
    if (Functions.isEmpty(user)) {
      return Center();
    } else {
      if (user[ConfigCustom.sharedUserPay] == ConfigCustom.userFree) {
        return PageView(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                WalkThrough(
                  textContent: 'assets/app/com_timer.png',
                ),
                Positioned(
                  bottom: 0,
                  child: Row(
                    children: [
                      TextCustom(
                        'You have ',
                        textAlign: TextAlign.center,
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                      TextCustom(
                        '${user[ConfigCustom.authTimerBasic]} : 00',
                        color: ConfigCustom.colorErrorLight,
                        textAlign: TextAlign.center,
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_touchscreen.png',
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_scan_report.png',
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_physical_grading.png',
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_summary_report.png',
            ),
          ],
          onPageChanged: (value) {
            setState(() => currentIndexPage = value);
          },
        );
      } else if (user[ConfigCustom.sharedUserPay] == ConfigCustom.userPro ||
          user[ConfigCustom.sharedUserPay] == ConfigCustom.userTransaction) {
        return PageView(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                WalkThrough(
                  textContent: 'assets/app/com_timer.png',
                ),
                Positioned(
                  bottom: 0,
                  child: Row(
                    children: [
                      TextCustom(
                        'You have ',
                        textAlign: TextAlign.center,
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                      TextCustom(
                        '${user[ConfigCustom.authTimer]} : 00',
                        color: ConfigCustom.colorErrorLight,
                        textAlign: TextAlign.center,
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_touchscreen.png',
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_scan_report.png',
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_voice_text.png',
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_blacklist.png',
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_physical_grading.png',
            ),
            WalkThrough(
              textContent: 'assets/app/com_walkthrough_summary_report.png',
            ),
          ],
          onPageChanged: (value) {
            setState(() => currentIndexPage = value);
          },
        );
      } else
        return Center();
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    PreferredSize appBar = Functions.getAppbarMain(
      context,
      Expanded(
        flex: 2,
        child: TextCustom(
          title,
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 16,
          letterSpacing: ConfigCustom.letterSpacing2,
        ),
      ),
      () {
        _drawerKey.currentState.openDrawer();
      },
    );

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: BackgroundImage(
        child: _isLoading
            ? Loading()
            : Scaffold(
                drawer: DrawerScan(),
                backgroundColor: Colors.transparent,
                key: _drawerKey,
                appBar: appBar,
                body: Functions.isEmpty(user)
                    ? Center()
                    : Center(
                        child: SingleChildScrollView(
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.only(
                                      left: ConfigCustom.globalPadding,
                                      right: ConfigCustom.globalPadding),
                                  width: MediaQuery.of(context).size.width,
                                  height: height * 0.4,
                                  child: renderPageView(),
                                ),
                                SpaceCustom(),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: new DotsIndicator(
                                      dotsCount: pageLength,
                                      position: double.tryParse(
                                          currentIndexPage.toString()),
                                      decorator: DotsDecorator(
                                        color: ConfigCustom.colorGreyWarm,
                                        activeColor: ConfigCustom.colorWhite,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ConfigCustom.globalPadding,
                                        right: ConfigCustom.globalPadding),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 20),
                                        TextCustom(
                                          titles[currentIndexPage],
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        SizedBox(height: 10),
                                        Center(
                                          child: TextCustom(
                                            subTitles[currentIndexPage],
                                            fontSize: 16,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SpaceCustom(),
                                SpaceCustom(),
                                Container(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ConfigCustom.globalPadding * 2,
                                        right: ConfigCustom.globalPadding * 2),
                                    child: ButtonCustomArrow(
                                      'Next',
                                      onTap: () {
                                        scanPhone();
                                      },
                                    ),
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
    );
  }
}
