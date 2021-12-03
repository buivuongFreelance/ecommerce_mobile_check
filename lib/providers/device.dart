import 'dart:convert' show json;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:dingtoimc/helpers/api.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/lock_phone_screen.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:imei_plugin/imei_plugin.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Device {
  static Future<String> checkIsPhoneTransactionScanWidget(context) async {
    // return ConfigCustom.no;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String deviceAppId = '';
      if (prefs.containsKey(ConfigCustom.transactionCodeLockScan))
        deviceAppId = prefs.getString(ConfigCustom.transactionCodeLockScan);

      String status = await Device.checkTransactionQrCodeBuyer(
          context, deviceAppId, prefs.getString(ConfigCustom.authEmail));
      if (status == ConfigCustom.isLocked) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            LockPhoneScreen.routeName, (Route<dynamic> route) => false);
        return ConfigCustom.yes;
      } else if (status == ConfigCustom.isNormal) {
        return ConfigCustom.no;
      } else {
        return ConfigCustom.yes;
      }
    } catch (error) {
      return ConfigCustom.no;
    }
  }

  static Future<bool> checkIsPhoneTransactionScan(context) async {
    try {
      bool statusCheck = await Device.checkQrCode(context);
      return statusCheck;
    } catch (error) {
      return false;
    }
  }

  static Future checkQrCode(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());

    String deviceAppId = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.transactionCodeLockScan))
      deviceAppId = prefs.getString(ConfigCustom.transactionCodeLockScan);
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/checkQrCode';

    String bearer = prefs.getString(ConfigCustom.authToken) != null
        ? prefs.getString(ConfigCustom.authToken)
        : 'bearer';

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $bearer',
    };

    try {
      http.Response result = await http
          .post(
            url,
            body: {
              'deviceId': deviceAppId,
            },
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future transactionListCompare(context, transactionCode) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/transaction/listCompare';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    try {
      http.Response result = await http
          .post(
            url,
            body: {
              'transactionCode': transactionCode,
            },
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future transactionBuyerAccept(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/transaction/buyerAccept';

    String deviceAppId = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.transactionCodeLockScan))
      deviceAppId = prefs.getString(ConfigCustom.transactionCodeLockScan);

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    try {
      http.Response result = await http
          .post(
            url,
            body: {
              'transactionCode': deviceAppId,
            },
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future backendTransactionProcess(context, step, timeout) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/transaction/process';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    String transactionCode =
        prefs.getString(ConfigCustom.transactionCodeOwnerWeb);

    if (transactionCode == null || transactionCode.isEmpty) {
      transactionCode = prefs.getString(ConfigCustom.transactionCodeLockScan);
    }

    try {
      http.Response result = await http
          .post(
            url,
            body: {
              'step': step.toString(),
              'timeout': timeout.toString(),
              'transactionId': transactionCode,
            },
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future backendGetDeviceScan(context, deviceScanId) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/deviceScan/$deviceScanId';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    try {
      http.Response result = await http
          .get(
            url,
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future transactionBuyerReject(
      context, transactionCode, questions) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/transaction/buyerReject';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    try {
      http.Response result = await http
          .post(
            url,
            body: {
              'transactionCode': transactionCode,
              'questions': json.encode(questions)
            },
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future listQuestionBuyerReject(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/question/listQuestionBuyerReject';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    try {
      http.Response result = await http
          .get(
            url,
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future checkTransactionQrCodeBuyer(
      context, String transactionCode, String email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    if (email == null) {
      return Future.value(ConfigCustom.isNormal);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/checkTransactionQrCodeBuyer';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': prefs.containsKey(ConfigCustom.authToken)
            ? 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
            : 'Bearer 111'
      };
      http.Response result = await http
          .post(
            url,
            body: {'transactionCode': transactionCode, 'email': email},
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        if (body['obj'] == ConfigCustom.errTransactionAuthorized)
          throw ConfigCustom.errTransactionAuthorized;
        else
          throw ConfigCustom.errUsage;
      } else {
        return Future.value(body['obj']);
      }
    } catch (error) {
      throw error;
    }
  }

  static Future checkTransactionQrCode(
      context, String transactionCode, String email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/checkTransactionQrCode';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            body: {'transactionCode': transactionCode, 'email': email},
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        if (body['obj'] == ConfigCustom.errTransactionAuthorized)
          throw ConfigCustom.errTransactionAuthorized;
        else
          throw ConfigCustom.errUsage;
      } else {
        return Future.value(body['obj']);
      }
    } catch (error) {
      throw error;
    }
  }

  static Future sendInboundText(context, String aliasCode) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/text/inbound';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            body: {'phone_number': aliasCode.toString()},
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return Future.value(body['status']);
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future sendVerificationInboundText(
    context,
    String phoneNumber,
    String type,
    String code,
  ) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/text/inbound/verification';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            body: {
              'phone_number': phoneNumber,
              'type': type,
              'code': code,
            },
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        if (body.containsKey('done')) {
          if (body['done'] == ConfigCustom.notExists)
            throw ConfigCustom.notExists;
        } else
          throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return Future.value(body['status']);
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future sendVerificationInbound(
    context,
    String phoneNumber,
    String type,
    String code,
  ) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/call/inbound/verification';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            body: {
              'phone_number': phoneNumber,
              'type': type,
              'code': code,
            },
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        if (body.containsKey('done')) {
          if (body['done'] == ConfigCustom.notExists)
            throw ConfigCustom.notExists;
        } else
          throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return Future.value(body['status']);
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future sendInbound(context, String aliasCode) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/call/inbound';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            body: {'phone_number': aliasCode.toString()},
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return Future.value(body['status']);
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future<String> getDeviceId() async {
    String uniqueId = '';
    if (Platform.isAndroid) {
      uniqueId = await ImeiPlugin.getId();
    } else {
      uniqueId = await ImeiPlugin.getImei();
    }
    return uniqueId;
  }

  static Future detailScanningHistoryWeb(
    context,
    String id,
  ) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/scanningWebHistory/$id';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
    };

    try {
      http.Response result = await http
          .get(
            url,
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        if (body.containsKey('obj')) {
          if (body['obj'] == ConfigCustom.notExists)
            throw ConfigCustom.notExists;
        } else
          throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return Future.value(body['obj']);
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future detailScanningHistory(
    context,
    String id,
  ) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/scanningHistory/$id';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .get(
            url,
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        if (body.containsKey('done')) {
          if (body['done'] == ConfigCustom.notExists)
            throw ConfigCustom.notExists;
        } else
          throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return Future.value(body['detail']);
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future checkDeviceExists(context, deviceId) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/device/check';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            body: {'deviceId': deviceId},
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        if (body['obj'] == ConfigCustom.errNotExists) {
          throw ConfigCustom.errNotExists;
        } else {
          throw ConfigCustom.errUsage;
        }
      } else {
        return Future.value('');
      }
    } catch (error) {
      throw error;
    }
  }

  static Future listScanningHistory(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String uniqueId = await getDeviceId();

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/scanningHistory';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            body: {
              'unique_id': uniqueId,
            },
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return Future.value(body['list']);
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future checkBlacklistStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedBlacklistStatus) &&
        prefs.containsKey(ConfigCustom.sharedBlacklistType)) {
      return Future.value({
        ConfigCustom.sharedBlacklistStatus:
            prefs.getString(ConfigCustom.sharedBlacklistStatus),
        ConfigCustom.sharedBlacklistType:
            prefs.getString(ConfigCustom.sharedBlacklistType),
      });
    } else {
      return Future.value({});
    }
  }

  static Future checkBlacklist(context, String imei, String countryCode) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/blacklist/check';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http.post(
        url,
        body: {
          'imei': imei,
          'countryCode': countryCode,
        },
        headers: requestHeaders,
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return '';
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 422) {
        throw ConfigCustom.errImei;
      } else {
        if (body.containsKey('done')) {
          return Future.value({'status': body['status'], 'type': body['type']});
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future checkScannerBasic(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var model = await prefs.get(ConfigCustom.sharedDeviceModel);
    var hardware = await prefs.get(ConfigCustom.sharedPointProcessor);
    var osRele = await prefs.get(ConfigCustom.sharedPointReleased);
    var storageUsed = await prefs.get(ConfigCustom.sharedPointStorageUsed);
    var storageTotal = await prefs.get(ConfigCustom.sharedPointStorage);
    var camera = await prefs.get(ConfigCustom.sharedPointCamera);
    var flash = await prefs.get(ConfigCustom.sharedPointFlash);
    var volume = await prefs.get(ConfigCustom.sharedPointVolume);
    var finger = await prefs.get(ConfigCustom.sharedPointFinger);
    var faceid = await prefs.get(ConfigCustom.sharedPointFaceID);
    var wifi = await prefs.get(ConfigCustom.sharedPointWifi);
    var bluetooth = await prefs.get(ConfigCustom.sharedPointBluetooth);
    var touchscreen = await prefs.get(ConfigCustom.sharedPointTouchScreen);
    var timestamp = await prefs.get(ConfigCustom.sharedTimestamp);
    var microphone = await prefs.get(ConfigCustom.sharedPointMicrophone);

    if (Functions.isEmpty(model) ||
        Functions.isEmpty(hardware) ||
        Functions.isEmpty(osRele) ||
        Functions.isEmpty(storageUsed) ||
        Functions.isEmpty(storageTotal) ||
        Functions.isEmpty(timestamp)) {
      Functions.goToRoute(context, AskingProScreen.routeName);
      return Future.value({});
    } else {
      String brand = '';
      if (Platform.isIOS) {
        brand = 'Apple';
        Map deviceInfo = await getDeviceInfoIOS(model);
        model = deviceInfo[ConfigCustom.sharedDeviceModel];
      } else if (Platform.isAndroid) {
        try {
          List list = await Device.listAndroidByModel(model);
          if (list.length > 0) {
            model = list[0]['modelName'];
            if (model.contains('Samsung'))
              brand = 'Samsung';
            else
              brand = ConfigCustom.notVerified;
          }
        } catch (error) {
          brand = 'Samsung';
        }
      }

      return Future.value({
        ConfigCustom.sharedDeviceModel: model,
        'brand': brand,
        ConfigCustom.sharedPointProcessor: hardware,
        ConfigCustom.sharedPointReleased: osRele,
        ConfigCustom.sharedPointStorageUsed: storageUsed,
        ConfigCustom.sharedPointStorage: storageTotal,
        ConfigCustom.sharedPointCamera: camera,
        ConfigCustom.sharedPointFlash: flash,
        ConfigCustom.sharedPointVolume: volume,
        ConfigCustom.sharedPointFinger: finger,
        ConfigCustom.sharedPointFaceID: faceid,
        ConfigCustom.sharedPointWifi: wifi,
        ConfigCustom.sharedPointBluetooth: bluetooth,
        ConfigCustom.sharedPointMicrophone: microphone,
        ConfigCustom.sharedPointTouchScreen: touchscreen,
        ConfigCustom.sharedTimestamp: DateTime.parse(timestamp),
      });
    }
  }

  static Future checkCamera() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      List cameras = await availableCameras();
      String available;
      if (Functions.isEmpty(cameras.length)) {
        await prefs.setString(ConfigCustom.sharedPointCamera, ConfigCustom.no);
        available = ConfigCustom.no;
      } else {
        await prefs.setString(ConfigCustom.sharedPointCamera, ConfigCustom.yes);
        available = ConfigCustom.yes;
      }
      return Future.value(available);
    } catch (error) {
      return Future.value(ConfigCustom.notVerified);
    }
  }

  static Future checkBiometricsFace(List systemFeatures) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var localAuth = LocalAuthentication();
      bool canCheckBiometrics = await localAuth.canCheckBiometrics;

      if (Platform.isAndroid) {
        if (!systemFeatures.contains('com.samsung.android.bio.face') &&
            !systemFeatures.contains('android.hardware.camera2.params.Face') &&
            !systemFeatures.contains('android.hardware.Camera.Face')) {
          await prefs.setString(
              ConfigCustom.sharedPointFaceID, ConfigCustom.nothave);
          return Future.value(ConfigCustom.nothave);
        } else {
          if (!canCheckBiometrics) {
            await prefs.setString(
                ConfigCustom.sharedPointFaceID, ConfigCustom.no);
            return Future.value(ConfigCustom.no);
          } else {
            await prefs.setString(
                ConfigCustom.sharedPointFaceID, ConfigCustom.yes);
            return Future.value(ConfigCustom.yes);
          }
        }
      } else {
        if (!systemFeatures.contains('ios.hardware.face')) {
          await prefs.setString(
              ConfigCustom.sharedPointFaceID, ConfigCustom.nothave);
          return Future.value(ConfigCustom.nothave);
        } else {
          if (!canCheckBiometrics) {
            await prefs.setString(
                ConfigCustom.sharedPointFaceID, ConfigCustom.no);
            return Future.value(ConfigCustom.no);
          } else {
            await prefs.setString(
                ConfigCustom.sharedPointFaceID, ConfigCustom.yes);
            return Future.value(ConfigCustom.yes);
          }
        }
      }
    } catch (error) {
      return Future.value(ConfigCustom.notAvailable);
    }
  }

  static Future checkBiometricsFingerprint(
      List systemFeatures, String brand) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var localAuth = LocalAuthentication();
      bool canCheckBiometrics = await localAuth.canCheckBiometrics;
      if (Platform.isAndroid) {
        if (!systemFeatures.contains('android.hardware.fingerprint') &&
            !systemFeatures.contains('android.hardware.biometrics')) {
          await prefs.setString(
              ConfigCustom.sharedPointFinger, ConfigCustom.nothave);
          return Future.value(ConfigCustom.nothave);
        } else {
          if (!canCheckBiometrics) {
            await prefs.setString(
                ConfigCustom.sharedPointFinger, ConfigCustom.no);
            return Future.value(ConfigCustom.no);
          } else {
            await prefs.setString(
                ConfigCustom.sharedPointFinger, ConfigCustom.yes);
            return Future.value(ConfigCustom.yes);
          }
        }
      } else {
        if (!systemFeatures.contains('ios.hardware.fingerprint')) {
          await prefs.setString(
              ConfigCustom.sharedPointFinger, ConfigCustom.nothave);
          return Future.value(ConfigCustom.nothave);
        } else {
          if (!canCheckBiometrics) {
            await prefs.setString(
                ConfigCustom.sharedPointFinger, ConfigCustom.no);
            return Future.value(ConfigCustom.no);
          } else {
            await prefs.setString(
                ConfigCustom.sharedPointFinger, ConfigCustom.yes);
            return Future.value(ConfigCustom.yes);
          }
        }
      }
    } catch (error) {
      return Future.value(ConfigCustom.notVerified);
    }
  }

  static Future checkMicrophone(List systemFeatures, String brand) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (Platform.isAndroid) {
        if (!systemFeatures.contains('android.hardware.microphone')) {
          await prefs.setString(
              ConfigCustom.sharedPointMicrophone, ConfigCustom.no);
          return Future.value(ConfigCustom.no);
        } else {
          await prefs.setString(
              ConfigCustom.sharedPointMicrophone, ConfigCustom.yes);
          return Future.value(ConfigCustom.yes);
        }
      } else if (Platform.isIOS) {
        if (!systemFeatures.contains('ios.hardware.microphone')) {
          await prefs.setString(
              ConfigCustom.sharedPointMicrophone, ConfigCustom.no);
          return Future.value(ConfigCustom.no);
        } else {
          await prefs.setString(
              ConfigCustom.sharedPointMicrophone, ConfigCustom.yes);
          return Future.value(ConfigCustom.yes);
        }
      }
    } catch (error) {
      return Future.value(ConfigCustom.notVerified);
    }
  }

  static Future<bool> checkTouchscreen(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (prefs.containsKey(ConfigCustom.sharedPointTouchScreen)) {
        var sharedPointTouchScreen =
            prefs.get(ConfigCustom.sharedPointTouchScreen);
        if (sharedPointTouchScreen == ConfigCustom.yes)
          return Future.value(true);
        else
          return Future.value(false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            AskingProScreen.routeName, (Route<dynamic> route) => false);
        return Future.value(false);
      }
    } catch (error) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
      return Future.value(false);
    }
  }

  static Future checkUserAnonymous(context) async {}

  static Future<Map> checkBlacklistIcloud(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedBacklist)) {
      return Future.value({
        ConfigCustom.sharedBacklist: prefs.get(ConfigCustom.sharedBacklist),
      });
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
      return Future.value({
        ConfigCustom.sharedBacklist: ConfigCustom.no,
      });
    }
  }

  static Future<Map> checkSim(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedSim)) {
      return Future.value({
        ConfigCustom.sharedSim: prefs.get(ConfigCustom.sharedSim),
      });
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
      return Future.value({
        ConfigCustom.sharedSim: ConfigCustom.no,
      });
    }
  }

  static Future<Map> checkImeiCountryCode(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedImei) &&
        prefs.containsKey(ConfigCustom.sharedCountryCode)) {
      if (Functions.isEmpty(prefs.get(ConfigCustom.sharedImei))) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            AskingProScreen.routeName, (Route<dynamic> route) => false);
        return Future.value({
          ConfigCustom.sharedImei: ConfigCustom.no,
          ConfigCustom.sharedCountryCode: ConfigCustom.no,
        });
      } else {
        return Future.value({
          ConfigCustom.sharedImei: prefs.get(ConfigCustom.sharedImei),
          ConfigCustom.sharedCountryCode:
              prefs.get(ConfigCustom.sharedCountryCode),
        });
      }
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
      return Future.value({
        ConfigCustom.sharedImei: ConfigCustom.no,
        ConfigCustom.sharedCountryCode: ConfigCustom.no,
      });
    }
  }

  static Future getTouchscreen(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(ConfigCustom.sharedPointTouchScreen)) {
      String touchscreen = prefs.getString(ConfigCustom.sharedPointTouchScreen);
      return Future.value(touchscreen);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
      return Future.value(ConfigCustom.no);
    }
  }

  static Future<Map> getDeviceDataAndroid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;

      await prefs.setString(ConfigCustom.sharedPointProcessor, info.hardware);
      await prefs.setString(
          ConfigCustom.sharedPointReleased, info.version.release.toString());
      await prefs.setString(ConfigCustom.sharedDeviceModel, info.model);

      String model = info.model;
      List list = await Device.listAndroidByModel(model);

      if (list.length > 0) {
        model = list[0]['modelName'];
      }

      return Future.value({
        ConfigCustom.sharedDeviceModel: model,
        ConfigCustom.sharedPointProcessor: info.hardware,
        ConfigCustom.sharedPointReleased: info.version.release.toString(),
        'brand': info.brand == 'samsung' ? 'Samsung' : info.brand,
        'systemFeatures': info.systemFeatures,
      });
    } catch (error) {
      return Future.value({
        ConfigCustom.sharedDeviceModel: ConfigCustom.notVerified,
        ConfigCustom.sharedPointProcessor: ConfigCustom.notVerified,
        ConfigCustom.sharedPointReleased: ConfigCustom.notVerified,
        'brand': ConfigCustom.notVerified,
        'systemFeatures': [],
      });
    }
  }

  static Future listAndroidByModel(model) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/android/list';

    try {
      http.Response result = await http.post(
        url,
        body: {'model': model},
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (body.containsKey('done'))
        return body['list'];
      else
        return [];
    } catch (error) {
      return [];
    }
  }

  static Future getDeviceDataIOS() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      IosDeviceInfo info = await deviceInfoPlugin.iosInfo;

      Map device = await getDeviceInfoIOS(info.utsname.machine);
      await prefs.setString(
          ConfigCustom.sharedDeviceModel, info.utsname.machine);
      await prefs.setString(
          ConfigCustom.sharedPointProcessor, device['processor']);
      await prefs.setString(
          ConfigCustom.sharedPointReleased, info.systemVersion);

      return Future.value({
        'machine': info.utsname.machine,
        ConfigCustom.sharedPointReleased: info.systemVersion,
        'brand': 'Apple',
        'systemFeatures': [],
      });
    } catch (error) {
      return Future.value({
        'machine': ConfigCustom.notVerified,
        ConfigCustom.sharedPointReleased: ConfigCustom.notVerified,
        'brand': 'Apple',
        'systemFeatures': [],
      });
    }
  }

  static Future processSanner(Map obj, Map deviceInfo) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-lite/device/scanner';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'tokenUser': obj['tokenUser'],
          'tokenDevice': obj['tokenDevice'],
          'deviceInfo': json.encode(deviceInfo),
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      int statusCode = result.statusCode;
      if (statusCode == 400) return false;
      Map body = json.decode(result.body);
      if (body.containsKey('done'))
        return body['done'];
      else
        throw ConfigCustom.notFoundKey;
    } catch (error) {
      throw error;
    }
  }

  static Future uploadImage(file) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/upload/image';

    Dio dio = new Dio();
    try {
      FormData formData = new FormData.fromMap({
        'image': await MultipartFile.fromFile(file, filename: "file.png"),
      });

      Response response = await dio.post(url, data: formData);

      if (response.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (response.data.containsKey('done'))
          return response.data['url'];
        else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future saveCommentReport(context, id, comment) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/summaryReport/saveComment';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    try {
      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'comment': comment,
          'id': id,
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return body['done'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future updateConfirmReport(context, id, type, Map obj) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/summaryReport/physicalUpdate';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    obj.remove(ConfigCustom.sharedTimestamp);

    try {
      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'main_info': json.encode(obj),
          'type': type,
          'id': id,
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return body['done'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future updateConfirmReportWeb(context, id, type, Map obj) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/summaryWebReport';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    obj.remove(ConfigCustom.sharedTimestamp);

    try {
      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'mainInfo': json.encode(obj),
          'type': type,
          'id': id,
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future onwerScanAccept(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/ownerScanAccept';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(ConfigCustom.transactionCodeOwnerWeb)) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
    }

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    String transactionCode =
        prefs.getString(ConfigCustom.transactionCodeOwnerWeb);

    try {
      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'transactionCode': transactionCode,
          'deviceAppId': transactionCode,
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future updateConfirmReportTransactionWeb(
      context, id, type, Map obj) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/summaryTransactionWebReport';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    obj.remove(ConfigCustom.sharedTimestamp);

    String transactionCode = '';
    if (type == ConfigCustom.transactionCodeLockScanSummary) {
      transactionCode = prefs.getString(ConfigCustom.transactionCodeLockScan);
    } else {
      transactionCode = prefs.getString(ConfigCustom.transactionCodeOwnerWeb);
    }

    try {
      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'mainInfo': json.encode(obj),
          'type': type,
          'id': id,
          'transactionCode': transactionCode
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future confirmReportWeb(
      context, mode, timestamp, pay, mainUrl, Map obj) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/confirmWebReport';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };
    obj.remove(ConfigCustom.sharedTimestamp);

    try {
      String transactionCode = '';
      String uniqueId = await Device.getDeviceId();

      if (mode == ConfigCustom.transactionCodeLockScan) {
        pay = ConfigCustom.transactionCodeLockScan;
        transactionCode = prefs.getString(ConfigCustom.transactionCodeLockScan);
      } else if (prefs.containsKey(ConfigCustom.transactionCodeOwnerWeb)) {
        transactionCode = prefs.getString(ConfigCustom.transactionCodeOwnerWeb);
      }

      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'timestamp': timestamp.toString(),
          'mainInfo': json.encode(obj),
          'type': pay,
          'mainUrl': mainUrl,
          'deviceId': uniqueId,
          'email': prefs.getString(ConfigCustom.authEmail),
          'realDeviceId': prefs.containsKey(ConfigCustom.deviceIdWeb)
              ? prefs.getString(ConfigCustom.deviceIdWeb)
              : '',
          'transactionCode': transactionCode,
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          return body['obj'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future confirmReport(context, timestamp, pay, mainUrl, Map obj) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/summaryReport';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    obj.remove(ConfigCustom.sharedTimestamp);

    try {
      String deviceId = await getDeviceId();

      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'timestamp': timestamp.toString(),
          'main_info': json.encode(obj),
          'type': pay,
          'main_url': mainUrl,
          'device_id': deviceId,
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done')) {
          return body['id'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future getDeviceInfoIOS(value) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/device/ios/check';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    try {
      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {'value': value},
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('obj')) {
          Map result = body['obj'];
          return {
            ConfigCustom.sharedDeviceModel: result['model'],
            ConfigCustom.sharedPointProcessor: result['processor'],
            'systemFeatures': result['systemFeatures']
          };
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }
}
