import 'package:flutter/material.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/utils/validation_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class TwoFactorAuthForm extends StatefulWidget {
  TwoFactorAuthForm({
    this.username,
    this.securityCode,
    this.onSecurityCodeChange,
    this.onStateReceived,
    this.onErrorReceived,
  });

  final username;
  final securityCode;
  final void Function(String) onSecurityCodeChange;
  final void Function(InstagramAccountState) onStateReceived;
  final void Function(String) onErrorReceived;

  @override
  _TwoFactorAuthFormState createState() {
    return _TwoFactorAuthFormState();
  }
}

class _TwoFactorAuthFormState extends State<TwoFactorAuthForm> {
  InstagramRepository _instagramRepository;
  SubscriptionRepository _subscriptionRepository;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _securityCodeController = TextEditingController();

  bool _autoValidate = false;
  bool _fixing = false;

  String _securityCode;

  FocusNode _securityCodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _securityCode = widget.securityCode;

    _securityCodeController.text = _securityCode;

    _securityCodeController.addListener(() {
      setState(() {
        _securityCode = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _securityCodeController.text);
        widget.onSecurityCodeChange(_securityCode);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _instagramRepository = Provider.of<InstagramRepository>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fixSecurityCode() async {
    if (_formKey.currentState.validate()) {
      if (_fixing) return;

      setState(() {
        _fixing = true;
      });

      try {
        final response = await _instagramRepository.sendTwoFactorAuthCode(
          securityCode: _securityCode,
          username: widget.username,
        );

        if (response.message == 'success') {
          widget.onStateReceived(InstagramAccountState.Running);
          Navigator.maybePop(context);
        } else if (response.message == 'checkpoint-required') {
          widget.onStateReceived(InstagramAccountState.CheckpointRequired);
        }
      } on CloudFunctionsException catch (e) {
        print(e);

        switch (e.code) {
          case 'INVALID_ARGUMENT':
            widget.onErrorReceived(
                'Username or password has been changed recently, please edit added instagram account!');
            break;
          case 'DEADLINE_EXCEEDED':
            widget.onErrorReceived(
                'Operation is taking a long time, but will be completed soon.');
            break;
          default:
            widget.onErrorReceived('Unknown error occurred!');
            break;
        }
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsivityUtils.compute(20.0, context)),
      width: ResponsivityUtils.compute(320.0, context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsivityUtils.compute(20.0, context),
        ),
      ),
      child: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Two factor code required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsivityUtils.compute(23.0, context),
                fontWeight: FontWeight.bold,
                color: Provider.of<SubscriptionRepository>(context)
                    .planTheme
                    .gradientStartColor,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: ResponsivityUtils.compute(10.0, context),
                bottom: ResponsivityUtils.compute(20.0, context),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(10.0, context),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  cursorColor: _securityCodeController.text.isEmpty &&
                          _autoValidate
                      ? Colors.red
                      : _subscriptionRepository.planTheme.gradientStartColor,
                  textSelectionColor:
                      _securityCodeController.text.isEmpty && _autoValidate
                          ? Colors.red.withOpacity(0.5)
                          : _subscriptionRepository.planTheme.gradientStartColor
                              .withOpacity(0.5),
                ),
                child: TextFormField(
                  focusNode: _securityCodeFocusNode,
                  controller: _securityCodeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _securityCodeFocusNode.unfocus();
                    _fixSecurityCode();
                  },
                  validator: _validateField,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'Security code from SMS or app',
                    labelStyle: TextStyle(
                        color: _securityCodeFocusNode.hasFocus
                            ? _securityCodeController.text.isEmpty &&
                                    _autoValidate
                                ? Colors.red
                                : _subscriptionRepository
                                    .planTheme.gradientStartColor
                            : null),
                    errorStyle: TextStyle(color: Colors.red),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: _subscriptionRepository
                            .planTheme.gradientStartColor,
                        width: ResponsivityUtils.compute(2.0, context),
                      ),
                    ),
                    focusColor:
                        _subscriptionRepository.planTheme.gradientStartColor,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
            GradientButton(
              width: ResponsivityUtils.compute(_fixing ? 45.0 : 130.0, context),
              height: ResponsivityUtils.compute(45.0, context),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      opacity: !_fixing ? 1.0 : 0.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Send',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
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
                      opacity: _fixing ? 1.0 : 0.0,
                      child: Container(
                        width: 30.0,
                        height: 30.0,
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
              onPressed: () {
                _fixSecurityCode();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _validateField(String value) {
    value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);

    if (value.isEmpty) {
      return 'This field is required!';
    } else if (value.length != 6) {
      return 'Security code must have 6 digits!';
    } else {
      return null;
    }
  }
}
