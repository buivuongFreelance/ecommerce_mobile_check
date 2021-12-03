import 'package:dingtoimc/helpers/config.dart';
import 'package:flutter/material.dart';

class DividerCustomWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Divider(
        color: ConfigCustom.colorErrorLight2,
        height: 25,
        thickness: 1,
      ),
    );
  }
}
