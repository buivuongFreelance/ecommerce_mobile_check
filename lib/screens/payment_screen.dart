import 'dart:async';
import 'dart:io';

import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/asking_user_screen.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/loading_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment-screen';

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];

  Future _init() async {
    setState(() {
      _isLoading = true;
    });
    if (!await User.auth(context)) return;

    final bool available = await _connection.isAvailable();
    if (!available) {
      Functions.goToRoute(context, AskingProScreen.routeName);
      return;
    }

    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      //Functions.goToRoute(context, AskingProScreen.routeName);
    });

    initStoreInfo();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> initStoreInfo() async {
    try {
      final bool isAvailable = await _connection.isAvailable();
      if (!isAvailable) {
        Functions.goToRoute(context, AskingProScreen.routeName);
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> _kIds = {prefs.getString(ConfigCustom.authProItem)};
      final ProductDetailsResponse response =
          await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
      _products = response.productDetails;

      if (Platform.isAndroid) {
        final QueryPurchaseDetailsResponse purchaseResponse =
            await _connection.queryPastPurchases();
        if (purchaseResponse.error != null) {
          Functions.goToRoute(context, AskingProScreen.routeName);
          return;
        }
      }

      if (Platform.isIOS) {
        await FlutterInappPurchase.instance.clearTransactionIOS();
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: _products[0],
          applicationUserName: null,
        );
        sleep(const Duration(seconds: 1));
        InAppPurchaseConnection.instance
            .buyConsumable(purchaseParam: purchaseParam);
      } else {
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: _products[0],
          applicationUserName: null,
        );
        InAppPurchaseConnection.instance
            .buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (error) {
      Functions.goToRoute(context, AskingProScreen.routeName);
      return;
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    try {
      purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          if (Platform.isAndroid) {
            Functions.goToRoute(context, AskingProScreen.routeName);
          } else {}
        } else {
          if (purchaseDetails.status == PurchaseStatus.error) {
            Functions.goToRoute(context, AskingProScreen.routeName);
          } else if (purchaseDetails.status == PurchaseStatus.purchased) {}
          if (Platform.isAndroid) {
            await InAppPurchaseConnection.instance
                .consumePurchase(purchaseDetails);
          }
          if (purchaseDetails.pendingCompletePurchase) {
            if (Platform.isIOS) {
              if (purchaseDetails.status == PurchaseStatus.error) {
                Functions.goToRoute(context, AskingProScreen.routeName);
                return;
              }
            }
            try {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if (prefs.containsKey(ConfigCustom.authPricePro)) {
                double money = prefs.getDouble(ConfigCustom.authPricePro);
                await User.addWallet(
                  context,
                  money,
                );
                await prefs.setString(ConfigCustom.authScan, ConfigCustom.yes);
                await InAppPurchaseConnection.instance
                    .completePurchase(purchaseDetails);
                Functions.goToRoute(context, AskingUserScreen.routeName);
              } else {
                Functions.goToRoute(context, AskingProScreen.routeName);
              }
            } catch (error) {
              Functions.goToRoute(context, AskingProScreen.routeName);
            }
          }
        }
      });
    } catch (error) {
      Functions.goToRoute(context, AskingProScreen.routeName);
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? Loading() : LoadingCustom('Execute Payment');
  }
}
