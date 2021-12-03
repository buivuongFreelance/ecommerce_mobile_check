import 'package:dingtoimc/helpers/config.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: ConfigCustom.colorWhite,
        child: Center(
          child: Image.asset(
            'assets/app/com_loading.gif',
            width: width / 1.6,
          ),
        ),
      ),
    );
  }
}
