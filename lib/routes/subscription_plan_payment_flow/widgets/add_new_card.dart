import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddNewCard extends StatefulWidget {
  @override
  _AddNewCardState createState() {
    return _AddNewCardState();
  }
}

class _AddNewCardState extends State<AddNewCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: CreditCardWidget(
          cardNumber: "",
          expiryDate: "",
          cardHolderName: "",
          cvvCode: "",
          showBackView: false,
        ),
      ),
    );
  }
}
