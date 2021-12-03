import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dingtoimc/helpers/api.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Rules {
  static Future listSettings(context) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/settings';

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
        return [];
      } else if (result.statusCode == 500) {
        throw ConfigCustom.errUsage;
      } else {
        if (body.containsKey('done'))
          return body['list'];
        else
          throw ConfigCustom.notFoundKey;
      }
    } catch (error) {
      throw error;
    }
  }

  static Future listRules() async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw (ConfigCustom.notFoundInternet);
    }

    String url = '${Api().prefix}/${Api().version}/dingtoi-pro/rules';

    try {
      http.Response result = await http
          .get(
            url,
          )
          .timeout(Duration(seconds: ConfigCustom.timeout));
      Map body = json.decode(result.body);
      if (body.containsKey('done'))
        return body['list'];
      else
        throw ConfigCustom.notFoundKey;
    } catch (error) {
      throw error;
    }
  }

  static Map getRulesDiamond() {
    return {
      'total': 50,
      ConfigCustom.sharedPointTouchScreen: 50,
      ConfigCustom.sharedPointBluetooth: 5,
      ConfigCustom.sharedPointWifi: 5,
      ConfigCustom.sharedPointFinger: 2,
      ConfigCustom.sharedPointCamera: 15,
      ConfigCustom.sharedPointFlash: 15,
      ConfigCustom.sharedPointStorage: 15,
      ConfigCustom.sharedPointProcessor: 15,
      ConfigCustom.sharedPointReleased: 15,
      ConfigCustom.sharedPointFaceID: 2,
    };
  }
}
