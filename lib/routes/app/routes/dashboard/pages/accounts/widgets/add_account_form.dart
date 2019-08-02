import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/utils/validation_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class AddAccountForm extends StatefulWidget {
  @override
  _AddAccountFormState createState() {
    return _AddAccountFormState();
  }
}

class _AddAccountFormState extends State<AddAccountForm> {
  SubscriptionRepository _subscriptionRepository;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _autoValidate = false;

  String _username = '';
  String _password = '';

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _usernameController.addListener(() {
      setState(() {
        _username = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _usernameController.text);
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _password = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _passwordController.text);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addInstagramAccount() {}

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
              'Add Instagram account',
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
                  top: ResponsivityUtils.compute(10.0, context)),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(10.0, context),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  cursorColor:
                      _subscriptionRepository.planTheme.gradientStartColor,
                  textSelectionColor: _subscriptionRepository
                      .planTheme.gradientStartColor
                      .withOpacity(0.5),
                ),
                child: TextFormField(
                  focusNode: _usernameFocusNode,
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _usernameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'Username',
                    labelStyle: TextStyle(
                        color: _usernameFocusNode.hasFocus
                            ? _subscriptionRepository
                                .planTheme.gradientStartColor
                            : null),
                    errorStyle: TextStyle(color: Colors.black),
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
            Container(
              margin: EdgeInsets.only(
                  bottom: ResponsivityUtils.compute(20.0, context)),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(10.0, context),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  cursorColor:
                      _subscriptionRepository.planTheme.gradientStartColor,
                  textSelectionColor: _subscriptionRepository
                      .planTheme.gradientStartColor
                      .withOpacity(0.5),
                ),
                child: TextFormField(
                  focusNode: _passwordFocusNode,
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _passwordFocusNode.unfocus();
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: _passwordFocusNode.hasFocus
                            ? _subscriptionRepository
                                .planTheme.gradientStartColor
                            : null),
                    errorStyle: TextStyle(color: Colors.black),
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
              width: ResponsivityUtils.compute(130.0, context),
              height: ResponsivityUtils.compute(45.0, context),
              child: Text(
                'Add account',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
