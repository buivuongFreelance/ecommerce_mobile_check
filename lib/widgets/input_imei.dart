import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:flutter/material.dart';

class InputImei extends StatefulWidget {
  final double fontSize;
  final Color textColor;
  final String hint;
  final TextEditingController mController;
  final Function onChanged;
  final Widget prefixIcon;
  final double bottomIcon;
  final Function validator;
  final TextInputType textInputType;
  final FocusNode focusNode;

  InputImei({
    this.fontSize = 20,
    this.textColor = Colors.white,
    this.hint = '',
    this.mController,
    this.onChanged,
    this.prefixIcon,
    this.bottomIcon = 0,
    this.validator,
    this.textInputType = TextInputType.text,
    this.focusNode,
  });
  @override
  _InputImeiState createState() => _InputImeiState();
}

class _InputImeiState extends State<InputImei> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.textInputType,
      controller: widget.mController,
      focusNode: widget.focusNode,
      validator: widget.validator,
      style: TextStyle(
          fontSize: widget.fontSize,
          fontFamily: 'AvenirNext',
          color: widget.textColor,
          fontWeight: FontWeight.w300),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(40.0, 20.0, 10.0, 20.0),
        errorStyle: TextStyle(
          fontSize: 15,
          color: ConfigCustom.colorError,
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 23, maxHeight: 30),
        prefixIcon: Functions.isEmpty(widget.prefixIcon)
            ? null
            : Container(
                padding: EdgeInsets.only(
                  left: ConfigCustom.globalPadding,
                  bottom: widget.bottomIcon,
                ),
                child: widget.prefixIcon,
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
    );
  }
}
