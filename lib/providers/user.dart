import 'dart:convert' show json;

import 'package:connectivity/connectivity.dart';
import 'package:dingtoimc/helpers/api.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class User {
  static Future loginWithQrCode(email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/loginQrCode';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('obj')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Map user = body['obj'];
          await prefs.setString(ConfigCustom.authEmail, user['email']);
          await prefs.setString(ConfigCustom.authUserId, user['id']);
          await prefs.setString(ConfigCustom.authToken, user['token']);
          await prefs.setDouble(
              ConfigCustom.authWallet,
              Functions.isEmpty(user['wallet'])
                  ? 0
                  : double.tryParse(user['wallet'].toString()));
          await prefs.setBool(ConfigCustom.authFromWeb, true);
          return body['user'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future getWallet(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/user/wallet';

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
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('done')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          double wallet = Functions.isEmpty(body['wallet'])
              ? 0
              : double.tryParse(body['wallet'].toString());
          await prefs.setDouble(ConfigCustom.authWallet, wallet);
          return wallet;
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future addWallet(context, wallet) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/wallet/plus';

    try {
      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'money': wallet.toString(),
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        throw ConfigCustom.errCommon;
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

  static Future removeWallet(context, wallet) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}',
    };

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/wallet/minus';

    try {
      http.Response result = await http.post(
        url,
        headers: requestHeaders,
        body: {
          'money': wallet.toString(),
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        Functions.confirmLostToken(context, () {});
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('done')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool(ConfigCustom.authIsPay, true);
          return body['done'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future emptyTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.authStartTimer)) {
      await prefs.remove(ConfigCustom.authStartTimer);
    }
    if (prefs.containsKey(ConfigCustom.authEndTimer)) {
      await prefs.remove(ConfigCustom.authEndTimer);
    }
    if (prefs.containsKey(ConfigCustom.sharedStep)) {
      await prefs.remove(ConfigCustom.sharedStep);
    }
  }

  static Future emptyUserIsScanning() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.authScan)) {
      await prefs.remove(ConfigCustom.authScan);
    }
    if (prefs.containsKey(ConfigCustom.sharedUserPay)) {
      await prefs.remove(ConfigCustom.sharedUserPay);
    }
    if (prefs.containsKey(ConfigCustom.sharedBacklist)) {
      await prefs.remove(ConfigCustom.sharedBacklist);
    }
    if (prefs.containsKey(ConfigCustom.sharedBlacklistStatus)) {
      await prefs.remove(ConfigCustom.sharedBlacklistStatus);
    }
    if (prefs.containsKey(ConfigCustom.sharedBlacklistType)) {
      await prefs.remove(ConfigCustom.sharedBlacklistType);
    }
    if (prefs.containsKey(ConfigCustom.sharedVoice)) {
      await prefs.remove(ConfigCustom.sharedVoice);
    }
    if (prefs.containsKey(ConfigCustom.sharedText)) {
      await prefs.remove(ConfigCustom.sharedText);
    }
    if (prefs.containsKey(ConfigCustom.sharedStep)) {
      await prefs.remove(ConfigCustom.sharedStep);
    }
    if (prefs.containsKey(ConfigCustom.sharedPointPhysical)) {
      //if (!prefs.get(ConfigCustom.authFromWeb))
      await prefs.remove(ConfigCustom.sharedPointPhysical);
    }
    if (prefs.containsKey(ConfigCustom.sharedCountryCode)) {
      await prefs.remove(ConfigCustom.sharedCountryCode);
    }
    if (prefs.containsKey(ConfigCustom.authPricePro)) {
      await prefs.remove(ConfigCustom.authPricePro);
    }
    if (prefs.containsKey(ConfigCustom.authIsPay)) {
      await prefs.remove(ConfigCustom.authIsPay);
    }
    if (prefs.containsKey(ConfigCustom.authStartTimer)) {
      await prefs.remove(ConfigCustom.authStartTimer);
    }
    if (prefs.containsKey(ConfigCustom.authEndTimer)) {
      await prefs.remove(ConfigCustom.authEndTimer);
    }
    if (prefs.containsKey(ConfigCustom.sharedIsCheckPhoneManual)) {
      await prefs.remove(ConfigCustom.sharedIsCheckPhoneManual);
    }
    if (prefs.containsKey(ConfigCustom.sharedIsCheckTextManual)) {
      await prefs.remove(ConfigCustom.sharedIsCheckTextManual);
    }
    if (prefs.containsKey(ConfigCustom.sharedSelectedScanId)) {
      await prefs.remove(ConfigCustom.sharedSelectedScanId);
    }
    if (prefs.containsKey(ConfigCustom.transactionCodeOwnerWeb)) {
      await prefs.remove(ConfigCustom.transactionCodeOwnerWeb);
    }
  }

  static Future checkPreUserIsScanning(context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userPay = prefs.get(ConfigCustom.sharedUserPay);
      var userScan = prefs.get(ConfigCustom.authScan);
      var timerPro = prefs.get(ConfigCustom.authTimer);
      var timerBasic = prefs.get(ConfigCustom.authTimerBasic);

      if (Functions.isEmpty(userPay) || Functions.isEmpty(userScan)) {
        Functions.confirmLostScan(context);
        return {
          ConfigCustom.sharedUserPay: ConfigCustom.userFree,
          ConfigCustom.authScan: ConfigCustom.no,
          ConfigCustom.authTimer: 0,
          ConfigCustom.authTimerBasic: 0,
        };
      } else {
        return {
          ConfigCustom.sharedUserPay: userPay,
          ConfigCustom.authScan: userScan,
          ConfigCustom.authTimer: timerPro,
          ConfigCustom.authTimerBasic: timerBasic,
        };
      }
    } catch (error) {
      Functions.confirmLostScan(context);
      return {
        ConfigCustom.sharedUserPay: ConfigCustom.userFree,
        ConfigCustom.authScan: ConfigCustom.no,
      };
    }
  }

  static Future checkUserIsScanning(context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userPay = prefs.get(ConfigCustom.sharedUserPay);
      var userScan = prefs.get(ConfigCustom.authScan);
      var userStartTimer = prefs.get(ConfigCustom.authStartTimer);
      var userEndTimer = prefs.get(ConfigCustom.authEndTimer);

      if (Functions.isEmpty(userPay) ||
          Functions.isEmpty(userScan) ||
          Functions.isEmpty(userStartTimer) ||
          Functions.isEmpty(userEndTimer)) {
        Functions.confirmLostScan(context);
        return {
          ConfigCustom.sharedUserPay: ConfigCustom.userFree,
          ConfigCustom.authScan: ConfigCustom.no,
          ConfigCustom.authStartTimer: DateTime.now(),
          ConfigCustom.authEndTimer: DateTime.now(),
        };
      } else {
        return {
          ConfigCustom.sharedUserPay: userPay,
          ConfigCustom.authScan: userScan,
          ConfigCustom.authStartTimer:
              DateTime.tryParse(userStartTimer.toString()),
          ConfigCustom.authEndTimer: DateTime.tryParse(userEndTimer.toString()),
        };
      }
    } catch (error) {
      Functions.confirmLostScan(context);
      return {
        ConfigCustom.sharedUserPay: ConfigCustom.userFree,
        ConfigCustom.authScan: ConfigCustom.no,
        ConfigCustom.authStartTimer: DateTime.now(),
        ConfigCustom.authEndTimer: DateTime.now(),
      };
    }
  }

  static Future checkAuth() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString(ConfigCustom.authEmail);
      String userId = prefs.getString(ConfigCustom.authUserId);
      String token = prefs.getString(ConfigCustom.authToken);

      if (!Functions.isEmpty(email) &&
          !Functions.isEmpty(userId) &&
          !Functions.isEmpty(token)) {
        if (prefs.containsKey(ConfigCustom.authWallet))
          return {
            'email': email,
            'userId': userId,
            'token': token,
          };
        else
          throw ConfigCustom.errCommon;
      } else
        throw ConfigCustom.errCommon;
    } catch (error) {
      throw error;
    }
  }

  static Future auth(context) async {
    try {
      await User.checkAuth();
      return true;
    } catch (error) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          WelcomeScreen.routeName, (Route<dynamic> route) => false);
      return false;
    }
  }

  static Future notAuth(context) async {
    try {
      await User.checkAuth();
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
      return false;
    } catch (error) {
      return true;
    }
  }

  static Future emailChecking(email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/emailChecking';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (body.containsKey('done'))
        return body['done'];
      else
        throw ConfigCustom.notFoundKey;
    } catch (error) {
      throw error;
    }
  }

  static Future loginWithApple(id) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/login-with-apple';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': id,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('done')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Map user = body['user'];
          await prefs.setString(ConfigCustom.authEmail, user['email']);
          await prefs.setString(ConfigCustom.authUserId, user['id']);
          await prefs.setString(ConfigCustom.authToken, user['token']);
          await prefs.setDouble(
              ConfigCustom.authWallet,
              Functions.isEmpty(user['wallet'])
                  ? 0
                  : double.tryParse(user['wallet'].toString()));
          return body['user'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future loginWithGoogle(email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/login-with-google';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('done')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Map user = body['user'];
          await prefs.setString(ConfigCustom.authEmail, user['email']);
          await prefs.setString(ConfigCustom.authUserId, user['id']);
          await prefs.setString(ConfigCustom.authToken, user['token']);
          await prefs.setDouble(
              ConfigCustom.authWallet,
              Functions.isEmpty(user['wallet'])
                  ? 0
                  : double.tryParse(user['wallet'].toString()));
          return body['user'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future loginWithGoogleTransaction(email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/login-with-google-transaction';

    String deviceAppId = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.transactionCodeLockScan))
      deviceAppId = prefs.getString(ConfigCustom.transactionCodeLockScan);

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
          'transactionCode': deviceAppId,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('message')) {
          return {'error': body['message']};
        } else {
          if (body.containsKey('done')) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            Map user = body['user'];
            await prefs.setString(ConfigCustom.authEmail, user['email']);
            await prefs.setString(ConfigCustom.authUserId, user['id']);
            await prefs.setString(ConfigCustom.authToken, user['token']);
            await prefs.setDouble(
                ConfigCustom.authWallet,
                Functions.isEmpty(user['wallet'])
                    ? 0
                    : double.tryParse(user['wallet'].toString()));
            return body['user'];
          } else
            throw ConfigCustom.notFoundKey;
        }
      }
    } catch (error) {
      throw error;
    }
  }

  static Future loginWithFacebook(email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/login-with-facebook';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('done')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Map user = body['user'];
          await prefs.setString(ConfigCustom.authEmail, user['email']);
          await prefs.setString(ConfigCustom.authUserId, user['id']);
          await prefs.setString(ConfigCustom.authToken, user['token']);
          await prefs.setDouble(
              ConfigCustom.authWallet,
              Functions.isEmpty(user['wallet'])
                  ? 0
                  : double.tryParse(user['wallet'].toString()));
          return body['user'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future loginWithFacebookTransaction(email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/login-with-facebook-transaction';

    try {
      String deviceAppId = '';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(ConfigCustom.transactionCodeLockScan))
        deviceAppId = prefs.getString(ConfigCustom.transactionCodeLockScan);
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
          'transactionCode': deviceAppId,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('message')) {
          return {'error': body['message']};
        } else {
          if (body.containsKey('done')) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            Map user = body['user'];
            await prefs.setString(ConfigCustom.authEmail, user['email']);
            await prefs.setString(ConfigCustom.authUserId, user['id']);
            await prefs.setString(ConfigCustom.authToken, user['token']);
            await prefs.setDouble(
                ConfigCustom.authWallet,
                Functions.isEmpty(user['wallet'])
                    ? 0
                    : double.tryParse(user['wallet'].toString()));
            return body['user'];
          } else
            throw ConfigCustom.notFoundKey;
        }
      }
    } catch (error) {
      throw error;
    }
  }

  static Future forgotPassword(email) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/forgotPassword';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
        },
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.notExists;
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

  static Future login(email, password) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/user/login';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('done')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Map user = body['user'];
          await prefs.setString(ConfigCustom.authEmail, user['email']);
          await prefs.setString(ConfigCustom.authUserId, user['id']);
          await prefs.setString(ConfigCustom.authToken, user['token']);
          await prefs.setDouble(
              ConfigCustom.authWallet,
              Functions.isEmpty(user['wallet'])
                  ? 0
                  : double.tryParse(user['wallet'].toString()));
          return body['user'];
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future loginWithTransactionCode(email, password) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/loginWithTransaction';

    String deviceAppId = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.transactionCodeLockScan))
      deviceAppId = prefs.getString(ConfigCustom.transactionCodeLockScan);

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
          'transactionCode': deviceAppId,
        },
      ).timeout(
        Duration(seconds: ConfigCustom.timeout),
      );
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else if (result.statusCode == 400) {
        throw ConfigCustom.errCommon;
      } else {
        if (body.containsKey('done')) {
          if (body.containsKey('message')) {
            return {'error': body['message']};
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            Map user = body['user'];
            await prefs.setString(ConfigCustom.authEmail, user['email']);
            await prefs.setString(ConfigCustom.authUserId, user['id']);
            await prefs.setString(ConfigCustom.authToken, user['token']);
            await prefs.setDouble(
                ConfigCustom.authWallet,
                Functions.isEmpty(user['wallet'])
                    ? 0
                    : double.tryParse(user['wallet'].toString()));
            return body['user'];
          }
        } else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future logoutLocked(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/user/logout';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (body.containsKey('done')) {
        await prefs.remove(ConfigCustom.authToken);
        // await prefs.remove(ConfigCustom.authEmail);
        return body['done'];
      } else
        throw ConfigCustom.notFoundKey;
    } catch (error) {
      throw error;
    }
  }

  static Future logout(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/user/logout';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer ${prefs.getString(ConfigCustom.authToken)}'
      };
      http.Response result = await http
          .post(
            url,
            headers: requestHeaders,
          )
          .timeout(
            Duration(seconds: ConfigCustom.timeout),
          );
      Map body = json.decode(result.body);
      if (body.containsKey('done')) {
        await prefs.clear();
        Functions.goToRoute(context, AskingProScreen.routeName);
        return body['done'];
      } else
        throw ConfigCustom.notFoundKey;
    } catch (error) {
      throw error;
    }
  }

  static Future registration(String email, String password) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url =
        '${Api().prefix}/${Api().version}/dingtoi-pro/user/registration';

    try {
      http.Response result = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (result.statusCode == 500) {
        if (body['done'] == ConfigCustom.exists) {
          throw ConfigCustom.exists;
        }
      } else if (result.statusCode == 200) {
        if (body.containsKey('done'))
          return body['done'];
        else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }
}
