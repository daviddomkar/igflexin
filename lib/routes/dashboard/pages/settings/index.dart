import 'package:flutter/material.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/resources/subscription.dart';
import 'package:igflexin/routes/dashboard/pages/settings/widgets/account_settings_group.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  SubscriptionRepository _subscriptionRepository;
  InstagramRepository _instagramRepository;

  Subscription _cachedSubscription;
  List<InstagramAccount> _cachedAccounts;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _instagramRepository = Provider.of<InstagramRepository>(context);

    if (_subscriptionRepository.subscription.state ==
        SubscriptionState.Active) {
      _cachedSubscription = _subscriptionRepository.subscription.data;
    }

    if (_instagramRepository.accounts.state == AccountsState.Some) {
      _cachedAccounts = _instagramRepository.accounts.data;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (_cachedSubscription != null && _cachedAccounts != null) {
      return ListView(
        padding: EdgeInsets.symmetric(
            vertical: ResponsivityUtils.compute(4.0, context)),
        children: [
          AccountSettingsGroup(),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientStartColor,
          ),
        ),
      );
    }
  }
}
