import 'package:flutter/material.dart';
import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class AccountSettingsGroup extends StatefulWidget {
  @override
  _AccountSettingsGroupState createState() {
    return _AccountSettingsGroupState();
  }
}

class _AccountSettingsGroupState extends State<AccountSettingsGroup> {
  SubscriptionRepository _subscriptionRepository;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsivityUtils.compute(8.0, context),
        vertical: ResponsivityUtils.compute(4.0, context),
      ),
      child: Container(
        margin: EdgeInsets.all(
          ResponsivityUtils.compute(20.0, context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsivityUtils.compute(26.0, context),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: ResponsivityUtils.compute(50.0, context),
                  margin: EdgeInsets.only(
                      top: ResponsivityUtils.compute(10.0, context)),
                  child: CurvedTransparentButton(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign out',
                        style: TextStyle(
                            color: _subscriptionRepository
                                .planTheme.gradientStartColor),
                      ),
                    ),
                    onPressed: () {
                      Provider.of<AuthRepository>(context).signOut();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
