import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class ButtonBottom extends StatelessWidget {
  final String message;
  final double width;
  final Function onPressed;
  final bool isLoading;

  ButtonBottom(
    this.message,
    this.width,
    this.onPressed, {
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: ConfigCustom.heightButton,
      child: FlatButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
            //borderRadius: BorderRadius.circular(35.5),
            ),
        textColor: ConfigCustom.colorPrimary,
        padding: const EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
            color: ConfigCustom.colorSecondary,
          ),
          child: Container(
            padding: EdgeInsets.only(
                right: isLoading ? 0 : ConfigCustom.globalPadding * 2),
            constraints: BoxConstraints(
                maxWidth: width, minHeight: ConfigCustom.heightButton),
            alignment: Alignment.center,
            child: isLoading
                ? LoadingWidget()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Center(),
                      ),
                      Expanded(
                        flex: 100,
                        child: TextCustom(
                          message.toUpperCase(),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w600,
                          letterSpacing: ConfigCustom.letterSpacing,
                          color: ConfigCustom.colorPrimary,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                            height: 45,
                            child: Icon(
                              Icons.arrow_forward,
                              size: 25,
                              color: ConfigCustom.colorPrimary,
                            )),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
