import 'package:dingtoimc/helpers/config.dart';
import 'package:flutter/material.dart';

class DividerCustom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Divider(
        color: ConfigCustom.colorWhite.withOpacity(0.2),
        height: 25,
        thickness: 1,
      ),
    );
  }
}
