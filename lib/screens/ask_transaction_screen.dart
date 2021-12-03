import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/screens/confirm_imei_transaction_screen.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:dingtoimc/widgets/button_bottom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class AskTransactionScreen extends StatefulWidget {
  static const routeName = '/ask_transaction';

  @override
  _AskTransactionScreenState createState() => _AskTransactionScreenState();
}

class _AskTransactionScreenState extends State<AskTransactionScreen> {
  String _selectedTransaction = '';
  bool _isLoading = false;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static Future<bool> confirmTransaction(
      context, text, String textYes, String textNo, callbackYes, callbackNo) {
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
                          text,
                          SpaceCustom(),
                          SpaceCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new FlatButton(
                                onPressed: callbackNo,
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
                                      textNo.toUpperCase(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              new FlatButton(
                                onPressed: callbackYes,
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
                                      textYes.toUpperCase(),
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

  Future _goToConfirmIMEI() async {
    if (_selectedTransaction != '') {
      confirmTransaction(
          context,
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Are you sure this transaction ',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: ConfigCustom.colorWhite,
                fontFamily: 'AvenirNext',
                fontSize: 20,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: "fs8dJHkj",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ConfigCustom.colorSecondary)),
                TextSpan(
                  text: ' is for your device?',
                ),
              ],
            ),
          ),
          'Yes',
          'No', () async {
        Navigator.of(context).pushNamedAndRemoveUntil(
            ConfirmImeiTransactionScreen.routeName,
            (Route<dynamic> route) => false);
      }, () async {
        Navigator.of(context).pop();
      });
    } else {
      Functions.confirmSomethingError(
          context, 'Please select your transaction ID.', () {});
    }
  }

  Widget widgetTransaction(String transID, value, String nameDevice,
      String price, String timestamp) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _selectedTransaction = value;
        });
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            ConfigCustom.globalPadding, 0, ConfigCustom.globalPadding, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ConfigCustom.borderRadius4),
            color:
                _selectedTransaction == value ? Colors.white : Colors.white10,
          ),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    _selectedTransaction == value
                        ? Positioned(
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: width / 5,
                              decoration: BoxDecoration(
                                color:
                                    ConfigCustom.colorPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        ConfigCustom.borderRadius4),
                                    bottomLeft: Radius.circular(
                                        ConfigCustom.borderRadius4)),
                              ),
                              child: Center(
                                  child: TextCustom(
                                value,
                                fontSize: width / 7,
                                fontWeight: FontWeight.w900,
                                color: ConfigCustom.colorSteel,
                              )),
                            ),
                          )
                        : Positioned(
                            top: 0,
                            bottom: 0,
                            child: Container(
                                width: width / 5,
                                decoration: BoxDecoration(
                                  color:
                                      ConfigCustom.colorWhite.withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          ConfigCustom.borderRadius4),
                                      bottomLeft: Radius.circular(
                                          ConfigCustom.borderRadius4)),
                                ),
                                child: Center(
                                    child: TextCustom(
                                  value,
                                  fontWeight: FontWeight.w900,
                                  fontSize: width / 7,
                                  color:
                                      ConfigCustom.colorWhite.withOpacity(0.7),
                                ))),
                          ),
                    Container(
                      width: width,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          width / 5 + 15,
                          ConfigCustom.globalPadding,
                          15,
                          ConfigCustom.globalPadding,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextCustom(
                                  transID.toUpperCase(),
                                  fontSize: 18,
                                  color: _selectedTransaction == value
                                      ? ConfigCustom.colorSteel
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                TextCustom(
                                  nameDevice,
                                  maxLines: 2,
                                  color: _selectedTransaction == value
                                      ? ConfigCustom.colorSteel
                                      : ConfigCustom.colorWhite,
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                TextCustom(
                                  price,
                                  fontSize: 15,
                                  maxLines: 2,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedTransaction == value
                                      ? ConfigCustom.colorSteel
                                      : ConfigCustom.colorWhite,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Functions.isEmpty(timestamp)
                                    ? Center()
                                    : TextCustom(
                                        timestamp,
                                        fontSize: 13,
                                        maxLines: 2,
                                        color: _selectedTransaction == value
                                            ? ConfigCustom.colorSteel
                                            : ConfigCustom.colorWhite,
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    PreferredSize appBar = Functions.getAppbar(
        context,
        TextCustom(
          'Transaction ID',
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          WelcomeScreen.routeName, (Route<dynamic> route) => false);
    });

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: ConfigCustom.colorBgBlendBottom,
        ),
        child: _isLoading
            ? Loading()
            : Scaffold(
                primary: true,
                appBar: appBar,
                backgroundColor: Colors.transparent,
                key: _drawerKey,
                drawer: DrawerCustom(),
                body: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: ConfigCustom.colorBg,
                      ),
                      child: Container(
                        child: ListView(
                          children: <Widget>[
                            SpaceCustom(),
                            SpaceCustom(),
                            Padding(
                              padding: EdgeInsets.only(
                                left: ConfigCustom.globalPadding,
                                right: ConfigCustom.globalPadding,
                              ),
                              child: TextCustom(
                                "Please select one transaction ID",
                                fontSize: 18,
                              ),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            widgetTransaction(
                              'D0ZAjqSRz',
                              'S',
                              'Iphone 11 Pro Max',
                              '1000 USD',
                              '02:20 PM',
                            ),
                            SpaceCustom(),
                            widgetTransaction(
                              'TDw4P5KEi',
                              'E',
                              'Iphone XS',
                              '800 USD',
                              '03:25 PM',
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ButtonBottom(
                        'Select Transaction',
                        MediaQuery.of(context).size.width,
                        () {
                          _goToConfirmIMEI();
                        },
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
