import 'package:flutter/widgets.dart';
import 'dart:async';

typedef Widget RouteBuilder(BuildContext context);

class Route {
  final String name;
  final RouteBuilder builder;
  final bool clearsHistory;

  Route(this.name, this.builder, {this.clearsHistory = false});
}

class RouterController extends Listenable {
  static final RouterController _singleton = RouterController._internal();

  factory RouterController() {
    return _singleton;
  }

  RouterController._internal();

  final Set<VoidCallback> _listeners = Set<VoidCallback>();

  // Tohle je mega špatný dělat z hlediska imutability, ale jsem líný teď vymýšlet nějaký lepší pattern xddd
  final Map<String, _RouterState> _routerStates = Map();

  int _version = 0;

  StreamSubscription<List> _exitingAnimationStreamSubscription;
  bool _exiting = false;

  void switchRoute(String routerName, String routeName, {bool recordHistory = true}) {
    if (_routerStates[routerName]._selectedRoute.name == routeName) {
      if (_exiting) {
        _exitingAnimationStreamSubscription?.cancel();

        int startIndex =
            _routerStates.values.toList().indexWhere((routerState) => routerState.widget.name == routerName);

        for (int i = startIndex; i < _routerStates.values.toList().length; i++) {
          _routerStates.values.toList()[i]._animationControllers.forEach((controller) {
            controller.forward();
          });
        }

        _exiting = false;
      } else {
        return;
      }
    }

    List<Future<void>> futures = List<Future<void>>();

    int startIndex = _routerStates.values.toList().indexWhere((routerState) => routerState.widget.name == routerName);

    for (int i = startIndex; i < _routerStates.values.toList().length; i++) {
      _routerStates.values.toList()[i]._animationControllers.forEach((controller) {
        futures.add(controller.reverse().whenComplete(() {}));
      });
    }

    _exiting = true;
    _exitingAnimationStreamSubscription = Future.wait(futures).asStream().listen((data) {
      _exiting = false;

      Route route = _routerStates[routerName].widget.routes.firstWhere((route) => route.name == routeName);

      if (recordHistory) {
        _routerStates[routerName]._history.add(_routerStates[routerName]._selectedRoute.name);
      }

      if (route.clearsHistory) {
        _routerStates[routerName]._history.clear();
      }

      _routerStates[routerName]._selectedRoute = route;

      notifyListeners();

      int startIndex = _routerStates.values.toList().indexWhere((routerState) => routerState.widget.name == routerName);

      for (int i = startIndex; i < _routerStates.values.toList().length; i++) {
        _routerStates.values.toList()[i]._animationControllers.forEach((controller) {
          controller.forward();
        });
      }
    });
  }

  void registerAnimationController(String routerName, AnimationController controller) {
    if (!_routerStates[routerName]._animationControllers.contains(controller)) {
      _routerStates[routerName]._animationControllers.add(controller);
    }
  }

  void unregisterAnimationController(String routerName, AnimationController controller) {
    _routerStates[routerName]._animationControllers.remove(controller);
  }

  bool pop() {
    List<_RouterState> routerStates = _routerStates.values.toList();

    int startIndex = routerStates.lastIndexWhere((routerState) => routerState.widget.autoPop);

    for (int i = startIndex; i >= 0; i--) {
      if (routerStates[i].widget.autoPop) {
        if (routerStates[i]._history.isNotEmpty) {
          String routeName = routerStates[i]._history.removeLast();
          switchRoute(routerStates[i].widget.name, routeName, recordHistory: false);
          break;
        } else {
          if (i == 0) {
            if (_exiting) {
              _exitingAnimationStreamSubscription?.cancel();

              int startIndex = _routerStates.values
                  .toList()
                  .indexWhere((routerState) => routerState.widget.name == routerStates[i].widget.name);

              for (int i = startIndex; i < _routerStates.values.toList().length; i++) {
                _routerStates.values.toList()[i]._animationControllers.forEach((controller) {
                  controller.forward();
                });
              }

              _exiting = false;
              return false;
            } else {
              return true;
            }
          }
        }
      }
    }

    notifyListeners();
    return false;
  }

