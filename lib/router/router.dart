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

        int startIndex = _routerStates.values.toList().indexWhere((routerState) => routerState.widget.name == routerName);

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

    Route route = _routerStates[routerName].widget.routes.firstWhere((route) => route.name == routeName);

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

      if (route.clearsHistory) {
        _routerStates[routerName]._history.clear();
      }

      if (recordHistory) {
        _routerStates[routerName]._history.add(_routerStates[routerName]._selectedRoute.name);
      }

      _routerStates[routerName]._selectedRoute = route;

      notifyListeners();
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

              int startIndex = _routerStates.values.toList().indexWhere((routerState) => routerState.widget.name == routerStates[i].widget.name);

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

  static Widget createRouter(BuildContext context, {Key key, @required name, @required routes, @required startingRoute, autoPop = true}) {
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

  static void registerAnimationControllerStatic(BuildContext context, String routerName, AnimationController controller) {
    RouterController.of(context, routerName).registerAnimationController(routerName, controller);
  }

  static void unregisterAnimationControllerStatic(BuildContext context, String routerName, AnimationController controller) {
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
        super(key: key, child: child) {}

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

  _Router({Key key, @required this.name, @required this.routes, @required this.startingRoute, this.autoPop = true}) : super(key: key);

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

/*
class _RouterState extends State<Router> {
  _RouterController _routerController;

  @override
  void initState() {
    _routerController = _RouterController(this.widget.name, this.widget.routes, this.widget.startingRoute);
    _routerController.addListener(updateRoute);
    super.initState();
  }

  @override
  void didUpdateWidget(Router oldWidget) {
    _remountController();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void reassemble() {
    //_remountController();
    super.reassemble();
  }

  void _remountController() {
    _routerController.removeListener(updateRoute);
    _routerController.dispose();
    _routerController = _RouterController(this.widget.name, this.widget.routes, this.widget.startingRoute);
    _routerController.addListener(updateRoute);
  }

  void updateRoute() {
    // idk ale bez toho to nefunguje xdddd
    setState(() {});
  }

  @override
  void dispose() {
    _routerController.removeListener(updateRoute);
    _routerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.inherit

    if (_RouterController.routers.length > 1) {
      return _routerController.selectedRouteBuilder(context);
    } else {
      return WillPopScope(
        onWillPop: () async => await _RouterController.popRoot(),
        child: _routerController.selectedRouteBuilder(context),
      );
    }
  }
}

class RouterController {
  final _RouterController router;

  RouterController(this.router);

  static Future<bool> popRoot() async {
    return await _RouterController.popRoot();
  }

  factory RouterController.main() {
    return RouterController(_RouterController.routers[_RouterController.routers.keys.first]);
  }

  factory RouterController.withName(String name) {
    return RouterController(_RouterController.routers[name]);
  }

  void switchRoute(String name) {
    router.switchRoute(name);
  }

  void clearHistory() {
    router.clearHistory();
  }

  void registerAnimationController(AnimationController controller) {
    router.registerAnimationController(controller);
  }

  void unregisterAnimationController(AnimationController controller) {
    router.unregisterAnimationController(controller);
  }

  Future<bool> pop() async {
    return await router.pop();
  }
}


class _RouterController extends Listenable {
  final Set<VoidCallback> _listeners = Set<VoidCallback>();
  final List<String> _history = List<String>();
  final List<AnimationController> _animationControllers = List<AnimationController>();

  final String name;
  final List<Route> routes;
  final String startingRoute;
  final bool autoPop;

  Route _selectedRoute;
  bool _disposed;

  static Map<String, _RouterController> _routers = Map();

  static Map<String, _RouterController> get routers {
    return _routers;
  }

  _RouterController(this.name, this.routes, this.startingRoute, {this.autoPop = true}) {
    _selectedRoute = routes[routes.indexWhere((route) => route.name == startingRoute)];
    _routers[this.name] = this;
    _disposed = false;
  }

  Future<void> switchRoute(String name, {bool record = true}) async {
    if (name == _selectedRoute.name) return Future.value();
    if (record) _history.add(_selectedRoute.name);
    _selectedRoute = routes[routes.indexWhere((route) => route.name == name)];

    if (_selectedRoute.clearsHistory) {
      clearHistory();
    }

    await reverseAnimationControllers();
    notifyListeners();
    await forwardAnimationControllers();
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @protected
  void notifyListeners() {
    _listeners.toList().forEach((VoidCallback listener) => listener());
  }

  RouteBuilder get selectedRouteBuilder {
    return _selectedRoute.builder;
  }

  Future<void> reverseAnimationControllers() async {
    List<Future<void>> futures = List<Future<void>>();

    List<_RouterController> routers = _routers.values.toList();

    for (int i = routers.indexOf(this); i < _routers.values.length; i++) {
      routers.toList()[i]._animationControllers.forEach((controller) {
        futures.add(controller.reverse().whenComplete(() {}));
      });
    }

    await Future.wait(futures);
  }

  Future<void> forwardAnimationControllers() async {
    List<Future<void>> futures = List<Future<void>>();

    List<_RouterController> routers = _routers.values.toList();

    for (int i = routers.indexOf(this); i < _routers.values.length; i++) {
      routers.toList()[i]._animationControllers.forEach((controller) {
        futures.add(controller.forward().whenComplete(() {}));
      });
    }

    await Future.wait(futures);
  }

  Future<bool> pop() async {
    if (_history.isNotEmpty) {
      String route = _history.removeLast();
      await switchRoute(route, record: false);
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> popRoot() async {
    return await _popRecursive(_routers.values.toList().lastIndexWhere((router) => router.autoPop));
  }

  static Future<bool> _popRecursive(int routerIndex) async {
    if (routerIndex < 0) return true;

    _RouterController router = _routers.values.toList()[routerIndex];
    if (router._history.isNotEmpty && router.autoPop) {
      String route = router._history.removeLast();
      await router.switchRoute(route, record: false);
      return false;
    } else {
      return await _popRecursive(routerIndex - 1);
    }
  }

  void clearHistory() {
    _history.clear();
  }

  void registerAnimationController(AnimationController controller) {
    _animationControllers.add(controller);
  }

  void unregisterAnimationController(AnimationController controller) {
    _animationControllers.remove(controller);
  }

  bool get disposed {
    return _disposed;
  }

  void dispose() {
    _routers.remove(this.name);
    _disposed = true;
  }
}
*/
