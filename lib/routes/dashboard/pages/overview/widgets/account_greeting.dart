import 'package:flutter/material.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class AccountGreeting extends StatefulWidget {
  const AccountGreeting({Key key, this.onIconTap}) : super(key: key);

  final Function onIconTap;

  @override
  _AccountGreetingState createState() => _AccountGreetingState();
}

class _AccountGreetingState extends State<AccountGreeting> {
  InstagramRepository _instagramRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _instagramRepository = Provider.of<InstagramRepository>(context);
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
            if (_instagramRepository.selectedAccount != null)
              Container(
                width: ResponsivityUtils.compute(300.0, context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hi, ' + _instagramRepository.selectedAccount.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsivityUtils.compute(24.0, context),
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
            if (_instagramRepository.selectedAccount == null)
              Container(
                width: ResponsivityUtils.compute(300.0, context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hi, let's get started!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsivityUtils.compute(24.0, context),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Add your account on Accounts page',
                        style: TextStyle(
                          fontSize: ResponsivityUtils.compute(14.0, context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_instagramRepository.selectedAccount == null)
              IconButton(
                iconSize: ResponsivityUtils.compute(32.0, context),
                icon: Icon(Icons.people),
                onPressed: () {
                  widget.onIconTap();
                },
              ),
          ],
        ),
      ),
    );
  }
}
