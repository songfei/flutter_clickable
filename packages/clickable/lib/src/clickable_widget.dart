import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'clickable_info.dart';
import 'clickable_manager.dart';
import 'clickable_parameter_widget.dart';

class ClickableWidget extends StatefulWidget {
  ClickableWidget({
    required this.builder,
    Key? key,
    this.name,
    this.uuid,
    this.parameter,
    this.touchGroup,
    this.onTap,
    this.onTapDown,
    this.onDoubleTap,
  }) : super(key: key);

  final ClickableBuilder builder;

  final ClickableOnTapCallback? onTap;
  final ClickableOnTapDownCallback? onTapDown;
  final ClickableOnTapCallback? onDoubleTap;

  final String? name;
  final String? uuid;

  final Map<String, dynamic>? parameter;

  final String? touchGroup;

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
    GestureTapCallback? onTapCallback;
    if (widget.onTap != null) {
      onTapCallback = () {
        if (!canTouch) {
          return;
        }

        widget.onTap!(ClickableTapInfo(
          name: widget.name,
          parameter: _inheritedParameter(context),
        ));
        reportGestureEvent(context, 'tap');
      };
    }

    GestureTapCallback? onDoubleTapCallback;
    if (widget.onDoubleTap != null) {
      onDoubleTapCallback = () {
        if (!canTouch) {
          return;
        }

        widget.onDoubleTap!(ClickableTapInfo(
          name: widget.name,
          parameter: _inheritedParameter(context),
        ));
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
          widget.onTapDown!(ClickableTapDownInfo(
            name: widget.name,
            parameter: _inheritedParameter(context),
            tapDownDetails: details,
          ));
          reportGestureEvent(context, 'tapDown');
        }
      },
      onTapUp: (details) {
        cancelHighlight();
      },
      onTapCancel: cancelHighlight,
      child: widget.builder(
        context,
        ClickableBuilderInfo(
          isHighlight: _isHighlighted,
          isHover: _isHover,
        ),
      ),
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

  Map<String, dynamic> _inheritedParameter(BuildContext context) {
    Map<String, dynamic> inheritedParameter = ClickableParameterWidget.of(context);
    if (widget.parameter != null) {
      inheritedParameter.addAll(widget.parameter!);
    }
    return inheritedParameter;
  }

  void reportGestureEvent(BuildContext context, String gestureType) {
    if (widget.uuid != null && widget.uuid!.isNotEmpty) {
      ClickableManager().sendTouchReport(
        gestureType: gestureType,
        uuid: widget.uuid!,
        name: widget.name ?? '',
        parameter: _inheritedParameter(context),
      );
    }
  }
}
