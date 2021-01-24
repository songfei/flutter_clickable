import 'package:clickable/clickable.dart';
import 'package:clickable/src/clickable_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef ClickableBuilder = Widget Function(BuildContext context, bool isHighlight, bool isHover);

class ClickableWidget extends StatefulWidget {
  ClickableWidget({
    @required this.builder,
    Key key,
    this.name,
    this.parameter,
    this.touchGroup,
    this.onTap,
    this.onTapDown,
    this.onDoubleTap,
  }) : super(key: key);

  final ClickableBuilder builder;

  final GestureTapCallback onTap;
  final GestureTapDownCallback onTapDown;
  final GestureTapCallback onDoubleTap;

  final String name;

  final Map<String, dynamic> parameter;

  final String touchGroup;

  @override
  State<StatefulWidget> createState() {
    return _ClickableWidgetState();
  }
}

class _ClickableWidgetState extends State<ClickableWidget> {
  bool _isTouchDown = false;
  bool _isHighlighting = false;
  bool _isHighlighted = false;
  bool _isHover = false;

  @override
  void initState() {
    super.initState();
  }

  bool get canTouch {
    return ClickableManager().canTouch;
  }

  @override
  Widget build(BuildContext context) {
    GestureTapCallback onTapCallback;
    if (widget.onTap != null) {
      onTapCallback = () {
        if (!canTouch) {
          return;
        }

        widget.onTap();
        reportGestureEvent(context, 'tap');
      };
    }

    GestureTapCallback onDoubleTapCallback;
    if (widget.onDoubleTap != null) {
      onDoubleTapCallback = () {
        if (!canTouch) {
          return;
        }
        widget.onDoubleTap();
        reportGestureEvent(context, 'doubleTap');
      };
    }

    Widget child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapCallback,
      onDoubleTap: onDoubleTapCallback,
      onTapDown: (details) {
        if (!canTouch) {
          return;
        }

        highlight();
        if (widget.onTapDown != null) {
          widget.onTapDown(details);
          reportGestureEvent(context, 'tapDown');
        }
      },
      onTapUp: (details) {
        cancelHighlight();
      },
      onTapCancel: cancelHighlight,
      child: widget.builder(context, _isHighlighted, _isHover),
    );

    if (kIsWeb) {
      return MouseRegion(
        onEnter: (event) {
          setState(() {
            _isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            _isHover = false;
          });
        },
        cursor: SystemMouseCursors.click,
        child: child,
      );
    }
    return child;
  }

  void highlight() {
    _isTouchDown = true;

    setState(() {
      _isHighlighted = true;
    });
  }

  void cancelHighlight() {
    if (_isTouchDown) {
      _isTouchDown = false;
      if (!_isHighlighting) {
        _isHighlighting = true;

        Future.delayed(
          Duration(milliseconds: 200),
          () {
            if (mounted) {
              _isHighlighting = false;
              setState(() {
                _isHighlighted = false;
              });
            }
          },
        );
      }
    }
  }

  void reportGestureEvent(BuildContext context, String gestureType) {
    if (widget.name != null && widget.name.isNotEmpty) {
      Map<String, dynamic> inheritedParameter = ReportParameterWidget.of(context);
      if (widget.parameter != null) {
        inheritedParameter.addAll(widget.parameter);
      }
      ClickableManager().sendTouchReport(gestureType: gestureType, name: widget.name, parameter: inheritedParameter);
    }
  }
}
