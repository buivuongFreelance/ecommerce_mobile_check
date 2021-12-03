import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoneyInput extends StatefulWidget {
  final Function onChangeInput;
  final Function onChangeCountry;

  final double price;
  final String currency;

  MoneyInput(
      this.price, this.currency, this.onChangeInput, this.onChangeCountry);

  @override
  _MoneyInputState createState() => _MoneyInputState();
}

class _MoneyInputState extends State<MoneyInput> {
  String _dropdownValue = 'CAD';
  TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.onChangeCountry(_dropdownValue);
    if (!Functions.isEmpty(widget.price))
      _priceController.text = widget.price.round().toString();
    if (_dropdownValue != widget.currency) {
      setState(() {
        _dropdownValue = widget.currency;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return (Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: ConfigCustom.colorWhite,
                  ),
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ConfigCustom.colorGreyWarm,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ConfigCustom.colorGreyWarm,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ConfigCustom.colorSecondary,
                      ),
                    ),
                    filled: false,
                    hintText: 'Price',
                    hintStyle: TextStyle(
                      color: ConfigCustom.colorWhite,
                    ),
                  ),
                  onChanged: (price) {
                    widget.onChangeInput(double.tryParse(price));
                  },
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: width * 0.2,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          //                   <--- left side
                          color: ConfigCustom.colorGreyWarm,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _dropdownValue,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: ConfigCustom.colorWhite,
                      ),
                      iconSize: 22,
                      elevation: 16,
                      dropdownColor: ConfigCustom.colorPrimary,
                      style: TextStyle(
                        color: ConfigCustom.colorWhite,
                      ),
                      underline: Container(
                        height: 1,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValue = newValue;
                        });
                        widget.onChangeCountry(newValue);
                      },
                      items: <String>['CAD', 'USD']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
