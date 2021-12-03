import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class LoadingBlacklist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: ConfigCustom.colorWhite,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/app/com_loading.gif',
                width: width / 1.6,
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(right: 30, left: 30),
                child: TextCustom(
                  "We are checking your IMEI. This may take a few moments. Thank you for your patience!",
                  textAlign: TextAlign.center,
                  color: ConfigCustom.colorText,
                  fontSize: 17,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
