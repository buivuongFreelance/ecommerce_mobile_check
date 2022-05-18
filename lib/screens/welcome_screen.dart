import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/login_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/walkthrough.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart' show PlatformException;
// import 'package:shared_preferences/shared_preferences.dart';

import 'asking_pro_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isLoading = false;
  bool isCheckQrCode = true;

  Future _checkAuth() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString(ConfigCustom.transactionCodeLockScan,
    //     'a03b5820-9d8f-11eb-8143-0f4898fc0763');

    // test clear cache transaction
    // await prefs.remove(ConfigCustom.transactionCodeOwnerWeb);
    // await prefs.remove(ConfigCustom.transactionCodeLockScan);
    // end test clear cache transaction
    await User.notAuth(context);
  }

  Future scan() async {
    setState(() {
      isLoading = true;
    });
    try {
      ScanResult result = await BarcodeScanner.scan();
      if (result.rawContent != '') {
        Map obj =
            await Functions.getObjectQrCodeDeviceNotAuth(result.rawContent);
        if (!obj.containsKey('error')) {
          setState(() {
            isCheckQrCode = true;
          });
          await User.loginWithQrCode(obj['email']);
          Functions.goToRoute(context, AskingProScreen.routeName);
        } else {
          if (obj['error'] == ConfigCustom.isNotValid) {
            Functions.confirmOkModel(context,
                'QR Code You Scan For this feature is not right', () {});
          }
        }
      }
    } on PlatformException catch (err) {
      if (err.code == 'PERMISSION_NOT_GRANTED') {
        setState(() {
          isCheckQrCode = true;
        });
        Functions.confirmErrorScanQRModel(
            context,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    'Dingtoi need access Camera permission to scan QR Code. Please click on ',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: ConfigCustom.colorWhite,
                  fontFamily: 'AvenirNext',
                  height: 1.7,
                  fontSize: 20,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Open Setting',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          AppSettings.openAppSettings();
                        },
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ConfigCustom.colorPrimary)),
                  TextSpan(
                    text: ' and go to enable Camera permission for Dingtoi.',
                  ),
                ],
              ),
            ),
            () {});
      }
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  int currentIndexPage = 0;
  int pageLength;
  StreamSubscription subscription;
  ConnectivityResult connect = ConnectivityResult.wifi;

  List titles = [
    'Welcome to the Dingtoi App!',
  ];

  List subTitles = [
    'This App will run a diagnostic scan of the basic functions of your phone to make sure it’s working.',
  ];

  @override
  void initState() {
    _checkAuth();
    currentIndexPage = 0;
    pageLength = 3;
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

  Widget widgetDesc() {
    if (currentIndexPage > 0) {
      return Center(
        child: TextCustom(
          subTitles[currentIndexPage],
          fontSize: 16,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      );
    } else {
      if (isCheckQrCode) {
        return Center(
          child: TextCustom(
            subTitles[currentIndexPage],
            fontSize: 16,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        );
      } else {
        return Center(
          child: TextCustom(
            'Please enable or turn on permission camera to scan QR Code',
            fontSize: 16,
            textAlign: TextAlign.center,
            maxLines: 3,
            color: ConfigCustom.colorError,
          ),
        );
      }
    }
  }

  Widget widgetTitle() {
    if (currentIndexPage > 0) {
      return TextCustom(
        titles[currentIndexPage],
        fontSize: 18,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w900,
      );
    } else {
      if (isCheckQrCode) {
        return TextCustom(
          titles[currentIndexPage],
          fontSize: 18,
          fontWeight: FontWeight.w900,
        );
      } else {
        return TextCustom(
          'Camera Permission',
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: ConfigCustom.colorError,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double widthWidget = width - ConfigCustom.globalPadding * 4;
    double height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: null,
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    SafeArea(
                      child: Center(
                        child: Container(
                          width: widthWidget / 1.5,
                          child: Image.asset(
                            'assets/app/com_logo_white.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SpaceCustom(),
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
                            textContent: 'assets/app/com_device_scan.png',
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
                            SizedBox(height: 20),
                            widgetTitle(),
                            SizedBox(height: 10),
                            widgetDesc(),
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
                              child: isCheckQrCode
                                  ? ButtonCustom(
                                      'Sign In With Qr Code',
                                      onTap: () {
                                        scan();
                                      },
                                    )
                                  : ButtonCustom(
                                      'Retry Scan',
                                      color: ConfigCustom.colorErrorLight,
                                      backgroundColor: ConfigCustom.colorWhite,
                                      onTap: () {
                                        scan();
                                      },
                                    ),
                            ),
                          ),
                    SpaceCustom(),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: ConfigCustom.globalPadding * 2,
                            right: ConfigCustom.globalPadding * 2),
                        child: ButtonCustom(
                          'Sign In',
                          color: ConfigCustom.colorPrimary,
                          backgroundColor: ConfigCustom.colorWhite,
                          onTap: () {
                            Functions.goToRoute(context, LoginScreen.routeName);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