  Future<bool> _onWillPop() async {
    return pop();
  }

  factory RouterController.of(BuildContext context, String routerName) {
    return InheritedModel.inheritFrom<_RouterControllerModel>(context, aspect: routerName).controller;
  }

  static Widget createRouter(BuildContext context,
      {Key key, @required name, @required routes, @required startingRoute, autoPop = true}) {
    return _Router(name: name, routes: routes, startingRoute: startingRoute, autoPop: autoPop);
  }

  static Widget create(BuildContext context, {Widget child}) {
    return _RouterControllerUpdater(
      child: child,
    );
  }

  static void switchRouteStatic(BuildContext context, String routerName, String routeName) {
    RouterController.of(context, routerName).switchRoute(routerName, routeName);
  }

  static void registerAnimationControllerStatic(
      BuildContext context, String routerName, AnimationController controller) {
    RouterController.of(context, routerName).registerAnimationController(routerName, controller);
  }

  static void unregisterAnimationControllerStatic(
      BuildContext context, String routerName, AnimationController controller) {
    RouterController.of(context, routerName).unregisterAnimationController(routerName, controller);
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  int get listenerCount => _listeners.length;

  @protected
  void notifyListeners() {
    _version++;
    _listeners.toList().forEach((VoidCallback listener) => listener());
  }
}

class _RouterControllerUpdater extends StatelessWidget {
  _RouterControllerUpdater({@required this.child});

  final RouterController controller = RouterController();
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return WillPopScope(
            onWillPop: controller._onWillPop,
            child: _RouterControllerModel(child: child, controller: controller),
          );
        });
  }
}

class _RouterControllerModel extends InheritedModel<String> {
  _RouterControllerModel({Key key, Widget child, RouterController controller})
      : this.controller = controller,
        this.version = controller._version,
        super(key: key, child: child);

  final RouterController controller;
  final int version;

  @override
  bool updateShouldNotify(_RouterControllerModel oldWidget) {
    return (oldWidget.version != version);
  }

  @override
  bool updateShouldNotifyDependent(InheritedModel<String> oldWidget, Set<String> aspects) {
    bool result = false;

    controller._routerStates.keys.forEach((routerName) {
      if (aspects.contains(routerName)) result = true;
    });

    return result;
  }
}

class _Router extends StatefulWidget {
  final String name;
  final List<Route> routes;
  final String startingRoute;
  final bool autoPop;

  _Router({Key key, @required this.name, @required this.routes, @required this.startingRoute, this.autoPop = true})
      : super(key: key);

  @override
  _RouterState createState() => _RouterState();
}

class _RouterState extends State<_Router> {
  RouterController _controller;
  Route _selectedRoute;
  List<String> _history = List();
  List<AnimationController> _animationControllers = List();

  @override
  void didChangeDependencies() {
    _controller = RouterController.of(context, widget.name);
    if (!_controller._routerStates.containsKey(widget.name)) {
      _selectedRoute = widget.routes[widget.routes.indexWhere((route) => route.name == widget.startingRoute)];
      _controller._routerStates[widget.name] = this;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _selectedRoute.builder(context);
  }

  @override
  void dispose() {
    if (_controller._routerStates.containsKey(widget.name)) {
      _controller._routerStates.remove(widget.name);
    }

    super.dispose();
  }
}

typedef Widget RouterAnimationControllerBuilder(BuildContext context, AnimationController controller);

class RouterAnimationController extends StatefulWidget {
  RouterAnimationController({Key key, @required this.routerName, @required this.duration, @required this.builder})
      : super(key: key);

  final String routerName;
  final Duration duration;
  final RouterAnimationControllerBuilder builder;

  @override
  _RouterAnimationControllerState createState() => _RouterAnimationControllerState();
}

class _RouterAnimationControllerState extends State<RouterAnimationController> with TickerProviderStateMixin {
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
    _routerController = RouterController.of(context, widget.routerName);
    _routerController.registerAnimationController(widget.routerName, _controller);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _routerController.unregisterAnimationController(widget.routerName, _controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}
