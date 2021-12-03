import 'package:circular_check_box/circular_check_box.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/thank_screen.dart';
import 'package:dingtoimc/widgets/button_bottom.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/loading.dart';

class TransactionBuyerConfirmScreen extends StatefulWidget {
  static const routeName = '/transaction-buyer-confirm';

  @override
  _TransactionBuyerConfirmScreenState createState() =>
      _TransactionBuyerConfirmScreenState();
}

class _TransactionBuyerConfirmScreenState
    extends State<TransactionBuyerConfirmScreen> {
  bool isLoading = false;
  bool isNo = false;
  List questions = [];
  List selectedQuestions = [];
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future init() async {
    setState(() {
      isLoading = true;
    });
    try {
      List list = await Device.listQuestionBuyerReject(context);
      setState(() {
        questions = list;
      });
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget widgetQuestions() {
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < questions.length; i++) {
      list.add(
        new ListTile(
          leading: CircularCheckBox(
              value:
                  selectedQuestions.contains(questions[i]['id']) ? true : false,
              checkColor: Colors.white,
              activeColor: Colors.green,
              inactiveColor: Colors.redAccent,
              disabledColor: Colors.grey,
              onChanged: (val) => this.setState(() {
                    if (val) {
                      selectedQuestions.add(questions[i]['id']);
                    } else {
                      selectedQuestions.remove(questions[i]['id']);
                    }
                  })),
          title: TextCustom(questions[i]['name'],
              letterSpacing: ConfigCustom.letterSpacing2,
              fontSize: 15,
              color: ConfigCustom.colorWhite,
              fontWeight: FontWeight.w600),
          onTap: () => this.setState(() {
            if (selectedQuestions.contains(questions[i]['id'])) {
              selectedQuestions.remove(questions[i]['id']);
            } else {
              selectedQuestions.add(questions[i]['id']);
            }
          }),
        ),
      );
    }
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: list);
  }

  Widget widgetNo(width, widthWidget) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Container(
                padding: EdgeInsets.only(
                  left: ConfigCustom.globalPadding / 2,
                  right: ConfigCustom.globalPadding / 2,
                ),
                alignment: Alignment.topLeft,
                width: widthWidget,
                height: ConfigCustom.heightBar,
                child: InkWell(
                  customBorder: new CircleBorder(),
                  onTap: () {
                    setState(() {
                      isNo = false;
                    });
                  },
                  child: Container(
                    height: ConfigCustom.heightBar,
                    padding: EdgeInsets.all(ConfigCustom.globalPadding / 2.5),
                    child: Row(
                      children: [
                        Icon(
                          SimpleLineIcons.arrow_left,
                          color: ConfigCustom.colorWhite,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        TextCustom(
                          'Back',
                          maxLines: 1,
                          fontWeight: FontWeight.w900,
                          textAlign: TextAlign.center,
                          fontSize: 16,
                          letterSpacing: ConfigCustom.letterSpacing2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SpaceCustom(),
            Container(
              width: width,
              child: TextCustom(
                "Why do you select Open Dispute ?",
                fontSize: 20,
                textAlign: TextAlign.center,
              ),
            ),
            SpaceCustom(),
            SpaceCustom(),
            Container(
              child: SingleChildScrollView(child: widgetQuestions()),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: ButtonBottom(
            'Send',
            MediaQuery.of(context).size.width,
            () {
              handlerSendNo();
            },
            isLoading: false,
          ),
        )
      ],
    );
  }

  Future handlerSendNo() async {
    if (selectedQuestions.length == 0) {
      Functions.confirmSomethingError(context,
          'You must give at least a reason to reject this device.', () {});
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
        String transactionCode =
            prefs.getString(ConfigCustom.transactionCodeLockScan);
        await Device.transactionBuyerReject(
            context, transactionCode, selectedQuestions);
      }
      Functions.goToRoute(context, AskingProScreen.routeName);
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future handleYes() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Device.transactionBuyerAccept(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(ConfigCustom.transactionCodeLockScan);
      await prefs.remove(ConfigCustom.transactionCodeOwnerWeb);
      Functions.goToRoute(context, ThankScreen.routeName);
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double widthWidget =
        MediaQuery.of(context).size.width - ConfigCustom.globalPadding * 4;

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: ConfigCustom.colorBg,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: _drawerKey,
          appBar: null,
          drawer: DrawerCustom(),
          body: isLoading
              ? Loading()
              : GestureClickOutside(
                  child: isNo
                      ? widgetNo(width, widthWidget)
                      : Stack(
                          children: <Widget>[
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        right: ConfigCustom.globalPadding),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isNo = true;
                                        });
                                      },
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: TextCustom(
                                          'Open Dispute',
                                          color: ConfigCustom.colorErrorLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SpaceCustom(),
                                  SpaceCustom(),
                                  Center(
                                    child: Container(
                                      width: widthWidget,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 80,
                                              child: Image.asset(
                                                'assets/app/com_confirm.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            SpaceCustom(),
                                            SpaceCustom(),
                                            Center(
                                              child: Container(
                                                child: TextCustom(
                                                  "Do you want to compare your scan with last owner scan ?",
                                                  fontSize: 15,
                                                  color: ConfigCustom
                                                      .colorGreyWarm,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: ConfigCustom
                                                            .globalPadding /
                                                        3),
                                                child: GestureDetector(
                                                  onTap: () {},
                                                  child: TextCustom(
                                                    "View Compare",
                                                    fontSize: 16,
                                                    color: ConfigCustom
                                                        .colorPrimary2,
                                                    textAlign: TextAlign.center,
                                                    textDecoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SpaceCustom(),
                                            SpaceCustom(),
                                            Center(
                                              child: Container(
                                                child: TextCustom(
                                                  "If you agree with your scan, please click confirm",
                                                  fontSize: 16,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            SpaceCustom(),
                                            SizedBox(
                                              width: 40,
                                              child: Image.asset(
                                                'assets/app/com_hand_maker.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            SpaceCustom(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 157,
                                                  child: ButtonCustom(
                                                    'Confirm',
                                                    color: ConfigCustom
                                                        .colorPrimary,
                                                    backgroundColor:
                                                        ConfigCustom
                                                            .colorSecondary,
                                                    onTap: () {
                                                      handleYes();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
        ),
      ),
    );
  }
}
