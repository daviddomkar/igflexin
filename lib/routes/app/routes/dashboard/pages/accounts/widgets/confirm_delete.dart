import 'package:flutter/material.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class ConfirmDelete extends StatelessWidget {
  const ConfirmDelete({Key key, this.account, this.onDeleted})
      : super(key: key);

  final InstagramAccount account;
  final Function() onDeleted;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete ${account.username} account',
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
            margin: EdgeInsets.symmetric(
                vertical: ResponsivityUtils.compute(20.0, context)),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsivityUtils.compute(10.0, context),
            ),
            child: Text(
              'Are you sure to delete ${account.username} account including all its statistics?',
              textAlign: TextAlign.center,
            ),
          ),
          GradientButton(
            width: ResponsivityUtils.compute(130.0, context),
            height: ResponsivityUtils.compute(45.0, context),
            child: Text(
              'Confirm delete',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              onDeleted();
              Navigator.maybePop(context);
              await Provider.of<InstagramRepository>(context)
                  .delete(id: account.id);
            },
          ),
        ],
      ),
    );
  }
}
