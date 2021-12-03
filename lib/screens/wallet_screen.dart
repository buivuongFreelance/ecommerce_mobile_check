import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/widgets/background_image.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/wallet_screen';
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isLoading = false;
  double _wallet = 0.0;
  String _countryCode = 'US';

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Future _checkAuth() async {
    return await User.auth(context);
  }

  Widget screenMain() {
    double width = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        padding: EdgeInsets.only(
            left: ConfigCustom.globalPadding,
            right: ConfigCustom.globalPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextCustom(
                "Your balance on account to scan.",
                fontSize: 16,
              ),
              SpaceCustom(),
              SpaceCustom(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: Container(
                      width: width / 2.5 - 25,
                      child: Column(
                        children: [
                          TextCustom(
                            '${Functions.formatCurrency(_wallet, _countryCode)}',
                            //'VND 26.000',
                            fontSize: 25,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w900,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: width / 2.5,
                    height: width / 2.5,
                    padding: EdgeInsets.all(width / 13),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: ConfigCustom.colorWhite.withOpacity(0.2),
                            width: 10)),
                    child: SizedBox(
                        child: Image.asset("assets/app/com_wallet.png")),
                  ),
                ],
              ),
              SpaceCustom(),
            ],
          ),
        ),
      ),
    );
  }

  Future init() async {
    if (!await _checkAuth()) return;
    setState(() {
      _isLoading = true;
    });
    await User.emptyUserIsScanning();
    double wallet = 0.0;
    String countryCode = '';
    try {
      wallet = await User.getWallet(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
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
    } catch (error) {}
    setState(() {
      _wallet = wallet;
      _isLoading = false;
      _countryCode = countryCode;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = screenMain();
    PreferredSize appBar = Functions.getAppbarMainHome(
        context,
        TextCustom(
          'My Wallet',
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
        child: _isLoading
            ? Loading()
            : Scaffold(
                key: _drawerKey,
                backgroundColor: Colors.transparent,
                appBar: appBar,
                body: widget,
                drawer: DrawerCustom(),
              ),
      ),
    );
  }
}
