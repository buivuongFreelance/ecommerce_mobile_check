import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/rules.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_user_screen.dart';
import 'package:dingtoimc/screens/payment_screen.dart';
import 'package:dingtoimc/screens/qr_scan_transaction_screen.dart';
import 'package:dingtoimc/widgets/background_image.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/button_readmore.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AskingProScreen extends StatefulWidget {
  static const routeName = '/asking-pro';
  @override
  _AskingProScreenState createState() => _AskingProScreenState();
}

class _AskingProScreenState extends State<AskingProScreen> {
  bool _isLoading = false;
  double _wallet;
  double _pricePro = 0.0;
  int timer = 10;
  String _countryCode = 'US';
  String mode = ConfigCustom.defaultMode;
  String transactionCode = '';

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  StreamSubscription subscription;
  ConnectivityResult connect = ConnectivityResult.wifi;

  Future _checkAuth() async {
    return await User.auth(context);
  }

  Future goToStepOnePro() async {
    if (_pricePro == 0.0) {
      Functions.confirmSomethingError(
          context, 'Network error. Unable to scan pro right now', () {});
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        if (_wallet < _pricePro) {
          Functions.confirmYesNoWarning(
              context,
              'You need to insert a SIM card to check the voice and SMS',
              'The Pro Scan requires an in-app purchase of ${Functions.formatCurrency(_pricePro, _countryCode)} per scan. Do you wish to proceed?',
              () async {
            await prefs.setString(
                ConfigCustom.sharedUserPay, ConfigCustom.userPro);
            await prefs.setBool(ConfigCustom.authIsPay, false);
            Functions.goToRoute(context, PaymentScreen.routeName);
          }, false);
        } else {
          Functions.confirmYesNoWarning(
              context,
              'You need to insert a SIM card to check the voice and SMS',
              'The Pro Scan requires an in-app purchase of ${Functions.formatCurrency(_pricePro, _countryCode)} per scan. Do you wish to proceed?',
              () {
            Functions.confirmYesNo(context,
                'You have ${Functions.formatCurrency(_wallet, _countryCode)} on your wallet, do you want to continue to scan Dingtoi',
                () async {
              setState(() {
                _isLoading = true;
              });
              await prefs.setString(
                  ConfigCustom.sharedUserPay, ConfigCustom.userPro);
              await prefs.setString(ConfigCustom.authScan, ConfigCustom.yes);
              await prefs.setBool(ConfigCustom.authIsPay, false);
              Functions.goToRoute(context, AskingUserScreen.routeName);
            }, false);
          }, false);
        }
      } catch (error) {
        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  Future goToStepOneFree() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(ConfigCustom.sharedUserPay, ConfigCustom.userFree);
      await prefs.setString(ConfigCustom.authScan, ConfigCustom.yes);

      Functions.goToRoute(context, AskingUserScreen.routeName);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget widgetTransactionSpacing() {
    if (mode == ConfigCustom.defaultMode ||
        mode == ConfigCustom.transactionCodeLockScan) {
      return SizedBox(height: 30);
    } else
      return Center();
  }

  Widget widgetDeviceSpacing() {
    if (mode == ConfigCustom.deviceScanMode) {
      return SizedBox(height: 30);
    } else
      return Center();
  }

  Widget widgetButtonCancelModeScan() {
    if (mode == ConfigCustom.deviceScanMode) {
      return ButtonCustom(
        'Exit Qr Code Scan',
        onTap: () async {
          await Functions.clearDeviceScan();
          setState(() {
            mode = ConfigCustom.defaultMode;
          });
        },
        colorOutline: ConfigCustom.colorWhite,
        color: ConfigCustom.colorWhite,
        backgroundColor: Colors.transparent,
      );
    } else {
      return Center();
    }
  }

  Future scanTransactionToAgree() async {
    setState(() {
      _isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          ConfigCustom.sharedUserPay, ConfigCustom.userTransaction);
      await prefs.setString(ConfigCustom.authScan, ConfigCustom.yes);
      await prefs.setString(
          ConfigCustom.sharedImei, prefs.getString(ConfigCustom.sharedImei));
      String transCode = '';
      if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
        transCode = prefs.getString(ConfigCustom.transactionCodeLockScan);
      }
      Map obj = await Device.transactionListCompare(context, transCode);
      String imei = obj['myScan']['imei'];
      await prefs.setString(ConfigCustom.sharedImei, imei);

      setState(() {
        _isLoading = false;
      });
      Functions.goToRoute(context, AskingUserScreen.routeName);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget widgetTransaction(widthWidget, heightWidget) {
    if (mode == ConfigCustom.defaultMode ||
        mode == ConfigCustom.transactionCodeLockScan) {
      return Container(
          decoration: BoxDecoration(
            color: ConfigCustom.colorPrimary,
            borderRadius: BorderRadius.circular(ConfigCustom.borderRadius / 2),
          ),
          width: widthWidget,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                height: heightWidget,
                width: widthWidget / 3,
                child: Container(
                  decoration: BoxDecoration(
                      color: ConfigCustom.colorWhite.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(heightWidget),
                          bottomLeft:
                              Radius.circular(ConfigCustom.borderRadius / 2),
                          topLeft:
                              Radius.circular(ConfigCustom.borderRadius / 2))),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                height: heightWidget,
                width: widthWidget / 3 + 20,
                child: Container(
                  decoration: BoxDecoration(
                      color: ConfigCustom.colorWhite.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(140),
                          bottomLeft:
                              Radius.circular(ConfigCustom.borderRadius / 2),
                          topLeft:
                              Radius.circular(ConfigCustom.borderRadius / 2))),
                ),
              ),
              InkWell(
                onTap: () {
                  if (mode != ConfigCustom.transactionCodeLockScan) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        QrScanTransactionScreen.routeName,
                        (Route<dynamic> route) => false);
                  } else {
                    scanTransactionToAgree();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: heightWidget,
                      width: widthWidget / 4,
                      child: Image.asset('assets/app/com_transaction_scan.png'),
                      padding:
                          EdgeInsets.only(left: ConfigCustom.globalPadding / 3),
                      margin:
                          EdgeInsets.only(left: ConfigCustom.globalPadding / 2),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          width: widthWidget -
                              widthWidget / 4 -
                              ConfigCustom.globalPadding / 2,
                          padding: EdgeInsets.only(
                            left: ConfigCustom.globalPadding,
                          ),
                          child: TextCustom(
                            'TRANSACTION SCAN',
                            fontWeight: FontWeight.w900,
                            color: ConfigCustom.colorWhite,
                            fontSize: 18,
                            letterSpacing: ConfigCustom.letterSpacing2,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: widthWidget -
                              widthWidget / 4 -
                              ConfigCustom.globalPadding / 2,
                          padding: EdgeInsets.only(
                            left: ConfigCustom.globalPadding,
                          ),
                          child: TextCustom(
                            '${Functions.formatCurrency(0, _countryCode)} / SCAN',
                            color: ConfigCustom.colorWhite,
                            fontSize: 15,
                            letterSpacing: ConfigCustom.letterSpacing2,
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                width: 150,
                height: 30,
                child: ButtonReadmore(
                  'Read more',
                  onTap: () {
                    Functions.readMoreInfo(
                        context,
                        "TRANSACTION SCAN",
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextCustom(
                              "The Transaction Scan is FREE and is only used to finalize the sale of a phone on the Dingtoi Marketplace.",
                              maxLines: 10,
                              fontSize: 14,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextCustom(
                              "It will perform the BASIC scan functionalities (see Basic Scan) and will prompt the seller to perform a factory reset, after which the phone will be in a locked mode and ready to ship to the buyer.",
                              maxLines: 10,
                              fontSize: 14,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    fontFamily: 'AvenirNext',
                                    fontSize: 15,
                                    color: ConfigCustom.colorWhite),
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 5,
                                      ),
                                      child: Icon(Icons.warning,
                                          color: ConfigCustom.colorSecondary),
                                    ),
                                  ),
                                  TextSpan(
                                      text:
                                          'Note that once the phone is in a locked mode, you cannot unlock it unless you are the buyer.'),
                                ],
                              ),
                            )
                          ],
                        ));
                  },
                ),
              ),
            ],
          ));
    } else
      return Center();
  }

  Widget screenMain() {
    final width = MediaQuery.of(context).size.width;
    final widthWidget = width - ConfigCustom.globalPadding * 2;
    final heightWidget = widthWidget / 2.5;

    return Center(
      child: Container(
        padding: EdgeInsets.only(
            left: ConfigCustom.globalPadding,
            right: ConfigCustom.globalPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SpaceCustom(),
              TextCustom(
                'DINGTOI SCAN',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.5,
              ),
              SpaceCustom(),
              TextCustom(
                mode == ConfigCustom.transactionCodeLockScan
                    ? 'Click Transaction Scan Below to scan this device'
                    : 'Please select the type of scan you would like to perform',
                fontSize: 16,
              ),
              SpaceCustom(),
              SpaceCustom(),
              widgetTransaction(widthWidget, heightWidget),
              widgetTransactionSpacing(),
              mode == ConfigCustom.transactionCodeLockScan
                  ? Center()
                  : Container(
                      decoration: BoxDecoration(
                        color: ConfigCustom.colorSecondary,
                        borderRadius: BorderRadius.circular(
                            ConfigCustom.borderRadius / 2),
                      ),
                      width: widthWidget,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            height: heightWidget,
                            width: widthWidget / 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ConfigCustom.colorPrimary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(140),
                                      bottomLeft: Radius.circular(
                                          ConfigCustom.borderRadius / 2),
                                      topLeft: Radius.circular(
                                          ConfigCustom.borderRadius / 2))),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            height: heightWidget,
                            width: widthWidget / 3 + 20,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ConfigCustom.colorPrimary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(140),
                                      bottomLeft: Radius.circular(
                                          ConfigCustom.borderRadius / 2),
                                      topLeft: Radius.circular(
                                          ConfigCustom.borderRadius / 2))),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              goToStepOnePro();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: widthWidget / 4,
                                  height: heightWidget,
                                  child: Image.asset(
                                      'assets/app/com_advanced_scan.png'),
                                  padding: EdgeInsets.only(
                                      left: ConfigCustom.globalPadding / 3),
                                  margin: EdgeInsets.only(
                                      left: ConfigCustom.globalPadding / 2),
                                ),
                                Column(
                                  children: <Widget>[
                                    Container(
                                      width: widthWidget -
                                          widthWidget / 4 -
                                          ConfigCustom.globalPadding / 2,
                                      padding: EdgeInsets.only(
                                        left: ConfigCustom.globalPadding,
                                      ),
                                      child: TextCustom(
                                        'PRO SCAN',
                                        fontWeight: FontWeight.w900,
                                        color: ConfigCustom.colorPrimary,
                                        fontSize: 18,
                                        letterSpacing:
                                            ConfigCustom.letterSpacing2,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      width: widthWidget -
                                          widthWidget / 4 -
                                          ConfigCustom.globalPadding / 2,
                                      padding: EdgeInsets.only(
                                        left: ConfigCustom.globalPadding,
                                      ),
                                      child: Functions.isEmpty(_pricePro)
                                          ? Center()
                                          : TextCustom(
                                              '${Functions.formatCurrency(_pricePro, _countryCode)} / SCAN',
                                              color: ConfigCustom.colorPrimary,
                                              fontSize: 15,
                                              letterSpacing:
                                                  ConfigCustom.letterSpacing2,
                                            ),
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            width: 150,
                            height: 30,
                            child: ButtonReadmore(
                              'Read more',
                              onTap: () {
                                Functions.readMoreInfo(
                                    context,
                                    "PRO SCAN",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                            "Will require in-app purchase of ${Functions.formatCurrency(_pricePro, _countryCode)} per scan.",
                                            fontSize: 14),
                                        SizedBox(height: 10),
                                        TextCustom(
                                            "The Pro Scan performs all the Basic Scan functions (see Basic Scan) PLUS:",
                                            fontSize: 14),
                                        SizedBox(height: 10),
                                        TextCustom(
                                            "- Verifies if phone is blacklisted using the phone’s IMEI number.",
                                            fontSize: 14),
                                        TextCustom(
                                            "- Verifies hardware to ensure the phone can perform Inbound/Outbound Voice calls and SMS.",
                                            fontSize: 14),
                                        TextCustom(
                                            "- Must have an active SIM card installed on the phone",
                                            fontSize: 14),
                                        SizedBox(height: 10),
                                      ],
                                    ));
                              },
                            ),
                          ),
                        ],
                      )),
              mode == ConfigCustom.transactionCodeLockScan
                  ? Center()
                  : SizedBox(height: 30),
              mode == ConfigCustom.transactionCodeLockScan
                  ? Center()
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFeef6ff),
                        borderRadius: BorderRadius.circular(
                            ConfigCustom.borderRadius / 2),
                      ),
                      width: widthWidget,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            height: heightWidget,
                            width: widthWidget / 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ConfigCustom.colorPrimary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(140),
                                      bottomLeft: Radius.circular(
                                          ConfigCustom.borderRadius / 2),
                                      topLeft: Radius.circular(
                                          ConfigCustom.borderRadius / 2))),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            height: heightWidget,
                            width: widthWidget / 3 + 20,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ConfigCustom.colorPrimary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(140),
                                      bottomLeft: Radius.circular(
                                          ConfigCustom.borderRadius / 2),
                                      topLeft: Radius.circular(
                                          ConfigCustom.borderRadius / 2))),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              goToStepOneFree();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    height: heightWidget,
                                    width: widthWidget / 4,
                                    child: Image.asset(
                                        'assets/app/com_free_scan.png'),
                                    padding: EdgeInsets.only(
                                        left: ConfigCustom.globalPadding / 3),
                                    margin: EdgeInsets.only(
                                        left: ConfigCustom.globalPadding / 2)),
                                Column(
                                  children: <Widget>[
                                    Container(
                                      width: widthWidget -
                                          widthWidget / 4 -
                                          ConfigCustom.globalPadding / 2,
                                      padding: EdgeInsets.only(
                                        left: ConfigCustom.globalPadding,
                                      ),
                                      child: TextCustom(
                                        'BASIC SCAN',
                                        fontWeight: FontWeight.w900,
                                        color: ConfigCustom.colorGreyWarm,
                                        fontSize: 18,
                                        letterSpacing:
                                            ConfigCustom.letterSpacing2,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      width: widthWidget -
                                          widthWidget / 4 -
                                          ConfigCustom.globalPadding / 2,
                                      padding: EdgeInsets.only(
                                        left: ConfigCustom.globalPadding,
                                      ),
                                      child: TextCustom(
                                        '${Functions.formatCurrency(0, _countryCode)} / SCAN',
                                        color: ConfigCustom.colorGreyWarm,
                                        fontSize: 15,
                                        letterSpacing:
                                            ConfigCustom.letterSpacing2,
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            width: 150,
                            height: 30,
                            child: ButtonReadmore(
                              'Read more',
                              onTap: () {
                                Functions.readMoreInfo(
                                    context,
                                    "BASIC SCAN",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                            "The Basic Scan verifies the following phone functions and hardware:",
                                            fontSize: 14),
                                        SizedBox(height: 10),
                                        TextCustom(
                                          "- Hardware check: phone model, storage capacity,operating system version and processor",
                                          fontSize: 14,
                                          maxLines: 5,
                                        ),
                                        TextCustom("- Touchscreen integrity",
                                            fontSize: 14),
                                        TextCustom("- Camera and Flash ",
                                            fontSize: 14),
                                        TextCustom(
                                            "- Volume, Microphone and Speaker",
                                            fontSize: 14),
                                        TextCustom("- Wi-Fi and Bluetooth",
                                            fontSize: 14),
                                        TextCustom(
                                            "- Fingerprint scanner (if equipped)",
                                            fontSize: 14),
                                        TextCustom(
                                            "- Face ID scanner (if equipped)",
                                            fontSize: 14),
                                      ],
                                    ));
                              },
                            ),
                          ),
                        ],
                      )),
              mode == ConfigCustom.transactionCodeLockScan
                  ? Center()
                  : widgetDeviceSpacing(),
              mode == ConfigCustom.transactionCodeLockScan
                  ? Center()
                  : widgetButtonCancelModeScan(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Future init() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double inAppPricePro = 0.0;
    double wallet = 0.0;
    int twilioNumber = 0;
    String inAppItem = '';
    String countryCode = '';
    int timerBasic = 0;
    try {
      if (!await _checkAuth()) return;
      await User.emptyUserIsScanning();

      transactionCode = await Device.checkIsPhoneTransactionScanWidget(context);

      String permission =
          await Functions.checkPermissionWithService2(Permission.location);

      if (permission == ConfigCustom.yes) {
        Position position = await Geolocator().getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            locationPermissionLevel: GeolocationPermission.locationWhenInUse);

        List<Placemark> p = await Geolocator()
            .placemarkFromCoordinates(position.latitude, position.longitude);

        Placemark place = p[0];

        countryCode = place.isoCountryCode;
        await prefs.setString(ConfigCustom.sharedCountryCode, countryCode);
      } else {
        countryCode = ConfigCustom.others;
        await prefs.setString(
            ConfigCustom.sharedCountryCode, ConfigCustom.others);
      }

      wallet = await User.getWallet(context);

      List list = await Rules.listSettings(context);
      for (int i = 0; i < list.length; i++) {
        if (list[i]['key'] == 'dingtoi_pro_price') {
          inAppPricePro = double.tryParse(list[i]['value'].toString());
        }
        if (list[i]['key'] == 'twilio_number') {
          twilioNumber = int.tryParse(list[i]['value'].toString());
        }
        if (list[i]['key'] == 'dingtoi_pro_id') {
          inAppItem = list[i]['value'];
        }
        if (list[i]['key'] == 'timer') {
          timer = int.tryParse(list[i]['value'].toString());
        }
        if (list[i]['key'] == 'timer_basic') {
          timerBasic = int.tryParse(list[i]['value'].toString());
        }
      }
      await prefs.setDouble(ConfigCustom.authPricePro, inAppPricePro);
      await prefs.setInt(ConfigCustom.authTwilioNumber, twilioNumber);
      await prefs.setString(ConfigCustom.authProItem, inAppItem);
      await prefs.setInt(ConfigCustom.authTimer, timer);
      await prefs.setInt(ConfigCustom.authTimerBasic, timerBasic);
    } catch (error) {
      await prefs.remove(ConfigCustom.authToken);
      Functions.goToRoute(context, AskingProScreen.routeName);
      Functions.confirmError(context, () {});
    }
    String customMode = await Functions.getModeType(context);
    if (customMode == ConfigCustom.deviceScanMode) {
      try {
        await Device.checkDeviceExists(
            context, prefs.get(ConfigCustom.deviceIdWeb));
      } catch (error) {
        if (error == ConfigCustom.errNotExists) {
          await prefs.remove(ConfigCustom.deviceIdWeb);
          await prefs.setBool(ConfigCustom.authFromWeb, false);
          customMode = ConfigCustom.defaultMode;
          Functions.confirmOkModel(
              context,
              'Device Not Sync With Dingtoi Marketplace. Please Scan Again',
              () => {});
        }
      }
    }
    if (mounted) {
      setState(() {
        _wallet = wallet;
        _isLoading = false;
        _pricePro = inAppPricePro;
        _countryCode = countryCode;
        mode = customMode;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != connect) {
        connect = result;
        init();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = screenMain();
    PreferredSize appBar = Functions.getAppbarMain(
        context,
        Expanded(
          flex: 1,
          child: Image.asset(
            'assets/app/com_logo_white.png',
          ),
        ), () {
      _drawerKey.currentState.openDrawer();
    });

    return BackgroundImage(
      child: _isLoading
          ? Loading()
          : Scaffold(
              key: _drawerKey,
              backgroundColor: Colors.transparent,
              appBar: appBar,
              body: widget,
              drawer: DrawerCustom(),
            ),
    );
  }
}
