import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String message;
  final String type;
  final Object focusNode;
  final Function onFieldSubmitted;
  final Function validator;
  final Function onSaved;

  Input(this.message, this.type, this.focusNode, this.onFieldSubmitted,
      this.validator, this.onSaved);

  @override
  Widget build(BuildContext context) {
    TextInputType _type = TextInputType.text;
    if (type == 'email') {
      _type = TextInputType.emailAddress;
    } else if (type == 'phone') {
      _type = TextInputType.phone;
    }

    return SizedBox(
      child: TextFormField(
        onFieldSubmitted: onFieldSubmitted,
        //textInputAction: TextInputAction.next,
        obscureText: type == 'password' ? true : false,
        autocorrect: type == 'password' ? false : true,
        decoration: InputDecoration(
          filled: false,
          fillColor: const Color(0xFFEDEDED),
          hintText: message,
          contentPadding: EdgeInsets.fromLTRB(20.0, 17.0, 20.0, 17.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        keyboardType: _type,
        focusNode: focusNode,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
