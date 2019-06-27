import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';

class SystemBarsRepository extends ChangeNotifier {
  bool useWhiteStatusBarForeground;
  bool useWhiteNavigationBarForeground;

  void setNavigationBarColor(Color color) {
    FlutterStatusbarcolor.setNavigationBarColor(color);
  }

  void setStatusBarColor(Color color) {
    FlutterStatusbarcolor.setStatusBarColor(color);
  }

  void setLightForeground() {
    useWhiteStatusBarForeground = true;
    useWhiteNavigationBarForeground = true;
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
  }

  void setDarkForeground() {
    useWhiteStatusBarForeground = false;
    useWhiteNavigationBarForeground = false;
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
  }
}

class SystemBarsObserver extends StatefulWidget {
  SystemBarsObserver({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _SystemBarsObserverState createState() {
    return _SystemBarsObserverState();
  }
}

class _SystemBarsObserverState extends State<SystemBarsObserver> with WidgetsBindingObserver {
  SystemBarsRepository _systembarsRepository;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _systembarsRepository = Provider.of<SystemBarsRepository>(context);
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_systembarsRepository.useWhiteStatusBarForeground != null)
        FlutterStatusbarcolor.setStatusBarWhiteForeground(
            _systembarsRepository.useWhiteStatusBarForeground);
      if (_systembarsRepository.useWhiteNavigationBarForeground != null)
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(
            _systembarsRepository.useWhiteNavigationBarForeground);
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
