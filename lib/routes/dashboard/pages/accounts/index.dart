import 'package:flutter/material.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/resources/subscription.dart';
import 'package:igflexin/routes/dashboard/pages/accounts/widgets/account_card.dart';
import 'package:igflexin/routes/dashboard/pages/accounts/widgets/account_dialog.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/dialog.dart';
import 'package:provider/provider.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts>
    with AutomaticKeepAliveClientMixin<Accounts> {
  SubscriptionRepository _subscriptionRepository;
  InstagramRepository _instagramRepository;

  Subscription _cachedSubscription;
  List<InstagramAccount> _cachedAccounts;

  @override
  bool get wantKeepAlive => true;

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

  void _addInstagramAccount(BuildContext context) {
    showModalWidgetLight(context, AccountDialog());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (_cachedSubscription != null && _cachedAccounts != null) {
      if (_cachedAccounts.length > 0) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(
              vertical: ResponsivityUtils.compute(4.0, context)),
          itemCount: _cachedAccounts.length + 1,
          itemBuilder: (context, index) {
            if (index == _cachedAccounts.length) {
              return Container(
                height: ResponsivityUtils.compute(100.0, context),
                padding: EdgeInsets.symmetric(
                    vertical: ResponsivityUtils.compute(4.0, context)),
                child: Center(
                  child: _cachedAccounts.length <
                          getMaxAccountLimitFromSubscriptionPlanType(
                              _cachedSubscription.type)
                      ? GradientButton(
                          width: ResponsivityUtils.compute(150.0, context),
                          height: ResponsivityUtils.compute(45.0, context),
                          child: Text(
                            'Add new account',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => _addInstagramAccount(context),
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsivityUtils.compute(20.0, context)),
                          child: Text(
                            'Max account limit reached.\n' +
                                (_cachedSubscription.type !=
                                        SubscriptionPlanType.BusinessPRO
                                    ? ' Upgrade your subscription to add more accounts.'
                                    : ''),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              );
            } else {
              return AccountCard(
                account: _cachedAccounts[index],
              );
            }
          },
        );
      } else {
        return Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: ResponsivityUtils.compute(10.0, context)),
                  child: Text('You haven´t added any accounts yet!'),
                ),
                GradientButton(
                  width: ResponsivityUtils.compute(130.0, context),
                  height: ResponsivityUtils.compute(45.0, context),
                  child: Text(
                    'Add account',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _addInstagramAccount(context),
                ),
              ],
            ),
          ),
        );
      }
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
