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
    print(_instagramRepository.selectedAccount.username);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsivityUtils.compute(8.0, context),
        vertical: ResponsivityUtils.compute(4.0, context),
      ),
      height: ResponsivityUtils.compute(100.0, context),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsivityUtils.compute(20.0, context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: ResponsivityUtils.compute(240.0, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hi, @dejf33',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsivityUtils.compute(22.0, context),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Showing stats for selected account',
                      style: TextStyle(
                        fontSize: ResponsivityUtils.compute(14.0, context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                  colors: [
                    Provider.of<SubscriptionRepository>(context)
                        .planTheme
                        .gradientStartColor,
                    Provider.of<SubscriptionRepository>(context)
                        .planTheme
                        .gradientEndColor
                  ],
                ),
              ),
              height: ResponsivityUtils.compute(30.0, context),
              width: ResponsivityUtils.compute(110.0, context),
              padding: EdgeInsets.only(
                left: 10.0,
                right: 5.0,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  iconEnabledColor: Colors.white,
                  style: TextStyle(
                    fontFamily: 'LatoLatin',
                    color: Colors.white,
                  ),
                  elevation: 4,
                  isDense: true,
                  items: [
                    for (var account in _instagramRepository.accounts.data)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(
                          account.username,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {});
                  },
                  value: _instagramRepository.selectedAccount.id,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
