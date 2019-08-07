import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

enum EditOrDeleteActionType {
  None,
  Edit,
  Delete,
}

class EditOrDelete extends StatelessWidget {
  EditOrDelete({@required this.account, this.onEditOrDeleteActionChange});

  final InstagramAccount account;
  final Function(EditOrDeleteActionType) onEditOrDeleteActionChange;

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
            'Edit ' + account.username + ' account',
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
            margin:
                EdgeInsets.only(top: ResponsivityUtils.compute(20.0, context)),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsivityUtils.compute(10.0, context),
            ),
            child: CurvedBlackBorderedTransparentButton(
              child: Text('Edit username or password'),
              onPressed: () {
                onEditOrDeleteActionChange(EditOrDeleteActionType.Edit);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsivityUtils.compute(10.0, context),
            ),
            child: CurvedRedBorderedTransparentButton(
              child: Text(
                'Delete account',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                onEditOrDeleteActionChange(EditOrDeleteActionType.Delete);
              },
            ),
          ),
        ],
      ),
    );
  }
}
