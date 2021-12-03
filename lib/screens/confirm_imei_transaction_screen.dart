import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/screens/ask_transaction_screen.dart';
import 'package:dingtoimc/screens/asking_user_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

import '../widgets/loading.dart';

class ConfirmImeiTransactionScreen extends StatefulWidget {
  static const routeName = '/confirm_transaction_imei';

  @override
  _ThankScreenState createState() => _ThankScreenState();
}

class _ThankScreenState extends State<ConfirmImeiTransactionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double widthWidget =
        MediaQuery.of(context).size.width - ConfigCustom.globalPadding * 4;

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
          AskTransactionScreen.routeName, (Route<dynamic> route) => false);
    });
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: _isLoading
            ? Loading()
            : GestureClickOutside(
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: Container(
                          width: widthWidget,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: width / 2.5,
                                  child: Image.asset(
                                    'assets/app/com_imei.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SpaceCustom(),
                                SpaceCustom(),
                                SpaceCustom(),
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
                                              color:
                                                  ConfigCustom.colorSecondary)),
                                      TextSpan(
                                        text: ' is for your device?',
                                      ),
                                    ],
                                  ),
                                ),
                                SpaceCustom(),
                                SpaceCustom(),
                                SpaceCustom(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: width / 2.8,
                                      child: ButtonCustom(
                                        'No',
                                        backgroundColor: Colors.transparent,
                                        color: ConfigCustom.colorWhite,
                                        colorOutline: ConfigCustom.colorWhite,
                                        onTap: () {
                                          //
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: width / 2.8,
                                      child: ButtonCustom(
                                        'Yes',
                                        backgroundColor:
                                            ConfigCustom.colorWhite,
                                        color: ConfigCustom.colorPrimary,
                                        colorOutline: ConfigCustom.colorWhite,
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  AskingUserScreen.routeName,
                                                  (Route<dynamic> route) =>
                                                      false);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
