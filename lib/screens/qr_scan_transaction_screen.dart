import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_user_screen.dart';
import 'package:dingtoimc/widgets/background_image.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/walkthrough.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'asking_pro_screen.dart';

class QrScanTransactionScreen extends StatefulWidget {
  static const routeName = '/qr_scan_transaction_screen';
  @override
  _QrScanTransactionScreenState createState() =>
      _QrScanTransactionScreenState();
}

class _QrScanTransactionScreenState extends State<QrScanTransactionScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  bool isLoading = false;
  int currentIndexPage = 0;
  int pageLength = 1;
  StreamSubscription subscription;
  ConnectivityResult connect = ConnectivityResult.wifi;

  var titles = [
    'Scan Transaction Device',
  ];

  var subTitles = [
    'This Feature will scan your device and complete transaction for this device on Dingtoi Marketplace',
  ];

  Future _checkAuth() async {
    return await User.auth(context);
  }

  Future init() async {
    if (!await _checkAuth()) return;
    await User.emptyUserIsScanning();
  }

  Future scan() async {
    setState(() {
      isLoading = true;
    });
    try {
      ScanResult result = await BarcodeScanner.scan();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.rawContent != '') {
        List arrStr = result.rawContent.split('%');
        String transactionCode = arrStr[0];
        String email = arrStr[1];
        Map detail = await Device.checkTransactionQrCode(
            context, transactionCode, email);
        if (detail.containsKey('physical_grading')) {
          int physicalGrading = 0;
          if (detail['physical_grading'] == 'A') {
            physicalGrading = 50;
          } else if (detail['physical_grading'] == 'B') {
            physicalGrading = 50;
          } else if (detail['physical_grading'] == 'C') {
            physicalGrading = 30;
          }
          prefs.setInt(ConfigCustom.sharedPointPhysical, physicalGrading);
        }
        if (prefs.containsKey(ConfigCustom.authEmail) && detail.isNotEmpty) {
          await prefs.setString(
              ConfigCustom.transactionCodeOwnerWeb, transactionCode);
          await prefs.setString(
              ConfigCustom.sharedUserPay, ConfigCustom.userTransaction);
          await prefs.setString(ConfigCustom.authScan, ConfigCustom.yes);
          await prefs.setString(ConfigCustom.sharedImei, detail['imei']);
          await Device.backendTransactionProcess(context, 1, '');
          Functions.goToRoute(context, AskingUserScreen.routeName);
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else if (error == ConfigCustom.errTransactionAuthorized) {
        Functions.confirmOkModel(context,
            'You have no authorization to scan this transaction', () {});
      } else {
        Functions.confirmError(context, () {});
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    init();

    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != connect) {
        connect = result;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  Widget screenMain() {
    double height = MediaQuery.of(context).size.height;

    return Center(
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
                child: PageView(
                  children: <Widget>[
                    WalkThrough(
                      textContent: 'assets/app/com_transaction_scan.png',
                    ),
                  ],
                  onPageChanged: (value) {
                    setState(() => currentIndexPage = value);
                  },
                ),
              ),
              SpaceCustom(),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: ConfigCustom.globalPadding,
                      right: ConfigCustom.globalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 14),
                      TextCustom(
                        titles[currentIndexPage],
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: TextCustom(
                          subTitles[currentIndexPage],
                          fontSize: 16,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SpaceCustom(),
              SpaceCustom(),
              isLoading
                  ? Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: ConfigCustom.globalPadding * 2,
                            right: ConfigCustom.globalPadding * 2),
                        child: LoadingWidget(),
                      ),
                    )
                  : Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: ConfigCustom.globalPadding * 2,
                            right: ConfigCustom.globalPadding * 2),
                        child: ButtonCustom(
                          'Scan Qr Code',
                          onTap: () {
                            scan();
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = screenMain();
    PreferredSize appBar = Functions.getAppbarMainHome(
        context,
        TextCustom(
          'Qr Transaction Scan',
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      _drawerKey.currentState.openDrawer();
    }, () {
      Functions.goToRoute(context, AskingProScreen.routeName);
    });
    return WillPopScope(
        onWillPop: () {
          Functions.goToRoute(context, AskingProScreen.routeName);
          return Future.value(false);
        },
        child: BackgroundImage(
          child: Scaffold(
            key: _drawerKey,
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: widget,
            drawer: DrawerCustom(),
          ),
        ));
  }
}
