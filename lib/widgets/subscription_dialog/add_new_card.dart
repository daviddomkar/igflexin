import 'dart:async';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_stripe_sdk/model/card.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/repositories/system_bars_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';
import 'package:igflexin/utils/keyboard_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/utils/validation_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/dialog.dart';
import 'package:igflexin/widgets/error_dialog.dart';
import 'package:igflexin/widgets/subscription_dialog/index.dart';
import 'package:provider/provider.dart';

// TODO Split this to multiple files for better maintenance

class AddNewCard extends StatefulWidget {
  AddNewCard(
      {Key key,
      this.willPopNotifier,
      this.onDisposeReady,
      this.refreshPaymentMethods})
      : super(key: key);

  final WillPopNotifier willPopNotifier;
  final Function onDisposeReady;
  final Future<void> Function() refreshPaymentMethods;

  @override
  _AddNewCardState createState() {
    return _AddNewCardState();
  }
}

class _AddNewCardState extends State<AddNewCard>
    with SingleTickerProviderStateMixin {
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardHolderName = '';
  bool _cvvFocused = false;

  AnimationController _animationController;

  Animation<Offset> _creditCardFormOffset;
  Animation<Color> _creditCardBackground;
  Animation<double> _creditCardScale;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animationController.forward();

    widget.willPopNotifier.addListener(_onWillPop);
  }

  void _onWillPop() {
    _animationController.reverse().then((_) {
      Provider.of<SystemBarsRepository>(context).setLightForeground();
      widget.onDisposeReady();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _creditCardFormOffset = Tween(
      begin: Offset(0.0, ResponsivityUtils.compute(80.0, context)),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.500, 1.000, curve: Curves.ease),
      ),
    );

    _creditCardBackground = ColorTween(
      begin: Colors.white,
      end: Color.fromARGB(255, 232, 232, 232),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.000, 0.500, curve: Curves.ease),
      ),
    );

    _creditCardScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.000, 1.000, curve: Curves.elasticOut),
      ),
    );

    Provider.of<SystemBarsRepository>(context).setDarkForeground();
  }

  @override
  void dispose() {
    widget.willPopNotifier.removeListener(_onWillPop);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardInfoProvider(builder: (context, keyboard) {
      return SystemBarsInfoProvider(
          builder: (context, child, info, orientation) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  color: _creditCardBackground.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          child: Transform.scale(
                            scale: _creditCardScale.value,
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              height: ResponsivityUtils.compute(240.0, context),
                              child: CreditCardWidget(
                                width:
                                    ResponsivityUtils.compute(400.0, context),
                                height:
                                    ResponsivityUtils.compute(180.0, context),
                                cardNumber: _cardNumber,
                                expiryDate: _expiryDate,
                                cvvCode: _cvv,
                                cardHolderName: _cardHolderName,
                                showBackView: _cvvFocused,
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
                      Transform.translate(
                        offset: _creditCardFormOffset.value,
                        child: CreditCardForm(
                          onCardNumber: (cardNumber) =>
                              setState(() => _cardNumber = cardNumber),
                          onExpiryDate: (expiryDate) =>
                              setState(() => _expiryDate = expiryDate),
                          onCVV: (cvv) => setState(() => _cvv = cvv),
                          onCardHolderName: (cardHolderName) =>
                              setState(() => _cardHolderName = cardHolderName),
                          onCVVFocused: (cvvFocused) =>
                              setState(() => _cvvFocused = cvvFocused),
                          onDisposeReady: () {
                            _animationController.reverse().then((_) {
                              widget.onDisposeReady();
                            });
                          },
                          refreshPaymentMethods: widget.refreshPaymentMethods,
                        ),
                      ),
                    ],
                  ),
                ),
                if (orientation == Orientation.portrait &&
                    keyboard.offsetY <= info.navigationBarHeight)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.white,
                      height: info.navigationBarHeight,
                    ),
                  ),
              ],
            );
          },
        );
      });
    });
  }
}

class CreditCardForm extends StatefulWidget {
  CreditCardForm({
    Key key,
    @required this.onCardNumber,
    @required this.onExpiryDate,
    @required this.onCardHolderName,
    @required this.onCVV,
    @required this.onCVVFocused,
    this.onDisposeReady,
    this.refreshPaymentMethods,
  }) : super(key: key);

