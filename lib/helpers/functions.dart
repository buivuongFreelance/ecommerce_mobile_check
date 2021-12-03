import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_torch/flutter_torch.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_control/volume_control.dart';

import '../widgets/space_custom.dart';

class Functions {
  static Future clearDeviceScan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ConfigCustom.authFromWeb, false);
    if (prefs.containsKey(ConfigCustom.sharedImei)) {
      await prefs.remove(ConfigCustom.sharedImei);
    }
    if (prefs.containsKey(ConfigCustom.sharedPointPhysical)) {
      await prefs.remove(ConfigCustom.sharedPointPhysical);
    }
  }

  static Future<String> getModeType(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      bool checkIsPhoneTransactionScan =
          await Device.checkIsPhoneTransactionScan(context);
      if (checkIsPhoneTransactionScan) {
        return ConfigCustom.transactionCodeLockScan;
      } else if (prefs.containsKey(ConfigCustom.transactionCodeOwnerWeb)) {
        return ConfigCustom.transactionOwnerMode;
      } else {
        if (prefs.containsKey(ConfigCustom.authFromWeb)) {
          if (prefs.getBool(ConfigCustom.authFromWeb)) {
            return ConfigCustom.deviceScanMode;
          } else {
            return ConfigCustom.defaultMode;
          }
        } else {
          return ConfigCustom.defaultMode;
        }
      }
    } catch (error) {
      return ConfigCustom.defaultMode;
    }
  }

  static int getPhysicalGradingPoint(String grade) {
    int point = 0;
    switch (grade) {
      case 'A':
        point = 50;
        break;
      case 'B':
        point = 40;
        break;
      case 'C':
        point = 30;
        break;
      default:
        point = 0;
        break;
    }
    return point;
  }

  static Future<Map> getObjectQrCodeDeviceAuth(String str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List arrStr = str.split('%');
    if (arrStr.length != 5) {
      return {
        'error': ConfigCustom.isNotValid,
      };
    }
    await prefs.setInt(
      ConfigCustom.sharedPointPhysical,
      getPhysicalGradingPoint(arrStr[1]),
    );
    await prefs.setString(
      ConfigCustom.sharedImei,
      arrStr[4],
    );
    await prefs.setString(
      ConfigCustom.deviceIdWeb,
      arrStr[2],
    );
    return {
      'email': arrStr[0],
      'physicalGrading': arrStr[1],
      'deviceId': arrStr[2],
      'status': arrStr[3],
      'imei': arrStr[4],
    };
  }

  static Future<Map> getObjectQrCodeDeviceNotAuth(String str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List arrStr = str.split('%');
    if (arrStr.length != 5) {
      return {
        'error': ConfigCustom.isNotValid,
      };
    }
    await prefs.setInt(
      ConfigCustom.sharedPointPhysical,
      getPhysicalGradingPoint(arrStr[1]),
    );
    await prefs.setString(
      ConfigCustom.sharedImei,
      arrStr[4],
    );
    await prefs.setString(
      ConfigCustom.deviceIdWeb,
      arrStr[2],
    );
    return {
      'email': arrStr[0],
      'physicalGrading': arrStr[1],
      'deviceId': arrStr[2],
      'status': arrStr[3],
      'imei': arrStr[4],
    };
  }

  static String countryParse(code) {
    String c = '';
    switch (code) {
      case 'VN':
        c = 'Viet Nam';
        break;
      case 'US':
        c = 'USA';
        break;
      case 'CA':
        c = 'Canada';
        break;
      default:
        c = code;
    }
    return c;
  }

  static Future startTimer(type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.authTimer) &&
        prefs.containsKey(ConfigCustom.authTimerBasic)) {
      int timer = prefs.getInt(ConfigCustom.authTimer);
      if (type == ConfigCustom.userFree)
        timer = prefs.getInt(ConfigCustom.authTimerBasic);
      await prefs.setString(
        ConfigCustom.authStartTimer,
        DateTime.now().toString(),
      );

      await prefs.setString(
          ConfigCustom.authEndTimer,
          DateTime.now()
              .add(
                Duration(
                  minutes: timer,
                ),
              )
              .toString());
    }
  }

  static void goToRoute(context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false);
    });
  }

  static String convertCodeToCurrency(code) {
    String str = 'USD';
    switch (code) {
      case 'US':
        str = 'USD';
        break;
      case 'CA':
        str = 'CAD';
        break;
      case 'VN':
        str = 'VND';
        break;
    }
    return str;
  }

  static double exchangeFromUS(code) {
    double n = 1.0;
    switch (code) {
      case 'CA':
        n = 1.34;
        break;
      case 'VN':
        n = 23180;
        break;
    }
    return n;
  }

  static String formatCurrency(double number, String code) {
    Currency currency = Currency.create(
      convertCodeToCurrency(code),
      2,
    );

    double exchangeRate = exchangeFromUS(code);
    double newNumber = number * exchangeRate;
    if (code == 'VN')
      return '${Money.from(newNumber, currency).format('###,###').toString()} Đ';
    else
      return Money.from(newNumber, currency).format('SCC ###.###').toString();
  }

  static String formatDuration(Duration d) {
    String f(int n) {
      return n.toString().padLeft(2, '0');
    }

    // We want to round up the remaining time to the nearest second
    d += Duration(microseconds: 999999);
    return "${f(d.inMinutes)}:${f(d.inSeconds % 60)}";
  }

  static Future<String> getTemporaryPath() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    return Future.value(tempPath);
  }

  static Future<String> checkPermissionWithService(
      PermissionWithService permission) async {
    if (!await permission.serviceStatus.isEnabled) {
      if (await permission.request().isGranted) {
        return Future.value(ConfigCustom.yes);
      } else
        return Future.value(ConfigCustom.no);
    }
    if (await permission.isPermanentlyDenied) {
      return Future.value(ConfigCustom.isPermanent);
    }
    PermissionStatus status = await permission.status;
    if (status.isUndetermined || status.isDenied || status.isRestricted) {
      if (await permission.request().isGranted) {
        return Future.value(ConfigCustom.yes);
      } else
        return Future.value(ConfigCustom.no);
    } else if (status.isGranted) {
      return Future.value(ConfigCustom.yes);
    } else {
      return Future.value(ConfigCustom.no);
    }
  }

  static Future<String> checkPermissionWithService2(
      PermissionWithService permission) async {
    if (!await permission.serviceStatus.isEnabled) {
      return Future.value(ConfigCustom.isDisabled);
    }
    if (await permission.isPermanentlyDenied) {
      return Future.value(ConfigCustom.isPermanent);
    }
    PermissionStatus status = await permission.status;
    if (status.isUndetermined || status.isDenied || status.isRestricted) {
      if (await permission.request().isGranted) {
        return Future.value(ConfigCustom.yes);
      } else
        return Future.value(ConfigCustom.no);
    } else if (status.isGranted) {
      return Future.value(ConfigCustom.yes);
    } else {
      return Future.value(ConfigCustom.no);
    }
  }

  static Future<String> checkPermission(Permission permission) async {
    if (await permission.isPermanentlyDenied) {
      return Future.value(ConfigCustom.isPermanent);
    }
    PermissionStatus status = await permission.status;
    if (status.isUndetermined || status.isDenied || status.isRestricted) {
      if (await Permission.locationWhenInUse.request().isGranted) {
        return Future.value(ConfigCustom.yes);
      } else
        return Future.value(ConfigCustom.no);
    } else if (status.isGranted) {
      return Future.value(ConfigCustom.yes);
    } else {
      return Future.value(ConfigCustom.no);
    }
  }

  static double getScannerPointRating(total) {
    double rating = 0;

    if (total < 10) {
      rating = 1;
    } else if (total >= 10 && total <= 19) {
      rating = 2;
    } else if (total >= 20 && total <= 29) {
      rating = 3;
    } else if (total >= 30 && total <= 39) {
      rating = 4;
    } else if (total >= 40 && total <= 50) {
      rating = 5;
    }

    return rating;
  }

  static String getDateCustom(dt) {
    DateTime datetime = DateTime.parse(dt);
    return DateFormat.yMEd().format(datetime);
  }

  static String getTimeCustom(dt) {
    DateTime datetime = DateTime.parse(dt);
    return DateFormat.jms().format(datetime);
  }

  static String getDateTime(DateTime dt) {
    return DateFormat.yMEd().add_jms().format(dt);
  }

  static Future<dynamic> getPreferenceAttr(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return Future.value(prefs.get(key));
    } else
      return Future.value(ConfigCustom.notVerified);
  }

  static Future checkBluetooth() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      FlutterBlue flutterBlue = FlutterBlue.instance;
      String available =
          await flutterBlue.isAvailable ? ConfigCustom.yes : ConfigCustom.no;
      await prefs.setString(ConfigCustom.sharedPointBluetooth, available);
      return available;
    } catch (error) {
      return Future.value(ConfigCustom.notVerified);
    }
  }

  static Future checkWifi() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (connectivityResult != ConnectivityResult.none) {
        await prefs.setString(ConfigCustom.sharedPointWifi, ConfigCustom.yes);
        return Future.value(ConfigCustom.yes);
      } else {
        await prefs.setString(ConfigCustom.sharedPointWifi, ConfigCustom.no);
        return Future.value(ConfigCustom.no);
      }
    } catch (error) {
      return Future.error(ConfigCustom.notVerified);
    }
  }

  static bool containsSimple(List list, String str) {
    for (String e in list) {
      if (e == str) return true;
    }
    return false;
  }

  static Future checkVolume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      double _val = await VolumeControl.volume;
      if (_val >= 0)
        await prefs.setString(ConfigCustom.sharedPointVolume, ConfigCustom.yes);
      else
        await prefs.setString(ConfigCustom.sharedPointVolume, ConfigCustom.no);
      return await Future.value(ConfigCustom.yes);
    } catch (error) {
      return Future.error(ConfigCustom.notVerified);
    }
  }

  static Future checkFlash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String available =
          await FlutterTorch.hasLamp ? ConfigCustom.yes : ConfigCustom.no;
      await prefs.setString(ConfigCustom.sharedPointFlash, available);
      return available;
    } catch (error) {
      return Future.value(ConfigCustom.notVerified);
    }
  }

  static String formatMB(double number) {
    return '${number.round()}GB';
  }

  static Future<Map> getDiskSpace() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      double free = await DiskSpace.getFreeDiskSpace;
      double total = await DiskSpace.getTotalDiskSpace;

      double used = total - free;

      double totalGB = total / 1024;
      double totalAll = 0;

      if (totalGB <= 8)
        totalAll = 8;
      else if (totalGB > 8 && totalGB <= 16)
        totalAll = 16;
      else if (totalGB > 16 && totalGB <= 32)
        totalAll = 32;
      else if (totalGB > 32 && totalGB <= 64)
        totalAll = 64;
      else if (totalGB > 64 && totalGB <= 128)
        totalAll = 128;
      else if (totalGB > 128 && totalGB <= 256)
        totalAll = 256;
      else if (totalGB > 256 && totalGB <= 512)
        totalAll = 512;
      else if (totalGB > 512 && totalGB <= 1024) totalGB = 1024;

      double systemGB = totalAll - totalGB;
      used = used / 1024 + systemGB;
      if (!isEmpty(total)) {
        await prefs.setString(
            ConfigCustom.sharedPointStorageUsed, formatMB(used));
        await prefs.setString(
            ConfigCustom.sharedPointStorage, '${totalAll.round()}GB');
      } else {
        await prefs.setString(
            ConfigCustom.sharedPointStorageUsed, ConfigCustom.notVerified);
        await prefs.setString(
            ConfigCustom.sharedPointStorage, ConfigCustom.notVerified);
      }

      return Future.value(
          {'used': formatMB(used), 'total': '${totalAll.round()}GB'});
    } catch (error) {
      return Future.value({
        'used': ConfigCustom.notVerified,
        'total': ConfigCustom.notVerified
      });
    }
  }

  static Future onCheckPoint(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var physicalGrading = prefs.get(ConfigCustom.sharedPointPhysical);
    var scannerPoint = prefs.get(ConfigCustom.sharedPointScanner);

    if (isEmpty(physicalGrading) || isEmpty(scannerPoint)) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
      return Future.value({});
    } else {
      return Future.value({
        'physicalGrading': physicalGrading,
        'scannerPoint': scannerPoint,
      });
    }
  }

  static Future<bool> confirmOkModel(context, text, callbackOk) {
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
                          TextCustom(
                            text,
                            fontSize: 20,
                            textAlign: TextAlign.center,
                          ),
                          SpaceCustom(),
                          SpaceCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  callbackOk();
                                },
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
                                      'OK',
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

  static Future<bool> confirmErrorScanQRModel(context, text, callbackOk) {
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            builder: (BuildContext bc) {
              return Wrap(
                children: [
                  Stack(alignment: Alignment.topCenter, children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 22),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: ConfigCustom.globalPadding * 2,
                          bottom: ConfigCustom.globalPadding * 1.5,
                          left: ConfigCustom.globalPadding,
                          right: ConfigCustom.globalPadding,
                        ),
                        decoration: BoxDecoration(
                          gradient: ConfigCustom.colorBgError,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(ConfigCustom.borderRadius2),
                          ),
                        ),
                        child: Center(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text,
                              SpaceCustom(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      callbackOk();
                                    },
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
                                          'OK',
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
                        child: Icon(Icons.warning,
                            color: ConfigCustom.colorErrorLight2, size: 30),
                        backgroundColor: ConfigCustom.colorErrorLight,
                      ),
                    )
                  ]),
                ],
              );
            }) ??
        false;
  }

  static Future<bool> confirmError(context, callbackOk) {
    return confirmOkModel(
        context,
        'Network server under construction. Please retry after a few minutes!',
        callbackOk);
  }

  static Future<bool> confirmAlertConnectivity(context, callbackOk) {
    return confirmOkModel(
        context, 'Please connect to internet and try again', callbackOk);
  }

  static Future<bool> confirmSomethingError(context, message, callbackOk) {
    return confirmOkModel(context, message, callbackOk);
  }

  static Future<bool> confirmScanAgain(context) async {
    String customMode = await Functions.getModeType(context);

    return confirmYesNo(context, 'Do you want to scan again?', () {
      if (customMode == ConfigCustom.transactionOwnerMode) {
        Device.backendTransactionProcess(context, -2, '');
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
    }, false);
  }

  static Future<bool> confirmYesNoWarning(
      context, waring, text, callbackYes, noClose) {
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            builder: (BuildContext bc) {
              return Wrap(
                children: [
                  Stack(alignment: Alignment.topCenter, children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 22),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: ConfigCustom.globalPadding * 2,
                          bottom: ConfigCustom.globalPadding * 1.5,
                          left: ConfigCustom.globalPadding,
                          right: ConfigCustom.globalPadding,
                        ),
                        decoration: BoxDecoration(
                          gradient: ConfigCustom.colorBg,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(ConfigCustom.borderRadius2),
                          ),
                        ),
                        child: Center(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextCustom(
                                waring,
                                fontSize: 18,
                                textAlign: TextAlign.center,
                                color: ConfigCustom.colorSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                              SpaceCustom(),
                              TextCustom(
                                text,
                                fontSize: 20,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              ),
                              SpaceCustom(),
                              SpaceCustom(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
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
                                          "NO",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  new FlatButton(
                                    onPressed: () {
                                      if (noClose == false)
                                        Navigator.of(context).pop();
                                      callbackYes();
                                    },
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
                                          "YES",
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
                  ]),
                ],
              );
            }) ??
        false;
  }

  static Future<bool> confirmYesNo(context, text, callbackYes, noClose) {
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            builder: (BuildContext bc) {
              return Wrap(
                children: [
                  Stack(alignment: Alignment.topCenter, children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 22),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: ConfigCustom.globalPadding * 2,
                          bottom: ConfigCustom.globalPadding * 1.5,
                          left: ConfigCustom.globalPadding,
                          right: ConfigCustom.globalPadding,
                        ),
                        decoration: BoxDecoration(
                          gradient: ConfigCustom.colorBg,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(ConfigCustom.borderRadius2),
                          ),
                        ),
                        child: Center(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextCustom(
                                text,
                                fontSize: 20,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              ),
                              SpaceCustom(),
                              SpaceCustom(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
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
                                          "NO",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  new FlatButton(
                                    onPressed: () {
                                      if (noClose == false)
                                        Navigator.of(context).pop();
                                      callbackYes();
                                    },
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
                                          "YES",
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
                  ]),
                ],
              );
            }) ??
        false;
  }

  static Future<bool> confirmLostToken(context, callbackOk) {
    return confirmOkModel(
        context, 'You lost token or not login. Please Login !', () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      goToRoute(context, WelcomeScreen.routeName);
    });
  }

  static Future<bool> confirmLostScan(context) {
    return confirmOkModel(
        context, 'You ran out of time to scan. Please Scan Again !', () {
      goToRoute(context, AskingProScreen.routeName);
    });
  }

  static Future<bool> readMoreInfo(context, title, content) {
    return showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            builder: (BuildContext bc) {
              return Wrap(
                children: [
                  Stack(alignment: Alignment.topCenter, children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        top: 22,
                      ),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: ConfigCustom.globalPadding * 2,
                          bottom: ConfigCustom.globalPadding * 1.5,
                          left: ConfigCustom.globalPadding,
                          right: ConfigCustom.globalPadding,
                        ),
                        decoration: BoxDecoration(
                          gradient: ConfigCustom.colorBg,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(ConfigCustom.borderRadius2),
                          ),
                        ),
                        child: Center(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              TextCustom(
                                title,
                                maxLines: 1,
                                fontWeight: FontWeight.w900,
                              ),
                              SizedBox(height: 10),
                              content,
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
                  ]),
                ],
              );
            }) ??
        false;
  }

  static bool isEmpty(value) {
    if (value is Map) {
      var _list = value.values.toList();
      if (_list.length == 0)
        return true;
      else
        return false;
    } else {
      if ([0, false, '', null, [], ConfigCustom.no].contains(value))
        return true;
      else
        return false;
    }
  }

  static Widget getAppbarHeader(context, child) {
    return PreferredSize(
      preferredSize: Size(double.infinity, 100),
      child: SafeArea(
        child: Container(
          height: ConfigCustom.heightBar,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(
            left: ConfigCustom.globalPadding / 2,
            right: ConfigCustom.globalPadding / 2,
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget getItemIcon(
      context, IconData iconData, onTap, Alignment alignment) {
    return Expanded(
      flex: 1,
      child: Container(
        alignment: alignment,
        width: MediaQuery.of(context).size.width,
        height: ConfigCustom.heightBar,
        child: InkWell(
          customBorder: new CircleBorder(),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(ConfigCustom.globalPadding / 2.5),
            child: Icon(
              iconData,
              color: ConfigCustom.colorWhite,
            ),
          ),
        ),
      ),
    );
  }

  static PreferredSize getAppbarScanner(context, widget, callbackMenu) {
    return getAppbarHeader(
      context,
      Row(
        children: <Widget>[
          getItemIcon(context, SimpleLineIcons.refresh, () {
            Functions.confirmYesNo(context, 'Do you want to scan again ?', () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  AskingProScreen.routeName, (Route<dynamic> route) => false);
            }, false);
          }, Alignment.centerLeft),
          widget,
          getItemIcon(context, SimpleLineIcons.menu, callbackMenu,
              Alignment.centerRight),
        ],
      ),
    );
  }

  static PreferredSize getAppbar(context, widget, callbackBack) {
    return getAppbarHeader(
      context,
      Row(
        children: <Widget>[
          getItemIcon(context, SimpleLineIcons.arrow_left, callbackBack,
              Alignment.centerLeft),
          widget,
          Expanded(
            flex: 1,
            child: Center(),
          ),
        ],
      ),
    );
  }

  static PreferredSize getAppbarMain(context, widget, callbackMenu) {
    return getAppbarHeader(
      context,
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Center(),
          ),
          widget,
          getItemIcon(context, SimpleLineIcons.menu, callbackMenu,
              Alignment.centerRight),
        ],
      ),
    );
  }

  static PreferredSize getAppbarMainBack(
      context, widget, callbackMenu, callbackBack) {
    return getAppbarHeader(
      context,
      Row(
        children: <Widget>[
          getItemIcon(context, SimpleLineIcons.arrow_left, callbackBack,
              Alignment.centerLeft),
          widget,
          getItemIcon(context, SimpleLineIcons.menu, callbackMenu,
              Alignment.centerRight),
        ],
      ),
    );
  }

  static PreferredSize getAppbarMainHome(
      context, widget, callbackMenu, callbackBack) {
    return getAppbarHeader(
      context,
      Row(
        children: <Widget>[
          getItemIcon(context, SimpleLineIcons.home, callbackBack,
              Alignment.centerLeft),
          widget,
          getItemIcon(context, SimpleLineIcons.menu, callbackMenu,
              Alignment.centerRight),
        ],
      ),
    );
  }
}
