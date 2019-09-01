import 'package:flutter/material.dart';
import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/auth_info.dart';
import 'package:igflexin/router_controller.dart';

import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class SendEmailForPasswordChangeButton extends StatefulWidget {
  SendEmailForPasswordChangeButton({
    Key key,
    this.controller,
    this.onPressed, this.processing,
  })  : scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.400, 0.900, curve: Curves.elasticOut),
        )),
        super(key: key);

  final AnimationController controller;
  final GestureTapCallback onPressed;

  final Animation<double> scale;
  final bool processing;

  @override
  _SendEmailForPasswordChangeButtonState createState() => _SendEmailForPasswordChangeButtonState();
}

class _SendEmailForPasswordChangeButtonState extends State<SendEmailForPasswordChangeButton>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.scale.value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutExpo,
        width: ResponsivityUtils.compute(
            widget.processing
                ? 50.0
                : 300,
            context),
        height: ResponsivityUtils.compute(50.0, context),
        margin:
        EdgeInsets.only(top: ResponsivityUtils.compute(10.0, context)),
        child: CurvedWhiteButton(
          padding: EdgeInsets.all(0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                  opacity: !widget.processing
                      ? 1.0
                      : 0.0,
                  child: Text(
                    'Recover password',
                    style: TextStyle(
                      fontSize: ResponsivityUtils.compute(16.0, context),
                      color: Provider.of<SubscriptionRepository>(context)
                          .planTheme
                          .gradientStartColor,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                  opacity: widget.processing
                      ? 1.0
                      : 0.0,
                  child: Container(
                    width: ResponsivityUtils.compute(40.0, context),
                    height: ResponsivityUtils.compute(40.0, context),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Provider.of<SubscriptionRepository>(context)
                            .planTheme
                            .gradientStartColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
