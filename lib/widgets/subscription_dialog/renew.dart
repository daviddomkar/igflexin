import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

import '../buttons.dart';

class Renew extends StatefulWidget {
  Renew({
    Key key,
    this.onSuccess,
    this.onError,
    this.willPop,
  }) : super(key: key);

  final Function onSuccess;
  final Function onError;
  final Function(bool) willPop;

  @override
  _RenewState createState() {
    return _RenewState();
  }
}

class _RenewState extends State<Renew> with SingleTickerProviderStateMixin {
  SubscriptionRepository _subscriptionRepository;

  bool _processing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsivityUtils.compute(20.0, context),
      ),
      width: ResponsivityUtils.compute(320.0, context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsivityUtils.compute(20.0, context),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Renew subscription',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsivityUtils.compute(23.0, context),
              fontWeight: FontWeight.bold,
              color: _subscriptionRepository.planTheme.gradientStartColor,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                vertical: ResponsivityUtils.compute(20.0, context)),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsivityUtils.compute(10.0, context),
            ),
            child: Text(
              'Subscription will be renewed and your billing will continue at the end of current period.',
              textAlign: TextAlign.center,
            ),
          ),
          GradientButton(
            width:
                ResponsivityUtils.compute(_processing ? 45.0 : 130.0, context),
            height: ResponsivityUtils.compute(45.0, context),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                    opacity: !_processing ? 1.0 : 0.0,
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        fontSize: ResponsivityUtils.compute(16.0, context),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                    opacity: _processing ? 1.0 : 0.0,
                    child: Container(
                      width: ResponsivityUtils.compute(36.0, context),
                      height: ResponsivityUtils.compute(36.0, context),
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
              if (_processing) return;

              setState(() {
                _processing = true;
              });

              widget.willPop(false);

              try {
                await _subscriptionRepository.renewSubscription();
                widget.willPop(true);
                widget.onSuccess();
              } catch (e) {
                widget.willPop(true);
                widget.onError();
              }
            },
          ),
        ],
      ),
    );
  }
}
