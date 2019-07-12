import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/routes/auth/widgets/text_form_field.dart';
import 'package:igflexin/utils/keyboard_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class AddNewCard extends StatefulWidget {
  @override
  _AddNewCardState createState() {
    return _AddNewCardState();
  }
}

/*
LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Container(),),);
*/

class _AddNewCardState extends State<AddNewCard> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: true,
      body: SystemBarsInfoProvider(
        builder: (context, child, systemBarsInfo, orientation) {
          return KeyboardInfoProvider(
            builder: (context, keyboardInfo) {
              return Container(
                color: Color.fromARGB(255, 232, 232, 232),
                margin: EdgeInsets.only(
                  bottom: (orientation == Orientation.portrait
                          ? systemBarsInfo.navigationBarHeight
                          : 0.0) +
                      keyboardInfo.offsetY,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.only(
                              top: systemBarsInfo.statusBarHeight,
                              bottom: systemBarsInfo.statusBarHeight,
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: CreditCardWidget(
                                width: ResponsivityUtils.compute(400.0, context),
                                height: ResponsivityUtils.compute(180.0, context),
                                cardNumber: "4242 4242 4242 4242",
                                expiryDate: "12/19",
                                cardHolderName: "David Domkář",
                                cvvCode: "852",
                                showBackView: false,
                                textStyle: TextStyle(
                                  fontFamily: 'LatoLatin',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                cvvTextStyle: TextStyle(
                                  fontFamily: 'LatoLatin',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundGradientColor: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Provider.of<SubscriptionRepository>(context)
                                        .planTheme
                                        .gradientStartColor,
                                    Provider.of<SubscriptionRepository>(context)
                                        .planTheme
                                        .gradientEndColor,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    /*
                    */
                    CreditCardForm(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CreditCardForm extends StatefulWidget {
  @override
  _CreditCardFormState createState() {
    return _CreditCardFormState();
  }
}

class _CreditCardFormState extends State<CreditCardForm> {
  SubscriptionRepository _subscriptionRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      height: ResponsivityUtils.compute(80.0, context),
      child: Form(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(20.0, context),
              ),
              width: 180.0,
              child: Center(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'Card number',
                    labelStyle:
                        TextStyle(color: _subscriptionRepository.planTheme.gradientStartColor),
                    isDense: true,
                    alignLabelWithHint: true,
                    hintText: 'XXXX XXXX XXXX XXXX',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(20.0, context),
              ),
              width: 80.0,
              child: Center(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'Expiry date',
                    labelStyle:
                        TextStyle(color: _subscriptionRepository.planTheme.gradientStartColor),
                    isDense: true,
                    alignLabelWithHint: true,
                    hintText: 'MM/YY',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(20.0, context),
              ),
              width: 50.0,
              child: Center(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'CVV',
                    labelStyle:
                        TextStyle(color: _subscriptionRepository.planTheme.gradientStartColor),
                    isDense: true,
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(20.0, context),
              ),
              width: 140.0,
              child: Center(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'Card holder name',
                    labelStyle:
                        TextStyle(color: _subscriptionRepository.planTheme.gradientStartColor),
                    isDense: true,
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(20.0, context),
                vertical: ResponsivityUtils.compute(15.0, context),
              ),
              child: GradientButton(
                width: 160.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'ADD CARD',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
                child: Form(
                  child: Row(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Card number'),
                      ),
                    ],
                  ),
                ),

Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CreditCardWidget(
              width: ResponsivityUtils.compute(400.0, context),
              height: ResponsivityUtils.compute(180.0, context),
              cardNumber: "4242 4242 4242 4242",
              expiryDate: "12/19",
              cardHolderName: "David Domkář",
              cvvCode: "852",
              showBackView: false,
              textStyle: TextStyle(
                fontFamily: 'LatoLatin',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              cvvTextStyle: TextStyle(
                fontFamily: 'LatoLatin',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              backgroundGradientColor: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
                  Provider.of<SubscriptionRepository>(context).planTheme.gradientEndColor,
                ],
              ),
            ),
          ],
        ),
      ),
*/
