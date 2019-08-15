import 'package:flutter/material.dart' hide Route;

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/repositories/system_bars_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';
import 'package:igflexin/resources/subscription.dart';

import 'package:igflexin/resources/user.dart';

import 'package:igflexin/routes/auth/index.dart';
import 'package:igflexin/routes/dashboard/index.dart';
import 'package:igflexin/routes/splash/index.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/index.dart';
import 'package:igflexin/routes/subscription_plan_selection/index.dart';

import 'package:provider/provider.dart';

class MainRouterController extends RouterController {
  static List<Route> _generateRoutes() {
    return [
      Route('splash', (context) {
        return Splash();
      }, clearsHistory: true),
      Route('auth', (context) {
        return Auth();
      }, clearsHistory: true),
      Route('subscription_plan_selection', (context) {
        return SubscriptionPlanSelection();
      }, clearsHistory: true),
      Route('subscription_plan_payment_flow', (context) {
        return SubscriptionPlanPaymentFlow();
      }, clearsHistory: false),
      Route('dashboard', (context) {
        return Dashboard();
      }, clearsHistory: true),
    ];
  }

  MainRouterController(BuildContext context)
      : super(context, _generateRoutes(), 'splash');

  UserRepository _userRepository;
  SubscriptionRepository _subscriptionRepository;
  SystemBarsRepository _systembarsRepository;

  @override
  void didWidgetChangeDependencies(BuildContext context) {
    _userRepository = Provider.of<UserRepository>(context);
    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _systembarsRepository = Provider.of<SystemBarsRepository>(context);

    _systembarsRepository.setNavigationBarColor(Colors.transparent);
    _systembarsRepository.setStatusBarColor(Colors.transparent);
  }

  @override
  void beforeBuild(BuildContext context) {
    UserResource user = _userRepository.user;
    SubscriptionResource subscription = _subscriptionRepository.subscription;

    switch (user.state) {
      case UserState.None:
        push('splash');
        break;
      case UserState.Unauthenticated:
        push('auth');
        break;
      case UserState.Authenticated:
        switch (subscription.state) {
          case SubscriptionState.None:
            push(
              'splash',
              playExitAnimations: false,
              playExceptLastAnimation: true,
            );
            break;
          case SubscriptionState.Inactive:
            if (currentRoute.name != 'subscription_plan_payment_flow') {
              push(
                'subscription_plan_selection',
                playExitAnimations: false,
                playExceptLastAnimation: true,
              );
            }
            break;
          case SubscriptionState.Active:
            if (currentRoute.name == 'auth') {
              push(
                'dashboard',
                playExitAnimations: false,
                playOnlyLastAnimation: true,
              );
            } else if (currentRoute.name == 'subscription_plan_payment_flow') {
              push(
                'dashboard',
                playExitAnimations: false,
                playLastTwoAnimationsForward: true,
              );
            } else {
              push('dashboard');
            }
            break;
        }
        break;
    }
  }

  @override
  void afterPush(Route nextRoute) {
    _changeSystemBarsAppearanceForToNextRoute(nextRoute);
  }

  @override
  void afterPop(Route nextRoute) {
    _changeSystemBarsAppearanceForToNextRoute(nextRoute);
  }

  void _changeSystemBarsAppearanceForToNextRoute(Route nextRoute) {
    switch (nextRoute.name) {
      case 'splash':
        print('splash');
        _systembarsRepository.setLightForeground();
        break;
      case 'auth':
        print('auth');
        _systembarsRepository.setLightForeground();
        break;
      case 'subscription_plan_selection':
        print('subscription_plan_selection');
        _systembarsRepository.setDarkForeground();
        break;
      case 'subscription_plan_payment_flow':
        print('subscription_plan_payment_flow');
        _systembarsRepository.setLightForeground();
        break;
      case 'dashboard':
        print('dashboard');
        _systembarsRepository.setDarkForeground();
        break;
    }
  }
}
