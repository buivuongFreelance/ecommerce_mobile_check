import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class TextGroup extends StatelessWidget {
  final String message;
  TextGroup(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(ConfigCustom.globalPadding * 2, 0,
            ConfigCustom.globalPadding * 2, 0),
        child: TextCustom(
          message.toUpperCase(),
          color: ConfigCustom.colorWhite.withOpacity(0.5),
          letterSpacing: ConfigCustom.letterSpacing2,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
