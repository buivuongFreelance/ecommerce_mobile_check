import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class InputPhone extends StatefulWidget {
  final double fontSize;
  final Color textColor;
  final String hint;
  final TextEditingController mController;
  final Function onChanged;
  final Widget prefixIcon;
  final double bottomIcon;
  final Function validator;
  final TextInputType textInputType;
  final int phoneCode;

  InputPhone({
    this.fontSize = 20,
    this.textColor = Colors.white,
    this.hint = '',
    this.mController,
    this.onChanged,
    this.prefixIcon,
    this.bottomIcon = 0,
    this.validator,
    this.textInputType = TextInputType.text,
    this.phoneCode = 1,
  });
  @override
  _InputPhoneState createState() => _InputPhoneState();
}

class _InputPhoneState extends State<InputPhone> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Container(
          width: width / 6,
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 0),
          child: Row(
            children: <Widget>[
              TextCustom(
                '+',
                fontSize: 20,
              ),
              SizedBox(
                width: 5,
              ),
              TextCustom(
                widget.phoneCode.toString(),
                fontSize: 20,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: width / 6),
          child: TextFormField(
            keyboardType: widget.textInputType,
            controller: widget.mController,
            validator: widget.validator,
            style: TextStyle(
                fontSize: widget.fontSize,
                fontFamily: 'AvenirNext',
                color: widget.textColor,
                fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              errorStyle: TextStyle(
                fontSize: 15,
                color: ConfigCustom.colorError,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(ConfigCustom.borderRadius2),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(ConfigCustom.borderRadius2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ConfigCustom.colorError,
                ),
                borderRadius: BorderRadius.circular(ConfigCustom.borderRadius2),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ConfigCustom.colorError,
                ),
                borderRadius: BorderRadius.circular(ConfigCustom.borderRadius2),
              ),
              filled: true,
              fillColor: ConfigCustom.colorWhite.withOpacity(0.1),
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: ConfigCustom.colorGreyWarm,
              ),
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
