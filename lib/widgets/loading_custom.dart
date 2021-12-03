import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingCustom extends StatelessWidget {
  final String message;
  LoadingCustom(this.message);

  @override
  Widget build(BuildContext context) {
    //final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: ConfigCustom.colorWhite,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitHourGlass(
                color: ConfigCustom.colorPrimary,
                size: 50.0,
              ),
              SpaceCustom(),
              TextCustom(
                message,
                color: ConfigCustom.colorPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
