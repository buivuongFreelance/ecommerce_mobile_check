import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class InputPasswordFilled extends StatefulWidget {
  final double fontSize;
  final Color textColor;
  final String hint;
  final Color hintColor;
  final TextEditingController mController;
  final bool isPassword;
  final Function onChanged;
  final Widget prefixIcon;
  final Function validator;

  InputPasswordFilled({
    this.fontSize = 15,
    this.textColor = Colors.white,
    this.hintColor = const Color(0xFF888888),
    this.hint = '',
    this.mController,
    this.isPassword = true,
    this.onChanged,
    this.prefixIcon,
    this.validator,
  });
  @override
  _InputPasswordFilledState createState() => _InputPasswordFilledState();
}

class _InputPasswordFilledState extends State<InputPasswordFilled> {
  bool isPassword = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isPassword = widget.isPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      validator: widget.validator,
      obscureText: isPassword,
      style: TextStyle(
          fontSize: widget.fontSize,
          fontFamily: 'AvenirNext',
          color: widget.textColor,
          fontWeight: FontWeight.w300),
      decoration: InputDecoration(
        errorStyle: TextStyle(
          fontSize: 15,
          color: ConfigCustom.colorError,
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 23, maxHeight: 30),
        prefixIcon: Functions.isEmpty(widget.prefixIcon)
            ? null
            : Container(
                padding: EdgeInsets.only(
                  right: ConfigCustom.globalPadding / 2,
                  left: ConfigCustom.globalPadding,
                  bottom: 5,
                ),
                child: widget.prefixIcon,
              ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              isPassword = !isPassword;
            });
          },
          child: new Icon(
            isPassword ? Ionicons.ios_eye : Ionicons.ios_eye_off,
            color: ConfigCustom.colorWhite,
          ),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ConfigCustom.colorGreyWarm,
          ),
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
        fillColor: ConfigCustom.colorWhite.withOpacity(0.2),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: ConfigCustom.colorGreyWarm,
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
