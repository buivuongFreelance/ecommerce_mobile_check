import 'package:dingtoimc/helpers/config.dart';
import 'package:flutter/material.dart';

class InputCode extends StatefulWidget {
  final double fontSize;
  final Color textColor;
  final String hint;
  final TextEditingController mController;
  final Function onChanged;
  final Widget prefixIcon;
  final double bottomIcon;
  final Function validator;
  final TextInputType textInputType;

  InputCode({
    this.fontSize = 20,
    this.textColor = Colors.white,
    this.hint = '',
    this.mController,
    this.onChanged,
    this.prefixIcon,
    this.bottomIcon = 0,
    this.validator,
    this.textInputType = TextInputType.text,
  });
  @override
  _InputCodeState createState() => _InputCodeState();
}

class _InputCodeState extends State<InputCode> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
        contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        errorStyle: TextStyle(
          fontSize: 15,
          color: ConfigCustom.colorError,
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 23, maxHeight: 30),
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
    );
  }
}
