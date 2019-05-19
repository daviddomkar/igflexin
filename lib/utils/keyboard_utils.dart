import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

typedef Widget KeyboardInfoProviderBuilder(
  BuildContext context,
  KeyboardInfo info,
);

class KeyboardInfo {
  KeyboardInfo(this.offsetY);

  final double offsetY;
}

class KeyboardInfoProvider extends StatefulWidget {
  KeyboardInfoProvider({this.builder});

  final KeyboardInfoProviderBuilder builder;

  @override
  _KeyboardInfoProviderState createState() => _KeyboardInfoProviderState();
}

class _KeyboardInfoProviderState extends State<KeyboardInfoProvider> with WidgetsBindingObserver {
  double offsetY = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    _updateInfo();
  }

  Future<Null> _keyboardToggled() async {
    if (mounted) {
      EdgeInsets edgeInsets = MediaQuery.of(context).viewInsets;
      while (mounted && MediaQuery.of(context).viewInsets == edgeInsets) {
        await new Future.delayed(const Duration(milliseconds: 10));
      }
    }

    return;
  }

  Future<Null> _updateInfo() async {
    await Future.any([new Future.delayed(const Duration(milliseconds: 300)), _keyboardToggled()]);

    final mediaQuery = MediaQuery.of(context);
    final screenInsets = mediaQuery.viewInsets;

    offsetY = screenInsets.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, KeyboardInfo(offsetY));
  }
}

class EnsureVisibleWhenFocused extends StatefulWidget {
  const EnsureVisibleWhenFocused({
    Key key,
    @required this.child,
    @required this.focusNode,
    this.curve: Curves.ease,
    this.duration: const Duration(milliseconds: 100),
  }) : super(key: key);

  final FocusNode focusNode;
  final Widget child;
  final Curve curve;
  final Duration duration;

  @override
  _EnsureVisibleWhenFocusedState createState() => new _EnsureVisibleWhenFocusedState();
}

class _EnsureVisibleWhenFocusedState extends State<EnsureVisibleWhenFocused> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_ensureVisible);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.focusNode.removeListener(_ensureVisible);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (widget.focusNode.hasFocus) {
      _ensureVisible();
    }
  }

  Future<Null> _keyboardToggled() async {
    if (mounted) {
      EdgeInsets edgeInsets = MediaQuery.of(context).viewInsets;
      while (mounted && MediaQuery.of(context).viewInsets == edgeInsets) {
        await new Future.delayed(const Duration(milliseconds: 10));
      }
    }

    return;
  }

  Future<Null> _ensureVisible() async {
    await Future.any([new Future.delayed(const Duration(milliseconds: 300)), _keyboardToggled()]);

    if (!widget.focusNode.hasFocus) {
      return;
    }

    final RenderObject object = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);

    if (viewport == null) {
      return;
    }

    ScrollableState scrollableState = Scrollable.of(context);
    assert(scrollableState != null);

    ScrollPosition position = scrollableState.position;

    final availableSpace = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
    final scrollableAreaHeight = scrollableState.position.maxScrollExtent + availableSpace;
    final keyboardIntersectionHeight = MediaQuery.of(context).viewInsets.bottom -
        ((MediaQuery.of(context).size.height - scrollableAreaHeight) + position.pixels);

    final objectOffset = viewport.getOffsetToReveal(object, 0.0).offset;
    final objectHeight = viewport.getOffsetToReveal(object, 0.0).rect.height;

    final keyboardIntersectionWithObject =
        scrollableAreaHeight - objectOffset - keyboardIntersectionHeight - objectHeight;

    if (keyboardIntersectionWithObject - 10 < 0) {
      position.animateTo((keyboardIntersectionWithObject - 10).abs(), duration: widget.duration, curve: widget.curve);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
