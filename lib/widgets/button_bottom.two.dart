import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class ButtonBottomTwo extends StatelessWidget {
  final String message;
  final String message2;
  final double width;
  final Function onPressed;
  final Function onPressed2;
  final bool isLoading;

  ButtonBottomTwo(
    this.message,
    this.message2,
    this.width,
    this.onPressed,
    this.onPressed2, {
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: ConfigCustom.heightButton,
      child: Row(
        children: [
          FlatButton(
            onPressed: onPressed,
            shape: RoundedRectangleBorder(
                //borderRadius: BorderRadius.circular(35.5),
                ),
            textColor: ConfigCustom.colorPrimary,
            padding: const EdgeInsets.all(0.0),
            child: Ink(
              decoration: BoxDecoration(
                color: ConfigCustom.colorPrimary,
              ),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: width / 1.6,
                    minHeight: ConfigCustom.heightButton),
                alignment: Alignment.center,
                child: isLoading
                    ? LoadingWidget()
                    : TextCustom(
                        message.toUpperCase(),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w600,
                      ),
              ),
            ),
          ),
          FlatButton(
            onPressed: onPressed2,
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
                constraints: BoxConstraints(
                    maxWidth: width - width / 1.6,
                    minHeight: ConfigCustom.heightButton),
                alignment: Alignment.center,
                child: isLoading
                    ? LoadingWidget()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextCustom(
                            message2.toUpperCase(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w600,
                            letterSpacing: ConfigCustom.letterSpacing,
                            color: ConfigCustom.colorPrimary,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                                child: Icon(
                              Icons.arrow_forward,
                              size: 25,
                              color: ConfigCustom.colorPrimary,
                            )),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
