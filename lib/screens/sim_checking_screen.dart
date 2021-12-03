import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/voice_status_screen.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/loading_custom.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sim_info/sim_info.dart';

class SimCheckingScreen extends StatefulWidget {
  static const routeName = '/sim-checking-screen';

  @override
  _SimCheckingScreenState createState() => _SimCheckingScreenState();
}

class _SimCheckingScreenState extends State<SimCheckingScreen> {
  bool _isLoading = false;

  Future _navigate(step) async {
    if (step == 2) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          VoiceStatusScreen.routeName, (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
    }
  }

  Future _init() async {
    setState(() {
      _isLoading = true;
    });
    if (!await User.auth(context)) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int step = prefs.get(ConfigCustom.sharedStep);

    try {
      await Functions.checkPermissionWithService(Permission.phone);

      String carrierName = await SimInfo.getCarrierName;
      String isoCountryCode = await SimInfo.getIsoCountryCode;
      String mobileCountryCode = await SimInfo.getMobileCountryCode;

      await prefs.setString(ConfigCustom.sharedSim, ConfigCustom.yes);
      await prefs.setString(ConfigCustom.sharedSimCarrierName, carrierName);
      await prefs.setString(ConfigCustom.sharedSimCountryCode, isoCountryCode);
      await prefs.setString(
          ConfigCustom.sharedSimCountryPhonePrefix, mobileCountryCode);
    } catch (error) {
      if (error.code == 'PERMISSION_DENIED') {
        await prefs.setString(ConfigCustom.sharedSim, ConfigCustom.isPermanent);
      } else if (error.code == 'SIM_STATE_NOT_READY') {
        await prefs.setString(ConfigCustom.sharedSim, ConfigCustom.isNotReady);
      } else {
        await prefs.setString(ConfigCustom.sharedSim, ConfigCustom.isPermanent);
      }
    }

    _navigate(step);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? Loading() : LoadingCustom('Checking Sim');
  }
}