  final void Function(String) onCardNumber;
  final void Function(String) onExpiryDate;
  final void Function(String) onCardHolderName;
  final void Function(String) onCVV;
  final void Function(bool) onCVVFocused;

  final Function onDisposeReady;
  final Future<void> Function() refreshPaymentMethods;

  @override
  _CreditCardFormState createState() {
    return _CreditCardFormState();
  }
}

class _CreditCardFormState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();

  ScrollController _scrollController;

  SubscriptionRepository _subscriptionRepository;

  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardHolderName = '';

  bool _autoValidate = false;
  bool _addingCard = false;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cvvController =
      MaskedTextController(mask: '0000');
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  FocusNode _cardNumberFocusNode = FocusNode();
  FocusNode _expiryDateFocusNode = FocusNode();
  FocusNode _cvvFocusNode = FocusNode();
  FocusNode _cardHolderNameFocusNode = FocusNode();

  bool _isCvvFocused = false;

  void _textFieldFocusDidChange() {
    setState(() {
      _isCvvFocused = _cvvFocusNode.hasFocus;
      widget.onCVVFocused(_isCvvFocused);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _cvvFocusNode.addListener(_textFieldFocusDidChange);

    _cardNumberController.addListener(() {
      setState(() {
        _cardNumber = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _cardNumberController.text);
        widget.onCardNumber(_cardNumber);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        _expiryDate = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _expiryDateController.text);
        widget.onExpiryDate(_expiryDate);
      });
    });

    _cvvController.addListener(() {
      setState(() {
        _cvv = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _cvvController.text);
        widget.onCVV(_cvv);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        _cardHolderName = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _cardHolderNameController.text);
        widget.onCardHolderName(_cardHolderName);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);

    if (!_cardNumberFocusNode.hasFocus &&
        !_expiryDateFocusNode.hasFocus &&
        !_cvvFocusNode.hasFocus &&
        !_cardHolderNameFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_cardNumberFocusNode);
    }
  }

  @override
  void dispose() {
    _cvvFocusNode.removeListener(_textFieldFocusDidChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardInfoProvider(builder: (context, keyboard) {
      return SystemBarsInfoProvider(
          builder: (context, child, info, orientation) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          margin: EdgeInsets.only(
              bottom: orientation == Orientation.portrait
                  ? keyboard.offsetY <= info.navigationBarHeight
                      ? info.navigationBarHeight
                      : 0.0
                  : 0.0),
          height: ResponsivityUtils.compute(80.0, context),
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: ListView(
              controller: _scrollController,
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
                      focusNode: _cardNumberFocusNode,
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _cardNumberFocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_expiryDateFocusNode);
                        _scrollController.animateTo(
                          ResponsivityUtils.compute(20.0, context) * 2 + 180.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease,
                        );
                      },
                      validator: _validateField,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsivityUtils.compute(10.0, context),
                        ),
                        labelText: 'Card number',
                        errorStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(
                            color: _subscriptionRepository
                                .planTheme.gradientStartColor),
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
                  width: 120.0,
                  child: Center(
                    child: TextFormField(
                      focusNode: _expiryDateFocusNode,
                      controller: _expiryDateController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _expiryDateFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(_cvvFocusNode);
                        _scrollController.animateTo(
                          ResponsivityUtils.compute(20.0, context) * 4 +
                              180.0 +
                              120.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease,
                        );
                      },
                      validator: _validateExpiryDate,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsivityUtils.compute(10.0, context),
                        ),
                        labelText: 'Expiry date',
                        errorStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(
                            color: _subscriptionRepository
                                .planTheme.gradientStartColor),
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
                  width: 120.0,
                  child: Center(
                    child: TextFormField(
                      focusNode: _cvvFocusNode,
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _cvvFocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_cardHolderNameFocusNode);
                        _scrollController.animateTo(
                          ResponsivityUtils.compute(20.0, context) * 6 +
                              180.0 +
                              120.0 +
                              120.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease,
                        );
                      },
                      validator: _validateField,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsivityUtils.compute(10.0, context),
                        ),
                        labelText: 'CVV',
                        errorStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(
                            color: _subscriptionRepository
                                .planTheme.gradientStartColor),
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
                      focusNode: _cardHolderNameFocusNode,
                      controller: _cardHolderNameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_cardHolderNameFocusNode);
                      },
                      validator: _validateField,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsivityUtils.compute(10.0, context),
                        ),
                        labelText: 'Card holder name',
                        errorStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(
                            color: _subscriptionRepository
                                .planTheme.gradientStartColor),
                        isDense: true,
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: ResponsivityUtils.compute(160.0, context),
                  margin: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: ResponsivityUtils.compute(15.0, context),
                  ),
                  alignment: Alignment.centerRight,
                  child: GradientButton(
                    width: ResponsivityUtils.compute(
                        _addingCard ? 50.0 : 160.0, context),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                            opacity: !_addingCard ? 1.0 : 0.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  child: Text(
                                    'ADD CARD',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                            opacity: _addingCard ? 1.0 : 0.0,
                            child: Container(
                              width: ResponsivityUtils.compute(30.0, context),
                              height: ResponsivityUtils.compute(30.0, context),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if (_addingCard) return;

                        var expiryDate = _expiryDateController.text.split('/');

                        setState(() {
                          _addingCard = true;
                        });

                        try {
                          await _subscriptionRepository.addCard(
                            Card(
                              number: _cardNumberController.text,
                              cvv: _cvvController.text,
                              expMonth: int.parse(expiryDate[0]),
                              expYear: int.parse(expiryDate[1]),
                            ),
                            PaymentMethodBillingDetails(
                              name: _cardHolderNameController.text,
                              email: Provider.of<UserRepository>(context)
                                  .user
                                  .data
                                  .email,
                            ),
                          );
                          await widget.refreshPaymentMethods();
                          Provider.of<SystemBarsRepository>(context)
                              .setLightForeground();
                          widget.onDisposeReady();
                        } catch (e) {
                          setState(() {
                            _addingCard = false;
                          });

                          showModalWidgetLight(
                              context,
                              ErrorDialog(
                                message:
                                    'An error occurred while adding a card. Check your card information!',
                              ));
                        }
                      } else {
                        setState(() {
                          _autoValidate = true;
                        });

                        if (_validateField(_cardNumber) != null) {
                          _scrollController.animateTo(
                            0.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            _expiryDateFocusNode.unfocus();
                            _cvvFocusNode.unfocus();
                            _cardHolderNameFocusNode.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_cardNumberFocusNode);
                          });
                        } else if (_validateExpiryDate(_expiryDate) != null) {
                          _scrollController.animateTo(
                            ResponsivityUtils.compute(20.0, context) * 4 +
                                180.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            _cardNumberFocusNode.unfocus();
                            _cvvFocusNode.unfocus();
                            _cardHolderNameFocusNode.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_expiryDateFocusNode);
                          });
                        } else if (_validateField(_cvv) != null) {
                          _scrollController.animateTo(
                            ResponsivityUtils.compute(20.0, context) * 6 +
                                180.0 +
                                120.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            _cardNumberFocusNode.unfocus();
                            _cardHolderNameFocusNode.unfocus();
                            _expiryDateFocusNode.unfocus();
                            FocusScope.of(context).requestFocus(_cvvFocusNode);
                          });
                        } else if (_validateField(_cardHolderName) != null) {
                          _scrollController.animateTo(
                            ResponsivityUtils.compute(20.0, context) * 8 +
                                180.0 +
                                120.0 +
                                120.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            _cardNumberFocusNode.unfocus();
                            _cvvFocusNode.unfocus();
                            _expiryDateFocusNode.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_cardHolderNameFocusNode);
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }

  String _validateField(String value) {
    value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);

    if (value.isEmpty) {
      return 'This field is required!';
    } else {
      return null;
    }
  }

  String _validateExpiryDate(String value) {
    value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);

    if (value.isEmpty) {
      return 'This field is required!';
    } else if (!value.contains('/')) {
      return 'Wrong date format!';
    } else {
      return null;
    }
  }
}
