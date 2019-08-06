import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class AccountCard extends StatelessWidget {
  AccountCard({this.account});

  final InstagramAccount account;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ResponsivityUtils.compute(8.0, context),
          vertical: ResponsivityUtils.compute(4.0, context)),
      height: ResponsivityUtils.compute(100.0, context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: account.profilePictureURL ??
                'https://scontent-mxp1-1.cdninstagram.com/vp/6e968c363d4874107ae4b2e9ae3abdcf/5DCB27F1/t51.2885-19/44884218_345707102882519_2446069589734326272_n.jpg?_nc_ht=scontent-mxp1-1.cdninstagram.com',
            imageBuilder: (context, imageProvider) => Container(
              margin: EdgeInsets.only(
                  left: ResponsivityUtils.compute(10.0, context)),
              height: ResponsivityUtils.compute(80.0, context),
              width: ResponsivityUtils.compute(80.0, context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            placeholder: (context, url) => Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  left: ResponsivityUtils.compute(10.0, context)),
              height: ResponsivityUtils.compute(80.0, context),
              width: ResponsivityUtils.compute(80.0, context),
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Provider.of<SubscriptionRepository>(context)
                      .planTheme
                      .gradientStartColor,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  left: ResponsivityUtils.compute(10.0, context)),
              height: ResponsivityUtils.compute(80.0, context),
              width: ResponsivityUtils.compute(80.0, context),
              child: Expanded(
                child: Text('Error loading profile image'),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  left: ResponsivityUtils.compute(10.0, context),
                  right: ResponsivityUtils.compute(10.0, context)),
              height: ResponsivityUtils.compute(80.0, context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        account.username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsivityUtils.compute(24.0, context)),
                      ),
                      Container(
                        width: ResponsivityUtils.compute(90, context),
                        height: ResponsivityUtils.compute(35, context),
                        child: CurvedBlackBorderedTransparentButton(
                          child: Text(
                            'Edit',
                            style: TextStyle(),
                          ),
                          onPressed: (() {}),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status: ' + account.status),
                      GradientButton(
                        width: ResponsivityUtils.compute(90, context),
                        height: ResponsivityUtils.compute(35, context),
                        child: Text(
                          'Pause',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: (() {}),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
