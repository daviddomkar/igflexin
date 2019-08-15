/*
,
*/

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class AccountSelection extends StatefulWidget {
  @override
  _AccountSelectionState createState() => _AccountSelectionState();
}

class _AccountSelectionState extends State<AccountSelection> {
  InstagramRepository _instagramRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _instagramRepository = Provider.of<InstagramRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsivityUtils.compute(170.0, context),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            iconEnabledColor: Colors.black,
            style: TextStyle(
              fontFamily: 'LatoLatin',
              color: Colors.black,
            ),
            elevation: 4,
            isDense: true,
            items: [
              for (var account in _instagramRepository.accounts.data)
                DropdownMenuItem(
                  value: account.id,
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: account.profilePictureURL ??
                            'https://scontent-mxp1-1.cdninstagram.com/vp/6e968c363d4874107ae4b2e9ae3abdcf/5DCB27F1/t51.2885-19/44884218_345707102882519_2446069589734326272_n.jpg?_nc_ht=scontent-mxp1-1.cdninstagram.com',
                        imageBuilder: (context, imageProvider) => Container(
                          margin: EdgeInsets.only(
                              left: ResponsivityUtils.compute(10.0, context)),
                          height: ResponsivityUtils.compute(20.0, context),
                          width: ResponsivityUtils.compute(20.0, context),
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
                          height: ResponsivityUtils.compute(20.0, context),
                          width: ResponsivityUtils.compute(20.0, context),
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
                          height: ResponsivityUtils.compute(20.0, context),
                          width: ResponsivityUtils.compute(20.0, context),
                          child: Expanded(
                            child: Text('Error loading profile image'),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: ResponsivityUtils.compute(5.0, context),
                        ),
                        child: Text(
                          account.username,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            onChanged: (value) {
              setState(() {
                _instagramRepository.selectAccount(
                  id: value,
                );
              });
            },
            value: _instagramRepository.selectedAccount.id,
          ),
        ),
      ),
    );
  }
}
