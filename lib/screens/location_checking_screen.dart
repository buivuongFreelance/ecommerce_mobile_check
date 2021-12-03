import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/blacklist_status_screen.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/loading_custom.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationCheckingScreen extends StatefulWidget {
  static const routeName = '/location-checking-screen';

  @override
  _LocationCheckingScreenState createState() => _LocationCheckingScreenState();
}

class _LocationCheckingScreenState extends State<LocationCheckingScreen> {
  Position position;
  bool _isLoading = false;

  Future _navigate(step, blacklist) async {
    if (step == 3) {
      if (blacklist == ConfigCustom.yes) {
        Functions.goToRoute(context, BlacklistStatusScreen.routeName);
      } else {
        Functions.goToRoute(context, AskingProScreen.routeName);
      }
    } else {
      Functions.goToRoute(context, AskingProScreen.routeName);
    }
  }

  Future _init() async {
    setState(() {
      _isLoading = true;
    });
    if (!await User.auth(context)) return;

    String permission =
        await Functions.checkPermissionWithService2(Permission.location);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int step = prefs.get(ConfigCustom.sharedStep);
    String blacklist = prefs.get(ConfigCustom.sharedBacklist);

    if (permission == ConfigCustom.yes) {
      try {
        position = await Geolocator().getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            locationPermissionLevel: GeolocationPermission.locationWhenInUse);
        List<Placemark> p = await Geolocator()
            .placemarkFromCoordinates(position.latitude, position.longitude);

        Placemark place = p[0];
        await prefs.setString(
            ConfigCustom.sharedCountryCode, place.isoCountryCode);

        _navigate(step, blacklist);
      } catch (error) {
        Functions.goToRoute(context, AskingProScreen.routeName);
      }
    } else {
      if (permission == ConfigCustom.isDisabled) {
        await prefs.setString(
            ConfigCustom.sharedCountryCode, ConfigCustom.isDisabled);
        _navigate(step, blacklist);
      } else if (permission == ConfigCustom.isPermanent) {
        await prefs.setString(
            ConfigCustom.sharedCountryCode, ConfigCustom.isPermanent);
        _navigate(step, blacklist);
      } else {
        await prefs.setString(
            ConfigCustom.sharedCountryCode, ConfigCustom.isReject);
        _navigate(step, blacklist);
      }
    }

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
    return _isLoading ? Loading() : LoadingCustom('Checking Location');
  }
}
