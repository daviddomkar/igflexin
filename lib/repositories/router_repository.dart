import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class RouterRepository {
  RouterRepository() : _controllers = List();

  final List<RouterController> _controllers;

  void registerController(RouterController controller) {
    if (!_controllers.contains(controller)) {
      _controllers.add(controller);
    }
  }

  void unregisterController(RouterController controller) {
    if (_controllers.contains(controller)) {
      _controllers.remove(controller);
    }
  }

  Future<void> reverseAnimationControllers(RouterController controller) async {
    var startIndex = _controllers.indexOf(controller);

    List<Future<void>> futures = List<Future<void>>();

    for (var i = startIndex; i < _controllers.length; i++) {
      _controllers[i].controllers.forEach((animationController) {
        futures.add(animationController.reverse());
      });
    }

    await Future.wait(futures);
  }

  Future<void> forwardAnimationControllers(RouterController controller) async {
    var startIndex = _controllers.indexOf(controller);

    List<Future<void>> futures = List<Future<void>>();

    for (var i = startIndex; i < _controllers.length; i++) {
      _controllers[i].controllers.forEach((animationController) {
        futures.add(animationController.forward());
      });
    }

    await Future.wait(futures);
  }

  Future<bool> pop() async {
    bool willPop = await _controllers.last.pop();

    var index = 2;

    while (willPop) {
      willPop = await _controllers[_controllers.length - index].pop();

      if (_controllers.length - index == 0) {
        return true;
      }

      index++;
    }

    return false;
  }
}

class Router<C extends RouterController> extends StatefulWidget {
  Router({@required this.builder});

  final ValueBuilder<C> builder;

  static C of<C extends RouterController>(BuildContext context) {
    return Provider.of<C>(context);
  }

  @override
  _RouterState createState() => _RouterState<C>();
}

class _RouterState<C extends RouterController> extends State<Router> {
  C _routerController;
  RouterRepository _routerRepository;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routerController == null) {
      _routerController = widget.builder(context);
    }

    _routerRepository = Provider.of<RouterRepository>(context);
    _routerRepository.registerController(_routerController);

    _routerController.didWidgetChangeDependencies(context);
  }

  @override
  void dispose() {
    _routerRepository.unregisterController(_routerController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _routerController.beforeBuild(context);

    return ChangeNotifierProvider<C>(
      builder: (_) => _routerController,
      child: Consumer<C>(
        builder: (context, controller, child) {
          return _routerController.currentRoute.builder(context);
        },
      ),
    );
  }
}

typedef Widget RouteBuilder(BuildContext context);

class Route {
  Route(this.name, this.builder, {this.clearsHistory = false});

  final String name;
  final RouteBuilder builder;
  final bool clearsHistory;
}

abstract class RouterController extends ChangeNotifier {
  RouterController(BuildContext context, this.routes, String startingRouteName)
      : controllers = List(),
        this.history = List() {
    this.currentRoute = this.routes.firstWhere((route) => route.name == startingRouteName);
    this._routerRepository = Provider.of<RouterRepository>(context);
  }

  final List<Route> routes;
  final List<Route> history;

  List<AnimationController> controllers;
  Route currentRoute;
  RouterRepository _routerRepository;

  bool _exiting = false;

  void didWidgetChangeDependencies(BuildContext context) {}

  void beforeBuild(BuildContext context) {}

  Future<void> push(String routeName,
      {bool playExitAnimations = true, bool playOnlyLastAnimation = false}) async {
    if (currentRoute.name == routeName) return;

    if (playExitAnimations) {
      _exiting = true;
      await _routerRepository.reverseAnimationControllers(this);
      _exiting = false;
    } else if (playOnlyLastAnimation) {
      if (controllers.isNotEmpty) {
        await controllers.last.reverse();
      }
    }

    Route nextRoute = this.routes.firstWhere((route) => route.name == routeName);

    if (nextRoute.clearsHistory) {
      history.clear();
    } else {
      history.add(currentRoute);
    }

    currentRoute = nextRoute;
    afterPush(nextRoute);
    notifyListeners();
  }

  void afterPush(Route nextRoute) {}

  Future<bool> pop() async {
    if (_exiting) {
      _exiting = false;
      await _routerRepository.forwardAnimationControllers(this);
      return false;
    }

    if (history.isEmpty) {
      return true;
    }

    await _routerRepository.reverseAnimationControllers(this);

    currentRoute = history.removeLast();
    notifyListeners();

    return false;
  }

  void registerAnimationController(AnimationController controller) {
    if (!this.controllers.contains(controller)) {
      this.controllers.add(controller);
    }
  }

  void unregisterAnimationController(AnimationController controller) {
    if (this.controllers.contains(controller)) {
      this.controllers.remove(controller);
    }
  }
}

typedef Widget RouterAnimationControllerBuilder(
    BuildContext context, AnimationController controller);

class RouterAnimationController<C extends RouterController> extends StatefulWidget {
  RouterAnimationController({@required this.duration, @required this.builder});

  final Duration duration;
  final RouterAnimationControllerBuilder builder;

  @override
  _RouterAnimationControllerState createState() {
    return _RouterAnimationControllerState<C>();
  }
}

class _RouterAnimationControllerState<C extends RouterController>
    extends State<RouterAnimationController> with SingleTickerProviderStateMixin {
  RouterController _routerController;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routerController = Provider.of<C>(context);
    _routerController.registerAnimationController(_controller);
  }

  @override
  void dispose() {
    _routerController.unregisterAnimationController(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}

class RouterPopScope extends StatefulWidget {
  RouterPopScope({@required this.child});

  final Widget child;

  @override
  _RouterPopScopeState createState() {
    return _RouterPopScopeState();
  }
}

class _RouterPopScopeState extends State<RouterPopScope> {
  _RouterPopScopeState();

  RouterRepository _routerRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routerRepository = Provider.of<RouterRepository>(context);
  }

  Future<bool> _onWillPop() async {
    return await _routerRepository.pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.child,
    );
  }
}
