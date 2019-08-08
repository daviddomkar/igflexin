import 'package:flutter/material.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/resources/subscription.dart';
import 'package:provider/provider.dart';

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
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
      return Center(
        child: Text(_cachedSubscription.type.toString()),
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
